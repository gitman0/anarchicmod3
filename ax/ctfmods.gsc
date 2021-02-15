/* $Id: ctfmods.gsc 118 2011-02-22 07:01:25Z  $ */

#include ax\utility;

init()
{
	if ( level.gametype != "ctf" )
		return;

	level.flag_carrier_icon = "objective";

	if( !gameStarted() )
		precacheShader(level.flag_carrier_icon);

	if ( isdefined( game["axisscore"] ) )
		setTeamScore( "axis", game["axisscore"] );
	if ( isdefined( game["alliedscore"] ) )
		setTeamScore( "allies", game["alliedscore"] );

	if ( isdefined( game["roundsplayed"] ) && game["roundsplayed"] > 0 )
		thread scoreRestore();

	if ( !inWarmup() && level.ax_ctf_pressurecook > 0 )
	{
		spawnpointname = "mp_sd_spawn_attacker";
		spawnpoints = getentarray(spawnpointname, "classname");

		if(!spawnpoints.size)
			level.ax_ctf_pressurecook = 0;

		for(i = 0; i < spawnpoints.size; i++)
			spawnpoints[i] PlaceSpawnpoint();

		spawnpointname = "mp_sd_spawn_defender";
		spawnpoints = getentarray(spawnpointname, "classname");

		if(!spawnpoints.size)
			level.ax_ctf_pressurecook = 0;

		for(i = 0; i < spawnpoints.size; i++)
			spawnpoints[i] PlaceSpawnpoint();

		level thread announcePressureCooker();
	}

	game["objid_axis"] = 14;
	game["objid_allies"] = 15;

	level.ctf_in_warmup = false;
	level.sudden_death_norespawn = false;
	
	if ( matchStarted() )
	{
		thread fixFlagPositions();
		thread sayMoveIn();
	}

	level thread onPlayerConnect();

	// overrides
	level.autoassign = ::menuAutoAssign;
	if ( level.ax_autoassign_forced )
	{
		level.allies = ::menuAutoAssign;
		level.axis = ::menuAutoAssign;
	}
	else
	{
		level.allies = ::menuAllies;
		level.axis = ::menuAxis;
	}
	level.flag = ::flag;
	level.dropFlag = ::dropFlag;
	level.respawnAllowed = ::respawnAllowed;
	level.dropOffHand = ax\weapons::dropOffHand;

	level.roundended = false;
}

onPlayerConnect()
{
	for(;;)
	{
		level waittill("connected", player);
		player thread onPlayerSpawned();
                player thread onPlayerKilled();

		if ( isdefined( player.pers["score"] ) )
			player.score = player.pers["score"];
	}
}

onPlayerSpawned()
{
	self endon("disconnect");

	for(;;)
	{
		self waittill("spawned_player");
		self.obj_id = undefined;
		self.flag_holder = false;
		if ( !inWarmup() && level.ax_ctf_pressurecook > 0 )
		{
			timepassed = (getTime() - getStartTime()) / 1000;
			if ( timepassed < level.ax_ctf_pressurecook )
				self iprintln("Using pressure-cooker spawns!");
		}
	}
}

onPlayerKilled()
{
	self endon("disconnect");
        
	for(;;)
	{
		self waittill("killed_player");

		self notify("flag_dropped");
		if (isdefined(self.obj_id))
			objective_delete(self.obj_id);
	}
}

checkScoreLimit()
{
	if(level.scorelimit <= 0)
		return;

	shutout = false;
	shutout_limit = getcvarint("scr_ctf_shutout_limit");	
	score_axis = getTeamScore("axis");
	score_allies = getTeamScore("allies");

	if (shutout_limit > 0)
	{
		if (score_allies == 0 && score_axis >= shutout_limit)
			shutout = true;
		if (score_axis == 0 && score_allies >= shutout_limit)
			shutout = true;
	}

	if(getTeamScore("allies") < level.scorelimit && getTeamScore("axis") < level.scorelimit && !shutout)
		return;

//	if ( level.roundlimit > game["roundsplayed"] )
//		return;

	if(level.mapended || level.roundended)
		return;
	level.mapended = true;

	if(!shutout)
		iprintln(&"MP_SCORE_LIMIT_REACHED");
	else iprintln("Game over - TOTAL SHUTOUT!");

/#	iprintln("endRound in checkScoreLimit");	#/
	level thread endRound();
}

