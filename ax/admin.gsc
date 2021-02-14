/**********************
    ADMIN FUNCTIONS
**********************/

#include ax\utility;

init()
{
        level._effect["bombfire"] = loadfx("fx/props/barrelexp.efx");

	level thread switchteam();
	level thread killum();
	level thread smiteplayer();
	level thread forcename();
	level thread freezeum();
	level thread unfreezeum();
	level thread kicktospec();
	level thread wallops();
	level thread kickspecs();
	level thread muteplayer();
	level thread unmuteplayer();

	shitlist_setup();

	level thread onPlayerConnect();
}

onPlayerConnect()
{
	for(;;)
	{
		level waittill("connecting", player);
		player thread onPlayerSpawned();
	}
}

onPlayerSpawned()
{
	self endon("disconnect");

	for(;;)
	{
		self waittill("spawned_player");
		self thread shitlist();
/#
		if (isadminNew(self))
			self iprintln("The new isadmin function returned true");
		else self iprintln("The new isadmin function returned false");
#/
	}
}

shitlist_setup()
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

isadminNew(player)
{
	return isAdmin(player);
}

isadmin(player)
{
	adminRecord = getAdminRecord(player);
	if ( isdefined(adminRecord) )
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
	dvarName = "g_killum";
	dvarType = "int";

	level thread monitorDvar( dvarName, dvarType );

	for (;;)
	{
		level waittill( "dvar_" + dvarName, val );
		player = getPlayerByNumber( val );

		if ( !isdefined(player) )
			continue;

		player suicide();
		iprintln( player.name + "^7 was killed by the admin!" );
	}
}

smiteplayer()
{
	dvarName = "g_smite";
	dvarType = "int";

	level thread monitorDvar( dvarName, dvarType );

	for (;;)
	{
		level waittill( "dvar_" + dvarName, val );
		player = getPlayerByNumber( val );

		if ( !isdefined(player) )
			continue;

		if ( player.sessionstate == "playing" )
		{
			range = 180;
			maxdamage = 150;
			mindamage = 10;

			playfx(level._effect["bombfire"], player.origin);
			wait 0.05;
			player playsound("flak88_explode");
			radiusDamage(player.origin + (0,0,12), range, maxdamage, mindamage);
			iprintln("Lo, the admin smote " + player.name + " with fire!");
		}
	}
}

wallOps()
{
	dvarName = "wallop";
	dvarType = "string";

	level thread monitorDvar( dvarName, dvarType );

	for (;;)
	{
		level waittill( "dvar_" + dvarName, val );
		adminAnnounce( val );
	}
}

forcename()
{
	dvarName = "g_forcename";
	dvarType = "string";

	level thread monitorDvar( dvarName, dvarType );

	for (;;)
	{
		level waittill( "dvar_" + dvarName, val );

		arr = explode( val, "," );
		num = int( arr[0] );
		name = arr[1];

		player = getPlayerByNumber( num );

		if ( !isdefined(player) )
			continue;

		player setClientCvar( "name", name );
	}
}

freezeum()
{
	dvarName = "g_freeze";
	dvarType = "int";

	level thread monitorDvar( dvarName, dvarType );

	for (;;)
	{
		level waittill( "dvar_" + dvarName, val );
		player = getPlayerByNumber( val );

		if ( !isdefined(player) )
			continue;

		if ( player.sessionstate == "playing" )
		{
			guid = player getGuid();
			level.frozen_player[guid] = spawn( "script_model", (0,0,0) );
			level.frozen_player[guid].origin = player.origin;
			level.frozen_player[guid].angles = player.angles;
			player linkto( level.frozen_player[guid] );
			player disableWeapon();
			iprintln("Lo, the admin has frozen " + player.name + "^7! Free kill!");
		}
	}
}

