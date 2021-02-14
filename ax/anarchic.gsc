// anarchicmod 3.0 for Call of Duty 2 by gitman @ anarchic-x.com
// not to be distributed or used anywhere but anarchic-x servers

#include ax\utility;

init()
{
	ax\dvars::setupDvars();

	if(!isDefined(game["gamestarted"]))
	{
		game["deaths_axis"]	= 0;
		game["deaths_allies"]	= 0;
		game["kills_axis"]	= 0;
		game["kills_allies"]	= 0;

		precacheString(&"AX_PENALTY_TIME_LEFT");
		precacheString(&"AX_HUD_TEAMKILLS");
		precacheString(&"AX_WAIT_FOR_PLAYERS");
		precacheString(&"AX_MATCHSTARTING");
	}

	ax\admin::init();
	ax\antiflop::init();
	ax\client::init();
	ax\ctfmods::init();
	ax\hud::init();
	ax\mapvote::init();
	ax\persistence::init();
	ax\rotation::init();
	ax\spawn::init();
	ax\weapons::init();

	level thread onPlayerConnect();
}

onPlayerConnect()
{
	for(;;)
	{
		level waittill("connected", player);

		if (!isdefined(player.kills))
			player.kills = 0;
		if (!isdefined(player.pers["kills"]))
			player.pers["kills"] = 0;
		if (!isdefined(player.pers["flag_caps"]))
			player.pers["flag_caps"] = 0;
		if (!isdefined(player.pers["headshots"]))
			player.pers["headshots"] = 0;
		if (!isdefined(player.team_kills))
			player.team_kills = 0;
		if (!isdefined(player.cannot_play))
			player.cannot_play = false;
		if (!isdefined(player.muted))
			player.muted = false;

		player.team_kill_level = 0;
		player.team_damage = 0;
		player.team_kill_suicides = 0;
		player.team_kill_timeout = level.team_kill_timeout;
		player.team_kill_counter = false;
		player.chose_auto_assign = false;

		player thread onPlayerSpawned();
		player thread onPlayerKilled();
		player thread onJoinedTeam();
		player thread onJoinedSpectators();
		player thread onPlayerDisconnect();
	}
}

onPlayerSpawned()
{
	self endon("disconnect");

	for(;;)
	{
		self waittill("spawned_player");

		if ( (isdefined(game["matchstarted"]) && game["matchstarted"]) || !isdefined(game["matchstarted"]) )
		{
			if (!isdefined(self.pers["seen_onjoin"]))
				self.pers["seen_onjoin"] = false;
			if (!isdefined(self.onjoin_welcome_back))
				self.onjoin_welcome_back = false;

			if (!self.pers["seen_onjoin"]) {
				if (getCvarInt("ax_needfeedback"))
				{
					clientAnnouncement(self, "Welcome " + nocolors(self.name) + "^7!");
					clientAnnouncement(self, " ");
					clientAnnouncement(self, "^3We really need your feedback about the server and maps!^7");
					clientAnnouncement(self, " ");
					clientAnnouncement(self, "Please let us know on our forums - www.Anarchic-X.com");
				}
				else if (!self.onjoin_welcome_back)
				{
					clientAnnouncement(self, "Welcome " + nocolors(self.name) + "^7!");
					clientAnnouncement(self, " ");
					clientAnnouncement(self, &"AX_MOTD_DEFAULT");
					clientAnnouncement(self, "Remember, friendly fire is ^1ON^7, don't shoot your teammates!");
				}
				else {
					clientAnnouncement(self, "Welcome back, " + nocolors(self.name) + "^7!");
					clientAnnouncement(self, " ");
					clientAnnouncement(self, "Your previous score has been restored.");
				}
			}
			self.pers["seen_onjoin"] = true;
		}

		if ( (int(level.friendlyfire) > 0) && (!isdefined(self.team_kill_display)) && (!isdefined(self.team_kill_display_counter)) )
		{
			x = -88;
			y = 188;

			self.team_kill_display = newClientHudElem(self);
			self.team_kill_display.alignX = "left";
			self.team_kill_display.alignY = "top";
			self.team_kill_display.horzAlign = "right";
			self.team_kill_display.vertAlign = "middle";
			self.team_kill_display.x = x;
			self.team_kill_display.y = y;
			self.team_kill_display.fontscale = 0.85;
			self.team_kill_display.archived = false;
			self.team_kill_display.alpha = 0;
			self.team_kill_display setText(&"AX_HUD_TEAMKILLS");

			self.team_kill_display_counter = newClientHudElem(self);
			self.team_kill_display_counter.alignX = "left";
			self.team_kill_display_counter.alignY = "top";
			self.team_kill_display_counter.horzAlign = "right";
			self.team_kill_display_counter.vertAlign = "middle";
			self.team_kill_display_counter.x = x + 42;
			self.team_kill_display_counter.y = y;
			self.team_kill_display_counter.fontscale = 0.9;
			self.team_kill_display_counter.archived = false;
			self.team_kill_display_counter.alpha = 0;
		}
		self.last_victim_team = undefined;
		self thread check_ax();
	}
}

