//***********************************************************************************************************
// MAP VOTE PACKAGE
// ORIGINALLY MADE BY NC-17 (codam, powerserver), REWORKED BY wizard220, MODIFIED BY FrAnCkY55, Modified again by bell
// and again by gitman for anarchicmod2.0
//***********************************************************************************************************

#include ax\utility;

init()
{
	if (!level.awe_mapvote)
		return;

	level.mapvotetext["MapVote"]  	   = &"Press ^2FIRE^7 to vote                                           Votes";
	level.mapvotetext["TimeLeft"]      = &"Time Left: ";
	level.mapvotetext["MapVoteHeader"] = &"Next Map Vote";

	if(!isdefined(game["gamestarted"]))
	{
		precacheString(level.mapvotetext["MapVote"]);
		precacheString(level.mapvotetext["TimeLeft"]);
		precacheString(level.mapvotetext["MapVoteHeader"]);
		precacheShader("white");
	}
	level thread main();
}

main()
{
	level waittill("intermission");

	level.awe_mapvotehudoffset = 30;
	logPrint("\** MAP VOTE **\ Initializing...\n");

	// Small wait
	wait 0.05;

	// Cleanup some stuff to free up some resources
	CleanUp();

	CreateHud();

	// Start mapvote thread	
	thread RunMapVote();

	// Wait for voting to finish
	level waittill("VotingComplete");

	logPrint("\** MAP VOTE **\ Voting complete, deleting HUD elems...\n");

	// Delete HUD
	DeleteHud();
}

CleanUp()
{
	// Wait for threads to die
	wait .05;
	// Delete some HUD elements
	if(isdefined(level.clock)) level.clock destroy();
	if(isdefined(level.mod_title)) level.mod_title destroy();
	if(isdefined(level.rule_hud)) level.rule_hud destroy();
	if(isdefined(level.kdhud_sep[0])) level.kdhud_sep[0] destroy();
	if(isdefined(level.kdhud_sep[1])) level.kdhud_sep[1] destroy();
	if(isdefined(level.kdhud_sep[2])) level.kdhud_sep[2] destroy();
	if(isdefined(level.kdhud_flag0)) level.kdhud_flag0 destroy();
	if(isdefined(level.kdhud_flag1)) level.kdhud_flag1 destroy();
	if(isdefined(level.kdhud_kills[0])) level.kdhud_kills[0] destroy();
	if(isdefined(level.kdhud_kills[1])) level.kdhud_kills[1] destroy();
	if(isdefined(level.kdhud_kills[2])) level.kdhud_kills[2] destroy();
	if(isdefined(level.kdhud_deaths[0])) level.kdhud_deaths[0] destroy();
	if(isdefined(level.kdhud_deaths[1])) level.kdhud_deaths[1] destroy();
	if(isdefined(level.kdhud_deaths[2])) level.kdhud_deaths[2] destroy();
	players = getentarray("player", "classname");
	for(i=0;i<players.size;i++)
	{
		player = players[i];

		if (isdefined(player.healthbar_back))
			player.healthbar_back destroy();
		if (isdefined(player.healthbar_cross))
			player.healthbar_cross destroy();
		if (isdefined(player.healthbar))
			player.healthbar destroy();
		if (isdefined(player.kdhud_kills))
			player.kdhud_kills destroy();
		if (isdefined(player.kdhud_deaths))
			player.kdhud_deaths destroy();
		if (isdefined(player.kdhud_caps))
			player.kdhud_caps destroy();
		if (isdefined(player.kdhud_caps_count))
			player.kdhud_caps_count destroy();
		if (isdefined(player.hud_headshot))
			player.hud_headshot destroy();
		if (isdefined(player.hud_headshot_count))
			player.hud_headshot_count destroy();
		if (isdefined(player.penaltytimer))
			player.penaltytimer destroy();
		if (isdefined(player.teamkill_display))
			player.teamkill_display destroy();
		if (isdefined(player.teamkill_display_counter))
			player.teamkill_display_counter destroy();
		if (isdefined(player.spawn_assist_display_title))
			player.spawn_assist_display_title destroy();
		if (isdefined(player.spawn_assist_display_sec))
			player.spawn_assist_display_sec destroy();
		
	}
}