startGame()
{
	if ( !matchStarted() && level.ax_ctf_wait_for_players > 0 )
	{
		wait_time = 0;
		players = maps\mp\gametypes\_teams::CountPlayers();
		while ( ( players["allies"] == 0 || players["axis"] == 0 ) && wait_time < level.ax_ctf_wait_for_players )
		{
			if ( wait_time == 0 )
				thread make_permanent_announcement(&"AX_WAIT_FOR_PLAYERS", "end_wait_for_players", level.ax_ctf_wait_for_players);
			wait 1;
			wait_time += 1;
		}
		level notify( "end_wait_for_players" );
	}

	if ( !matchStarted() && level.ax_ctf_warmup > 0 )
	{
		thread make_permanent_announcement(&"AX_MATCHSTARTING", "cleanup match starting", level.ax_ctf_warmup);

		level.ctf_in_warmup = true;
		wait level.ax_ctf_warmup;
		level.ctf_in_warmup = false;

		level notify("cleanup match starting");
		waittillframeend;

		game["matchstarted"] = true;

		level notify("restarting");

		map_restart(true);
	}
	else 
	{
		game["matchstarted"] = true;

		level.starttime = getTime();
	
		if(level.timelimit > 0)
		{
			level.clock = newHudElem();
			level.clock.horzAlign = "left";
			level.clock.vertAlign = "top";
			level.clock.x = 8;
			level.clock.y = 2;
			level.clock.font = "default";
			level.clock.fontscale = 2;
			level.clock setTimer(level.timelimit * 60);
		}

		thread delayedSpectatePermissions();

		for(;;)
		{
			checkTimeLimit();
			wait 1;
		}
	}
}

delayedSpectatePermissions()
{
	wait 0.15;
	thread maps\mp\gametypes\_spectating::updateSpectatePermissions();
}

checkTimeLimit()
{
	if(level.timelimit <= 0)
		return;

	timepassed = (getTime() - level.starttime) / 1000;
	timepassed = timepassed / 60.0;

	if(timepassed < level.timelimit)
		return;

	if(level.mapended || level.roundended)
		return;

	if (!isdefined(level.sudden_death_status))
		level.sudden_death_status = false;

	players = maps\mp\gametypes\_teams::CountPlayers();

	if ( level.sudden_death_status && level.sudden_death_timelimit > 0 )
	{
		sudden_death_timepassed = (getTime() - level.sudden_death_starttime) / 1000;
		sudden_death_timepassed = sudden_death_timepassed / 60.0;

		playersAlive = 0;
		allplayers = getentarray( "player", "classname" );
		for ( i = 0; i < allplayers.size; i++ )
		{
			if ( allplayers[i].sessionstate == "playing" || ( allplayers[i] WaitingToSpawn() && (sudden_death_timepassed*60) < 1 ) )
				playersAlive++;
		}
		if ( ( sudden_death_timepassed >= level.sudden_death_timelimit ) || playersAlive == 0 )
		{
			iprintln(&"MP_TIME_LIMIT_REACHED");
/#			iprintln("endRound in checkTimeLimit1");	#/
			level thread endRound();
			return;
		}
	}

	if ( level.sudden_death_timelimit == 0 && ( players["allies"] < level.sudden_death_minplayers || players["axis"] < level.sudden_death_minplayers ) )
	{
/#		iprintln("endRound in checkTimeLimit2");	#/
		level thread endRound();
		return;
	}

	totalPlayers = players["allies"] + players["axis"];

	if ( totalPlayers > 0 && suddenDeathSupported() && level.sudden_death_timelimit > -1 ) 
	{
		debug = getCvarInt("ax_debug_sudden_death");
		if ( ( players["allies"] >= level.sudden_death_minplayers && players["axis"] >= level.sudden_death_minplayers ) || debug > 0 )
		{
			score_axis = getTeamScore("axis");
			score_allies = getTeamScore("allies");

			if (score_axis > score_allies)
			{
				score_diff = score_axis - score_allies;
				winning_team = "axis";
				losing_team = "allied";
			}
			else {
				score_diff = score_allies - score_axis;
				winning_team = "allied";
				losing_team = "axis";
			}

			// go to sudden death if either of the flags are gone or if its a tie
			if ( ( !flagAtHome("axis") || !flagAtHome("allied") ) || ( level.sudden_death_suppress_tie && score_diff == 0 ) )
			{
				if ( !level.sudden_death_status )
				{
					level.clock reset();
					level.clock.color = (1, 0, 0);
					level.clock.horzAlign = "left";
					level.clock.vertAlign = "top";
					level.clock.x = 8;
					level.clock.y = 2;
					level.clock.font = "default";
					level.clock.fontscale = 2;
					level.clock setTimerUp(0);

					level.sudden_death_status = true;
					level.sudden_death_starttime = getTime();
					iprintln(&"AX_SUDDEN_DEATH");
				}
				// disable respawns if its a tie, or if we just want it that way
				if ( score_diff == 0 || level.sudden_death_disable_respawn_forced )
				{
					if ( !level.sudden_death_norespawn )
					{
						level.sudden_death_norespawn = true;
						thread delayedPrintln( &"AX_RESPAWNS_DISABLED", 1 );
					}
					return;
				}
				// don't end the game if the losing team has a chance to tie it up
				if ( score_diff == 1 && !flagAtHome( winning_team ) && !level.sudden_death_suppress_tie )
						return;
			}
		}
	}
	iprintln(&"MP_TIME_LIMIT_REACHED");
/#	iprintln("endRound in checkTimeLimit3");	#/
	level thread endRound();
}