onJoinedTeam()
{
	self endon("disconnect");
        
	for(;;)
	{
		self waittill("joined_team");
	}
}

onJoinedSpectators()
{
	self endon("disconnect");
        
	for(;;)
	{
		self waittill("joined_spectators");
	}
}

onPlayerKilled()
{
	self endon("disconnect");
        
	for(;;)
	{
		self waittill("killed_player");
	}
}

onPlayerDisconnect()
{
	self waittill("disconnect");
}

Callback_PlayerKilled(eInflictor, attacker, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc)
{
	if ((!isplayer(attacker)) || (!isdefined(attacker.pers["kills"])))
		return;

	if ( (isdefined(game["matchstarted"]) && game["matchstarted"]) || !isdefined(game["matchstarted"]) )
	{
		if (isPlayer(attacker)) {
			if (attacker == self)
			{
				if (!isdefined (self.autobalance))
					attacker.pers["kills"]--;
				if (attacker.team_kills > level.team_kill_limit)
					attacker.score--;
				if (isdefined(attacker.last_victim_team) && (attacker.last_victim_team == self.pers["team"]))
					attacker.team_kill_suicides++;
			}
			else
			{
				if (self.pers["team"] == attacker.pers["team"]) // killed by a friendly
				{
					attacker.pers["kills"]--;
					attacker.team_kills++;
				}
				else
				{
					t = "kills_" + attacker.pers["team"];
					if (isdefined(game[t]))
						game[t]++;
					attacker.pers["kills"]++;
					if(sHitLoc == "head" && sMeansOfDeath != "MOD_MELEE")
						attacker.pers["headshots"]++;
				}
			}
		}
		else self.pers["kills"]--; // If you weren't killed by a player, you were in the wrong place at the wrong time
	
		if (isdefined(self.pers["team"]) && (self.pers["team"] != "spectator") && (isdefined(game["deaths_allies"])) && (isdefined(game["deaths_axis"])))
		{
			s = "deaths_" + self.pers["team"];
			game[s]++;
		}
	}
	attacker team_kill_counter_destroy();
}