CreateHud()
{
	level.vote_hud_bgnd = newHudElem();
	level.vote_hud_bgnd.archived = false;
	level.vote_hud_bgnd.alpha = .7;
	level.vote_hud_bgnd.x = 205;
	level.vote_hud_bgnd.y = level.awe_mapvotehudoffset + 17;
	level.vote_hud_bgnd.sort = 9000;
	level.vote_hud_bgnd.color = (0,0,0);
	level.vote_hud_bgnd setShader("white", 260, 140);
	
	level.vote_header = newHudElem();
	level.vote_header.archived = false;
	level.vote_header.alpha = .3;
	level.vote_header.x = 208;
	level.vote_header.y = level.awe_mapvotehudoffset + 19;
	level.vote_header.sort = 9001;
	level.vote_header setShader("white", 254, 21);
	
	level.vote_headerText = newHudElem();
	level.vote_headerText.archived = false;
	level.vote_headerText.x = 210;
	level.vote_headerText.y = level.awe_mapvotehudoffset + 21;
	level.vote_headerText.sort = 9998;
	level.vote_headerText.label = level.mapvotetext["MapVoteHeader"];
	level.vote_headerText.fontscale = 1.3;

	level.vote_leftline = newHudElem();
	level.vote_leftline.archived = false;
	level.vote_leftline.alpha = .3;
	level.vote_leftline.x = 207;
	level.vote_leftline.y = level.awe_mapvotehudoffset + 19;
	level.vote_leftline.sort = 9001;
	level.vote_leftline setShader("white", 1, 135);
	
	level.vote_rightline = newHudElem();
	level.vote_rightline.archived = false;
	level.vote_rightline.alpha = .3;
	level.vote_rightline.x = 462;
	level.vote_rightline.y = level.awe_mapvotehudoffset + 19;
	level.vote_rightline.sort = 9001;
	level.vote_rightline setShader("white", 1, 135);
	
	level.vote_bottomline = newHudElem();
	level.vote_bottomline.archived = false;
	level.vote_bottomline.alpha = .3;
	level.vote_bottomline.x = 207;
	level.vote_bottomline.y = level.awe_mapvotehudoffset + 154;
	level.vote_bottomline.sort = 9001;
	level.vote_bottomline setShader("white", 256, 1);

	level.vote_hud_timeleft = newHudElem();
	level.vote_hud_timeleft.archived = false;
	level.vote_hud_timeleft.x = 400;
	level.vote_hud_timeleft.y = level.awe_mapvotehudoffset + 26;
	level.vote_hud_timeleft.sort = 9998;
	level.vote_hud_timeleft.fontscale = .8;
	level.vote_hud_timeleft.label = level.mapvotetext["TimeLeft"];
	level.vote_hud_timeleft setValue( level.awe_mapvotetime );	
	
	level.vote_hud_instructions = newHudElem();
	level.vote_hud_instructions.archived = false;
	level.vote_hud_instructions.x = 328;
	level.vote_hud_instructions.y = level.awe_mapvotehudoffset + 56;
	level.vote_hud_instructions.sort = 9998;
	level.vote_hud_instructions.fontscale = 1.1;
	level.vote_hud_instructions.label = level.mapvotetext["MapVote"];
	level.vote_hud_instructions.alignX = "center";
	level.vote_hud_instructions.alignY = "middle";
	
	level.vote_map1 = newHudElem();
	level.vote_map1.archived = false;
	level.vote_map1.x = 434;
	level.vote_map1.y = level.awe_mapvotehudoffset + 69;
	level.vote_map1.sort = 9998;
		
	level.vote_map2 = newHudElem();
	level.vote_map2.archived = false;
	level.vote_map2.x = 434;
	level.vote_map2.y = level.awe_mapvotehudoffset + 85;
	level.vote_map2.sort = 9998;
		
	level.vote_map3 = newHudElem();
	level.vote_map3.archived = false;
	level.vote_map3.x = 434;
	level.vote_map3.y = level.awe_mapvotehudoffset + 101;
	level.vote_map3.sort = 9998;	

	level.vote_map4 = newHudElem();
	level.vote_map4.archived = false;
	level.vote_map4.x = 434;
	level.vote_map4.y = level.awe_mapvotehudoffset + 117;
	level.vote_map4.sort = 9998;	

	level.vote_map5 = newHudElem();
	level.vote_map5.archived = false;
	level.vote_map5.x = 434;
	level.vote_map5.y = level.awe_mapvotehudoffset + 133;
	level.vote_map5.sort = 9998;	
}