endRound()
{
	assertEx( isdefined( game["roundsplayed"] ), "Error: game[\"roundsplayed\"] is not defined" );
	assertEx( isdefined( level.roundlimit ), "Error: level.roundlimit is not defined" );
	assertEx( ( !level.roundended ), "Error: level.roundended is already true" );

	level.roundended = true;

	if ( !isdefined( game["alliedScoreByRound"] ) && !isdefined( game["axisScoreByRound"] ) )
	{
		game["alliedScoreByRound"] = [];
		game["axisScoreByRound"] = [];
	}

	game["alliedScoreByRound"][ game["roundsplayed"] ] = getTeamScore( "allies" );
	game["axisScoreByRound"][ game["roundsplayed"] ] = getTeamScore( "axis" );

	game["roundsplayed"]++;

	if ( game["roundsplayed"] < level.roundlimit )
	{
		level notify("ax_stop_flag_threads");
		announcement("Starting new round in " + level.ax_ctf_round_delay + " seconds");
		level.clock reset();
		level.clock.color = (1, 1, 1);
		level.clock.horzAlign = "left";
		level.clock.vertAlign = "top";
		level.clock.x = 8;
		level.clock.y = 2;
		level.clock.font = "default";
		level.clock.fontscale = 2;
		level.clock setTimer(level.ax_ctf_round_delay);
		wait level.ax_ctf_round_delay;
		level.mapended = true;
		level notify( "restarting" );
		scoreSave();
		weaponSave();
		waittillframeend;
		map_restart( true );
		return;
	}
	else iprintln(&"MP_ROUND_LIMIT_REACHED");
	level thread endMap();
}
endMap()
{
	game["state"] = "intermission";
	level notify("intermission");

	if ( isdefined( game["alliedScoreByRound"] ) && isdefined( game["axisScoreByRound"] ) )
	{
		realAlliedScore = 0;
		for ( i = 0; i < game["alliedScoreByRound"].size; i++ )
			realAlliedScore += game["alliedScoreByRound"][i];

		realAxisScore = 0;
		for ( i = 0; i < game["axisScoreByRound"].size; i++ )
			realAxisScore += game["axisScoreByRound"][i];

		setTeamScore( "allies", realAlliedScore );
		setTeamScore( "axis", realAxisScore );
	}

	alliedscore = getTeamScore("allies");
	axisscore = getTeamScore("axis");

	if(alliedscore == axisscore)
	{
		winningteam = "tie";
		losingteam = "tie";
		text = "MP_THE_GAME_IS_A_TIE";
	}
	else if(alliedscore > axisscore)
	{
		winningteam = "allies";
		losingteam = "axis";
		text = &"MP_ALLIES_WIN";
	}
	else
	{
		winningteam = "axis";
		losingteam = "allies";
		text = &"MP_AXIS_WIN";
	}

	winners = "";
	losers = "";

	if(winningteam == "allies")
		level thread playSoundOnPlayers("MP_announcer_allies_win");
	else if(winningteam == "axis")
		level thread playSoundOnPlayers("MP_announcer_axis_win");
	else
		level thread playSoundOnPlayers("MP_announcer_round_draw");

	players = getentarray("player", "classname");
	for(i = 0; i < players.size; i++)
	{
		player = players[i];

		if((winningteam == "allies") || (winningteam == "axis"))
		{
			lpGuid = player getGuid();
			if((isDefined(player.pers["team"])) && (player.pers["team"] == winningteam))
				winners = (winners + ";" + lpGuid + ";" + player.name);
			else if((isDefined(player.pers["team"])) && (player.pers["team"] == losingteam))
				losers = (losers + ";" + lpGuid + ";" + player.name);
		}

		player closeMenu();
		player closeInGameMenu();
		player setClientCvar("cg_objectiveText", text);

		player [[level.spawnIntermission]]();
	}

	if((winningteam == "allies") || (winningteam == "axis"))
	{
		logPrint("W;" + winningteam + winners + "\n");
		logPrint("L;" + losingteam + losers + "\n");
	}
/#	iprintln("10 seconds before calling exitLevel");	#/
	wait 10;
	exitLevel(false);
}

