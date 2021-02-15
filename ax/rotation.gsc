/* $Id: rotation.gsc 86 2010-10-02 01:28:00Z  $ */

#include ax\utility;

init()
{
	level thread showNextMap();
	level thread rotationHistory();

	level thread onPlayerConnect();
}

onPlayerConnect()
{
	for (;;)
	{
		level waittill( "connected", player );
		player thread onPlayerSpawned();
	}
}

onPlayerSpawned()
{
	self endon( "disconnect" );
	for (;;)
	{
		self waittill( "spawned_player" );

/#
		wait 5;
		self printRotationArray( "all" );
#/
	}
}

printRotationArray( type, gt )
{
	rotationArray = rotationArray( type, gt );

	if ( !rotationarray.size )
	{
		self iprintln( "rotationArray returned null" );
		return;
	}
	for ( i = 0; i < rotationArray.size; i++ )
		self iprintln( "rotationArray[" + i + "] == " + rotationArray[i] );
}

rotationByPlayerCount()
{
}

rotationArray( type, gt )
{
	if ( type == "current" )
		maprotationStr = strip( getCvar( "sv_maprotationcurrent" ) );
	else maprotationStr = strip( getCvar( "sv_maprotation" ) );

	maprotationStr_e = explode( maprotationStr, " " );

	maprotationArray = [];

	rotationGt = undefined;
	if ( isDefined( gt ) && gt != "" )
		rotationGt = gt;

	for ( i = 0; i < maprotationStr_e.size; i++ )
	{
		if ( isDefined( gt ) && gt != "" )
		{
			if ( strip(maprotationStr_e[i] == "gametype") || strip(maprotationStr_e[i] == "g_gametype") )
			{
				rotationGt = strip( maprotationStr_e[i+1] );
				i++;
			}
			if ( rotationGt != gt )
				continue;
		}
		if ( strip( maprotationStr_e[i] ) == "map" )
		{
			maprotationArray[maprotationArray.size] = strip( maprotationStr_e[i+1] );
			i++;
		}
	}
	return maprotationArray;
}

rotationHistory()
{
	level waittill("intermission");

	limit = cvardef("scr_past_rotation_mem", 10, 0, 30, "int");
	r = getcvar("scr_past_rotation");
	if ( r == "" )
		setcvar("scr_past_rotation", level.mapname);
	else
	{
		past = "";
		m = explode(r, ",");
		m[m.size] = level.mapname;

		if ( m.size <= limit ) i = 0;
		else i = ( m.size - limit );

		start = i;

		while ( i < m.size )
		{
			if ( i == start) s = m[i];
			else s = "," + m[i];
			past = past + s;
			i++;
		}
		setcvar("scr_past_rotation", past);
	}
}

showNextMap()
{
	level endon("intermission");

	if ( !level.nextmap_display || level.awe_mapvote )
		return;

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
