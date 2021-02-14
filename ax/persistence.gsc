#include ax\utility;

init()
{
	level thread onPlayerConnect();
}

onPlayerConnect()
{
	for(;;)
	{
		level waittill("connected", player);

		guid = player getGuid();
		if (isdefined(game["matchstarted"]) && game["matchstarted"]) {
			if (isdefined(level.lostplayer) && isdefined(level.lostplayer[guid]))
			{
				player.pers["kills"]		= level.lostplayer[guid].kills;
				player.score			= level.lostplayer[guid].score;
				player.deaths			= level.lostplayer[guid].deaths;
				player.pers["team"]		= level.lostplayer[guid].team;
				player.pers["headshots"]	= level.lostplayer[guid].headshots;
				player.pers["melees"]		= level.lostplayer[guid].melees;
				player.pers["flag_caps"]	= level.lostplayer[guid].flag_caps;
				player.team_kills		= level.lostplayer[guid].team_kills;
				player.muted			= level.lostplayer[guid].muted;
				player.cannot_play		= level.lostplayer[guid].cannot_play;
				if (isdefined(level.lostplayer[guid].weapon))
					player.pers["weapon"] 	= level.lostplayer[guid].weapon;
				player.onjoin_welcome_back = true;
                	}
        	}
		player thread onPlayerDisconnect();
	}
}

onPlayerDisconnect()
{
	self waittill("disconnect");
	rememberinfo(self);
}

rememberinfo(player)
{
	if (isdefined(game["matchstarted"]) && !game["matchstarted"])
		return;

	if (!isdefined(player.pers["team"]) || !isdefined(player.deaths) || !isdefined(player.score) || !isdefined(player.pers["kills"]))
		return;

	if (!isdefined(level.lostplayer))
		level.lostplayer = [];

	guid = player getGuid();

	if (isdefined(level.lostplayer[guid]))
		level.lostplayer[guid] = undefined;

	level.lostplayer[guid] 				= spawnstruct();
	level.lostplayer[guid].score 			= player.score;
	level.lostplayer[guid].deaths			= player.deaths;
	level.lostplayer[guid].team			= player.pers["team"];
	level.lostplayer[guid].kills 			= player.pers["kills"];
	level.lostplayer[guid].headshots	 	= player.pers["headshots"];
	level.lostplayer[guid].melees 			= player.pers["melees"];

	if ( level.gametype == "ctf" )
		level.lostplayer[guid].flag_caps	= player.pers["flag_caps"];

	if ( isdefined(player.pers["weapon"]) )
		level.lostplayer[guid].weapon 		= player.pers["weapon"];

	level.lostplayer[guid].team_kills 		= player.team_kills;
	level.lostplayer[guid].team_kill_suicides	= player.team_kill_suicides;
	level.lostplayer[guid].team_damage 		= player.team_damage;
	level.lostplayer[guid].muted 			= player.muted;
	level.lostplayer[guid].cannot_play 		= player.cannot_play;

	level thread expireOverTime( level.lostplayer, guid, level.ax_scoresave_expire );
}
