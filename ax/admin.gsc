/* $Id: admin.gsc 119 2011-03-26 19:51:39Z  $ */

/**********************
    ADMIN FUNCTIONS
**********************/

#include ax\utility;

init()
{
        level._effect["bombfire"] = loadfx( "fx/props/barrelexp.efx" );

	level.ax_sticky_spectator = 0;
	level.ax_sticky_spectator_max = 5;

	loadAdminRecords();

	level thread switchteam();

	level thread registerDvarEvent( "g_killum",		"int",	::killUm );
	level thread registerDvarEvent( "g_smite",		"int",	::smitePlayer );
	level thread registerDvarEvent( "g_forcename",		"str",	::forceName );
	level thread registerDvarEvent( "g_freeze",		"int",	::freezeUm );
	level thread registerDvarEvent( "g_unfreeze",		"int",	::unFreezeUm );
	level thread registerDvarEvent( "g_kicktospec",		"int",	::kickToSpec );
	level thread registerDvarEvent( "wallops",		"str",	::adminAnnounce );
	level thread registerDvarEvent( "g_kickspecs",		"int",	::kickSpecs );
	level thread registerDvarEvent( "g_mute",		"int",	::mutePlayer );
	level thread registerDvarEvent( "g_unmute",		"int",	::unMutePlayer );
	level thread registerDvarEvent( "ax_givetags",		"int",	::giveClanTags );
	level thread registerDvarEvent( "ax_sticky_spec",	"int",	::stickySpectate );
	level thread registerDvarEvent( "ax_print_score_sort",	"int",	::printScoreSortedPlayers );
	setupShitlist();

	level thread onPlayerConnect();
}

onPlayerConnect()
{
	for(;;)
	{
		level waittill( "connected", player );
		player thread shitlist();
		if ( !isDefined( player.ax_admin_record ) && isAdmin( player ) )
			adminPrint( "Player " + player.name + " (" + player.ax_admin_record[1] + ") is a registered server admin." );
	}
}

setupShitlist()
{
	level.shitlist = [];

	// Example
	// guid = 123456;
	// level.shitlist[guid] = spawnstruct();
	// level.shitlist[guid].name = "forced_name";
	// level.shitlist[guid].chat = "blocked";
}

shitlist()
{
	guid = self getGUID();
	if ( !isDefined(level.shitlist[guid]) )
		return;
	if ( isDefined( level.shitlist[guid].name ) )
		self thread shitlistName( level.shitlist[guid].name );
	if ( isDefined( level.shitlist[guid].chat ) && level.shitlist[guid].chat == "blocked" )
		self thread shitlistChat();
}

shitlistName(name)
{
	self endon( "disconnect" );
	for (;;)
	{
		self setclientcvar("name", name);
		wait 1;
	}
}

shitlistChat()
{
	self endon( "disconnect" );
	for (;;)
	{
		self setClientCvar( "cg_chattime", 0 );
		wait 1;
	}
}

isAdminNew(player)
{
	return isAdmin(player);
}

isAdmin( player )
{
	if ( !isDefined( player.ax_admin_record ) )
	{
		adminRecord = getAdminRecord( player );
		if ( isDefined( adminRecord ) )
		{
			player.ax_admin_record = adminRecord;
			return true;
		}
		else return false;
	}
	else return true;
}

getAdminRecord( player )
{
	result = undefined;

	guid = player getGuid();

	if ( guid == 0 )
	{
		record[0] = 0;
		record[1] = "localAdmin";
		return record;
	}
	for ( i=0; i<level.adminRecords.size; i++ )
	{
		record = level.adminRecords[i];
		if ( int( record[0] ) == guid )
		{
			result = record;
			break;
		}
	}
	return result;
}

loadAdminRecords()
{
	level.adminRecords = [];
	record = [];

	result = undefined;

	guidFile = openFile( "admin_players.dat", "read" );
	if ( guidFile < 0 ) return false;

	numval = fReadLn( guidFile );
	while ( numval > 0 )
	{
		if ( numval == 2 )
		{
			record[0] = fGetArg( guidFile, 0 );
			record[1] = fGetArg( guidFile, 1 );

			level.adminRecords[level.adminRecords.size] = record;
		}
		numval = fReadLn( guidFile );
	}
	closeFile( guidFile );
	return result;
}

