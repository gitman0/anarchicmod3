/* $Id: spawn.gsc 99 2011-01-23 07:24:56Z  $ */

#include ax\utility;

init()
{
	if ( level.spawn_assist > 0 && !gameStarted() )
		precacheString(&"AX_SPAWN_ASSIST");

	if (isdefined(level.gametype) && level.gametype == "ctf")
	{
		spawnpoints_allied = getentarray("mp_ctf_spawn_allied", "classname");
		spawnpoints_axis   = getentarray("mp_ctf_spawn_axis", "classname");

		allied_flag = getent("allied_flag", "targetname");
		axis_flag = getent("axis_flag", "targetname");

		level.spawnpoint_forward["axis"] = getClosest( allied_flag.origin, spawnpoints_axis );
		level.spawnpoint_forward["allies"] = getClosest( axis_flag.origin, spawnpoints_allied );

		level.spawnpoint_rear["axis"] = getClosest( axis_flag.origin, spawnpoints_axis );
		level.spawnpoint_rear["allies"] = getClosest( allied_flag.origin, spawnpoints_allied );
	}

	level thread onPlayerConnect();
	level thread showspawns();
}

onPlayerConnect()
{
	for(;;)
	{
		level waittill("connected", player);
		player.spawn_assist = false;
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
		self thread logSpawn();
		self thread spawn_assist();
	}
}

onPlayerKilled()
{
	self endon("disconnect");

	for(;;)
	{
		self waittill("killed_player");
		self thread logSpawn();
		self spawn_assist_hud_destroy();
	}
}

spawn_assist()
{
	self endon("disconnect");
	self endon("killed_player");
	self endon("player_fired");
	if ( level.spawn_assist <= 0 )
		return;

	self.spawn_assist = true;
	self spawn_assist_hud();
	//self ax\weapons::takeFrags();

	self thread spawn_assist_discharge();
	wait level.spawn_assist;
	self.spawn_assist_time = gettime();
	self spawn_assist_cleanup();
	//self ax\weapons::giveFrags();
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
		//self ax\weapons::giveFrags();
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
	if ( isdefined(self.spawn_assist_display_title) )
		self.spawn_assist_display_title destroy();
	if ( isdefined(self.spawn_assist_display_sec) )
		self.spawn_assist_display_sec destroy();
}

// this is a work-in-progress... it records positional stats for every spawn event
// this data may be used in the future to optimize the spawnlogic
logSpawn()
{
	if ( !level.ax_spawn_stats )
		return;

	if ( !isdefined( game["matchstarted"] ) || !game["matchstarted"] )
		return;

	if ( self.pers["team"] != "allies" && self.pers["team"] != "axis" )
		return;

	waittillframeend;

	enemy_team = otherTeam( self.pers["team"] );

	teammates = [];
	inclusiveTeammates = getPlayersByTeam( self.pers["team"] );
	for ( i = 0; i < inclusiveTeammates.size; i++ )
		if ( inclusiveTeammates[i] != self )
			teammates[teammates.size] = inclusiveTeammates[i];

	enemies = getPlayersByTeam( enemy_team );

	if ( teammates.size > 0 )
	{
		closest_teammate = getClosest( self.origin, teammates );
		dist_closest_teammate = distance( self.origin, closest_teammate.origin );
	}
	else dist_closest_teammate = 0;

	if ( enemies.size > 0 )
	{
		closest_enemy = getClosest( self.origin, enemies );
		dist_closest_enemy = distance( self.origin, closest_enemy.origin );
	}
	else dist_closest_enemy = 0;

	enemy_flag =  getEnemyFlag( self.pers["team"] );
	dist_enemy_flag = distance( self.origin, enemy_flag.origin );

	dist_spawnpoint_forward = distance( self.origin, level.spawnpoint_forward[self.pers["team"]].origin );
	dist_spawnpoint_rear = distance( self.origin, level.spawnpoint_rear[self.pers["team"]].origin );

	if ( flagAtHome(otherTeam(self.pers["team"])) )
		enemy_flag_at_home = 1;
	else enemy_flag_at_home = 0;

	logStr = "S";
	logStr = appendLogStr( logStr, level.mapname );
	logStr = appendLogStr( logStr, inclusiveTeammates.size + enemies.size );
	logStr = appendLogStr( logStr, dist_closest_teammate );
	logStr = appendLogStr( logStr, dist_closest_enemy );
	logStr = appendLogStr( logStr, dist_enemy_flag );
	logStr = appendLogStr( logStr, dist_spawnpoint_forward );
	logStr = appendLogStr( logStr, dist_spawnpoint_rear );
	logStr = appendLogStr( logStr, enemy_flag_at_home );
	logStr = logStr + "\n";

	logPrint( logStr );
}

showspawns()
{
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

getClosest( org, array, dist )
{
	return compareSizes( org, array, dist, ::closerFunc ); 
}

getFarthest( org, array, dist )
{
	return compareSizes( org, array, dist, ::fartherFunc ); 
}

compareSizes( org, array, dist, compareFunc )
{
	if( !array.size )
		return undefined; 
	if( IsDefined( dist ) )
	{
		distSqr = dist * dist;
		ent = undefined; 
		for( i = 0; i < array.size; i ++ )
			{
			newdistSqr = DistanceSquared( array[ i ].origin, org );
			if( [[ compareFunc ]]( newdistSqr, distSqr ) )
				continue; 
			distSqr = newdistSqr; 
			ent = array[ i ];
		}
		return ent;
	}

	ent = array[ 0 ];
	distSqr = DistanceSquared( ent.origin, org ); 
	for( i = 1; i < array.size; i ++ )
	{
		newdistSqr = DistanceSquared( array[ i ].origin, org );
		if( [[ compareFunc ]]( newdistSqr, distSqr ) )
			continue; 
		distSqr = newdistSqr; 
		ent = array[ i ];
	}
	return ent; 
}

closerFunc( dist1, dist2 )
{
	return dist1 >= dist2; 
}

fartherFunc( dist1, dist2 )
{
	return dist1 <= dist2; 
}
