// anarchicmod 3.0 for Call of Duty 2 by gitman @ anarchic-x.com
// not to be distributed or used anywhere but anarchic-x servers

main()
{
	level._effect["bombfire"]	= loadfx("fx/props/barrelexp.efx");

	// static definitions
	level.modstr			= &"^9anarchicmod^13.0^7 - anarchic-x.com";
	level.gametype 			= getcvar("g_gametype");
	level.mapname			= getcvar("mapname");

	// fix misconfigured clients
	level.forcedownload		= cvardef("scr_force_autodownload", 1, 0, 1, "int");
	level.forcerate			= cvardef("scr_force_rate", 25000, 2500, 25000, "int");
	level.rename_unknown		= cvardef("scr_rename_unknown_soldier", 0, 0, 1, "int");
	level.rename_unknown_prefix 	= getCvar("scr_rename_unknown_soldier_prefix");
	if (level.rename_unknown_prefix == "")
		level.rename_unknown_prefix 	= "^2anarchic-x.com";

	// HUD settings + notifications
	level.show_modhud		= cvardef("scr_show_modhud", 1, 0, 1, "int");
	level.show_rulehud		= cvardef("scr_show_rules", 1, 0, 1, "int");
	level.show_kdhud		= cvardef("scr_show_hud_score", 1, 0, 1, "int");
	level.show_teamscore		= cvardef("scr_show_teamscore", 1, 0, 1, "int");
	level.show_headshots		= cvardef("scr_show_headshots", 1, 0, 1, "int");
	level.show_healthbar		= cvardef("scr_show_healthbar", 1, 0, 1, "int");
	level.static_crosshair		= cvardef("scr_static_crosshair", 0, 0, 1, "int");
	level.grenadeicons		= cvardef("scr_grenadeicons", 0, 0, 1, "int");
	level.old_headicons		= cvardef("scr_old_headicons", 1, 0, 1, "int");
	level.nextmap_display		= cvardef("scr_show_nextmap", 1, 0, 1, "int");
	level.nextmap_delay		= cvardef("scr_show_nextmap_delay", 120, 60, 900, "int");
	level.disable_red_crosshair	= cvardef("scr_disable_red_crosshair", 1, 0, 1, "int");
	level.disable_hitblip		= cvardef("scr_disable_hitblip", 1, 0, 1, "int");
	level.disable_deathicon		= cvardef("scr_disable_deathicon", 1, 0, 1, "int");

	defineRuleSet();

	// teamkiller prevention
	level.team_kill_limit		= cvardef("scr_team_kill_limit", 2, 0, 9999, "int");
	level.team_damage_limit		= cvardef("scr_team_damage_limit", 150, 0, 9999, "int");
	level.team_kill_suicide_limit	= cvardef("scr_team_kill_suicide_limit", 4, 0, 9999, "int");

	// gameplay settings
	level.shellshock		= cvardef("scr_shellshock", 1, 0, 1, "int");
	level.antiflop			= cvardef("scr_antiflop", 1, 0, 1, "int");
	level.spawn_assist		= cvardef("scr_spawn_assist", 0, 0, 99, "int");
	level.static_nade_count		= cvardef("scr_static_nades", 0, 0, 99, "int");
	level.dropnades			= cvardef("scr_dropnades", 1, 0, 1, "int");
	level.allow_turrets		= cvardef("scr_allow_turrets", 1, 0, 1, "int");
	level.teambalance_hard		= cvardef("scr_teambalance_hard", 1, 0, 99, "int");
	level.ctf_warmup		= cvardef("scr_ctf_warmup", 50, 0, 300, "int");
	level.ctf_sudden_death		= cvardef("scr_ctf_sudden_death", 1, 0, 1, "int");
	level.ctf_autoreturn_delay	= cvardef("scr_ctf_autoreturn_delay", 120, 0, 1440, "int");
	level.idle_limit		= cvardef("scr_idle_limit", 0, 0, 3600, "int");
	level.idle_warn_count		= cvardef("scr_idle_warn", 2, 0, 720, "int");
	level.voting_minplayers		= cvardef("scr_voting_minplayers", 2, 0, 64, "int");

	// weapon limits
	level.allied_sniper		= cvardef("scr_limit_sniper_allied", 99, 0, 99, "int");
	level.allied_shotty		= cvardef("scr_limit_shotgun_allied", 99, 0, 99, "int");
	level.axis_sniper		= cvardef("scr_limit_sniper_axis", 99, 0, 99, "int");
	level.axis_shotty		= cvardef("scr_limit_shotgun_axis", 99, 0, 99, "int");
	publishWeaponLimits();

	// AWE map voting
	level.awe_mapvote 		= cvardef("awe_map_vote", 0, 0, 1, "int");
	level.awe_mapvotetime		= cvardef("awe_map_vote_time", 20, 10, 180, "int");

	// anarchicmod utilities
	level.ax_debug_spawns		= cvardef("ax_debug_spawns", 0, 0, 2, "int");
	level.ax_flag_offset		= cvardef("ax_flag_offset", 0, 0, 100, "int");
}

Callback_StartGametype()
{
	maps\mp\gametypes\_mapvote::init();

	if(!isDefined(game["gamestarted"])) {
		precacheString(level.modstr);

		if (level.static_crosshair) {
			level.crosshair = "gfx/reticle/center_cross.tga";
			precacheShader(level.crosshair);
		}
		game["deaths_axis"]	= 0;
		game["deaths_allies"]	= 0;
		game["kills_axis"]	= 0;
		game["kills_allies"]	= 0;

		if (level.gametype != "dm") {
			precacheShader(game["headicon_allies"]);
			precacheShader(game["headicon_axis"]);
		}

		precacheString(&"AX_PENALTY_TIME_LEFT");
		precacheString(&"^1Teamkills^7:");
		precacheShader("killiconheadshot");

		if (level.gametype == "ctf") {
			level.flag_carrier_icon = "objective";
			precacheShader(level.flag_carrier_icon);
			precacheShader("gfx/hud/death_suicide.tga");
			precacheString(&"AX_WAIT_FOR_PLAYERS");
			precacheString(&"AX_MATCHSTARTING");
		}

                if(level.show_healthbar)
                {
                        precacheShader("gfx/hud/hud@health_back.tga");
                        precacheShader("gfx/hud/hud@health_bar.tga");
                        precacheShader("gfx/hud/hud@health_cross.tga");
                }

		for (i=0;i<level.ruleset.size;i++)
			precacheString(level.ruleset[i]);

		if (level.spawn_assist > 1)
			precacheString(&"AX_SPAWN_ASSIST");
	}
	game["objid_allies"] = 15;
	game["objid_axis"] = 14;

	if ((level.show_kdhud) && (level.gametype != "dm"))
		thread miniscoreboard();
	if ((level.nextmap_display) && (!level.awe_mapvote))
		thread shownextmap();
	checksnipers();
	modHud();
	thread ruleHud();

	// admin tools
	thread switchteam();
	thread killum();
	thread smiteplayer();
	thread forcename();
	thread freezeum();
	thread unfreezeum();
	thread kicktospec();
	thread wallops();
	thread kickspecs();
	thread muteplayer();
	thread unmuteplayer();
	shitlist_setup();
	showspawns();

	if (level.gametype == "ctf")
	{
		fixFlagPositions();
		level.ctf_sudden_death_norespawn = false;
	}

	if (!level.allow_turrets)
		thread delete_turrets();
}

delete_turrets()
{
	_turret	= getentarray("misc_turret", "classname");
	for (i=0;i<_turret.size;i++)
		_turret[i] delete();
	_mg42	= getentarray("misc_mg42", "classname");
	for (i=0;i<_mg42.size;i++)
		_mg42[i] delete();
}

showspawns() {
	if (!level.ax_debug_spawns)
		return;

	sp = getentarray("mp_ctf_spawn_allied", "classname");
	for(i=0;i<sp.size;i++)
		sp[i] setmodel(spawnpointModelByTeam(game["allies"]));

	sp = getentarray("mp_ctf_spawn_axis", "classname");
	for(i=0;i<sp.size;i++)
		sp[i] setmodel(spawnpointModelByTeam(game["axis"]));
}