RunMapVote()
{
	logPrint("\** MAP VOTE **\ RunMapVote started...\n");

	currentgt = getcvar("g_gametype");
	currentmap = getcvar("mapname");

	maps = undefined;

	x = GetRandomMapRotation();
	if(isdefined(x))
	{
		if(isdefined(x.maps))
			maps = x.maps;
		x = undefined;
	}
	
	// Any maps?
	if(!isdefined(maps))
	{
		wait 0.05;
		level notify("VotingComplete");
		return;
	}

	// Fill all alternatives with the current map in case there is not enough unique maps
	for(j=0;j<5;j++)
	{
		level.mapcandidate[j]["map"] = currentmap;
		level.mapcandidate[j]["mapname"] = "Replay this map";
		level.mapcandidate[j]["gametype"] = currentgt;
		level.mapcandidate[j]["votes"] = 0;
	}

	//past stuff
	past_candidates = explode( getcvar("scr_past_candidates"), ",");
	past_rotation	= explode( getcvar("scr_past_rotation"), ",");

	logPrint("\** MAP VOTE **\ Candidate selection started...\n");
	//get candidates
	i = 0;
	for(j=0;j<5;j++)
	{
		// Skip current map and gametype combination and any part of the past rotation
		if((maps[i]["map"] == currentmap && maps[i]["gametype"] == currentgt) || inArray(maps[i]["map"], past_rotation))
		{
			i++;
			j--;
			continue;
		}
			
		// Any maps left?
		if(!isdefined(maps[i]))
			break;

		level.mapcandidate[j]["map"] = maps[i]["map"];
		level.mapcandidate[j]["mapname"] = getMapName(maps[i]["map"]);
		level.mapcandidate[j]["gametype"] = maps[i]["gametype"];
		level.mapcandidate[j]["votes"] = 0;

		i++;

		// Any maps left?
		if(!isdefined(maps[i]))
			break;
	}
	logPrint("\** MAP VOTE **\ Candidates chosen...\n");
	past_candidates = "";

	for (x=0; x<level.mapcandidate.size; x++) {
		if (x==0) past_candidates = level.mapcandidate[x]["map"];
		else past_candidates = past_candidates + "," + level.mapcandidate[x]["map"];
	}

	setcvar("scr_past_candidates",	past_candidates);
	setcvar("scr_oldgt",		getcvar("g_gametype"));
	setcvar("scr_oldmap",		getcvar("mapname"));

	thread DisplayMapChoices();

	game["menu_team"] = "";

	//start a voting thread per player
	players = getentarray("player", "classname");
	for(i = 0; i < players.size; i++)
		players[i] thread PlayerVote();

	logPrint("\** MAP VOTE **\ PlayerVote threads started, creating hud...\n");

	thread VoteLogic();
	
	wait 0.1;
	level.mapended = true;
}
inArray(element, array)
{
	if(!isdefined(array) || !array.size)
		return false;

	for(i=0;i<array.size;i++)
		if(array[i] == element)
			return true;
	return false;
}
DeleteHud()
{
	level.vote_headerText destroy();
	level.vote_hud_timeleft destroy();	
	level.vote_hud_instructions destroy();
	level.vote_map1 destroy();
	level.vote_map2 destroy();
	level.vote_map3 destroy();
	level.vote_map4 destroy();
	level.vote_map5 destroy();
	level.vote_hud_bgnd destroy();
	level.vote_header destroy();
	level.vote_leftline destroy();
	level.vote_rightline destroy();
	level.vote_bottomline destroy();

	players = getentarray("player", "classname");
	for(i = 0; i < players.size; i++)
		if(isdefined(players[i].vote_indicator))
			players[i].vote_indicator destroy();
	logPrint("\** MAP VOTE **\ Hudelems cleared...\n");
}

