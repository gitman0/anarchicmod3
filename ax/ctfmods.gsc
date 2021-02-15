/* $Id: ctfmods.gsc 93 2010-10-04 01:01:48Z  $ */

#include ax\utility;

init()
{
	level.flag_carrier_icon = "objective";

	if( !isDefined(game["gamestarted"]) || !game["gamestarted"] )
	{
		if (level.gametype == "ctf")
			precacheShader(level.flag_carrier_icon);
	}

	if ( isdefined( game["axisscore"] ) )
		setTeamScore( "axis", game["axisscore"] );
	if ( isdefined( game["alliedscore"] ) )
		setTeamScore( "allies", game["alliedscore"] );

	if ( level.ax_ctf_pressurecook > 0 && level.gametype == "ctf" )
	{
		spawnpointname = "mp_sd_spawn_attacker";
		spawnpoints = getentarray(spawnpointname, "classname");

		if(!spawnpoints.size)
			level.ax_ctf_pressurecook = 0;

		for(i = 0; i < spawnpoints.size; i++)
			spawnpoints[i] PlaceSpawnpoint();
	}
	if ( level.ax_ctf_pressurecook > 0 && level.gametype == "ctf" )
	{
		spawnpointname = "mp_sd_spawn_defender";
		spawnpoints = getentarray(spawnpointname, "classname");

		if(!spawnpoints.size)
			level.ax_ctf_pressurecook = 0;

		for(i = 0; i < spawnpoints.size; i++)
			spawnpoints[i] PlaceSpawnpoint();
	}

	if ( level.ax_ctf_pressurecook > 0 && level.gametype == "ctf" )
		level thread announcePressureCooker();

	game["objid_axis"] = 14;
	game["objid_allies"] = 15;

	level.sudden_death_norespawn = false;
	level thread fixFlagPositions();

	level thread onPlayerConnect();
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
		if ( level.ax_ctf_pressurecook > 0 )
		{
			timepassed = (getTime() - getStartTime() + (level.ctf_warmup * 1000)) / 1000;
			timepassed = timepassed / 60.0;
			if ( timepassed < level.ax_ctf_pressurecook )
				self iprintln("Pressure-cooker spawns are ON!");
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

endRound()
{
/#
	assertEx( isdefined( game["roundsplayed"] ), "Error: game[\"roundsplayed\"] is not defined" );
	assertEx( isdefined( level.roundlimit ), "Error: level.roundlimit is not defined" );

	round_start_delay = 5;

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
		announcement("Starting new round in " + round_start_delay + " seconds");
		wait round_start_delay;
		level notify( "restarting" );
		waittillframeend;
		map_restart( true );
		return;
	}
	else iprintln(&"MP_ROUND_LIMIT_REACHED");
#/
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
	wait 10;
	exitLevel(false);
}

checkTimeLimit()
{
	if(level.timelimit <= 0)
		return;

	timepassed = (getTime() - level.starttime) / 1000;
	timepassed = timepassed / 60.0;

	if(timepassed < level.timelimit)
		return;

	if(level.mapended)
		return;

	if (!isdefined(level.sudden_death_status))
		level.sudden_death_status = false;

	players = maps\mp\gametypes\_teams::CountPlayers();

	if ( level.sudden_death_status && level.sudden_death_timelimit > 0 )
	{
		sudden_death_timepassed = (getTime() - level.sudden_death_starttime) / 1000;
		sudden_death_timepassed = sudden_death_timepassed / 60.0;

		if ( sudden_death_timepassed >= level.sudden_death_timelimit )
		{
			iprintln(&"MP_TIME_LIMIT_REACHED");
			level.mapended = true;
			level thread endRound();
			return;
		}
	}

	if ( level.sudden_death_timelimit == 0 && ( players["allies"] <= level.sudden_death_minplayers || players["axis"] <= level.sudden_death_minplayers ) )
	{
		level.mapended = true;
		level thread endRound();
		return;
	}

	if ( suddenDeathSupported() && level.sudden_death_timelimit > -1 ) 
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
			if ( ( level.gametype == "ctf" && ( !flagAtHome("axis") || !flagAtHome("allied") ) ) ||
					( level.sudden_death_notie && score_diff == 0 ) ) {

				if (!level.sudden_death_status)
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
				if ( score_diff == 0 || level.sudden_death_f_norespawn )
				{
					if (!level.sudden_death_norespawn)
					{
						level.sudden_death_norespawn = true;
						iprintln(&"AX_RESPAWNS_DISABLED");
					}
					return;
				}
				// don't end the game if the losing team has a chance to tie it up
				if ( score_diff == 1 && !flagAtHome(winning_team) && !level.sudden_death_notie )
						return;
			}
		}
	}
	iprintln(&"MP_TIME_LIMIT_REACHED");
	level.mapended = true;
	level thread endRound();

}

suddenDeathSupported()
{
	switch (level.gametype)
	{
		case "ctf":	return true;
		default:	return false;
	}
}

announcePressureCooker()
{
	if ( level.ax_ctf_pressurecook <= 0 || !isdefined( game["matchstarted"] ) || !game["matchstarted"] || ( isdefined( level.ctf_in_warmup ) && level.ctf_in_warmup ) )
		return;
	iprintln("Pressure-cooker spawns are ON!");
	wait level.ax_ctf_pressurecook;
	iprintln("Classic CTF spawns are ON!");
}

spawnpointName()
{
        timepassed = (getTime() - getStartTime() + (level.ctf_warmup * 1000)) / 1000;
        timepassed = timepassed / 60.0;

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
			else if ( level.ax_ctf_pressurecook > 0.0 && timepassed < level.ax_ctf_pressurecook )
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

pickupFlag(player) {
	player endon("flag_dropped");
	player endon("killed_player");
	teamid = "objid_" + player.pers["team"];
	obj_id = game[teamid];
	player.obj_id = obj_id;
	objective_add(obj_id, "current", player.origin, level.flag_carrier_icon, 8, 8);
	objective_onEntity(obj_id, player);
	objective_team(obj_id, self.pers["team"]);
	player thread dropFlag();
}

dropFlag() {
	self endon("killed_player");
	self waittill("flag_dropped");
	objective_delete(self.obj_id);
	self.obj_id = undefined;
}

autoReturn()
{
	self endon("end_autoreturn");

	if ( level.ctf_autoreturn_delay == 0 )
		return;

	wait level.ctf_autoreturn_delay;
	self thread [[level.returnFlag]]();
	[[level.printOnTeam]]("Your flag was auto-returned!", self.team);
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
	}

	axis_flags = getentarray("axis_flag", "targetname");
	for (i=0;i<axis_flags.size;i++)
	{
		axis_flags[i].home_origin = axis_flags[i].home_origin + (0, 0, offset);
		axis_flags[i].flagmodel.origin = axis_flags[i].home_origin;
		axis_flags[i].basemodel.origin = axis_flags[i].basemodel.origin + (0, 0, offset);
	}
}