spawnpointModelByTeam(team)
{
	if (!isdefined(team))
		return "xmodel/defaultactor";
	if (level.ax_debug_spawns > 1)
	{
		switch(team)
		{
			case "american":
			case "russian":
				return "xmodel/character_russian_diana_medic";
			case "german":
				return "xmodel/character_german_josh_preview";
		}
	}
	else {
		model = "xmodel/prop_flag_" + team;
		return model;
	}
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

fixFlagPositions()
{
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

fixflags(offset) {
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

Callback_PlayerConnect()
{
	guid = self getGuid();
	if (isdefined(game["matchstarted"]) && game["matchstarted"]) {
		if (isdefined(level.lostplayer) && isdefined(level.lostplayer[guid]))
		{
			self.pers["kills"]	= level.lostplayer[guid].kills;
			self.score		= level.lostplayer[guid].score;
			self.deaths		= level.lostplayer[guid].deaths;
			self.pers["team"]	= level.lostplayer[guid].team;
			self.pers["headshots"]	= level.lostplayer[guid].headshots;
			self.pers["melees"]	= level.lostplayer[guid].melees;
			self.pers["flag_caps"]	= level.lostplayer[guid].flag_caps;
			self.teamkills		= level.lostplayer[guid].teamkills;
			self.muted		= level.lostplayer[guid].muted;
			self.cannot_play	= level.lostplayer[guid].cannot_play;
			if (isdefined(level.lostplayer[guid].weapon))
				self.pers["weapon"] = level.lostplayer[guid].weapon;
			self.onjoin_welcome_back = true;
		}
	}

	if (!isdefined(self.kills))
		self.kills = 0;
	if (!isdefined(self.pers["kills"]))
		self.pers["kills"] = 0;
	if (!isdefined(self.pers["flag_caps"]))
		self.pers["flag_caps"] = 0;
	if (!isdefined(self.pers["headshots"]))
		self.pers["headshots"] = 0;

	if (level.forcedownload)
		self setClientCvar("cl_allowdownload", 1);

	self checkName();

	if (level.forcerate > 0) 
		self setClientCvar("rate", level.forcerate);
	self setClientCvar("cg_chattime", "12000");

	//self thread disableRedCrosshair();
	//self thread disableEnemyRadar();
	//self thread tweakAmbientFix();

	self thread oldHeadIcons(); // scale the headicons according to view distance
	self thread oldObjPoints(); // see the objpoints on the compass from farther away
	self thread forceSayPos(); // reset the chat position in case we forced it off-screen

	if ((level.show_kdhud) && (level.gametype != "cnq"))
		self thread miniscore_myscore();

	if (!isdefined(self.teamkills))
		self.teamkills = 0;
	self.team_kill_level = 0;
	self.team_damage = 0;
	self.teamkill_timeout = 3;
	if (!isdefined(self.cannot_play))
		self.cannot_play = false;
	self.teamkill_counter = false;

	self.spawn_assist = false;

	if (!isdefined(self.muted))
		self.muted = false;

	self.pers["hop_denial"] = 0.0;
	self thread hopwatch();
	self.hopping = false;
	self.chose_auto_assign = false;
	self.team_kill_suicides = 0;

	self thread shitlist();
}

rememberinfo(player)
{
	if (level.gametype != "ctf")
		return;

	if (isdefined(game["matchstarted"]) && !game["matchstarted"])
		return;

	if (!isdefined(player.pers["team"]) || !isdefined(player.deaths) || !isdefined(player.score) || !isdefined(player.pers["kills"]))
		return;

	if (!isdefined(level.lostplayer))
		level.lostplayer = [];

	guid = player getGuid();

	if (isdefined(level.lostplayer[guid]))
		level.lostplayer[guid] = undefined;

	level.lostplayer[guid] = spawnstruct();

	level.lostplayer[guid].score = player.score;
	level.lostplayer[guid].deaths = player.deaths;
	level.lostplayer[guid].team = player.pers["team"];
	level.lostplayer[guid].kills = player.pers["kills"];
	level.lostplayer[guid].headshots = player.pers["headshots"];
	level.lostplayer[guid].melees = player.pers["melees"];
	level.lostplayer[guid].flag_caps = player.pers["flag_caps"];
	if (isdefined(player.pers["weapon"]))
		level.lostplayer[guid].weapon =	player.pers["weapon"];
	level.lostplayer[guid].teamkills = player.teamkills;
	level.lostplayer[guid].team_kill_suicides = player.team_kill_suicides;
	level.lostplayer[guid].team_damage = player.team_damage;
	level.lostplayer[guid].muted = player.muted;
	level.lostplayer[guid].cannot_play = player.cannot_play;

	level thread timedundefined(guid, 600);
}

timedundefined(idx, time)
{
        wait time;
        level.lostplayer[idx] = undefined;
}

shitlist_setup()
{
	level.shitlist = [];

	// Shanny
	//level.shitlist[445041] = spawnstruct();
	//level.shitlist[445041].name = "^1|^9ax^1|^9 Shanny";

	// DangerUS
	//level.shitlist[664286] = spawnstruct();
	//level.shitlist[664286].chat = "blocked";
}

shitlist()
{
	guid = self getGUID();
	if (!isdefined(level.shitlist[guid]))
		return;
	if (isdefined(level.shitlist[guid].name))
		self thread shitlist_name(level.shitlist[guid].name);
	if (isdefined(level.shitlist[guid].chat) && level.shitlist[guid].chat == "blocked")
		self thread shitlist_chat();
}

shitlist_name(name)
{
	self endon("disconnect");
	for (;;)
	{
		self setclientcvar("name", name);
		wait 1;
	}
}

shitlist_chat()
{
	self endon("disconnect");
	for (;;)
	{
		self setclientcvar("cg_chattime", 0);
		wait 1;
	}
}

hopwatch()
{
	self endon("disconnect");
	self thread hop_deny_notify();
	self.hopping = false;
	for (;;)
	{
		i = 0.0;
		z_old = self.origin[2];
		while (!self isonground() && i < 0.5)
		{
			if (self.origin[2] < z_old && i < 0.15)
			{
				break;
			}
			self.hopping = true;
			i += 0.05;
			z_old = self.origin[2];
			wait 0.05;
		}
		self.hopping = false;

		while (!self isonground())
			wait 0.05;
		wait 0.05;
	}
}

hop_deny_notify()
{
	self endon("disconnect");
	total = 0.0;
	for (;;)
	{
		wait 45;
		if (self.pers["hop_denial"] > 0)
		{
			total += self.pers["hop_denial"];
			self iprintln("Total damage points denied because you hopped: ^1" + total);
			self.pers["hop_denial"] = 0.0;
		}
	}
}

Callback_PlayerKilled(eInflictor, attacker, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc) {

	/*if (getcvarint("g_debugdamage"))
	{
		attacker iprintln("sMeansOfDeath: " + sMeansOfDeath);
		attacker iprintln("sHitLoc: " + sHitLoc);
		attacker iprintln("sWeapon: " + sWeapon);
	}*/
	if ((!isplayer(attacker)) || (!isdefined(attacker.pers["kills"])))
		return;

	if ( (isdefined(game["matchstarted"]) && game["matchstarted"]) || !isdefined(game["matchstarted"]) )
	{
		if (isPlayer(attacker)) {
			if (attacker == self)
			{
				if (!isdefined (self.autobalance))
					attacker.pers["kills"]--;
				if (attacker.teamkills > level.team_kill_limit)
					attacker.score--;
				if (isdefined(attacker.last_victim_team) && (attacker.last_victim_team == self.pers["team"]))
					attacker.team_kill_suicides++;
			}
			else
			{
				if (self.pers["team"] == attacker.pers["team"]) // killed by a friendly
				{
					attacker.pers["kills"]--;
					attacker.teamkills++;
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

	if (isdefined(self.healthbar))
		self.healthbar destroy();
	if (isdefined(self.healthbar_back))
		self.healthbar_back destroy();
	if (isdefined(self.healthbar_cross))
		self.healthbar_cross destroy();

	attacker teamkill_counter_destroy();

	self notify("flag_dropped");

	self spawn_assist_hud_destroy();

	if(isdefined(self.awe_spinemarker)) 
	{ 
		self.awe_spinemarker unlink(); 
		self.awe_spinemarker delete(); 
	}

	if (isdefined(self.obj_id))
		objective_delete(self.obj_id);
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
				eAttacker thread playerTimeout(eAttacker.teamkill_timeout);
				eAttacker.teamkill_timeout++;
				break;
		}
		eAttacker thread teamkill_counter_update();

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

setTeamKillLevel() {
	if (self.teamkills < level.team_kill_limit)
		self.team_kill_level = 0;
	if (self.teamkills == level.team_kill_limit)
		self.team_kill_level = 1;
	if ( (self.teamkills > level.team_kill_limit) || (self.team_damage > level.team_damage_limit) )
		self.team_kill_level = 2;
	if ( (self.teamkills > level.team_kill_limit) || (self.team_damage > level.team_damage_limit && self.team_kill_suicides > level.team_kill_suicide_limit) )
		self.team_kill_level = 3;
}

playerTimeout(time)
{
	level endon("intermission");
	//self endon("killed_player");
	self suicide();
	self.pers["team"] = "spectator";
	self.sessionteam = "spectator";
	[[level.spawnspectator]]();
	clientAnnouncement(self, "You have been forced to spectate due to having too many team kills. Your penalty time is ^1" + time + "^7 minute(s). You may rejoin after that.");
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
	clientAnnouncement(self, "You may rejoin the game. Please do not damage your teammates!");
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

	if (self.spawn_assist)
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
	/* not affected by:
		- being on turret
		- any other means of death other than pistol/rifle
	*/
	if (isdefined(eattacker) && isPlayer(eAttacker))
	{
		if (eAttacker.hopping && !isturret(sWeapon) && (sMeansOfDeath == "MOD_RIFLE_BULLET" || sMeansOfDeath == "MOD_PISTOL_BULLET"))
		{
			old_damage = iDamage;
			iDamage = iDamage * mod_hop;
			eattacker.pers["hop_denial"] += old_damage - idamage;
		}
/*		if ( isdefined(eAttacker.spawn_assist_time) && (gettime() - eAttacker.spawn_assist_time < 3000) && sMeansOfDeath == "MOD_GRENADE_SPLASH" )
		{
			iDamage = iDamage * mod_nade_exp;
			eAttacker iprintln("^1* Your grenade only did " + iDamage + " damage points. Don't abuse spawn assist!");
		}
*/
	}
	return int(iDamage);
}

UpdateHealthBar()
{       
	level endon("intermission");
	self endon("killed_player");
	if (!level.show_healthbar)
		return;
	
	for (;;) {

		wait 0.05;

	        if(!isdefined(self.healthbar))
        	        continue;  
         
	        maxwidth = 128;

	        health = self.health / self.maxhealth;
                
        	hud_width = int(health * maxwidth);
                        
	        if ( hud_width < 1 )
        	        hud_width = 1;
                                
	        self.healthbar setShader("gfx/hud/hud@health_bar.tga", hud_width, 5);
        	self.healthbar.color = ( 1.0 - health, health, 0);
	}
}
spawnPlayer() {
	maps\mp\gametypes\_anarchic::checkSnipers();

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

	if(level.show_healthbar && !isdefined(self.healthbar))
        {
                x = -138;
                y = 231;
                maxwidth = 128;
                
                self.healthbar_back = newClientHudElem( self );
                self.healthbar_back setShader("gfx/hud/hud@health_back.tga", maxwidth + 2, 7);
                self.healthbar_back.alignX = "left";
                self.healthbar_back.alignY = "top";
		self.healthbar_back.horzAlign = "right";
		self.healthbar_back.vertAlign = "middle";
                self.healthbar_back.x = x;
                self.healthbar_back.y = y;

                self.healthbar_cross = newClientHudElem( self );
                self.healthbar_cross setShader("gfx/hud/hud@health_cross.tga", 7, 7);
                self.healthbar_cross.alignX = "right";
                self.healthbar_cross.alignY = "top";
		self.healthbar_cross.horzAlign = "right";
		self.healthbar_cross.vertAlign = "middle";
                self.healthbar_cross.x = x - 1;
                self.healthbar_cross.y = y;
        
                self.healthbar = newClientHudElem( self );
                self.healthbar setShader("gfx/hud/hud@health_bar.tga", maxwidth, 5);
                self.healthbar.color = ( 0, 1, 0);
                self.healthbar.alignX = "left";
                self.healthbar.alignY = "top";
		self.healthbar.horzAlign = "right";
		self.healthbar.vertAlign = "middle";
                self.healthbar.x = x + 1;
                self.healthbar.y = y + 1;
        }
	self thread updatehealthbar();
	if ( (int(level.friendlyfire) > 0) && (!isdefined(self.teamkill_display)) && (!isdefined(self.teamkill_display_counter)) ){
		x = -88;
		y = 188;

		self.teamkill_display = newClientHudElem(self);
		self.teamkill_display.alignX = "left";
		self.teamkill_display.alignY = "top";
		self.teamkill_display.horzAlign = "right";
		self.teamkill_display.vertAlign = "middle";
		self.teamkill_display.x = x;
		self.teamkill_display.y = y;
		self.teamkill_display.fontscale = 0.85;
		self.teamkill_display.archived = false;
		self.teamkill_display.alpha = 0;
		self.teamkill_display setText(&"^1Teamkills^7:");

		self.teamkill_display_counter = newClientHudElem(self);
		self.teamkill_display_counter.alignX = "left";
		self.teamkill_display_counter.alignY = "top";
		self.teamkill_display_counter.horzAlign = "right";
		self.teamkill_display_counter.vertAlign = "middle";
		self.teamkill_display_counter.x = x + 42;
		self.teamkill_display_counter.y = y;
		self.teamkill_display_counter.fontscale = 0.9;
		self.teamkill_display_counter.archived = false;
		self.teamkill_display_counter.alpha = 0;
	}
	self.obj_id = undefined;
	self.last_victim_team = undefined;

	self thread check_ax();

	if (level.antiflop)
		self thread start_antiflop();
	self thread spawn_assist();

	self thread make_crosshair();
	if (level.gametype == "ctf")
		self thread maps\mp\gametypes\_spectating::setSpectatePermissions();

	self thread idleWatchDog();
}

bodySearch(player)
{
	body = self;
//	body.pack = player.ammo_pack;
	unique_id = randomint(10000);
//	while (!verifyBodyId(unique_id))
//		unique_id = randomint(10000);
	body.id = unique_id;
	wait 0.05;
	body thread waitForSearch();
	level thread expireBody(body);
	iprintln("body search thread kicked off");
}

expireBody(body)
{
	id = body.id;

	while (isdefined(body))
		wait 0.05;

/*	players = getentarray("player", "classname");
	for (i = 0; i < players.size; i++) {
		player = players[i];
		if (!isdefined(player))
			continue;
		if (isalive(player) && (isdefined(player.is_searching)) && (player.is_searching_from == id)) {
			player search_cleanup();
			player notify ("clear_search_hint");
			level notify("body_" + id + "_clear");
		}
			
	}
*/
	level notify("body_" + id + "_clear");
	iprintln("body with id " + id + " expired");
}

waitForSearch()
{
	level endon("body_" + self.id + "_clear");

	mindist = 64;
	minhold = 0.25;

	target = undefined;

	for (;;)
	{
		players = getentarray("player", "classname");

		for (i = 0; i < players.size; i++)
		{
			player = players[i];
			dist = distance(player.origin, self.origin);
			if ( ( dist < mindist ) && isPlayer( player ) && isAlive( player ) && ( player.sessionstate == "playing" ) && ( !player meleeButtonPressed() ) )
			{
				target = player;
				break;
			}
		}
		wait 0.05;
		if (isdefined(target))
			iprintln(target.name + " can search body " + self.id);
		target = undefined;
	}
}

displaySearchHint()
{
	if (!isdefined(self.search_hint1))
		self.search_hint1 = self hudelemText("center", "middle", 570, 192, 0.8, 0.75, (1, 1, 1), 1, level.search_hint1);

	if (!isdefined(self.search_hint2))
		self.search_hint2 = self hudelemText("center", "middle", 570, 202, 0.8, 0.75, (1, 1, 1), 1, level.search_hint2);

	if (!isdefined(self.search_icon))
		self.search_icon = self hudelemShader("center", "middle", 570, 221, 0.8, (1, 0, 0), level.search_icon, 20, 20);

	self waittill("clear_search_hint");

	self searchHudCleanup();
}

searchHudCleanup()
{
	if(isdefined(self.progressbackground))
		self.progressbackground destroy();
	if(isdefined(self.progressbar))
		self.progressbar destroy();
	if (isdefined(self.search_hint1))
		self.search_hint1 destroy();
	if (isdefined(self.search_hint2))
		self.search_hint2 destroy();
	if (isdefined(self.search_icon))
		self.search_icon destroy();
}

hudelemText(alignx, aligny, x, y, alpha, fontscale, color, sort, textval)
{
	text = newClientHudElem( self );
	text.alignX = alignx;
	text.alignY = aligny;
	text.X = x;
	text.Y = y;
	text.alpha = alpha;
	text.fontScale = fontscale;
	text.color = color;
	text.sort = sort;
	text setText(textval);
	return text;
}

hudelemShader(alignx, aligny, x, y, alpha, color, shaderval, w, h)
{
	shader = newClientHudElem( self );
	shader.alignX = alignx;
	shader.alignY = aligny;
	shader.X = x;
	shader.Y = y;
	shader.alpha = alpha;
	shader.color = color;
	shader setShader(shaderval, w, h);
	return shader;
}
idleWatchdog()
{
	if ( !level.idle_limit || !isdefined(game["matchstarted"]) || !game["matchstarted"] )
		return;

	self endon("disconnect");
	self endon("killed_player");

	warn_interval = ( level.idle_limit / (level.idle_warn_count + 1) );

	origin_current = self.origin;
	angles_current = self getplayerangles();

	last_warn = 0;
	watch_delay = 1;
	spec_delay = 5;

	idle_time = 0;

	while ( isplayer(self) && isalive(self) && (self.sessionstate == "playing") )
	{
		wait watch_delay;

		origin_latest = self.origin;
		angles_latest = self getplayerangles();

		if ( (origin_current == origin_latest) && (angles_current == angles_latest) )
			idle_time++;
		else {
			idle_time = 0;
			last_warn = 0;
			origin_current = origin_latest;
			angles_current = angles_latest;
			continue;
		}

		if (idle_time > level.idle_limit)
		{
			clientAnnouncement(self, "^1Attention!");
			clientAnnouncement(self, "You are being forced to spectate because you are not playing!");
			iprintln("^5Idle Watchdog^7: " + self.name + "^7 has been idle too long - moving to spectate.");
			wait spec_delay;
			self thread moveToSpectate();
			return;
		}
		else if (idle_time > warn_interval && ( (idle_time - last_warn) > warn_interval ) )
		{
			clientAnnouncement(self, "^1Attention!");
			clientAnnouncement(self, "Please go to spectate if you are not playing!");
			last_warn = idle_time;
		}
		// new values become old values
		origin_current = origin_latest;
		angles_current = angles_latest;
	}
}
moveToSpectate()
{
	self.pers["team"] = "spectator";
	self.sessionteam = "spectator";
	[[level.spawnspectator]]();
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

	if (!isdefined(level.in_sudden_death))
		level.in_sudden_death = false;

	if ((level.ctf_sudden_death) && (level.gametype == "ctf"))
	{
		debug = getCvarInt("ax_debug_sudden_death");
		players = maps\mp\gametypes\_teams::CountPlayers();
		if ( ( players["allies"] > 1 && players["axis"] > 1 ) || debug > 0 )
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

			if (!flagAtHome("axis") || !flagAtHome("allied"))
			{
				if (!level.in_sudden_death)
				{
					level.clock reset();
					if (debug) iprintln("clock has been reset");
					level.clock.color = (1, 0, 0);
					level.clock.horzAlign = "left";
					level.clock.vertAlign = "top";
					level.clock.x = 8;
					level.clock.y = 2;
					level.clock.font = "default";
					level.clock.fontscale = 2;
					level.clock setTimerUp(0);
					if (debug) iprintln("settimerup has been called");

					// create some kind of notification
				}
				level.in_sudden_death = true;

				if (score_diff == 0)
				{
					// disable respawns if its a tie
					if (!level.ctf_sudden_death_norespawn)
					{
						level.ctf_sudden_death_norespawn = true;
						// create some kind of notification
					}
					return;
				}
				// don't end the game if the losing team has a chance to tie it up
				if (score_diff == 1 && !flagAtHome(winning_team))
					return;
			}
		}
	}

	level.mapended = true;

	if(!level.splitscreen)
		iprintln(&"MP_TIME_LIMIT_REACHED");

	level thread [[level.endGameConfirmed]]();
}

flagAtHome(team)
{
	ent = team + "_flag";
	flag = getent(ent, "targetname");
	if (flag.origin != flag.home_origin)
		return false;
	else return true;
}

endmap()
{
	pastrotation();
	if (level.awe_mapvote)
		maps\mp\gametypes\_mapvote::Initialise();
}

pastrotation() {
	limit = cvardef("scr_past_rotation_mem", 10, 0, 30, "int");
	r = getcvar("scr_past_rotation");
	if (r == "")
		setcvar("scr_past_rotation", level.mapname);

	else {
		//setcvar("scr_past_rotation", "");
		past = "";
		m = explode(r, ",");
		m[m.size] = level.mapname;

		if (m.size <= limit)
			i = 0;
		else i = (m.size-limit);

		start = i;

		while(i<m.size) {
			if (i==start)
				s = m[i];
			else
				s = "," + m[i];
			//setcvar("scr_past_rotation", getcvar("scr_past_rotation") + s);
			past = past + s;
			i++;
		}
		setcvar("scr_past_rotation", past);
	}
}

make_crosshair()
{
	if (!level.static_crosshair)
		return;
	if (!isdefined(self.crosshair))
	{
		self.crosshair = newClientHudElem(self);
		self.crosshair.x = 320;
		self.crosshair.y = 240;
		self.crosshair.alignx = "center";
		self.crosshair.aligny = "middle";
		self.crosshair setshader(level.crosshair, 64, 64);
	}
}

check_ax()
{
	//self iprintln(nocolors(name));
	tags = "^7|^4ax^7|";
	nc = nocolors(self.name);
	if (nc.size > tags.size)
		return;
}

nocolors(str)
{
	tmp = "";
	for (i=0; i<str.size; i++) {
		if (str[i] == "^" && isnum(int(str[i+1]))) // color code found
			i++;
		else tmp = tmp + str[i];
	}
	return tmp;		
}

isnum(x)
{
	if (x >= 0 || x <= 0)
		return true;
	else return false;
}

isturret(w)
{
	switch(w)
	{
		case "mg42_bipod_duck_mp":
		case "mg42_bipod_prone_mp":
		case "mg42_bipod_stand_mp":
		case "30cal_prone_mp":
		case "30cal_stand_mp":
			return true;
		default:
			return false;
	}
}

/*
   spawn assist

	06/01/08; added cancellation of spawn assist if player discharges their weapon
*/		

spawn_assist()
{
	self endon("disconnect");
	self endon("killed_player");
	self endon("player_fired");
	if (level.spawn_assist <= 0)
		return;

	self.spawn_assist = true;
	self spawn_assist_hud();
	//self takeFrags();

	self thread spawn_assist_discharge();
	wait level.spawn_assist;
	self.spawn_assist_time = gettime();
	self spawn_assist_cleanup();
	//self giveFrags();
}

spawn_assist_discharge()
{
	self endon("disconnect");
	i=0.0;
	fired=0;
	while (i < level.spawn_assist)
	{
		self.spawn_assist_time = gettime();
		if (!self attackbuttonpressed())
		{
			i+=0.05;
			wait 0.05;
		}
		else {
			fired = 1;
			break;
		}
	}
	if (fired)
	{
		self notify("player_fired");
		self.spawn_assist_time = gettime();
		self spawn_assist_cleanup();
		//self giveFrags();
	}
}			

spawn_assist_cleanup()
{
	if (isplayer(self))
		self.spawn_assist = false;
	self spawn_assist_hud_destroy();
}

spawn_assist_hud() 
{
	if (!isdefined(self.spawn_assist_display_title)) {
		self.spawn_assist_display_title	= newClientHudElem(self);
		self.spawn_assist_display_title.x = 285;
		self.spawn_assist_display_title.y = 470;
		self.spawn_assist_display_title.alignx = "left";
		self.spawn_assist_display_title.aligny = "top";
		self.spawn_assist_display_title.font = "default";
		self.spawn_assist_display_title.fontscale = 0.8;
		self.spawn_assist_display_title.archived = false;
		self.spawn_assist_display_title.color = (1, 1, 1);
		self.spawn_assist_display_title setText(&"AX_SPAWN_ASSIST");
	}
	if (!isdefined(self.spawn_assist_display_sec)) {
		self.spawn_assist_display_sec = newClientHudElem(self);
		self.spawn_assist_display_sec.x = 340;
		self.spawn_assist_display_sec.y = 470;
		self.spawn_assist_display_sec.alignx = "left";
		self.spawn_assist_display_sec.aligny = "top";
		self.spawn_assist_display_sec.font = "default";
		self.spawn_assist_display_sec.fontscale = 0.8;
		self.spawn_assist_display_sec.archived = false;
		self.spawn_assist_display_sec.color = (1, 0, 0);
		self.spawn_assist_display_sec setTimer(level.spawn_assist);
	}
}

spawn_assist_hud_destroy()
{
	if (isdefined(self.spawn_assist_display_title))
		self.spawn_assist_display_title destroy();
	if (isdefined(self.spawn_assist_display_sec))
		self.spawn_assist_display_sec destroy();
}

start_antiflop() {
	self endon("killed_player");
	wait 0.5;
	self.awe_spinemarker = spawn("script_origin",(0,0,0)); 
	self.awe_spinemarker linkto (self, "J_Spine4",(0,0,0),(0,0,0));
	wait 0.05;
	self thread antiflop();
}

antiflop() {
	self endon("killed_player");

	self.is_prone = self isProne();
	
	while (1) {
		wait 0.02;
		if ( !isalive(self) || !isplayer(self) || self.sessionstate != "playing" )
			continue;
		if ((self.is_prone == false) && (self isProne())) { // just went prone
			current = self getcurrentweapon();
			primary = self getWeaponSlotWeapon("primary");

			if (isdefined(primary) && (current == primary)) {
				reloading = self getWeaponSlotClipAmmo("primary");
			}
			else reloading = 1;

			if (reloading == 0)
				isreload = true;
			else isreload = false;

			if ((!isreload) && (!isSniper(self getcurrentweapon()))) {
				self disableweapon();
				switch (self.prior_stance) {
					case "stand":
						wait 0.6;
						break;
					case "crouch":
						wait 0.4;
						break;
					default:
						break;
				}
				self enableweapon();
			}
		}
		self.is_prone = self isProne();
		self.prior_stance = self getstance(0);
	}
}

isProne() {
	switch (self getStance(0)) {
		case "prone":
			return true;
		default:
			return false;
	}
}

isGrenade(weapon)
{
	switch(weapon)
	{
		case "frag_grenade_american_mp":
		case "frag_grenade_british_mp":
		case "frag_grenade_german_mp":
		case "frag_grenade_russian_mp":
			return true;
		default:
			return false;
	}
}
getGrenadeType()
{
	if(self.pers["team"] == "allies")
	{
                switch(game["allies"])
                {
	                case "american":
        	                return "frag_grenade_american_mp";
	                case "british":
        	                return "frag_grenade_british_mp";
	                default:
        	                assert(game["allies"] == "russian");
                	        return "frag_grenade_russian_mp";
                }
        }
        else
        {
                assert(self.pers["team"] == "axis");
                switch(game["axis"])
                {
	                default:
        	                assert(game["axis"] == "german");
                	        return "frag_grenade_german_mp";
                }
        }
}

isSniper(weapon) {
	switch (weapon) {
		case "enfield_scope_mp":
		case "kar98k_sniper_mp":
		case "mosin_nagant_sniper_mp":
		case "springfield_mp":
			return true;
		default:
			return false;
	}
}

isVotingAllowed()
{
	if (level.gametype == "ctf")
	{
		if ( !isdefined(game["matchstarted"]) || !game["matchstarted"] )
			return false;
	}
	if (level.voting_minplayers > 0)
	{
		m = level.voting_minplayers % 2;
		if (m > 0) level.voting_minplayers += m;
		per_team = level.voting_minplayers / 2;
		players = maps\mp\gametypes\_teams::CountPlayers();
		if ( ( players["allies"] < per_team && players["axis"] < per_team ) || players.size < level.voting_minplayers )
			return false;
	}
	return true;
}


takeFrags()
{
	self takeWeapon("frag_grenade_american_mp");
	self takeWeapon("frag_grenade_british_mp");
	self takeWeapon("frag_grenade_russian_mp");
	self takeWeapon("frag_grenade_german_mp");
}

giveFrags()
{
	if(getcvarint("scr_allow_fraggrenades"))
	{
		if (level.static_nade_count > 0)
			fraggrenadecount = level.static_nade_count;
		else fraggrenadecount = maps\mp\gametypes\_weapons::getWeaponBasedGrenadeCount(self.pers["weapon"]);
		if(fraggrenadecount)
		{
			grenadetype = self getGrenadeType();
			self giveWeapon(grenadetype);
			self setWeaponClipAmmo(grenadetype, fraggrenadecount);
		}
	}
}

teamkill_counter_update() {
	self endon("killed_player");
	if (!isalive(self) || !isplayer(self))
		return;
	if (self.teamkill_counter)
		return;
	if (!isdefined(self.teamkill_display_counter) || !isdefined(self.teamkill_display))
		return;
	self.teamkill_counter = true;
	self.teamkill_display_counter setValue(self.teamkills);
	self.teamkill_display_counter.alpha = 1;
	self.teamkill_display.alpha = 1;
	wait 3;
	self thread teamkill_counter_fade(0, 1);
}		

teamkill_counter_fade(in_out, time) {
	self endon("killed_player");
	if (!isdefined(self.teamkill_display) || !isdefined(self.teamkill_display_counter))
		return;
	self.teamkill_display fadeOverTime(time);
	self.teamkill_display.alpha = in_out;
	self.teamkill_display_counter fadeovertime(time);
	self.teamkill_display_counter.alpha = in_out;
	self.teamkill_counter = false;
}

teamkill_counter_destroy() {
	self.teamkill_counter = false;
	if (isdefined(self.teamkill_display))
		self.teamkill_display destroy();
	if (isdefined(self.teamkill_display_counter))
		self.teamkill_display_counter destroy();
}

disableRedCrosshair() {
	self endon("disconnect");
	for (;;) 
	{
		self setClientCvar("cg_crosshairEnemyColor", 0);
		wait 10;
	}
}
disableEnemyRadar() {
	self endon("disconnect");
	for (;;) 
	{
		self setClientCvar("cg_hudCompassSoundPingFadeTime", 0);
		wait 10;
	}
}

// scale the headicons according to view distance
oldHeadIcons() {
	self endon("disconnect");
	for (;;)
	{
		self setClientCvar("cg_headiconminscreenradius", 0.003);
		wait 10;
	}
}

// see the objpoints on the compass from farther away
oldObjPoints() {
	self endon("disconnect");
	for (;;)
	{
		self setClientCvar("cg_hudObjectiveMaxRange", 10000);
		wait 10;
	}
}

// reset the chat position in case we forced it off-screen
forceSayPos() {
	self endon("disconnect");
	//for (;;)
	//{
		self setClientCvar("cg_hudchatposition", "5 85");
	//	wait 10;
	//}
}
tweakAmbientFix() {
	self endon("disconnect");
	for (;;)
	{
		self setClientCvar("r_lighttweakambient", 0);
		self setClientCvar("r_lighttweakambientcolor", "0.85098 0.901961 1 1");
		wait 1;
	}
}
checkName() {

	// Renames unknown soldiers
	if (level.rename_unknown) {
		if (self.name == "Unknown Soldier") {
			rand = level.rename_unknown_prefix + "..." + randomint(30) + "_" + randomint(3000);
			self setClientCvar("name", rand);
		}
	}
}
//sets random allied team for rifles-only
setRandomAllied()
{
	switch (randomint(2)) {
		case 0:
			game["allies"] = "russian";
			game["russian_soldiertype"] = "padded";
			break;
		case 1:
			game["allies"] = "british";
			game["british_soldiertype"] = "normandy";
			break;
	}
}
isBalanced(response)
{
	if (isadmin(self))
	{
		self iprintln("Skipping autobalance (admin)");
		return false;
	}

	outofbalance = false;
	skipbalancecheck = undefined;

	if ( (level.teambalance_hard > 0) && (!isdefined (skipbalancecheck)) && (response != "spectator") && (response != "autoassign") )
	{
		players = maps\mp\gametypes\_teams::CountPlayers();
		
		if (self.sessionteam != "spectator")
		{
			if (((players[response] + 1) - (players[self.pers["team"]] - 1)) > level.teambalance_hard)
			{
				if (response == "allies")
				{
					switch(game["allies"]) {			
						case "american":
							self iprintlnbold(&"PATCH_1_3_CANTJOINTEAM_ALLIED",&"PATCH_1_3_AMERICAN");
						case "british":
							self iprintlnbold(&"PATCH_1_3_CANTJOINTEAM_ALLIED",&"PATCH_1_3_BRITISH");
						case "russian":
							self iprintlnbold(&"PATCH_1_3_CANTJOINTEAM_ALLIED",&"PATCH_1_3_RUSSIAN");
					}
				}
				else
					self iprintlnbold(&"PATCH_1_3_CANTJOINTEAM_ALLIED",&"PATCH_1_3_GERMAN");
				outofbalance = true;
			}
		}
		else
		{
			if (response == "allies")
				otherteam = "axis";
			else
				otherteam = "allies";
			if (((players[response] + 1) - players[otherteam]) > level.teambalance_hard)
			{
				if (response == "allies")
				{
					if (game["allies"] == "american")
						self iprintlnbold(&"PATCH_1_3_CANTJOINTEAM_ALLIED2",&"PATCH_1_3_AMERICAN");
					else if (game["allies"] == "british")
						self iprintlnbold(&"PATCH_1_3_CANTJOINTEAM_ALLIED2",&"PATCH_1_3_BRITISH");
					else if (game["allies"] == "russian")
						self iprintlnbold(&"PATCH_1_3_CANTJOINTEAM_ALLIED2",&"PATCH_1_3_RUSSIAN");
				}
				else
				{
					if (game["allies"] == "american")
						self iprintlnbold(&"PATCH_1_3_CANTJOINTEAM_AXIS",&"PATCH_1_3_AMERICAN");
					else if (game["allies"] == "british")
						self iprintlnbold(&"PATCH_1_3_CANTJOINTEAM_AXIS",&"PATCH_1_3_BRITISH");
					else if (game["allies"] == "russian")
						self iprintlnbold(&"PATCH_1_3_CANTJOINTEAM_AXIS",&"PATCH_1_3_RUSSIAN");
				}
				outofbalance = true;
			}
		}
	}
	return outofbalance;
}

menuAutoAssign()
{
	self.chose_auto_assign = true;
}

printJoinedTeam(team)
{
	if (!self.chose_auto_assign)
	{
		if(team == "allies")
			iprintln(&"MP_JOINED_ALLIES", self.name + "^7");
		else if(team == "axis")
			iprintln(&"MP_JOINED_AXIS", self.name + "^7");
	}
	else // need to localize
	{
		if(team == "allies")
			iprintln(self.name + "^7 Auto-Assigned to Allies");
		else if(team == "axis")
			iprintln(self.name + "^7 Auto-Assigned to Axis");
	}
	return;
}

modHud() {	
	if (level.show_modhud != 1)
		return;

	if(!isdefined(level.mod_title))
	{
		level.mod_title = newHudElem();
		level.mod_title.archived = false;
		level.mod_title.x = 10;
		level.mod_title.y = 230;
		level.mod_title.horzAlign = "left";
		level.mod_title.vertAlign = "middle";
		level.mod_title.alignX = "left";
		level.mod_title.alignY = "top";
		level.mod_title.fontScale = 0.8;
		level.mod_title.sort = 1;
		level.mod_title.color = (1, 1, 1);
	}
	level.mod_title setText(level.modstr);
}

// shows the server rules
ruleHud() {
	level endon("intermission");
	if (level.show_rulehud != 1)
		return;
	if (!isdefined(level.rule_hud))
	{
		level.rule_hud = newHudElem();
		level.rule_hud.archived = false;
		level.rule_hud.x = 320;
		level.rule_hud.y = 8;
		level.rule_hud.alignx = "center";
		level.rule_hud.aligny = "top";
		level.rule_hud.fontscale = 0.9;
		//level.mod_title.color = (1,1,1);
	}
	while(isdefined(game["state"]) && game["state"] == "playing")
	{
		for (i=0; i<level.ruleset.size; i++)
		{
			level.rule_hud setText(level.ruleset[i]);
			level.rule_hud fadeOvertime(1);
			level.rule_hud.alpha = 1;
			wait 4;
			level.rule_hud fadeOvertime(1);
			level.rule_hud.alpha = 0;
			wait 3;
		}
	}
}

defineRuleSet()
{
	level.ruleset = [];
	level.ruleset[level.ruleset.size] = &"AX_SPAM0";
	level.ruleset[level.ruleset.size] = &"AX_SPAM1";
	level.ruleset[level.ruleset.size] = &"AX_SPAM2";
	level.ruleset[level.ruleset.size] = &"AX_SPAM3";
	level.ruleset[level.ruleset.size] = &"AX_SPAM4";
	level.ruleset[level.ruleset.size] = &"AX_SPAM5";
	level.ruleset[level.ruleset.size] = &"AX_SPAM6";
	level.ruleset[level.ruleset.size] = &"AX_SPAM7";
	level.ruleset[level.ruleset.size] = &"AX_SPAM8";
	level.ruleset[level.ruleset.size] = &"AX_SPAM9";
	level.ruleset[level.ruleset.size] = &"AX_SPAM10";
	level.ruleset[level.ruleset.size] = &"AX_SPAM11";
	level.ruleset[level.ruleset.size] = &"AX_SPAM12";
}

/////////////////////////////////////////
// code loosely based on PRM for CoD 1.1
/////////////////////////////////////////

publishWeaponLimits()
{
	setCvar("ui_limit_sniper_allied", level.allied_sniper);
	makeCvarServerInfo("ui_limit_sniper_allied");
	setCvar("ui_limit_sniper_axis", level.axis_sniper);
	makeCvarServerInfo("ui_limit_sniper_axis");
	setCvar("ui_limit_shotgun_allied", level.allied_shotty);
	makeCvarServerInfo("ui_limit_shotgun_allied");
	setCvar("ui_limit_shotgun_axis", level.axis_shotty);
	makeCvarServerInfo("ui_limit_shotgun_axis");
}

checkSnipers() {

	allied_sniper 	= 0;
	allied_shotty	= 0;

	axis_sniper	= 0;
	axis_shotty	= 0;

	no_weapon = 0;

	lplayers = getentarray("player", "classname");

	for(i = 0; i < lplayers.size; i++) {
		lplayer = lplayers[i];

		if(!isdefined(lplayer.pers["weapon"])) {
			no_weapon++;
		}
		
		else {
			switch(lplayer.pers["weapon"]) {

				// allied sniper weapons
				case "springfield_mp":
				case "mosin_nagant_sniper_mp":
				case "enfield_scope_mp":
					allied_sniper++;
					break;

				// axis sniper
				case "kar98k_sniper_mp":
					axis_sniper++;
					break;

				// global shotgun
				case "shotgun_mp":
					if (lplayer.pers["team"] == "axis")
						axis_shotty++;
					else allied_shotty++;
					break;
				default:
					no_weapon++;
					break;
			}		
		}
	}

	switch (game["allies"]) {
		case "american":
			limitweapon("springfield", allied_sniper, level.allied_sniper);
			break;
		case "russian":
			limitweapon("nagantsniper", allied_sniper, level.allied_sniper);
			break;
		case "british":
			limitweapon("enfieldsniper", allied_sniper, level.allied_sniper);
			break;
	}
	limitweapon("kar98ksniper", axis_sniper, level.axis_sniper);

	// shotty gets treated a little differently
	limitShotgun(level.axis_shotty, level.allied_shotty, axis_shotty, allied_shotty);

}
dropsniper(weapon, team)
{
	hard_limit = 0;
	level.sniper_soft = 2;
	if (!issniper(weapon))
		return true;

	count = 0;
	no_weapon = 0;

	lplayers = getentarray("player", "classname");

	for(i = 0; i < lplayers.size; i++) {
		lplayer = lplayers[i];

		if (lplayer.pers["team"] == team)
		{
			if (team == "axis")
				hard_limit = level.axis_sniper;
			else hard_limit = level.allied_sniper;
			if(!isdefined(lplayer.pers["weapon"]))
				no_weapon++;
			else if (issniper(lplayer.pers["weapon"]))
				count++;
			else if (issniper(weapon))
				count++;
		}
	}
	if (count >= (level.sniper_soft + hard_limit))
		return false;
	else return true;
}
	
limitShotgun(axis_limit, allied_limit, axis_count, allied_count) {
	if (axis_count >= axis_limit)
		updateAllowedByTeam("axis", "shotgun", 0);
	else updateAllowedByTeam("axis", "shotgun", 1);

	if (allied_count >= allied_limit)
		updateAllowedByTeam("allies", "shotgun", 0);
	else updateAllowedByTeam("allies", "shotgun", 1);
}

updateAllowedByTeam(team, weapon, val) {
	players = getentarray("player", "classname");
	for(i = 0; i < players.size; i++) {
		if (players[i].pers["team"] == team)
			players[i] setClientCvar("ui_allow_" + weapon, val);
	}
}

limitweapon(weapon, count, limit) {
	if (count < limit) {
		if (getcvarint("scr_allow_" + weapon) != 1)
			setcvar("scr_allow_" + weapon, 1);
	}
	else {
		if (getcvarint("scr_allow_" + weapon) != 0)
			setcvar("scr_allow_" + weapon, 0);
	}
	maps\mp\gametypes\_weapons::updateallowed();
}

// some AWE here	
shownextmap() {
	for (;;) {
		maprotcur = strip(getcvar("sv_maprotationcurrent"));
		if(maprotcur == "")
			maprotcur = strip(getcvar("sv_maprotation"));
		if (maprotcur != "") {
			temparr = explode(maprotcur," ");
			if(temparr[0]=="gametype") {
				nextgt=temparr[1];
				nextmap=temparr[3];
			}
			else {
				nextgt=getcvar("g_gametype");
				nextmap=temparr[1];
			}
			durr = nextmap + " (" + nextgt + ")";
			iprintln(&"AX_NEXTMAP", localizedMap(nextmap), &"AX_NEXTMAP_SEP1", localizedGametype(nextgt), &"AX_NEXTMAP_SEP2");
		}
		wait level.nextmap_delay;
	}
}

localizedGametype(gt) {
	switch (gt) {
		case "tdm": return &"MPUI_TEAM_DEATHMATCH";
		case "dm": return &"MPUI_DEATHMATCH";
		case "ctf": return &"MPUI_CAPTURE_THE_FLAG";
		case "hq": return &"MPUI_HEADQUARTERS";
		case "sd": return &"MPUI_SEARCH_AND_DESTROY";
		case "rtdm": return "Rifles-Only TDM";
		case "lts": return "Last Team Standing";
	}
}
localizedMap(map) {
	switch (map) {
		case "mp_brecourt": return &"MENU_BRECOURT_FRANCE_MP";
		case "mp_burgundy": return &"MENU_BURGUNDY_FRANCE_MP";
		case "mp_trainstation": return &"MENU_CAEN_FRANCE_MP";
		case "mp_carentan": return &"MENU_CARENTAN_FRANCE_MP";
		case "mp_decoy": return &"MENU_EL_ALAMEIN_EGYPT_MP";
		case "mp_leningrad": return &"MENU_LENINGRAD_RUSSIA_MP";
		case "mp_matmata": return &"MENU_MATMATA_TUNISIA_MP";
		case "mp_downtown": return &"MENU_MOSCOW_RUSSIA_MP";
		case "mp_dawnville": return &"MENU_ST_MERE_EGLISE_FRANCE_MP";
		case "mp_railyard": return &"MENU_STALINGRAD_RUSSIA_MP";
		case "mp_toujane": return &"MENU_TOUJANE_TUNISIA_MP";
		case "mp_farmhouse": return &"MENU_BELTOT_FRANCE_MP";
		case "mp_breakout": return &"MENU_VILLERSBOCAGE_FRANCE_MP";
		case "mp_harbor": return &"AX_ROSTOV_RUSSIA_MP";
		case "mp_rhine": return &"AX_WALLENDER_GERMANY_MP";
		default: return map;
	}
}

miniscoreboard() {
	level endon("intermission");

	miniscore_seps();	// seperators
	miniscore_flags();	// team flags
	miniscore_teamscore();	// team score

	wait 0.5;

	while (1) {
		wait 0.5;

		if (!isdefined(game["kills_allies"]) || !isdefined(game["kills_axis"]))
			continue;
		if (!isdefined(game["deaths_allies"]) || !isdefined(game["deaths_axis"]))
			continue;

		level.kdhud_kills[0] setValue(game["kills_allies"]);
		level.kdhud_kills[1] setValue(game["kills_axis"]);
		level.kdhud_deaths[0] setValue(game["deaths_allies"]);
		level.kdhud_deaths[1] setValue(game["deaths_axis"]);
	}
}

miniscore_seps() {
	// setup the seperators
	sep_x = -24;
	sep_y = -208;
	//sep_x = 616;
	//sep_y = 32;

	level.kdhud_sep = [];
	level.kdhud_ratio = [];

	for (i = 0; i < 3; i++) {
		if (!isdefined(self.kdhud_sep[i])) {
			level.kdhud_sep[i] = newHudElem();
			level.kdhud_sep[i].archived = false;
			level.kdhud_sep[i].x = sep_x;
			level.kdhud_sep[i].y = sep_y;
			level.kdhud_sep[i].horzAlign = "right";
			level.kdhud_sep[i].vertAlign = "middle";
			level.kdhud_sep[i].alignX = "left";
			level.kdhud_sep[i].alignY = "top";
			level.kdhud_sep[i].fontScale = 0.6;
			level.kdhud_sep[i].sort = 1;
			level.kdhud_sep[i].color = (1, 1, 1);		
		}
		sep_y = sep_y + 10;
		level.kdhud_sep[i] setText(&"/");
	}
}
miniscore_flags() {
	if(!isdefined(level.kdhud_flag0))
	{
		level.kdhud_flag0 = newHudElem();
		level.kdhud_flag0.archived = false;
		level.kdhud_flag0.x = -54;
		level.kdhud_flag0.y = -201;
		level.kdhud_flag0.horzAlign = "right";
		level.kdhud_flag0.vertAlign = "middle";
		level.kdhud_flag0.alignX = "left";
		level.kdhud_flag0.alignY = "top";
		level.kdhud_flag0.sort = 1;
		level.kdhud_flag0.alpha = 1.5;
	}
	if(!isdefined(level.kdhud_flag1))
	{
		level.kdhud_flag1 = newHudElem();
		level.kdhud_flag1.archived = false;
		level.kdhud_flag1.x = -54;
		level.kdhud_flag1.y = -191;
		level.kdhud_flag1.horzAlign = "right";
		level.kdhud_flag1.vertAlign = "middle";
		level.kdhud_flag1.alignX = "left";
		level.kdhud_flag1.alignY = "top";
		level.kdhud_flag1.sort = 1;
		level.kdhud_flag1.alpha = 1.5;
	}
	level.kdhud_flag0 setShader(game["headicon_allies"], 12, 12);
	level.kdhud_flag1 setShader(game["headicon_axis"], 12, 12);

}
miniscore_teamscore() {
	// setup the column for kills
	sep_x = -27;
	sep_y = -200;
	level.kdhud_kills = [];

	for (i = 0; i < 2; i++) {
		if (!isdefined(level.kdhud_kills[i])) {
			level.kdhud_kills[i] = newHudElem();
			level.kdhud_kills[i].archived = false;
			level.kdhud_kills[i].x = sep_x;
			level.kdhud_kills[i].y = sep_y;
			level.kdhud_kills[i].horzAlign = "right";
			level.kdhud_kills[i].vertAlign = "middle";
			level.kdhud_kills[i].alignX = "right";
			level.kdhud_kills[i].alignY = "top";
			level.kdhud_kills[i].fontScale = 0.8;
			level.kdhud_kills[i].sort = 0.8;
			level.kdhud_kills[i].color = (1, 1, 1);		
		}
		sep_y = sep_y + 10;
	}

	// setup the column for deaths
	sep_x = -19;
	sep_y = -200;
	level.kdhud_deaths = [];

	for (i = 0; i < 3; i++) {
		if (!isdefined(level.kdhud_deaths[i])) {
			level.kdhud_deaths[i] = newHudElem();
			level.kdhud_deaths[i].archived = false;
			level.kdhud_deaths[i].x = sep_x;
			level.kdhud_deaths[i].y = sep_y;
			level.kdhud_deaths[i].horzAlign = "right";
			level.kdhud_deaths[i].vertAlign = "middle";
			level.kdhud_deaths[i].alignX = "left";
			level.kdhud_deaths[i].alignY = "top";
			level.kdhud_deaths[i].fontScale = 0.8;
			level.kdhud_deaths[i].sort = 0.8;
			level.kdhud_deaths[i].color = (1, 1, 1);		
		}
		sep_y = sep_y + 10;
	}
}
miniscore_myscore() {
	self endon("disconnect");
	level endon("intermission");
	if (!isdefined(self.kdhud_kills)) {
		self.kdhud_kills = newClientHudElem(self);
		self.kdhud_kills.archived = false;
		self.kdhud_kills.x = -27;
		self.kdhud_kills.y = -210;
		self.kdhud_kills.horzAlign = "right";
		self.kdhud_kills.vertAlign = "middle";
		self.kdhud_kills.alignX = "right";
		self.kdhud_kills.alignY = "top";
		self.kdhud_kills.fontScale = 0.8;
		self.kdhud_kills.sort = 0.8;
		self.kdhud_kills.color = (1, 1, 1);		
	}
	if (!isdefined(self.kdhud_deaths)) {
		self.kdhud_deaths = newClientHudElem(self);
		self.kdhud_deaths.archived = false;
		self.kdhud_deaths.x = -19;
		self.kdhud_deaths.y = -210;
		self.kdhud_deaths.horzAlign = "right";
		self.kdhud_deaths.vertAlign = "middle";
		self.kdhud_deaths.alignX = "left";
		self.kdhud_deaths.alignY = "top";
		self.kdhud_deaths.fontScale = 0.8;
		self.kdhud_deaths.sort = 0.8;
		self.kdhud_deaths.color = (1, 1, 1);		
	}
	if (level.gametype == "ctf") {
		if (!isdefined(self.kdhud_caps)) {
			self.kdhud_caps = newClientHudElem(self);
			self.kdhud_caps.archived = false;
			self.kdhud_caps.x = -45;
			self.kdhud_caps.y = -145;
			self.kdhud_caps.horzAlign = "right";
			self.kdhud_caps.vertAlign = "middle";
			self.kdhud_caps.alignX = "center";
			self.kdhud_caps.alignY = "middle";
			self.kdhud_caps.fontScale = 0.7;
			self.kdhud_caps.sort = 0.8;
			self.kdhud_caps.color = (1, 1, 1);
			self.kdhud_caps.alpha = 0.8;
			//self.kdhud_caps setText(&"Caps:");
			
		}
		if (!isdefined(self.kdhud_caps_count)) {
			self.kdhud_caps_count = newClientHudElem(self);
			self.kdhud_caps_count.archived = false;
			self.kdhud_caps_count.x = -24;
			self.kdhud_caps_count.y = -145;
			self.kdhud_caps_count.horzAlign = "right";
			self.kdhud_caps_count.vertAlign = "middle";
			self.kdhud_caps_count.alignX = "left";
			self.kdhud_caps_count.alignY = "middle";
			self.kdhud_caps_count.fontScale = 0.8;
			self.kdhud_caps_count.sort = 0.8;
			self.kdhud_caps_count.color = (1, 1, 1);
		}
	}
	if (level.show_headshots) {
		if (!isdefined(self.hud_headshot)) {
			self.hud_headshot = newClientHudElem(self);
			self.hud_headshot.archived = false;
			self.hud_headshot.x = -45;
			self.hud_headshot.y = -160;
			self.hud_headshot.horzAlign = "right";
			self.hud_headshot.vertAlign = "middle";
			self.hud_headshot.alignX = "center";
			self.hud_headshot.alignY = "middle";
			self.hud_headshot.fontScale = 0.7;
			self.hud_headshot.sort = 0.8;
			self.hud_headshot.color = (1, 1, 1);
			self.hud_headshot.alpha = 0.6;
			self.hud_headshot setShader("killiconheadshot", 11, 11);
		}
		if (!isdefined(self.hud_headshot_count)) {
			self.hud_headshot_count = newClientHudElem(self);
			self.hud_headshot_count.archived = false;
			self.hud_headshot_count.x = -24;
			self.hud_headshot_count.y = -160;
			self.hud_headshot_count.horzAlign = "right";
			self.hud_headshot_count.vertAlign = "middle";
			self.hud_headshot_count.alignX = "left";
			self.hud_headshot_count.alignY = "middle";
			self.hud_headshot_count.fontScale = 0.8;
			self.hud_headshot_count.sort = 0.8;
			self.hud_headshot_count.color = (1, 1, 1);
		}
	}

	wait 0.5;

	while (1) {
		wait 0.5;

		if (!isdefined(self))
			return;

		if (!isdefined(self.pers["kills"]) || !isdefined(self.deaths) || !isdefined(self.pers["flag_caps"]))
			continue;

		self.kdhud_kills setValue(self.pers["kills"]);
		self.kdhud_deaths setValue(self.deaths);
		if (level.gametype == "ctf")
		{
			self.kdhud_caps_count setValue(self.pers["flag_caps"]);
			if (!isdefined(self.pers["team"]))
				continue;
			switch(self.pers["team"])
			{
				case "allies":
						icon = "compass_flag_" + game["axis"];
						break;
				case "axis":
						icon = "compass_flag_" + game["allies"];
						break;
					default:
						icon = "gfx/hud/death_suicide.tga";
			}
			self.kdhud_caps setShader(icon, 14, 14);
		}
		if (level.show_headshots)
			self.hud_headshot_count setValue(self.pers["headshots"]);
	}

}


/**********************
    ADMIN FUNCTIONS
**********************/

isadmin(player) {
	guid = player getGuid();
	switch(guid) {
		//case 0:
		case 108775: // gitman
		case 102468: // boog
		case 107485: // logik
		case 131185: // bella
		case 133966: // sterling
		case 186783: // maiden
		case 146474: // the plague
		case 100854: // ganoush
		case 100562: // clint
		case 105447: // powerforward
		case 138948: // iceman
		case 158132: // krovotnokov
		case 289962: // fullwood
		case 202622: // fishy
		case 126027: // drugcop
		case 105347: // cornrow
		case 186127: // ransom
		case 521239: // ted
		case 104021: // c-knight
		case 103369: // bnuts
		case 722070: // hope
		case 185896: // geo
		case 191744: // odd sage
		case 172024: // rollin
		case 122658: // rup
		case 241669: // till
		case 104995: // mancini
		case 1274652: // ct
		case 784264: // grim
		// chev
		//
			return true;
		default:
			return false;
	}
}

wallOps()
{
	self endon("boot");
	setcvar ("wallop", "");
	while(1) {
		msg = getcvar("wallop");
		if (msg != "") {
			players = getentarray("player", "classname");
			for(i = 0; i < players.size; i++)
			{
				player = players[i];
				if (isadmin(player))
					clientAnnouncement(player, "^1admin^7CHAT: " + msg);
			}
			setcvar("wallop", "");
		}
		wait 1;
	}
}

////////////////////////////////////////////////////////////////
/// following functions courtesy of raviradmin.gsc
////////////////////////////////////////////////////////////////
switchteam()
{
	self endon("boot");
	setcvar("g_switchteam", "");
	newTeam = "";
	while(1)
	{
		if(getcvar("g_switchteam") != "")
		{
			if(getcvar("g_alliestag") != "" || getcvar("g_axistag") != "")
			{
				temptag = getcvar("g_alliestag");
				setcvar("g_alliestag", getcvar("g_axistag"));
				setcvar("g_axistag", temptag);
			}

			movePlayerNum = getcvarint("g_switchteam");
			players = getentarray("player", "classname");
			for(i = 0; i < players.size; i++)
			{
				thisPlayerNum = players[i] getEntityNumber();
				if(thisPlayerNum == movePlayerNum || movePlayerNum == -1) // this is the one we're looking for
				{

					if(players[i].pers["team"] == "axis")
						newTeam = "allies";
					if(players[i].pers["team"] == "allies")
						newTeam = "axis";

					players[i] suicide();

					if (isdefined(players[i].pers["score"]) && isdefined(players[i].pers["deaths"])) {
						players[i].pers["score"]++;
						players[i].pers["deaths"]--;
						players[i].score = players[i].pers["score"];
						players[i].deaths = players[i].pers["deaths"];
					}

					else {
						players[i].score++;
						players[i].deaths--;
					}

					players[i].pers["team"] = newTeam;
					players[i].pers["weapon"] = undefined;
					players[i].pers["weapon1"] = undefined;
					players[i].pers["weapon2"] = undefined;
					players[i].pers["spawnweapon"] = undefined;
					players[i].pers["savedmodel"] = undefined;

					players[i] setClientCvar("scr_showweapontab", "1");

					if(players[i].pers["team"] == "allies")
					{
						players[i] setClientCvar("g_scriptMainMenu", game["menu_weapon_allies"]);
						players[i] openMenu(game["menu_weapon_allies"]);
					}
					else
					{
						players[i] setClientCvar("g_scriptMainMenu", game["menu_weapon_axis"]);
						players[i] openMenu(game["menu_weapon_axis"]);
					}
					if(movePlayerNum != -1)
						iprintln(players[i].name + "^7 was forced to switch teams by the admin");
				}
			}
			if(movePlayerNum == -1)
				iprintln("The admin forced all players to switch teams.");

			setcvar("g_switchteam", "");
		}
		wait 0.05;
	}
}



killum()
{
	self endon("boot");

	setcvar("g_killum", "");
	while(1)
	{
		if(getcvar("g_killum") != "")
		{
			killPlayerNum = getcvarint("g_killum");
			players = getentarray("player", "classname");
			for(i = 0; i < players.size; i++)
			{
				thisPlayerNum = players[i] getEntityNumber();
				if(thisPlayerNum == killPlayerNum) // this is the one we're looking for
				{
					players[i] suicide();
					iprintln(players[i].name + "^7 was killed by the admin");
				}
			}
			setcvar("g_killum", "");
		}
		wait 0.05;
	}
}
smiteplayer() // make a player explode, will hurt people up to 15 feet away
{
	self endon("boot");

	setcvar("g_smite", "");
	while(1)
	{
		if(getcvar("g_smite") != "")
		{
			smitePlayerNum = getcvarint("g_smite");
			players = getentarray("player", "classname");
			for(i = 0; i < players.size; i++)
			{
				thisPlayerNum = players[i] getEntityNumber();
				if(thisPlayerNum == smitePlayerNum && players[i].sessionstate == "playing") // this is the one we're looking for
				{
					// explode 
					range = 180;
					maxdamage = 150;
					mindamage = 10;

					//playfx(level._effect["bombsmite"], players[i].origin);
					playfx(level._effect["bombfire"], players[i].origin);
					wait 0.05;
					players[i] playsound("flak88_explode");
					radiusDamage(players[i].origin + (0,0,12), range, maxdamage, mindamage);
					iprintln("Lo, the admin smote " + players[i].name + " with fire!");
				}
			}
			setcvar("g_smite", "");
		}
		wait 0.05;
	}
}
// the following are based on ravir's stuff but with my own twist
forcename() {
	self endon("boot");
	setcvar ("g_forcename", "");
	while(1) {
		if (getcvar("g_forcename") != "") {
			ar = explode(getcvar("g_forcename"), ",");
			num = int(ar[0]);
			name = ar[1];
			players = getentarray("player", "classname");
			if (isdefined(num) && isdefined(name))
			for(i = 0; i < players.size; i++)
			{
				this = players[i] getEntityNumber();
				if (this == num)
					players[i] setclientcvar("name", name);
			}
			setcvar("g_forcename", "");
		}
		wait 0.05;
	}
}
freezeum() {
	self endon("boot");

	setcvar("g_freeze", "");
	while(1)
	{
		if(getcvar("g_freeze") != "")
		{
			num = getcvarint("g_freeze");
			players = getentarray("player", "classname");
			for(i = 0; i < players.size; i++)
			{
				this = players[i] getEntityNumber();
				if(this == num && players[i].sessionstate == "playing") // this is the one we're looking for
				{
					level.stuck[players[i].name] = spawn ("script_model",(0,0,0));
					level.stuck[players[i].name].origin = players[i].origin;
					level.stuck[players[i].name].angles = players[i].angles;
					players[i] linkto (level.stuck[players[i].name]);
					players[i] disableweapon();
					iprintln("Lo, the admin froze " + players[i].name + "^7! Free kill!");
				}
			}
			setcvar("g_freeze", "");
		}
		wait 0.05;
	}
}
unfreezeum() {
	self endon("boot");

	setcvar("g_unfreeze", "");
	while(1)
	{
		if(getcvar("g_unfreeze") != "")
		{
			num = getcvarint("g_unfreeze");
			players = getentarray("player", "classname");
			for(i = 0; i < players.size; i++)
			{
				this = players[i] getEntityNumber();
				if(this == num && players[i].sessionstate == "playing") // this is the one we're looking for
				{
					if (isdefined(level.stuck[players[i].name])) {
						players[i] unlink();
						level.stuck[players[i].name] delete();
						players[i] enableweapon();
					}
				}
			}
			setcvar("g_unfreeze", "");
		}
		wait 0.05;
	}
}
kicktospec() {
	self endon("boot");

	setcvar("g_kicktospec", "");
	while(1)
	{
		if(getcvar("g_kicktospec") != "")
		{
			num = getcvarint("g_kicktospec");
			players = getentarray("player", "classname");
			for(i = 0; i < players.size; i++)
			{
				this = players[i] getEntityNumber();
				if(this == num && players[i].sessionstate == "playing") // this is the one we're looking for
				{
					if(isAlive(players[i]))
					{
						players[i].switching_teams = true;
						players[i].joining_team = "spectator";
						players[i].leaving_team = players[i].pers["team"];
						players[i] suicide();
					}
	
					players[i].pers["team"] = "spectator";
					players[i].pers["weapon"] = undefined;
					players[i].pers["savedmodel"] = undefined;

					players[i].sessionteam = "spectator";
					players[i] setClientCvar("ui_allow_weaponchange", "0");

					players[i].sessionstate = "spectator";
					players[i].spectatorclient = -1;
					players[i].archivetime = 0;
					players[i].psoffsettime = 0;
					players[i].friendlydamage = undefined;

					if(players[i].pers["team"] == "spectator")
						players[i].statusicon = "";

					maps\mp\gametypes\_spectating::setSpectatePermissions();

					spawnpointname = "mp_global_intermission";
					spawnpoints = getentarray(spawnpointname, "classname");
					spawnpoint = maps\mp\gametypes\_spawnlogic::getSpawnpoint_Random(spawnpoints);

					if(isDefined(spawnpoint))
						players[i] spawn(spawnpoint.origin, spawnpoint.angles);
					else
						maps\mp\_utility::error("NO " + spawnpointname + " SPAWNPOINTS IN MAP");
				}
			}
			setcvar("g_kicktospec", "");
		}
		wait 0.05;
	}
}

kickspecs() {
	self endon("boot");

	setcvar("g_kickspecs", "");
	while(1)
	{
		if(getcvar("g_kickspecs") != "")
		{
			delay = getCvarInt("g_kickspecs");
			if (delay < 10)
				delay = 10;

			private_slots = getCvarInt("sv_privateClients");
			if (private_slots != 0) {
				public_first = private_slots;
				private_slots = private_slots - 1;
			}
			else public_first = 0;
			/*
			public_last = getCvarInt("sv_maxclients") - 1;
			for(i = public_first; i<public_last; i++) {
				if (!isdefined ( getentbynum(i) ))
					continue;
			}
			*/

			// need to check if server is full.. 

			players = getentarray("player", "classname");
			for(i = 0; i < players.size; i++)
			{
				player = players[i];
				this = player getEntityNumber();
				if(player.pers["team"] == "spectator")
				{
					if ((private_slots > 0 && this > private_slots) || (private_slots == 0))
						thread delayed_kick(player, "kick_specs", "spectating in " + delay + " seconds!", true);
				}
			}
			setcvar("g_kickspecs", "");
			wait delay;
			level notify("kick_specs");
		}
		wait 0.05;
	}
}
delayed_kick(player, event, reason, spec)
{
	self endon("disconnect");
	clientAnnouncement(player, "^1Attention!^7 You will be kicked for " + reason);
	level waittill(event);
	if (spec) {
		if (player.pers["team"] != "spectator")
			return;
	}
	kick(player getEntityNumber());
}
muteplayer()
{
	setcvar("g_mute", "");
	for (;;)
	{
		wait 0.2;
		if (getcvar("g_mute") == "")
			continue;

		num = getcvarint("g_mute");
		if (num >= 0)
		{
			players = getentarray("player", "classname");
			for(i = 0; i < players.size; i++)
			{
				this = players[i] getEntityNumber();
				if(this == num && !players[i].muted) // this is the one we're looking for
				{
					players[i] setClientCvar("cl_voice", 0);
					players[i].muted = true;
					players[i] thread infimute();
					iprintln("Lo, the ^3admin^7 has muted " + players[i].name + "^7!");
				}
			}
			
		}
		setcvar("g_mute", "");
	}
}
infimute()
{
	self endon("stop_mute");
	self endon("disconnect");
	for (;;)
	{
		wait 1;
		self setClientCvar("cl_voice", 0);
	}
}
unmuteplayer()
{
	setcvar("g_unmute", "");
	for (;;)
	{
		wait 0.2;
		if (getcvar("g_unmute") == "")
			continue;

		num = getcvarint("g_unmute");

		if (num >= 0)
		{
			players = getentarray("player", "classname");
		
			for(i = 0; i < players.size; i++)
			{
				this = players[i] getEntityNumber();
				if(this == num && players[i].muted) // this is the one we're looking for
				{
					players[i] setClientCvar("cl_voice", 1);
					players[i].muted = false;
					players[i] notify ("stop_mute");
					iprintln("Lo, the ^3admin^7 has unmuted " + players[i].name + "^7! Say hello!");
					
				}
			}
		}
		setcvar("g_unmute", "");
	}
}

// Following code courtesy of AWE by bell
//
// Strip blanks at start and end of string
strip(s)
{
	if(s=="")
		return "";

	s2="";
	s3="";

	i=0;
	while(i<s.size && s[i]==" ")
		i++;

	// String is just blanks?
	if(i==s.size)
		return "";
	
	for(;i<s.size;i++)
	{
		s2 += s[i];
	}

	i=s2.size-1;
	while(s2[i]==" " && i>0)
		i--;

	for(j=0;j<=i;j++)
	{
		s3 += s2[j];
	}
		
	return s3;
}
explode(s,delimiter)
{
	j=0;
	temparr[j] = "";	

	for(i=0;i<s.size;i++)
	{
		if(s[i]==delimiter)
		{
			j++;
			temparr[j] = "";
		}
		else
			temparr[j] += s[i];
	}
	return temparr;
}
getMapName(map)
{
	if (!isdefined(map))
		return;

	switch(map)
	{
		case "mp_farmhouse":
			return "Beltot, France";
		case "mp_brecourt":
			return "Brecourt, France";
		case "mp_burgundy":
			return "Burgundy, France";
		case "mp_trainstation":
			return "Caen, France";
		case "mp_carentan":
			return "Carentan, France";
		case "mp_decoy":
			return "El Alamein, Egypt";
		case "mp_leningrad":
			return "Leningrad, Russia";
		case "mp_matmata":
			return "Matmata, Tunisia";
		case "mp_downtown":
			return "Moscow, Russia";
		case "mp_dawnville":
			return "St. Mere Eglise, France";
		case "mp_railyard":
			return "Stalingrad, Russia";
		case "mp_toujane":
			return "Toujane, Tunisia";
		case "mp_breakout":
			return "Villers-Bocage, France";
		case "mp_rhine":
			return "Wallendar, Germany";
		case "mp_harbor":
			return "Rostov, Russia";
		case "mp_borisovka":
			return "Borisovka, Russia";
		case "mp_bridge":
			return "The Bridge";
		case "mp_depot":
			return "Depot, Germany";
		case "mp_flakbatterie_v1_0":
		case "mp_flakbatterie":
			return "Flakbatterie, Germany";
		case "mp_heat_final":
			return "Heat, Normandy";
		case "mp_sabes_du_mot_beta":
			return "Sabes Du Mot, France";
		case "mp_buhlert":
			return "Buhlert, Germany";
		case "mp_siegfriedline":
			return "Westwall, Germany";
		case "mp_st-gatien":
			return "St-Gatien, France";
		case "mp_simmerath_beta2":
			return "Simmerath, Germany";
		case "mp_tobruk":
			return "Tobruk, Libya";
		case "mp_docks":
			return "Murmansk [BetaV2]";
		case "mp_farm_assault_beta2":
			return "Farm Assault beta2";
		case "mp_chelm":
			return "Chelm, Poland (Beta 1)";
		case "mp_d-day+7.2":
			return "D-day+7.2 Final";
		case "mp_neuville":
			return "Neuville, France";
		case "mp_townville":
			return "Townville";
		case "mp_cassino":
			return "Cassino, Italy";
		case "mp_commando":
			return "Commando";
		case "mp_salerno_beachhead_b":
		case "mp_salerno_beachhead":
			return "Salerno Beachhead Beta, Italy";
				
		default:
			return map;
	}
}
cvardef(varname, vardefault, min, max, type)
{
	mapname = getcvar("mapname");  // "mp_dawnville", "mp_rocket", etc.

	if(getcvar(varname) == "") // if the cvar is blank
		setcvar(varname, vardefault); // set the default

	mapvar = varname + "_" + mapname; // i.e., scr_teambalance becomes scr_teambalance_mp_dawnville
	if(getcvar(mapvar) != "") // if the map override is being used
		varname = mapvar; // use the map override instead of the standard variable

	// get the variable's definition
	switch(type)
	{
		case "int":
			definition = getcvarint(varname);
			break;
		case "float":
			definition = getcvarfloat(varname);
			break;
		case "string":
		default:
			definition = getcvar(varname);
			break;
	}

	// if it's a number, with a minimum, that violates the parameter
	if((type == "int" || type == "float") && !isdefined(min) && definition < min)
		definition = min;

	// if it's a number, with a maximum, that violates the parameter
	if((type == "int" || type == "float") && !isdefined(max) && definition > max)
		definition = max;

	return definition;
}
GetStance(checkjump) 
{ 
	if( checkjump && !self isOnGround() ) 
		return "jump"; 
	
	if(isdefined(self.awe_spinemarker)) 
	{ 
		distance = self.awe_spinemarker.origin[2] - self.origin[2]; 
		if(distance<18) 
			return "prone"; 
		else if(distance<43) 
			return "crouch"; 
		else 
			return "stand"; 
	} 
	else 
	{ 
		return 0; 
	} 
}