updateGametypeCvars()
{
	for(;;)
	{
		timelimit = getCvarFloat("scr_ctf_timelimit");
		if(level.timelimit != timelimit)
		{
			if(timelimit > 1440)
			{
				timelimit = 1440;
				setCvar("scr_ctf_timelimit", "1440");
			}

			level.timelimit = timelimit;
			setCvar("ui_ctf_timelimit", level.timelimit);
			level.starttime = getTime();

			if(level.timelimit > 0)
			{
				if(!isDefined(level.clock))
				{
					level.clock = newHudElem();
					level.clock.horzAlign = "left";
					level.clock.vertAlign = "top";
					level.clock.x = 8;
					level.clock.y = 2;
					level.clock.font = "default";
					level.clock.fontscale = 2;
				}
				level.clock setTimer(level.timelimit * 60);
			}
			else
			{
				if(isDefined(level.clock))
					level.clock destroy();
			}

			checkTimeLimit();
		}

		scorelimit = getCvarInt("scr_ctf_scorelimit");
		if(level.scorelimit != scorelimit)
		{
			level.scorelimit = scorelimit;
			setCvar("ui_ctf_scorelimit", level.scorelimit);
		}
		checkScoreLimit();

		wait 1;
	}
}

scoreSave()
{
	players = getentarray( "player", "classname" );
	for( i = 0; i < players.size; i++ )
	{
		player = players[i];
		player.pers["score"] = player.score;
		player.pers["deaths"] = player.deaths;
	}
}

scoreRestore()
{
	wait 0.15;
	players = getentarray( "player", "classname" );
	for( i = 0; i < players.size; i++ )
	{
		player = players[i];
		if ( isdefined( player.pers["score"] ) )
			player.score = player.pers["score"];
		if ( isdefined( player.pers["deaths"] ) )
			player.deaths = player.pers["deaths"];
	}
}

weaponSave()
{
	// for all living players store their weapons
	players = getentarray("player", "classname");
	for(i = 0; i < players.size; i++)
	{
		player = players[i];

		if(isdefined(player.pers["team"]) && player.pers["team"] != "spectator" && player.sessionstate == "playing")
		{
			weapon1 = player getWeaponSlotWeapon("primary");
			weapon1_ammo = player getWeaponSlotAmmo("primary");
			weapon1_clipammo = player getWeaponSlotClipAmmo("primary");

			weapon2 = player getWeaponSlotWeapon("primaryb");
			weapon2_ammo = player getWeaponSlotAmmo("primaryb");
			weapon2_clipammo = player getWeaponSlotClipAmmo("primaryb");

			current = player getCurrentWeapon();

			// A new weapon has been selected
			if(isdefined(player.oldweapon))
			{
				player.pers["weapon1"] = undefined;
				player.pers["weapon2"] = undefined;
				player.pers["spawnweapon"] = player.pers["weapon"];
			} // No new weapons selected
			else
			{
				player.pers["weapon1"] = weapon1;
				player.pers["weapon1_ammo"] = weapon1_ammo;
				player.pers["weapon1_clipammo"] = weapon1_clipammo;

				player.pers["weapon2"] = weapon2;
				player.pers["weapon2_ammo"] = weapon2_ammo;
				player.pers["weapon2_clipammo"] = weapon2_clipammo;

				player.pers["spawnweapon"] = player.pers["weapon1"];
			}
		}
	}
}

announcePressureCooker()
{
	waittillframeend;
	if ( level.ax_ctf_pressurecook <= 0 || !matchStarted() || inWarmup() )
		return;
	iprintln("Pressure-cooker spawns are ON!");
	wait level.ax_ctf_pressurecook;
	if (!level.sudden_death_norespawn)
		iprintln("Classic CTF spawns are ON!");
}

spawnpointName()
{
	timepassed = (getTime() - getStartTime()) / 1000;

	spawnpointname = undefined;
	switch ( level.gametype )
	{
		case "ctf":
			if ( level.reverse_spawns )
			{
				if ( self.pers["team"] == "allies" )
					spawnpointname = "mp_ctf_spawn_axis";
				else
					spawnpointname = "mp_ctf_spawn_allied";
			}
			else if ( !inWarmup() && level.ax_ctf_pressurecook > 0.0 && timepassed < level.ax_ctf_pressurecook )
			{
				if ( self.pers["team"] == "allies" )
					spawnpointname = "mp_sd_spawn_defender";
				else
					spawnpointname = "mp_sd_spawn_attacker";
			}
			else
			{
				if ( self.pers["team"] == "allies" )
					spawnpointname = "mp_ctf_spawn_allied";
				else
					spawnpointname = "mp_ctf_spawn_axis";
			}
	}
	return spawnpointname;
}

