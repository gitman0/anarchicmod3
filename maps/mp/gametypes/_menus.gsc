init()
{
	game["menu_ingame"] = "ingame";
	game["menu_serverinfo"] = "serverinfo_" + getCvar("g_gametype");
	game["menu_team"] = "team_" + game["allies"] + game["axis"];
	if (getcvar("g_gametype") == "rtdm") {
		game["menu_weapon_allies"] = "weapon_rifles";
		game["menu_weapon_axis"] = "weapon_rifles";
	}
	else {
		game["menu_weapon_allies"] = "weapon_" + game["allies"];
		game["menu_weapon_axis"] = "weapon_" + game["axis"];
	}

	precacheMenu(game["menu_ingame"]);
	precacheMenu(game["menu_serverinfo"]);
	precacheMenu(game["menu_team"]);
	precacheMenu(game["menu_weapon_allies"]);
	precacheMenu(game["menu_weapon_axis"]);
	precacheMenu("addfavorite");

	if(!level.xenon)
	{
		game["menu_callvote"] = "callvote";
		game["menu_muteplayer"] = "muteplayer";

		precacheMenu(game["menu_callvote"]);
		precacheMenu(game["menu_muteplayer"]);
	}
	else
	{
		level.splitscreen = isSplitScreen();
		if(level.splitscreen)
		{
			game["menu_team"] += "_splitscreen";
			game["menu_weapon_allies"] += "_splitscreen";
			game["menu_weapon_axis"] += "_splitscreen";
			game["menu_ingame_onteam"] = "ingame_onteam_splitscreen";
			game["menu_ingame_spectator"] = "ingame_spectator_splitscreen";

			precacheMenu(game["menu_team"]);
			precacheMenu(game["menu_weapon_allies"]);
			precacheMenu(game["menu_weapon_axis"]);
			precacheMenu(game["menu_ingame_onteam"]);
			precacheMenu(game["menu_ingame_spectator"]);
		}
	}

	level thread onPlayerConnect();
}

onPlayerConnect()
{
	for(;;)
	{
		level waittill("connecting", player);
		player thread onMenuResponse();
	}
}

onMenuResponse()
{
	for(;;)
	{
		self waittill("menuresponse", menu, response);

		if(menu == game["menu_serverinfo"] && response == "close")
		{
			if (!isdefined(self.pers["team"]) || self.pers["team"] == "spectator")
				self openMenu(game["menu_team"]);
			else self closeMenu();
		}

		if(response == "open" || response == "close")
			continue;

		if(response == "back")
		{
			self closeMenu();
			self closeInGameMenu();

			if(menu == game["menu_team"])
			{
				if(level.splitscreen)
				{
					if(self.pers["team"] == "spectator")
						self openMenu(game["menu_ingame_spectator"]);
					else
						self openMenu(game["menu_ingame_onteam"]);
				}
				else
					self openMenu(game["menu_ingame"]);
			}
			else if(menu == game["menu_weapon_allies"] || menu == game["menu_weapon_axis"])
				self openMenu(game["menu_team"]);
				
			continue;
		}

		if(response == "endgame")
		{
			if(level.splitscreen)
				level thread [[level.endgameconfirmed]]();
				
			continue;
		}

		if(menu == game["menu_ingame"] || (level.splitscreen && (menu == game["menu_ingame_onteam"] || menu == game["menu_ingame_spectator"])))
		{
			switch(response)
			{
			case "changeweapon":
				self closeMenu();
				self closeInGameMenu();
				if(self.pers["team"] == "allies")
					self openMenu(game["menu_weapon_allies"]);
				else if(self.pers["team"] == "axis")
					self openMenu(game["menu_weapon_axis"]);
				break;	

			case "changeteam":
				self closeMenu();
				self closeInGameMenu();
				self openMenu(game["menu_team"]);
				break;

			case "muteplayer":
				if(!level.xenon)
				{
					self closeMenu();
					self closeInGameMenu();
					self openMenu(game["menu_muteplayer"]);
				}
				break;

			case "callvote":
				if(!level.xenon)
				{
					self closeMenu();
					self closeInGameMenu();
					self openMenu(game["menu_callvote"]);
				}
				break;
			case "serverinfo":
				self closeMenu();
				self closeInGameMenu();
				self openMenu(game["menu_serverinfo"]);
				break;
			case "addfavorite":
				self closeMenu();
				self closeInGameMenu();
				self setClientCvar("ui_favoriteName", getcvar("sv_hostname"));
				self setClientCvar("ui_favoriteAddress", getcvar("sv_address"));
				self openMenu("addfavorite");
				break;
			}
		}
		else if(menu == game["menu_team"])
		{
			balancedChoice = self ax\anarchic::isBalancedChoice( response );
			if ( !balancedChoice )
			{
				self closeMenu();
				self closeInGameMenu();
				continue;
			}
			switch(response)
			{
			case "allies":
				self closeMenu();
				self closeInGameMenu();
				if (!self.cannot_play)
					self [[level.allies]]();
				break;

			case "axis":
				self closeMenu();
				self closeInGameMenu();
				if (!self.cannot_play)
					self [[level.axis]]();
				break;

			case "autoassign":
				self closeMenu();
				self closeInGameMenu();
				self [[level.autoassign]]();
				break;

			case "spectator":
				self closeMenu();
				self closeInGameMenu();
				self [[level.spectator]]();
				break;
			}
		}
		else if(menu == game["menu_weapon_allies"] || menu == game["menu_weapon_axis"])
		{
			if (response == "changeteam") {
				self closeMenu();
				self closeInGameMenu();
				self openMenu(game["menu_team"]);
			}
			else {
				self closeMenu();
				self closeInGameMenu();
				self [[level.weapon]](response);
				ax\weapons::updateAvailableWeapons();
			}
		}
		else if(!level.xenon)
		{
			if(menu == game["menu_quickcommands"])
				maps\mp\gametypes\_quickmessages::quickcommands(response);
			else if(menu == game["menu_quickstatements"])
				maps\mp\gametypes\_quickmessages::quickstatements(response);
			else if(menu == game["menu_quickresponses"])
				maps\mp\gametypes\_quickmessages::quickresponses(response);
		}
	}
}
