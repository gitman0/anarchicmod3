/* $Id: artillery.gsc 84 2010-09-06 06:42:10Z  $ */

init()
{
	level thread onPlayerConnect();
}

onPlayerConnect()
{
	level waittill( "connected", player );
	player thread onPlayerSpawned();
	player thread onPlayerKilled();
}

onPlayerSpawned()
{
	self endon( "disconnect" );
	for (;;)
	{
		self waittill( "spawned_player" );
	}
}

onPlayerKilled()
{
	self endon( "disconnect" );
	for (;;)
	{
		self waittill( "killed_player" );
	}
}