flag()
{
	objective_add(self.objective, "current", self.origin, self.compassflag);
	self createFlagWaypoint();

	level endon("ax_stop_flag_threads");

	for(;;)
	{
		self waittill("trigger", other);

		if(isPlayer(other) && isAlive(other) && (other.pers["team"] != "spectator"))
		{
			if(other.pers["team"] == self.team) // Touched by team
			{
				if(self.atbase)
				{
					if(isdefined(other.flag)) // Captured flag
					{
						println("CAPTURED THE FLAG!");

						friendlyAlias = "ctf_touchcapture";
						enemyAlias = "ctf_enemy_touchcapture";

						if(self.team == "axis")
							enemy = "allies";
						else
							enemy = "axis";

						thread playSoundOnPlayers(friendlyAlias, self.team);
						if(!level.splitscreen)
							thread playSoundOnPlayers(enemyAlias, enemy);

						thread printOnTeamWithArg(&"AX_ENEMY_FLAG_CAPTURED", other.name, self.team);
						thread [[level.printOnTeam]](&"MP_YOUR_FLAG_WAS_CAPTURED", enemy);

						lpselfnum = other getEntityNumber();
						lpselfguid = other getGuid();

						logPrint("A;" + lpselfguid + ";" + lpselfnum + ";" + other.pers["team"] + ";" + other.name + ";" + "flag_capture" + "\n");

						other.pers["flag_caps"]++; // anarchic
						other.flag returnFlag();
						other [[level.detachFlag]](other.flag);
						other.flag = undefined;
						other.statusicon = "";

						objective_delete(other.obj_id);
						other.obj_id = undefined;

						other.score += 10;
						teamscore = getTeamScore(other.pers["team"]);
						teamscore += 1;
						setTeamScore(other.pers["team"], teamscore);
						level notify("update_teamscore_hud");

						checkScoreLimit();
					}
				}
				else // Returned flag
				{
					other returnFlag(self);
				}
			}
			else if(other.pers["team"] != self.team) // Touched by enemy
			{
				println("PICKED UP THE FLAG!");

				friendlyAlias = "ctf_touchenemy";
				enemyAlias = "ctf_enemy_touchenemy";

				if(self.team == "axis")
					enemy = "allies";
				else
					enemy = "axis";

				thread playSoundOnPlayers(friendlyAlias, self.team);
				if(!level.splitscreen)
					thread playSoundOnPlayers(enemyAlias, enemy);

				thread [[level.printOnTeam]](&"MP_YOUR_FLAG_WAS_TAKEN", self.team);
				thread printOnTeamWithArg(&"AX_ENEMY_FLAG_TAKEN", other.name, enemy);

				lpselfnum = other getEntityNumber();
				lpselfguid = other getGuid();

				logPrint("A;" + lpselfguid + ";" + lpselfnum + ";" + other.pers["team"] + ";" + other.name + ";" + "flag_stolen" + "\n");

				other pickupFlag(self); // Stolen flag
			}
		}
		wait 0.05;
	}
}

pickupFlag(flag)
{
	flag notify("end_autoreturn");

	flag.origin = flag.origin + (0, 0, -10000);
	flag.flagmodel hide();
	self.flag = flag;

	if(self.pers["team"] == "allies")
		self.statusicon = level.hudflag_axis;
	else
		self.statusicon = level.hudflag_allies;

	self.dont_auto_balance = true;

	flag deleteFlagWaypoint();

	objective_state(self.flag.objective, "invisible");

	self [[level.attachFlag]]();

	teamid = "objid_" + self.pers["team"];
	obj_id = game[teamid];
	self.obj_id = obj_id;
	objective_add(obj_id, "current", self.origin, level.flag_carrier_icon, 8, 8);
	objective_onEntity(obj_id, self);
	objective_team(obj_id, self.pers["team"]);
}

dropFlag()
{
	if(isdefined(self.flag))
	{
		start = self.origin + (0, 0, 10);
		end = start + (0, 0, -2000);
		trace = bulletTrace(start, end, false, undefined);

		self.flag.origin = trace["position"];
		self.flag.flagmodel.origin = self.flag.origin;
		self.flag.flagmodel show();
		self.flag.atbase = false;
		self.statusicon = "";

		// set compass flag position on player
		objective_position(self.flag.objective, self.flag.origin);
		objective_state(self.flag.objective, "current");

		self.flag createFlagWaypoint();

		self.flag thread autoReturn();
		self [[level.detachFlag]](self.flag);

		//check if it's in a flag_returner
		for(i = 0; i < level.flag_returners.size; i++)
		{
			if(self.flag.flagmodel istouching(level.flag_returners[i]))
			{
				self.flag returnFlag();
				break;
			}
		}

		self.flag = undefined;
		self.dont_auto_balance = undefined;

		objective_delete(self.obj_id);
		self.obj_id = undefined;
	}
}