friendlyFire(eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, psOffsetTime)
{
	if (level.friendlyfire == "0")
		return;

	else if(level.friendlyfire == "1") // standard
	{
		// Make sure at least one point of damage is done
		if(iDamage < 1)
			iDamage = 1;

		self finishPlayerDamage(eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, psOffsetTime);

		// Shellshock/Rumble
		if ( level.allow_shellshock )
			self thread maps\mp\gametypes\_shellshock::shellshockOnDamage(sMeansOfDeath, iDamage);
		self playrumble("damage_heavy");
	}
	else if(level.friendlyfire == "2") // reflect
	{
		eAttacker.friendlydamage = true;
		iDamage = int(iDamage * .5);

		// Make sure at least one point of damage is done
		if(iDamage < 1)
			iDamage = 1;

		eAttacker finishPlayerDamage(eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, psOffsetTime);
		eAttacker.friendlydamage = undefined;
	}
	else if(level.friendlyfire == "3") // shared
	{
		if (sMeansOfDeath == "MOD_MELEE" && game["matchstarted"])
		{
			self finishPlayerDamage(eInflictor, eAttacker, 0, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, psOffsetTime);
			eAttacker finishPlayerDamage(eInflictor, eAttacker, 0, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, psOffsetTime);
			return;
		}

		eAttacker.friendlydamage = true;
		eAttacker setTeamKillLevel();

		attacker_damage = 0.0;
		victim_damage = 0.0;

		eAttacker.last_victim_team = self.pers["team"];

		switch (eAttacker.team_kill_level) {
			case 0:	// default shared
				attacker_damage = int(iDamage * .5);
				victim_damage = attacker_damage;
				break;
			case 1:	// weighted shared
				attacker_damage = int(iDamage * .65);
				victim_damage = int(iDamage * .35);
				eAttacker.team_damage += iDamage;
				break;
			case 2: // reflect
				attacker_damage = iDamage;
				victim_damage = undefined;
				eAttacker.team_damage += iDamage;
				break;
			case 3: // punishment
				attacker_damage = iDamage;
				victim_damage = undefined;
				eAttacker thread playerTimeout(eAttacker.team_kill_timeout);
				eAttacker.team_kill_timeout++;
				break;
		}
		eAttacker thread team_kill_counter_update();

		// Make sure at least one point of damage is done
		if(attacker_damage < 1)
			attacker_damage = 1;
		if (isdefined(victim_damage))
		{
			if (isdefined(self.flag))
				victim_damage = victim_damage * 0.2; 
			if (victim_damage < 1)
				victim_damage = 1;
		}
	
		if (isdefined(victim_damage))
			self finishPlayerDamage(eInflictor, eAttacker, int(victim_damage), iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, psOffsetTime);
		eAttacker finishPlayerDamage(eInflictor, eAttacker, int(attacker_damage), iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, psOffsetTime);
		eAttacker.friendlydamage = undefined;
	}
}

setTeamKillLevel()
{
	if (self.team_kills < level.team_kill_limit)
		self.team_kill_level = 0;
	if (self.team_kills == level.team_kill_limit)
		self.team_kill_level = 1;
	if ( (self.team_kills > level.team_kill_limit) || (self.team_damage > level.team_damage_limit) )
		self.team_kill_level = 2;
	if ( (self.team_kills > level.team_kill_limit) || (self.team_damage > level.team_damage_limit && self.team_kill_suicides > level.team_kill_suicide_limit) )
		self.team_kill_level = 3;
}

team_kill_counter_update() {
	self endon("killed_player");
	if (!isalive(self) || !isplayer(self))
		return;
	if (self.team_kill_counter)
		return;
	if (!isdefined(self.team_kill_display_counter) || !isdefined(self.team_kill_display))
		return;
	self.team_kill_counter = true;
	self.team_kill_display_counter setValue(self.team_kills);
	self.team_kill_display_counter.alpha = 1;
	self.team_kill_display.alpha = 1;
	wait 3;
	self thread team_kill_counter_fade(0, 1);
}		

team_kill_counter_fade(in_out, time) {
	self endon("killed_player");
	if (!isdefined(self.team_kill_display) || !isdefined(self.team_kill_display_counter))
		return;
	self.team_kill_display fadeOverTime(time);
	self.team_kill_display.alpha = in_out;
	self.team_kill_display_counter fadeovertime(time);
	self.team_kill_display_counter.alpha = in_out;
	self.team_kill_counter = false;
}

team_kill_counter_destroy() {
	self.team_kill_counter = false;
	if (isdefined(self.team_kill_display))
		self.team_kill_display destroy();
	if (isdefined(self.team_kill_display_counter))
		self.team_kill_display_counter destroy();
}

playerTimeout(time)
{
	level endon("intermission");

	self suicide();
	self.pers["team"] = "spectator";
	self.sessionteam = "spectator";
	[[level.spawnspectator]]();
	clientAnnouncement(self, &"AX_HUD_TEAMILL_PENALTY", time);

	if(!isdefined(self.penaltytimer))
	{
		self.penaltytimer = newClientHudElem(self);
		self.penaltytimer.x = 0;
		self.penaltytimer.y = -50;
		self.penaltytimer.alignX = "center";
		self.penaltytimer.alignY = "middle";
		self.penaltytimer.horzAlign = "center_safearea";
		self.penaltytimer.vertAlign = "center_safearea";
		self.penaltytimer.alpha = 1;
		self.penaltytimer.archived = false;
		self.penaltytimer.font = "default";
		self.penaltytimer.fontscale = 1;
		self.penaltytimer.label = (&"AX_PENALTY_TIME_LEFT");
		self.penaltytimer setTimer (time * 60);
	}

	self.cannot_play = true;
	wait (time * 60);
	clientAnnouncement(self, "&AX_HUD_TEAMKILL_PENALTY_REJOIN");
	if (isdefined(self.penaltytimer))
		self.penaltytimer destroy();
	self.cannot_play = false;
}