unfreezeum()
{
	dvarName = "g_unfreeze";
	dvarType = "int";

	level thread monitorDvar( dvarName, dvarType );

	for (;;)
	{
		level waittill( "dvar_" + dvarName, val );
		player = getPlayerByNumber( val );

		if ( !isdefined(player) )
			continue;

		if ( player.sessionstate == "playing" )
		{
			guid = player getGuid();
			if ( isdefined( level.frozen_player[guid] ) )
			{
				player unlink();
				level.frozen_player[guid] delete();
				player enableWeapon();
			}
		}
	}
}

kicktospec()
{
	dvarName = "g_kicktospec";
	dvarType = "int";

	level thread monitorDvar( dvarName, dvarType );

	for (;;)
	{
		level waittill( "dvar_" + dvarName, val );
		player = getPlayerByNumber( val );

		if ( !isdefined(player) )
			continue;

		if ( player.sessionstate == "playing" )
		{
			if ( isAlive(player) )
				player suicide();

		        player.pers["team"] = "spectator";
		        player.sessionteam = "spectator";
		        player [[level.spawnspectator]]();
		}
	}
}

kickspecs()
{
	dvarName = "g_kickspecs";
	dvarType = "int";

	level thread monitorDvar( dvarName, dvarType );

	for (;;)
	{
		level waittill( "dvar_" + dvarName, delay );

		if (delay < 10) delay = 10;

		private_slots = getCvarInt("sv_privateClients");
		if ( private_slots != 0 )
		{
			public_first = private_slots;
			private_slots = private_slots - 1;
		}
		else public_first = 0;

		/*public_last = getCvarInt("sv_maxclients") - 1;
		for(i = public_first; i<public_last; i++) {
			if (!isdefined ( getentbynum(i) ))
				continue;
		}*/
		// need to check if server is full.. 

		players = getentarray("player", "classname");
		for (i = 0; i < players.size; i++)
		{
			player = players[i];
			this = player getEntityNumber();
			if (player.pers["team"] == "spectator")
			{
				if ( (private_slots > 0 && this > private_slots) || private_slots == 0 )
					thread delayed_kick(player, "kick_specs", "spectating in " + delay + " seconds!", true);
			}
		}
		wait delay;
		level notify("kick_specs");
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
	dvarName = "g_mute";
	dvarType = "int";

	level thread monitorDvar( dvarName, dvarType );

	for (;;)
	{
		level waittill( "dvar_" + dvarName, val );
		player = getPlayerByNumber( val );

		if ( !isdefined(player) )
			continue;

		if ( !player.muted )
		{
			player setClientCvar("cl_voice", 0);
			player.muted = true;
			player thread infimute();
			iprintln("Lo, " + player.name + "^7 is now prohibited from using voice chat!");
		}
	}
}

unmuteplayer()
{
	dvarName = "g_unmute";
	dvarType = "int";

	level thread monitorDvar( dvarName, dvarType );

	for (;;)
	{
		level waittill( "dvar_" + dvarName, val );
		player = getPlayerByNumber( val );

		if ( !isdefined(player) )
			continue;

		if ( !player.muted )
		{
			player setClientCvar("cl_voice", 1);
			player.muted = false;
			player notify( "stop_mute" );
			iprintln("Lo, " + player.name + "^7 can now use voice chat. Welcome back!");
		}
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

getPlayerByNumber( num )
{
	players = getentarray("player", "classname");
	for (i = 0; i < players.size; i++)
	{
		this = players[i] getEntityNumber();
		if ( this == num )
			return players[i];
	}
	return;
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

monitorDvar(name, type)
{
	level endon( "intermission" );

	setCvar( name, "" );
	for (;;)
	{
		if ( type == "float" )
		{
			val = getCvarFloat( name );
			if ( val > 0.0 )
				level notify( "dvar_" + name, val );
		}
		else if ( type == "int" )
		{
			val = getCvarInt( name );
			if ( val > 0 )
				level notify( "dvar_" + name, val );
		}
		else
		{
			val = getCvar( name );
			if ( val != "" )
				level notify( "dvar_" + name, val );
		}
		setCvar( name, "" );
		wait 0.05;
	}
}