//Displays the map candidates
DisplayMapChoices()
{
	level endon("VotingDone");
	logPrint("\** MAP VOTE **\ Displaying map choices...\n");
	wait 0.05;
	for(;;)
	{
		iprintlnbold(level.mapcandidate[0]["mapname"]);
		iprintlnbold(level.mapcandidate[1]["mapname"]);
		iprintlnbold(level.mapcandidate[2]["mapname"]);
		iprintlnbold(level.mapcandidate[3]["mapname"]);
		iprintlnbold(level.mapcandidate[4]["mapname"]);
		wait 7.8;
	}	
}

//Changes the players vote as he hits the attack button and updates HUD
PlayerVote()
{
	level endon("VotingDone");
	self endon("disconnect");

	novote = false;

	// No voting for spectators
	if(self.pers["team"] == "spectator")
		novote = true;

	// Spawn player as spectator
	spawnSpectator();
	self.sessionstate = "spectator";
	self.spectatorclient = -1;
	resettimeout();
	
	//remove the scoreboard
	self setClientCvar("g_scriptMainMenu", "");
	self closeMenu();
	self closeInGameMenu();
	self notify("menuresponse", game["menu_ingame_onteam"], "close");
	

	//remove chat
	self setClientCvar("cg_chattime", "0");

	self allowSpectateTeam("allies", false);
	self allowSpectateTeam("axis", false);
	self allowSpectateTeam("freelook", false);
	self allowSpectateTeam("none", true);

	if(novote)
		return;

	self.votechoice = randomint(5);

	colors[0] = (0  ,  0,  1);
	colors[1] = (0  ,0.5,  1);
	colors[2] = (0  ,  1,  1);
	colors[3] = (0  ,  1,0.5);
	colors[4] = (0  ,  1,  0);
	
	self.vote_indicator = newClientHudElem( self );
	self.vote_indicator.alignY = "middle";
	self.vote_indicator.x = 208;
	self.vote_indicator.y = level.awe_mapvotehudoffset + 75 + self.votechoice * 16;
	self.vote_indicator.archived = false;
	self.vote_indicator.sort = 9998;
	self.vote_indicator.alpha = .3;
	self.vote_indicator.color = colors[self.votechoice];
	self.vote_indicator setShader("white", 254, 17);
	
	for (;;)
	{
		wait 0.05;								
		if(self attackButtonPressed() == true)
		{
			self.votechoice++;

			if (self.votechoice == 5)
				self.votechoice = 0;

			self iprintln("You have voted for ^2" + level.mapcandidate[self.votechoice]["mapname"]);
			self.vote_indicator.y = level.awe_mapvotehudoffset + 77 + self.votechoice * 16;				
			self.vote_indicator.color = colors[self.votechoice];

			self playLocalSound("hq_score");
		}					
		while(self attackButtonPressed() == true)
			wait 0.05;

		self.sessionstate = "spectator";
		self.spectatorclient = -1;
	}
}

//Determines winning map and sets rotation
VoteLogic()
{
	//Vote Timer
	for (;level.awe_mapvotetime>=0;level.awe_mapvotetime--)
	{
		for(j=0;j<10;j++)
		{
			// Count votes
			for(i=0;i<5;i++)
				level.mapcandidate[i]["votes"] = 0;

			players = getentarray("player", "classname");
			for(i = 0; i < players.size; i++)
				if(isdefined(players[i].votechoice))
					level.mapcandidate[players[i].votechoice]["votes"]++;

			// Update HUD
			level.vote_map1 setValue( level.mapcandidate[0]["votes"] );
			level.vote_map2 setValue( level.mapcandidate[1]["votes"] );
			level.vote_map3 setValue( level.mapcandidate[2]["votes"] );
			level.vote_map4 setValue( level.mapcandidate[3]["votes"] );
			level.vote_map5 setValue( level.mapcandidate[4]["votes"] );
			wait 0.1;
		}
		level.vote_hud_timeleft setValue( level.awe_mapvotetime );
	}	

	newmapnum = 0;
	topvotes = 0;
	for(i=0;i<5;i++)
	{
		if (level.mapcandidate[i]["votes"] > topvotes)
		{
			newmapnum = i;
			topvotes = level.mapcandidate[i]["votes"];
		}
	}
	logPrint("\** MAP VOTE **\ Map winner set...\n");
	SetMapWinner(newmapnum);
}

