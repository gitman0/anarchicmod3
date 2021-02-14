#include anarchicmod\utility;

/**********************
    ADMIN FUNCTIONS
**********************/

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
		case 1274652: // C2theT
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