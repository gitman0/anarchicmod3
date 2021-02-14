#include anarchicmod\admin;
#include anarchicmod\hud;
#include anarchicmod\utility;
#include anarchicmod\weapons;

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
	level.teamkill_tier1		= cvardef("scr_teamkill_tier1", 5, 0, 999, "int");
	level.teamkill_tier2		= cvardef("scr_teamkill_tier2", 10, (level.teamkill_tier1+1), 999, "int");
	level.teamkill_tier3		= cvardef("scr_teamkill_tier3", 300, 0, 999, "int");

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
	level.idle_limit		= cvardef("scr_idle_limit", 0, 0, 3600, "int");
	level.idle_warn_count		= cvardef("scr_idle_warn", 2, 0, 720, "int");

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
	anarchicmod\mapvote::init();

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

	self thread oldHeadIcons();
	self thread oldObjPoints();
	self thread forceSayPos();

	if ((level.show_kdhud) && (level.gametype != "cnq"))
		self thread miniscore_myscore();

	if (!isdefined(self.teamkills))
		self.teamkills = 0;
	self.teamkill_tier = 0;
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
	level.lostplayer[guid].muted = player.muted;
	level.lostplayer[guid].cannot_player = player.cannot_play;

	level thread timedundefined(guid, 600);
}

