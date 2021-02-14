// Consider moving timer to this script

init()
{
	switch(game["allies"])
	{
	case "american":
		game["hudicon_allies"] = "hudicon_american";
		break;
	
	case "british":
		game["hudicon_allies"] = "hudicon_british";
		break;
	
	case "russian":
		game["hudicon_allies"] = "hudicon_russian";
		break;
	}
	
	assert(game["axis"] == "german");
	game["hudicon_axis"] = "hudicon_german";

	precacheShader(game["hudicon_allies"]);
	precacheShader(game["hudicon_axis"]);
	
	level thread onPlayerConnect();
}

onPlayerConnect()
{
	for(;;)
	{
		level waittill("connecting", player);

		player thread onPlayerSpawned();
		player thread onJoinedTeam();
		player thread onJoinedSpectators();
		player thread onUpdatePlayerScoreHUD();
	}
}

onJoinedTeam()
{
	self endon("disconnect");
	
	for(;;)
	{
		self waittill("joined_team");
		self thread removePlayerHUD();
	}
}

onJoinedSpectators()
{
	self endon("disconnect");
	
	for(;;)
	{
		self waittill("joined_spectators");
		self thread removePlayerHUD();
	}
}

onPlayerSpawned()
{
	self endon("disconnect");
	
	for(;;)
	{
		self waittill("spawned_player");

		if(!isdefined(self.hud_playericon))
		{
            self.hud_playericon = newClientHudElem(self);
            self.hud_playericon.horzAlign = "left";
		    self.hud_playericon.vertAlign = "top";
		    self.hud_playericon.x = 6;
		    self.hud_playericon.y = 28;
		    self.hud_playericon.archived = false;
		}

		if(!isdefined(self.hud_playerscore))
		{
		    self.hud_playerscore = newClientHudElem(self);
		    self.hud_playerscore.horzAlign = "left";
		    self.hud_playerscore.vertAlign = "top";
		    self.hud_playerscore.x = 36;
		    self.hud_playerscore.y = 26;
		    self.hud_playerscore.font = "default";
		    self.hud_playerscore.fontscale = 2;
		    self.hud_playerscore.archived = false;
		}

		assert(self.pers["team"] == "allies" || self.pers["team"] == "axis");
		if(self.pers["team"] == "allies")
			self.hud_playericon setShader(game["hudicon_allies"], 24, 24);
		else
			self.hud_playericon setShader(game["hudicon_axis"], 24, 24);
		
		self thread updatePlayerScoreHUD();
	}
}

onUpdatePlayerScoreHUD()
{
	for(;;)
	{
		self waittill("update_playerscore_hud");
		
		self thread updatePlayerScoreHUD();
	}
}

updatePlayerScoreHUD()
{
	if(isDefined(self.hud_playerscore))
		self.hud_playerscore setValue(self.score);
}

removePlayerHUD()
{
	if(isDefined(self.hud_playericon))
		self.hud_playericon destroy();

	if(isDefined(self.hud_playerscore))
		self.hud_playerscore destroy();
}