autoReturn()
{
	self endon("end_autoreturn");

	if ( level.ax_autoreturn_delay == 0 || level.flag_hold_return > 0 )
		return;

	wait level.ax_autoreturn_delay;
	if ( isdefined( self.held ) && self.held > 0 )
	{
		self thread autoReturn();
		return;
	}
	self thread returnFlag();
	[[level.printOnTeam]]("Your flag was auto-returned!", self.team);
}

returnFlag(flag)
{
	self endon("disconnected");

	if ( level.flag_hold_return > 0 && isPlayer( self ) && isdefined( flag ) )
	{
		if ( self.flag_holder )
			return;

		if ( !isdefined( flag.held ) || flag.held == 0 ) // this is the first attempt at returning it
		{
			flag.held = 1;
			if ( !isdefined(flag.hold_time) )
				flag.hold_time = 0;
		}
		else flag.held++;

		self.flag_holder = true;
		flag thread flashWaypoint();

		if ( !isdefined( self.flag_progress_bar ) )
			self.flag_progress_bar = self doClientHudElem( -64, 192, "left", "middle", "center", "middle" );

		while ( distance(self.origin, flag.origin) < level.flag_hold_return_radius && flag.hold_time < level.flag_hold_return_time )
		{
			if ( !isdefined(self.flag_progress_bar) )
				continue;

			progress_bar_w = 128;
			progress_bar_h = 8;
			
			flag.hold_time += ( 0.05 / ( flag.held * level.flag_hold_return_multi ) );
			width = int((flag.hold_time / level.flag_hold_return_time) * progress_bar_w);
			self.flag_progress_bar setShader("white", width, progress_bar_h);
			wait 0.05;
		}
		if ( isdefined( self.flag_progress_bar ) )
			self.flag_progress_bar destroy();

		if ( flag.hold_time < level.flag_hold_return_time )
		{
			flag.held--;
			self.flag_holder = false;
			if ( flag.held == 0 )
			{
				flag notify( "return_stopped" );
				flag.hold_time = 0;
			}
			return;
		}
		if ( flag.hold_time >= level.flag_hold_return_time )
			flag notify( "return_stopped" );
	}
	else if ( !isPlayer( self ) && !isdefined( flag ) )
		flag = self;

	flag notify("end_autoreturn");

	println("RETURNED THE FLAG!");
	thread playSoundOnPlayers("ctf_touchown", flag.team);
	thread [[level.printOnTeam]](&"MP_YOUR_FLAG_WAS_RETURNED", flag.team);

 	flag.origin = flag.home_origin;
	flag.flagmodel.origin = flag.home_origin;
 	flag.flagmodel.angles = flag.home_angles;
	flag.flagmodel show();
	flag.atbase = true;

	objective_position(flag.objective, flag.origin);
	objective_state(flag.objective, "current");

	flag createFlagWaypoint();

	if ( isPlayer( self ) )
	{
		lpselfguid = self getGuid();
		lpselfnum = self getEntityNumber();
		logPrint("A;" + lpselfguid + ";" + lpselfnum + ";" + self.pers["team"] + ";" + self.name + ";" + "flag_return" + "\n");

		self.score += 2;
		level notify("update_teamscore_hud");
	}
}

flashWayPoint()
{
	self endon( "return_stopped" );
	if ( !isdefined( self.waypoint ) || ( isdefined( self.waypoint_flashing ) && self.waypoint_flashing ) )
		return;

	self.waypoint_flashing = true;
	flash_time = 1;
	alpha_start = self.waypoint.alpha;

	while ( isdefined( self.waypoint ) )
	{
		self.waypoint fadeOverTime(flash_time);
		self.waypoint.alpha = 0;
		wait flash_time;
		self.waypoint fadeOverTime(flash_time);
		self.waypoint.alpha = alpha_start;
		wait flash_time;
	}
}

createFlagWaypoint()
{
	self deleteFlagWaypoint();

	waypoint = newHudElem();
	waypoint.x = self.origin[0];
	waypoint.y = self.origin[1];
	waypoint.z = self.origin[2] + 100;
	//waypoint.alpha = .61; //anarchic
	waypoint.alpha = .4;
	waypoint.archived = true;

	if(level.splitscreen)
		waypoint setShader(self.objpointflag, 14, 14);
	else
		//waypoint setShader(self.objpointflag, 7, 7);//anarchic
		waypoint setShader(self.objpointflag, 6, 6);

	waypoint setwaypoint(true);
	self.waypoint = waypoint;
}

deleteFlagWaypoint()
{
	if(isdefined(self.waypoint))
		self.waypoint destroy();
}