/* the following functions are based on ravir's admin functions */

// this one needs to be redone
switchteam()
{
	self endon( "boot" );
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

stickySpectate( minutes )
{
	level endon( "intermission" );

	switch ( level.gametype )
	{
		case "ctf": case "hq":
			break;
		default:
			adminPrint( "stickySpectate: this gametype already has persistent spectating" );
			return;
	}

	if ( level.ax_sticky_spectator > 0 ) // already enabled
	{
		adminPrint( "stickSpectate: attempted to enable, but already enabled" );
		return;
	}
	
	if ( minutes > level.ax_sticky_spectator_max )
		minutes = level.ax_sticky_spectator_max;
	level.ax_sticky_spectator = minutes;

	adminPrint( "stickySpectate: persistent spectating enabled for " + level.ax_sticky_spectator + " minutes" );

	wait ( level.ax_sticky_spectator * 60 );

	level.ax_sticky_spectator = 0;

	adminPrint( "stickySpectate: persistent spectating disabled" );
}

giveClanTags( clientNum )
{
	if ( !isDefined( level.ax_server_clantag ) )
	{
		adminPrint( "giveClanTags: no default clan tag defined" );
		return;
	}

	player = getPlayerByNumber( clientNum );
	if ( !isDefined( player ) )
	{
		adminPrint( "giveClanTags: no players at clientNum " + clientNum );
		return;
	}

	iprintln( &"AX_ADMIN_TOOLS_GIVETAGS", player.name );
	player setClientCvar( "name", level.ax_server_clantag + "^7 " + player.name );
}

killUm( clientNum )
{
	player = getPlayerByNumber( clientNum );

	if ( !isDefined( player ) )
	{
		adminPrint( "killUm: no players at clientNum " + clientNum );
		return;
	}
	player suicide();
	iprintln( &"AX_ADMIN_TOOLS_KILLUM", player.name );
}

smitePlayer( clientNum )
{
	player = getPlayerByNumber( clientNum );

	if ( !isDefined( player ) )
	{
		adminPrint( "smitePlayer: no players at clientNum " + clientNum );
		return;
	}

	if ( player.sessionstate == "playing" )
	{
		range = 180;
		maxDamage = 150;
		minDamage = 10;

		playfx( level._effect["bombfire"], player.origin );
		wait 0.05;
		player playSound( "flak88_explode" );
		radiusDamage( player.origin + (0, 0, 12), range, maxDamage, minDamage );
		iprintln( &"AX_ADMIN_TOOLS_SMITE", player.name );
	}
}

forceName( val )
{
	arr = explode( val, "," );
	clientNum = int( arr[0] );
	newName = arr[1];

	player = getPlayerByNumber( clientNum );

	if ( !isDefined( player ) )
	{
		adminPrint( "forceName: no players at clientNum " + clientNum );
		return;
	}
	player setClientCvar( "name", newName );
}

freezeUm( clientNum )
{
	player = getPlayerByNumber( clientNum );

	if ( !isDefined( player ) )
	{
		adminPrint( "freezeUm: no players at clientNum " + clientNum );
		return;
	}

	if ( player.sessionstate == "playing" )
	{
		guid = player getGuid();
		level.frozen_player[guid] = spawn( "script_model", (0,0,0) );
		level.frozen_player[guid].origin = player.origin;
		level.frozen_player[guid].angles = player.angles;
		player linkTo( level.frozen_player[guid] );
		player disableWeapon();
		iprintln( &"AX_ADMIN_TOOLS_FREEZE", player.name );
	}
}

unFreezeUm( clientNum )
{
	player = getPlayerByNumber( clientNum );

	if ( !isDefined( player ) )
	{
		adminPrint( "unFreezeUm: no players at clientNum " + clientNum );
		return;
	}

	if ( player.sessionstate == "playing" )
	{
		guid = player getGuid();
		if ( isDefined( level.frozen_player[guid] ) )
		{
			player unlink();
			level.frozen_player[guid] delete();
			player enableWeapon();
		}
	}
}

kickToSpec( clientNum )
{
	player = getPlayerByNumber( clientNum );

	if ( !isDefined( player ) )
	{
		adminPrint( "kickToSpec: no players at clientNum " + clientNum );
		return;
	}

	if ( player.sessionstate == "playing" )
	{
		if ( isAlive( player ) )
			player suicide();

	        player.pers["team"] = "spectator";
	        player.sessionteam = "spectator";
	        player [[level.spawnSpectator]]();
		iprintln( &"AX_ADMIN_TOOLS_KICKTOSPEC", player.name );
	}
}

kickSpecs( delay )
{
	if ( !isServerFull( "public" ) )
	{
		adminPrint( "kickSpecs: aborted, server has open public slots" );
		return;
	}

	if ( delay < 10 ) delay = 10;
	spectators = 0;

	privateClients = privateClients( 0 );

	players = getentarray( "player", "classname" );
	for ( i = 0; i < players.size; i++ )
	{
		player = players[i];
		clientNum = player getEntityNumber();
		if ( player.pers["team"] == "spectator" )
		{
			if ( ( privateClients > 0 && ( clientNum > (privateClients - 1) ) ) || privateClients == 0 )
			{
				spectators++;
				level thread delayedKick( player, "kick_specs", "spectating in " + delay + " seconds!", true );
			}
		}
	}
	if ( spectators > 0 )
	{
		iprintln( &"AX_ADMIN_TOOLS_KICKSPECS", spectators, delay );
		wait delay;
		level notify( "kick_specs" );
	}
	else adminPrint( "kickSpecs: aborted, no spectators found" );
}

delayedKick( player, event, reason, spec )
{
	level endon( "intermission" );
	player endon( "disconnect" );

	clientAnnouncement( player, "^1Attention!^7 You will be kicked for " + reason );

	level waittill( event );

	if ( spec && player.pers["team"] != "spectator" )
			return; // don't kick if they joined a team after the thread was called
	kick(player getEntityNumber());
}

mutePlayer( clientNum )
{
	player = getPlayerByNumber( clientNum );

	if ( !isDefined( player ) )
	{
		adminPrint( "mutePlayer: no players at clientNum " + clientNum );
		return;
	}

	if ( !player.muted )
	{
		player setClientCvar( "cl_voice", 0 );
		player.muted = true;
		player thread forcedMute();
		iprintln( &"AX_ADMIN_TOOLS_MUTE", player.name );
	}
}

unMutePlayer( clientNum )
{
	player = getPlayerByNumber( clientNum );

	if ( !isDefined( player ) )
	{
		adminPrint( "unMutePlayer: no players at clientNum " + clientNum );
		return;
	}

	if ( !player.muted )
	{
		player setClientCvar( "cl_voice", 1 );
		player.muted = false;
		player notify( "stop_mute" );
		iprintln( &"AX_ADMIN_TOOLS_UNMUTE", player.name );
	}
}

forcedMute()
{
	self endon("stop_mute");
	self endon("disconnect");
	for (;;)
	{
		wait 1;
		self setClientCvar("cl_voice", 0);
	}
}

adminAnnounce( str )
{
	players = getentarray("player", "classname");
	for (i = 0; i < players.size; i++)
	{
		if ( isAdmin( players[i] ) )
			clientAnnouncement( players[i], level.ax_admin_chat_prefix + str );
	}
}

adminPrint( str )
{
	players = getentarray("player", "classname");
	for (i = 0; i < players.size; i++)
	{
		if ( isAdmin( players[i] ) )
			players[i] iprintln( str );
	}
}

printScoreSortedPlayers( val )
{
	if ( val > 0 )
	{
		scoreSortedPlayers = scoreSortedPlayers();
		for ( i=0; i<scoreSortedPlayers.size; i++ )
			iprintln( "scoreSortedPlayers[" + i + "]: " + scoreSortedPlayers[i].name + " - " + scoreSortedPlayers[i].score );
	}
}
