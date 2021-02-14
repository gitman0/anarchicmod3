/**********************
    ADMIN FUNCTIONS
**********************/

#include ax\utility;

init()
{
        level._effect["bombfire"] = loadfx( "fx/props/barrelexp.efx" );

	level thread switchteam();

	level thread registerDvarEvent( "g_killum",	"int",	::killUm );
	level thread registerDvarEvent( "g_smite",	"int",	::smitePlayer );
	level thread registerDvarEvent( "g_forcename",	"string", ::forceName );
	level thread registerDvarEvent( "g_freeze",	"int",	::freezeUm );
	level thread registerDvarEvent( "g_unfreeze",	"int",	::unFreezeUm );
	level thread registerDvarEvent( "g_kicktospec", "int",	::kickToSpec );
	level thread registerDvarEvent( "wallops",	"string", ::adminAnnounce );
	level thread registerDvarEvent( "g_kickspecs",	"int",	::kickSpecs );
	level thread registerDvarEvent( "g_mute",	"int",	::mutePlayer );
	level thread registerDvarEvent( "g_unmute",	"int",	::unMutePlayer );
	level thread registerDvarEvent( "ax_givetags",	"int",	::giveClanTags );

	setupShitlist();

	level thread onPlayerConnect();
}

onPlayerConnect()
{
	for(;;)
	{
		level waittill( "connected", player );
		player thread shitlist();
		player thread onPlayerSpawned();
	}
}

onPlayerSpawned()
{
	self endon( "disconnect" );

	for(;;)
	{
		self waittill( "spawned_player" );

		/# if (isadminNew(self))
			self iprintln("The new isadmin function returned true");
		else self iprintln("The new isadmin function returned false"); #/
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

isAdmin(player)
{
	if ( !isDefined(player.ax_admin_flag) )
	{
		adminRecord = getAdminRecord(player);
		if ( isDefined( adminRecord ) )
		{
			/# player iprintln( "Caching your admin record" ); #/
			player.ax_admin_flag = true;
			return true;
		}
	}
	else if ( player.ax_admin_flag )
		return true;
	else return false;
}

getAdminRecord(player)
{
	record = [];
	result = undefined;
	guid = player getGuid();

	if ( guid == 0 )
	{
		record[0] = 0;
		record[1] = "localAdmin";
		return record;
	}

	guidFile = openFile("admin_players.dat", "read");

	if ( guidFile < 0 )
		return result;

	numval = fReadLn(guidFile);
	while ( numval )
	{
		if (numval == 2)
		{
			record[0] = fGetArg(guidFile, 0);
			record[1] = fGetArg(guidFile, 1);
		}
		if ( record[0] == guid )
		{
			result = record;
			break;
		}
		numval = fReadLn(guidFile);
	}
	closeFile(guidFile);
	return result;
}
/*		
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
*/

//////////////////////////////////////////////////////////////////////////////
/// the following functions are either based on or courtesy of raviradmin.gsc
//////////////////////////////////////////////////////////////////////////////

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
	player setClientCvar( "name", level.ax_server_clantag + player.name );
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