getdamage(iDamage, sMeansOfDeath, eAttacker, sWeapon)
{
	if (getCvarInt("g_DebugDamage"))
	{
		if ( isDefined(self.origin) && isDefined(eAttacker.origin) )
			attack_dist = distance(self.origin, eAttacker.origin);
		else attack_dist = "unknown";
		iprintln("iDamage: " + iDamage + ", distance: " + attack_dist + ", sMeansOfDeath: " + sMeansOfDeath + ", sWeapon: " + sWeapon);
	}

	mod_nade	= 0.15;
	mod_nade_exp	= 0.01;
	mod_bullet	= 0.35;
	mod_hop		= 0.05;

	if ( isDefined(self.spawn_assist) && self.spawn_assist )
	{
		switch(sMeansOfDeath) {
			case "MOD_EXPLOSIVE":
			case "MOD_GRENADE_SPLASH":
				iDamage = iDamage * mod_nade;
				break;
			case "MOD_RIFLE_BULLET":
			case "MOD_PISTOL_BULLET":
				iDamage = iDamage * mod_bullet;
				break;
		}
	}
	// antihop - not affected by being on turret, any other means of death other than pistol/rifle
	if (isdefined(eattacker) && isPlayer(eAttacker))
	{
		if (eAttacker.hopping && !isturret(sWeapon) && (sMeansOfDeath == "MOD_RIFLE_BULLET" || sMeansOfDeath == "MOD_PISTOL_BULLET"))
		{
			old_damage = iDamage;
			iDamage = iDamage * mod_hop;
			eattacker.pers["hop_denial"] += old_damage - idamage;
		}
		/*
		if ( isdefined(eAttacker.spawn_assist_time) && (gettime() - eAttacker.spawn_assist_time < 3000) && sMeansOfDeath == "MOD_GRENADE_SPLASH" )
		{
			iDamage = iDamage * mod_nade_exp;
			eAttacker iprintln("^1* Your grenade only did " + iDamage + " damage points. Don't abuse spawn assist!");
		}
		*/
	}
	return int(iDamage);
}

isBalancedChoice(response)
{
	// go ahead of menu auto-balance is disabled
	if ( !level.ax_teambalance_menu )
		return true;

	// go ahead if spectator or auto-assign chosen
	if ( response == "spectator" || response == "autoassign" )
		return true;

	players = maps\mp\gametypes\_teams::CountPlayers();

	// go ahead if no other players
	if ( players["allies"] == 0 && players["axis"] == 0 )
		return true;

	// go ahead if admin
	adminRecord = ax\admin::getAdminRecord( self );
	if ( isDefined( adminRecord ) )
	{
		name = adminRecord[1];
		self iprintln( "Auto-balance skipped - admin GUID registered to: " + name + "^7" );
		return true;
	}

	// already playing, switching teams
	if ( self.sessionstate != "spectator" && ( (players[response] + 1) - (players[self.pers["team"]] - 1) ) > level.ax_teambalance_menu )
	{
		self iprintlnbold( &"AX_CANTJOINTEAM_UNBALANCED", localizedTeam(game[response]), localizedTeam(game[otherTeam(response)]) );
		return false;
	}

	// joining the game (from spectate)
	else if ( self.sessionstate == "spectator" && ( (players[response] + 1) - players[otherTeam(response)] ) > level.ax_teambalance_menu )
	{
		self iprintlnbold( &"AX_CANTJOINTEAM_UNBALANCED", localizedTeam(game[response]), localizedTeam(game[otherTeam(response)]) );
		return false;
	}
	// catch-all
	return true;
}

check_ax()
{
	//self iprintln(nocolors(name));
	tags = "^7|^4ax^7|";
	nc = nocolors(self.name);
	if (nc.size > tags.size)
		return;
}