printOnTeamWithArg(text, arg, team)
{
	players = getentarray("player", "classname");
	for(i = 0; i < players.size; i++)
	{
		if((isdefined(players[i].pers["team"])) && (players[i].pers["team"] == team))
			players[i] iprintln(text, arg);
	}
}

fixFlagPositions()
{
	waittillframeend;

        if (level.gametype != "ctf")
		return;

	switch(level.mapname)
	{
		case "mp_return_to_pavlov":
			offset = 4;
			break;
		case "mp_buhlert":
			offset = 1;
			break;
		case "mp_depot":
			offset = 1;
			break;
		case "mp_downtown":
			offset = 1;
			break;
		case "mp_pwerk":
			offset = 1;
			break;
		case "mp_remagen2":
			offset = 1;
			break;
		default:
			offset = level.ax_flag_offset;
			break;
	}
	fixflags(offset);
}

fixflags(offset)
{
	if (!isdefined(game["matchstarted"]) || !game["matchstarted"] || !offset)
		return;

	allied_flags = getentarray("allied_flag", "targetname");
	for (i=0;i<allied_flags.size;i++)
	{
		allied_flags[i].home_origin = allied_flags[i].home_origin + (0, 0, offset);
		allied_flags[i].flagmodel.origin = allied_flags[i].home_origin;
		allied_flags[i].basemodel.origin = allied_flags[i].basemodel.origin + (0, 0, offset);
		allied_flags[i].origin = allied_flags[i].origin + (0, 0, offset);
	}

	axis_flags = getentarray("axis_flag", "targetname");
	for (i=0;i<axis_flags.size;i++)
	{
		axis_flags[i].home_origin = axis_flags[i].home_origin + (0, 0, offset);
		axis_flags[i].flagmodel.origin = axis_flags[i].home_origin;
		axis_flags[i].basemodel.origin = axis_flags[i].basemodel.origin + (0, 0, offset);
		axis_flags[i].origin = axis_flags[i].origin + (0, 0, offset);
	}
}

menuAutoAssign()
{
	numonteam["allies"] = 0;
	numonteam["axis"] = 0;

	players = getentarray("player", "classname");
	for(i = 0; i < players.size; i++)
	{
		player = players[i];

		if(!isDefined(player.pers["team"]) || player.pers["team"] == "spectator" || player == self)
			continue;

		numonteam[player.pers["team"]]++;
	}

	teamScore["allies"] = getTeamScore("allies");
	teamScore["axis"] = getTeamScore("axis");

	if ( teamScore["allies"] > 0 && teamScore["axis"] > 0 )
		pct_diff_score = ( min( teamScore["allies"], teamScore["axis"] ) / max( teamScore["allies"], teamScore["axis"] ) ) * 100;
	else
		pct_diff_score = 0;
	if ( numonteam["allies"] > 0 && numonteam["axis"] > 0 )
		pct_diff_team = ( min( numonteam["allies"], numonteam["axis"] ) / max( numonteam["allies"], numonteam["axis"] ) ) * 100;
	else
		pct_diff_team = 0;

	// if teams are equal return the team with the lowest score
	if(numonteam["allies"] == numonteam["axis"])
	{
		if(getTeamScore("allies") == getTeamScore("axis"))
		{
			teams[0] = "allies";
			teams[1] = "axis";
			assignment = teams[randomInt(2)];	// should not switch teams if already on a team
		}
		else if(getTeamScore("allies") < getTeamScore("axis"))
			assignment = "allies";
		else
			assignment = "axis";
	}
	else if( numonteam["allies"] < numonteam["axis"] )
	{
		if ( teamScore["allies"] > teamScore["axis"] && level.ax_autoassign_score_pct >= pct_diff_score && level.ax_autoassign_team_pct <= pct_diff_team )
			assignment = "axis";
		else
			assignment = "allies";
	}
	else {
		if ( teamScore["axis"] > teamScore["allies"] && level.ax_autoassign_score_pct >= pct_diff_score && level.ax_autoassign_team_pct <= pct_diff_team )
			assignment = "allies";
		else
			assignment = "axis";
	}

	if ( level.ax_mvp_system && ax\mvp::isMVP( self ) && !( ax\mvp::mvpClearedForJoin( self, assignment ) ) )
		assignment = otherTeam( assignment );

	if(assignment == self.pers["team"] && (self.sessionstate == "playing" || self.sessionstate == "dead"))
	{
		if(!isdefined(self.pers["weapon"]))
		{
			if (self.pers["team"] == "allies")
				self openMenu(game["menu_weapon_allies"]);
			else
				self openMenu(game["menu_weapon_axis"]);
		}
		return;
	}

	if(assignment != self.pers["team"] && (self.sessionstate == "playing" || self.sessionstate == "dead"))
	{
		self.switching_teams = true;
		self.joining_team = assignment;
		self.leaving_team = self.pers["team"];
		self suicide();
	}

	self.pers["team"] = assignment;
	self.pers["weapon"] = undefined;
	self.pers["savedmodel"] = undefined;

	self setClientCvar("ui_allow_weaponchange", "1");

	if(self.pers["team"] == "allies")
	{
		self openMenu(game["menu_weapon_allies"]);
		self setClientCvar("g_scriptMainMenu", game["menu_weapon_allies"]);
	}
	else
	{
		self openMenu(game["menu_weapon_axis"]);
		self setClientCvar("g_scriptMainMenu", game["menu_weapon_axis"]);
	}

	self notify("joined_team");
	self notify("end_respawn");

	self.chose_auto_assign = true; // ax
}

