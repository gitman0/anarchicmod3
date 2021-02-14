#include ax\utility;

init()
{
	if(!isDefined(game["gamestarted"]))
	{
		if (level.gametype == "ctf")
		{
			level.flag_carrier_icon = "objective";
			precacheShader(level.flag_carrier_icon);
		}
	}

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
	}
}

onPlayerSpawned()
{
	self endon("disconnect");

	for(;;)
	{
		self waittill("spawned_player");
		self.obj_id = undefined;
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

	if ( level.sudden_death_status && level.sudden_death_timelimit > 0 )
	{
		sudden_death_timepassed = (getTime() - level.sudden_death_starttime) / 1000;
		sudden_death_timepassed = sudden_death_timepassed / 60.0;

		if ( sudden_death_timepassed >= level.sudden_death_timelimit )
		{
			timeLimitReached();
			return;
		}
	}

	if ( suddenDeathSupported() && level.sudden_death_timelimit > -1 ) 
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
	timeLimitReached();
}

timeLimitReached()
{
	level.mapended = true;
	iprintln(&"MP_TIME_LIMIT_REACHED");
	level thread [[level.endGameConfirmed]]();
}

suddenDeathSupported()
{
	switch (level.gametype)
	{
		case "ctf":	return true;
		default:	return false;
	}
}

spawnpointName()
{
        timepassed = (getTime() - getStartTime()) / 1000;
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