timedundefined(idx, time)
{
        wait time;
        level.lostplayer[idx] = undefined;
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

	if (getcvarint("g_debugdamage"))
	{
		attacker iprintln("sMeansOfDeath: " + sMeansOfDeath);
		attacker iprintln("sHitLoc: " + sHitLoc);
		attacker iprintln("sWeapon: " + sWeapon);
	}
	if ((!isplayer(attacker)) || (!isdefined(attacker.pers["kills"])))
		return;

	if ( (isdefined(game["matchstarted"]) && game["matchstarted"]) || !isdefined(game["matchstarted"]) )
	{
		if (isPlayer(attacker)) {
			if (attacker == self) {
				if (!isdefined (self.autobalance))
					attacker.pers["kills"]--;
			}
			else {
				if (self.pers["team"] == attacker.pers["team"]) // killed by a friendly
					attacker.pers["kills"]--;
				else {
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
	
		if (isdefined(self.pers["team"]) && (self.pers["team"] != "spectator") && (isdefined(game["deaths_allies"])) && (isdefined(game["deaths_axis"]))) {
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
	if(level.friendlyfire == "0")
	{
		return;
	}
	else if(level.friendlyfire == "1")
	{
		// Make sure at least one point of damage is done
		if(iDamage < 1)
			iDamage = 1;

		self finishPlayerDamage(eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, psOffsetTime);

		// Shellshock/Rumble
		self thread maps\mp\gametypes\_shellshock::shellshockOnDamage(sMeansOfDeath, iDamage);
		self playrumble("damage_heavy");
	}
	else if(level.friendlyfire == "2")
	{
		eAttacker.friendlydamage = true;

		iDamage = int(iDamage * .5);

		// Make sure at least one point of damage is done
		if(iDamage < 1)
			iDamage = 1;

		eAttacker finishPlayerDamage(eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, psOffsetTime);
		eAttacker.friendlydamage = undefined;

		friendly = true;
	}
	else if(level.friendlyfire == "3")
	{
		if (sMeansOfDeath == "MOD_MELEE" && game["matchstarted"])
		{
			self finishPlayerDamage(eInflictor, eAttacker, 0, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, psOffsetTime);
			eAttacker finishPlayerDamage(eInflictor, eAttacker, 0, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, psOffsetTime);
			return;
		}

		/*if (!isdefined(eattacker.teammate_damage))
			eattacker.teammate_damage = [];

		id = self getguid();
		if (!isdefined(eattacker.teammate_damage[id]))
			eattacker.teammate_damage[id] = 0;

		level.td_max = 225;

		eattacker.teammate_damage[id] += idamage;

		eattacker iprintln(eattacker.teammate_damage[id] + " damage accumulated for client " + id);
		eattacker thread td_timedzero(id, 240);*/

		eAttacker.friendlydamage = true;

		eAttacker getTeamkillTier();
		/*if (eattacker.teamkill_tier != 3)
		{
			if (eattacker.teammate_damage[id] > level.td_max)
				eattacker.teamkill_tier = 4;
		}*/
		attacker_damage = 0.0;
		victim_damage = 0.0;

		switch (eAttacker.teamkill_tier) {
			case 0:	// default shared
				attacker_damage = int(iDamage * .5);
				victim_damage = attacker_damage;
				break;
			case 1:	// weighted shared
				attacker_damage = int(iDamage * .65);
				victim_damage = int(iDamage * .35);
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
			/*case 4: // player-specific handling
				attacker_damage = iDamage;
				victim_damage = undefined;
				eAttacker.team_damage += iDamage;
				break;*/
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

		friendly = true;

		// Shellshock/Rumble
		//self thread maps\mp\gametypes\_shellshock::shellshockOnDamage(sMeansOfDeath, iDamage);
		//self playrumble("damage_heavy");
	}

}
td_timedzero(guid, time)
{
	wait time;
	self.teammate_damage[guid] = 0;
}	
getdamage(iDamage, sMeansOfDeath, eAttacker, sWeapon)
{
	mod_nade	= 0.15;
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
		if (eAttacker.hopping && !isturret(sWeapon) && (sMeansOfDeath == "MOD_RIFLE_BULLET" || sMeansOfDeath == "MOD_PISTOL_BULLET"))
		{
			old_damage = iDamage;
			iDamage = iDamage * mod_hop;
			eattacker.pers["hop_denial"] += old_damage - idamage;
		}
	return int(iDamage);
}

getTeamkillTier() {
	if (self.teamkills < level.teamkill_tier1)
		self.teamkill_tier = 0;
	else if ((self.teamkills >= level.teamkill_tier1) && (self.teamkills < level.teamkill_tier2))
		self.teamkill_tier = 1;
	else if ((self.teamkills >= level.teamkill_tier2) && (self.team_damage < level.teamkill_tier3))
		self.teamkill_tier = 2;
	else  self.teamkill_tier = 3;
	return;
}

playerTimeout(time)
{
	level endon("intermission");
	self endon("killed_player");
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

spawnSpectator(origin, angles)
{
	checkSnipers();
}

spawnPlayer() {
	checkSnipers();

	if ( (isdefined(game["matchstarted"]) && game["matchstarted"]) || !isdefined(game["matchstarted"]) )
	{
		if (!isdefined(self.pers["seen_onjoin"]))
			self.pers["seen_onjoin"] = false;
		if (!isdefined(self.onjoin_welcome_back))
			self.onjoin_welcome_back = false;

		if (!self.pers["seen_onjoin"]) {
			if (!self.onjoin_welcome_back)
			{
				clientAnnouncement(self, "Welcome " + nocolors(self.name) + "^7!");
				clientAnnouncement(self, " ");
				clientAnnouncement(self, &"AX_MOTD_DEFAULT");
				clientAnnouncement(self, "Remember, friendly fire is ^1ON^7, don't shoot your teammates!");
			}
			else {
				clientAnnouncement(self, "Welcome back " + nocolors(self.name) + "^7!");
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

	self thread check_ax();

	if (level.antiflop)
		self thread start_antiflop();
	self thread spawn_assist();

	self thread make_crosshair();
	if (level.gametype == "ctf")
		self thread maps\mp\gametypes\_spectating::setSpectatePermissions();

	self thread idleWatchDog();
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

	if ((level.ctf_sudden_death) && (level.gametype == "ctf"))
	{
		players = maps\mp\gametypes\_teams::CountPlayers();
		if (players["allies"] > 1 && players["axis"] > 1)
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
				level.clock.color = (1, 0, 0);
				level.clock setTimerUp(0);
				if (score_diff == 0)
				{
					// disable respawns
					level.ctf_sudden_death_norespawn = true;
					return;
				}
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
		anarchicmod\mapvote::Initialise();
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



/* spawn assist
	06/01/08; added cancellation of spawn assist if player discharges their weapon
*/		

spawn_assist()
{
	self endon("killed_player");
	self endon("player_fired");
	if (level.spawn_assist <= 0)
		return;

	self.spawn_assist = true;
	self spawn_assist_hud();
	self thread spawn_assist_discharge();
	wait level.spawn_assist;
	self spawn_assist_cleanup();
}

spawn_assist_discharge()
{
	self endon("disconnect");
	i=0.0;
	fired=0;
	while (i < level.spawn_assist)
	{
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
		self spawn_assist_cleanup();
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
oldHeadIcons() {
	self endon("disconnect");
	for (;;)
	{
		self setClientCvar("cg_headiconminscreenradius", 0.003);
		wait 10;
	}
}
oldObjPoints() {
	self endon("disconnect");
	for (;;)
	{
		self setClientCvar("cg_hudObjectiveMaxRange", 10000);
		wait 10;
	}
}
forceSayPos() {
	self endon("disconnect");
	for (;;)
	{
		self setClientCvar("cg_hudchatposition", "5 85");
		wait 10;
	}
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