menuAllies()
{
	if(self.pers["team"] != "allies")
	{
		if ( level.ax_team_switch_delay > 0 )
		{
			if ( !isdefined( self.ax_team_switch_time ) )
				self.ax_team_switch_time = getTime();
			else {

				numonteam["allies"] = 0;
				numonteam["axis"] = 0;

				players = getentarray("player", "classname");
				for(i = 0; i < players.size; i++)
				{
					player = players[i];

					if(!isDefined(player.pers["team"]) || player.pers["team"] == "spectator" || player == self)
						continue;

					numonteam[player.pers["team"]]++;
				}

				teamScore["allies"] = getTeamScore("allies");
				teamScore["axis"] = getTeamScore("axis");

				timepassed = (getTime() - self.ax_team_switch_time) / 1000;
				if ( timepassed < level.ax_team_switch_delay && teamScore["allies"] >= teamScore["axis"] && numonteam["allies"] >= numonteam["axis"] )
				{
					clientAnnouncement(self, "You must wait " + int((level.ax_team_switch_delay - timepassed)) + " seconds before switching teams again");
					return;
				}
				self.ax_team_switch_time = getTime();
			}
		}

		if(self.sessionstate == "playing")
		{
			self.switching_teams = true;
			self.joining_team = "allies";
			self.leaving_team = self.pers["team"];
			self suicide();
		}

		self.pers["team"] = "allies";
		self.pers["weapon"] = undefined;
		self.pers["savedmodel"] = undefined;
		if (isdefined(self.pers["flag_caps"]))
			self.pers["flag_caps"] = 0;

		self setClientCvar("ui_allow_weaponchange", "1");
		self setClientCvar("g_scriptMainMenu", game["menu_weapon_allies"]);

		self notify("joined_team");
		self notify("end_respawn");
	}

	if(!isdefined(self.pers["weapon"]))
		self openMenu(game["menu_weapon_allies"]);
}

menuAxis()
{
	if(self.pers["team"] != "axis")
	{
		if ( level.ax_team_switch_delay > 0 )
		{
			if ( !isdefined( self.ax_team_switch_time ) )
				self.ax_team_switch_time = getTime();
			else {

				numonteam["allies"] = 0;
				numonteam["axis"] = 0;

				players = getentarray("player", "classname");
				for(i = 0; i < players.size; i++)
				{
					player = players[i];

					if(!isDefined(player.pers["team"]) || player.pers["team"] == "spectator" || player == self)
						continue;

					numonteam[player.pers["team"]]++;
				}

				teamScore["allies"] = getTeamScore("allies");
				teamScore["axis"] = getTeamScore("axis");

				timepassed = (getTime() - self.ax_team_switch_time) / 1000;
				if ( timepassed < level.ax_team_switch_delay && teamScore["axis"] >= teamScore["allies"] && numonteam["axis"] >= numonteam["allies"] )
				{
					clientAnnouncement(self, "You must wait " + int((level.ax_team_switch_delay - timepassed)) + " seconds before switching teams again");
					return;
				}
				self.ax_team_switch_time = getTime();
			}
		}

		if(self.sessionstate == "playing")
		{
			self.switching_teams = true;
			self.joining_team = "axis";
			self.leaving_team = self.pers["team"];
			self suicide();
		}

		self.pers["team"] = "axis";
		self.pers["weapon"] = undefined;
		self.pers["savedmodel"] = undefined;
		if (isdefined(self.pers["flag_caps"]))
			self.pers["flag_caps"] = 0;

		self setClientCvar("ui_allow_weaponchange", "1");
		self setClientCvar("g_scriptMainMenu", game["menu_weapon_axis"]);

		self notify("joined_team");
		self notify("end_respawn");
	}

	if(!isdefined(self.pers["weapon"]))
		self openMenu(game["menu_weapon_axis"]);
}