//change the map rotation to represent the current selection
SetMapWinner(winner)
{
	map		= level.mapcandidate[winner]["map"];
	mapname		= level.mapcandidate[winner]["mapname"];
	gametype	= level.mapcandidate[winner]["gametype"];

	setcvar("sv_maprotationcurrent", " gametype " + gametype + " map " + map);

	logPrint("\** MAP VOTE **\ sv_maprotation is now set...\n");

	// Stop threads
	level notify( "VotingDone" );

	// Wait for threads to die
	wait 0.05;

	// Announce winner
	iprintlnbold(" ");
	iprintlnbold(" ");
	iprintlnbold(" ");
	iprintlnbold("The winner is");
	iprintlnbold("^2" + mapname);
	iprintlnbold("^2" + getGametypeName(gametype));

	// Fade HUD elements
	level.vote_headerText fadeOverTime (1);
	level.vote_hud_timeleft fadeOverTime (1);	
	level.vote_hud_instructions fadeOverTime (1);
	level.vote_map1 fadeOverTime (1);
	level.vote_map2 fadeOverTime (1);
	level.vote_map3 fadeOverTime (1);
	level.vote_map4 fadeOverTime (1);
	level.vote_map5 fadeOverTime (1);
	level.vote_hud_bgnd fadeOverTime (1);
	level.vote_header fadeOverTime (1);
	level.vote_leftline fadeOverTime (1);
	level.vote_rightline fadeOverTime (1);
	level.vote_bottomline fadeOverTime (1);

	level.vote_headerText.alpha = 0;
	level.vote_hud_timeleft.alpha = 0;	
	level.vote_hud_instructions.alpha = 0;
	level.vote_map1.alpha = 0;
	level.vote_map2.alpha = 0;
	level.vote_map3.alpha = 0;
	level.vote_map4.alpha = 0;
	level.vote_map5.alpha = 0;
	level.vote_hud_bgnd.alpha = 0;
	level.vote_header.alpha = 0;
	level.vote_leftline.alpha = 0;
	level.vote_rightline.alpha = 0;
	level.vote_bottomline.alpha = 0;

	players = getentarray("player", "classname");
	for(i = 0; i < players.size; i++)
	{
		if(isdefined(players[i].vote_indicator))
		{
			players[i].vote_indicator fadeOverTime (1);
			players[i].vote_indicator.alpha = 0;
		}
	}

	// Show winning map for a few seconds
	wait 4;
	level notify( "VotingComplete" );
}
GetRandomMapRotation(number)
{
	return GetMapRotation(true, false, number);
}
GetMapRotation(random, current, number)
{
	maprot = "";

	if(!isdefined(number))
		number = 0;

	// Get current maprotation
	if(current)
		maprot = strip(getcvar("sv_maprotationcurrent"));	

	// Get maprotation if current empty or not the one we want
	if(level.anarchic_debug) iprintln("(cvar)maprot: " + getcvar("sv_maprotation").size);
	if(maprot == "")
		maprot = strip(getcvar("sv_maprotation"));	
	if(level.anarchic_debug) iprintln("(var)maprot: " + maprot.size);

	// No map rotation setup!
	if(maprot == "")
		return undefined;
	
	// Explode entries into an array
//	temparr2 = explode(maprot," ");
	j=0;
	temparr2[j] = "";	
	for(i=0;i<maprot.size;i++)
	{
		if(maprot[i]==" ")
		{
			j++;
			temparr2[j] = "";
		}
		else
			temparr2[j] += maprot[i];
	}

	// Remove empty elements (double spaces)
	temparr = [];
	for(i=0;i<temparr2.size;i++)
	{
		element = strip(temparr2[i]);
		if(element != "")
		{
			if(level.anarchic_debug) iprintln("maprot" + temparr.size + ":" + element);
			temparr[temparr.size] = element;
		}
	}
	x = spawnstruct();

	x.maps = [];
	lastexec = undefined;
	lastjeep = undefined;
	lasttank = undefined;
	lastgt = level.awe_gametype;
	for(i=0;i<temparr.size;)
	{
		switch(temparr[i])
		{
			case "allow_jeeps":
				if(isdefined(temparr[i+1]))
					lastjeep = temparr[i+1];
				i += 2;
				break;

			case "allow_tanks":
				if(isdefined(temparr[i+1]))
					lasttank = temparr[i+1];
				i += 2;
				break;
	
			case "exec":
				if(isdefined(temparr[i+1]))
					lastexec = temparr[i+1];
				i += 2;
				break;

			case "gametype":
				if(isdefined(temparr[i+1]))
					lastgt = temparr[i+1];
				i += 2;
				break;

			case "map":
				if(isdefined(temparr[i+1]))
				{
					x.maps[x.maps.size]["exec"]		= lastexec;
					x.maps[x.maps.size-1]["jeep"]	= lastjeep;
					x.maps[x.maps.size-1]["tank"]	= lasttank;
					x.maps[x.maps.size-1]["gametype"]	= lastgt;
					x.maps[x.maps.size-1]["map"]	= temparr[i+1];
				}
				// Only need to save this for random rotations
				if(!random)
				{
					lastexec = undefined;
					lastjeep = undefined;
					lasttank = undefined;
					lastgt = undefined;
				}

				i += 2;
				break;

			// If code get here, then the maprotation is corrupt so we have to fix it
			default:
				iprintlnbold("ERROR_IN_MAPROT");
	
				if(isGametype(temparr[i]))
					lastgt = temparr[i];
				else if(isConfig(temparr[i]))
					lastexec = temparr[i];
				else
				{
					x.maps[x.maps.size]["exec"]		= lastexec;
					x.maps[x.maps.size-1]["jeep"]	= lastjeep;
					x.maps[x.maps.size-1]["tank"]	= lasttank;
					x.maps[x.maps.size-1]["gametype"]	= lastgt;
					x.maps[x.maps.size-1]["map"]	= temparr[i];
	
					// Only need to save this for random rotations
					if(!random)
					{
						lastexec = undefined;
						lastjeep = undefined;
						lasttank = undefined;
						lastgt = undefined;
					}
				}
					

				i += 1;
				break;
		}
		if(number && x.maps.size >= number)
			break;
	}

	if(random)
	{
		// Shuffle the array 20 times
		for(k = 0; k < 20; k++)
		{
			for(i = 0; i < x.maps.size; i++)
			{
				j = randomInt(x.maps.size);
				element = x.maps[i];
				x.maps[i] = x.maps[j];
				x.maps[j] = element;
			}
		}
	}

	return x;
}
randomizeArray(arr)
{
	// Shuffle the array 10 times
	for(k = 0; k < 10; k++)
	{
		for(i = 0; i < arr.size; i++)
		{
			j = randomInt(arr.size);
			element = arr[i];
			arr[i] = arr[j];
			arr[j] = element;
		}
	}
	return arr;
}
isGametype(gt)
{
	switch(gt)
	{
		case "dm":
		case "tdm":
		case "sd":
		case "re":
		case "hq":
		case "bel":
		case "bas":
		case "dom":
		case "ctf":
		case "actf":
		case "lts":
		case "cnq":
		case "rsd":
		case "tdom":

		case "mc_dm":
		case "mc_tdm":
		case "mc_sd":
		case "mc_re":
		case "mc_hq":
		case "mc_bel":
		case "mc_bas":
		case "mc_dom":
		case "mc_ctf":
		case "mc_actf":
		case "mc_lts":
		case "mc_cnq":
		case "mc_rsd":
		case "mc_tdom":

			return true;

		default:
			return false;
	}
}
isConfig(cfg)
{
	temparr = explode(cfg,".");
	if(temparr.size == 2 && temparr[1] == "cfg")
		return true;
	else
		return false;
}

getMapName(map)
{
	if (!isdefined(map))
		return;

	switch(map)
	{
		case "mp_farmhouse":
			return "Beltot, France";
		case "mp_brecourt":
			return "Brecourt, France";
		case "mp_burgundy":
			return "Burgundy, France";
		case "mp_trainstation":
			return "Caen, France";
		case "mp_carentan":
			return "Carentan, France";
		case "mp_decoy":
			return "El Alamein, Egypt";
		case "mp_leningrad":
			return "Leningrad, Russia";
		case "mp_matmata":
			return "Matmata, Tunisia";
		case "mp_downtown":
			return "Moscow, Russia";
		case "mp_dawnville":
			return "St. Mere Eglise, France";
		case "mp_railyard":
			return "Stalingrad, Russia";
		case "mp_toujane":
			return "Toujane, Tunisia";
		case "mp_breakout":
			return "Villers-Bocage, France";
		case "mp_rhine":
			return "Wallendar, Germany";
		case "mp_harbor":
			return "Rostov, Russia";
		case "mp_borisovka":
			return "Borisovka, Russia";
		case "mp_bridge":
			return "The Bridge";
		case "mp_depot":
			return "Depot, Germany";
		case "mp_flakbatterie_v1_0":
		case "mp_flakbatterie":
			return "Flakbatterie, Germany";
		case "mp_heat_final":
			return "Heat, Normandy";
		case "mp_sabes_du_mot_beta":
			return "Sabes Du Mot, France";
		case "mp_buhlert":
			return "Buhlert, Germany";
		case "mp_siegfriedline":
			return "Westwall, Germany";
		case "mp_st-gatien":
			return "St-Gatien, France";
		case "mp_simmerath_beta2":
			return "Simmerath, Germany";
		case "mp_tobruk":
			return "Tobruk, Libya";
		case "mp_docks":
			return "Murmansk [BetaV2]";
		case "mp_farm_assault_beta2":
			return "Farm Assault beta2";
		case "mp_chelm":
			return "Chelm, Poland (Beta 1)";
		case "mp_d-day+7.2":
			return "D-day+7.2 Final";
		case "mp_neuville":
			return "Neuville, France";
		case "mp_townville":
			return "Townville";
		case "mp_cassino":
			return "Cassino, Italy";
		case "mp_commando":
			return "Commando";
		case "mp_salerno_beachhead_b":
		case "mp_salerno_beachhead":
			return "Salerno Beachhead Beta, Italy";
				
		default:
			return map;
	}
}

getGametypeName(gt)
{
	switch(gt)
	{
		case "dm":
		case "mc_dm":
			gtname = "Deathmatch";
			break;
		
		case "tdm":
		case "mc_tdm":
			gtname = "Team Deathmatch";
			break;

		case "sd":
		case "mc_sd":
			gtname = "Search & Destroy";
			break;

		case "re":
		case "mc_re":
			gtname = "Retrieval";
			break;

		case "hq":
		case "mc_hq":
			gtname = "Headquarters";
			break;

		case "bel":
		case "mc_bel":
			gtname = "Behind Enemy Lines";
			break;
		
		case "cnq":
		case "mc_cnq":
			gtname = "Conquest TDM";
			break;

		case "lts":
		case "mc_lts":
			gtname = "Last Team Standing";
			break;

		case "ctf":
		case "mc_ctf":
			gtname = "Capture The Flag";
			break;

		case "dom":
		case "mc_dom":
			gtname = "Domination";
			break;

		case "bas":
		case "mc_bas":
			gtname = "Base assault";
			break;

		case "actf":
		case "mc_actf":
			gtname = "AWE Capture The Flag";
			break;

		case "mc_tdom":
			gtname = "Team Domination";
			break;
		
		default:
			gtname = gt;
			break;
	}

	return gtname;
}

spawnSpectator(origin, angles)
{
	self notify("spawned");
	self notify("end_respawn");

	resettimeout();

	// Stop shellshock and rumble
	self stopShellshock();
	self stoprumble("damage_heavy");

	self.sessionstate = "spectator";
	self.spectatorclient = -1;
	self.archivetime = 0;
	self.psoffsettime = 0;
	self.friendlydamage = undefined;

	if(self.pers["team"] == "spectator")
		self.statusicon = "";

	maps\mp\gametypes\_spectating::setSpectatePermissions();
	
	if(isDefined(origin) && isDefined(angles))
		self spawn(origin, angles);
	else
	{
         	spawnpointname = "mp_global_intermission";
		spawnpoints = getentarray(spawnpointname, "classname");
		spawnpoint = maps\mp\gametypes\_spawnlogic::getSpawnpoint_Random(spawnpoints);
	
		if(isDefined(spawnpoint))
			self spawn(spawnpoint.origin, spawnpoint.angles);
		else
			maps\mp\_utility::error("NO " + spawnpointname + " SPAWNPOINTS IN MAP");
	}
}