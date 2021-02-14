#include anarchicmod\utility;

modHud() {	
	if (level.show_modhud != 1)
		return;

	if(!isdefined(level.mod_title))
	{
		level.mod_title = newHudElem();
		level.mod_title.archived = false;
		level.mod_title.x = 10;
		level.mod_title.y = 230;
		level.mod_title.horzAlign = "left";
		level.mod_title.vertAlign = "middle";
		level.mod_title.alignX = "left";
		level.mod_title.alignY = "top";
		level.mod_title.fontScale = 0.8;
		level.mod_title.sort = 1;
		level.mod_title.color = (1, 1, 1);
	}
	level.mod_title setText(level.modstr);
}

// shows the server rules
ruleHud() {
	level endon("intermission");
	if (level.show_rulehud != 1)
		return;
	if (!isdefined(level.rule_hud))
	{
		level.rule_hud = newHudElem();
		level.rule_hud.archived = false;
		level.rule_hud.x = 320;
		level.rule_hud.y = 8;
		level.rule_hud.alignx = "center";
		level.rule_hud.aligny = "top";
		level.rule_hud.fontscale = 0.9;
		//level.mod_title.color = (1,1,1);
	}
	while(isdefined(game["state"]) && game["state"] == "playing")
	{
		for (i=0; i<level.ruleset.size; i++)
		{
			level.rule_hud setText(level.ruleset[i]);
			level.rule_hud fadeOvertime(1);
			level.rule_hud.alpha = 1;
			wait 4;
			level.rule_hud fadeOvertime(1);
			level.rule_hud.alpha = 0;
			wait 3;
		}
	}
}
defineRuleSet()
{
	level.ruleset = [];
	level.ruleset[level.ruleset.size] = &"AX_SPAM0";
	level.ruleset[level.ruleset.size] = &"AX_SPAM1";
	level.ruleset[level.ruleset.size] = &"AX_SPAM2";
	level.ruleset[level.ruleset.size] = &"AX_SPAM3";
	level.ruleset[level.ruleset.size] = &"AX_SPAM4";
	level.ruleset[level.ruleset.size] = &"AX_SPAM5";
	level.ruleset[level.ruleset.size] = &"AX_SPAM6";
	level.ruleset[level.ruleset.size] = &"AX_SPAM7";
	level.ruleset[level.ruleset.size] = &"AX_SPAM8";
	level.ruleset[level.ruleset.size] = &"AX_SPAM9";
	level.ruleset[level.ruleset.size] = &"AX_SPAM10";
	level.ruleset[level.ruleset.size] = &"AX_SPAM11";
	level.ruleset[level.ruleset.size] = &"AX_SPAM12";
	level.ruleset[level.ruleset.size] = &"AX_SPAM13";
	level.ruleset[level.ruleset.size] = &"AX_SPAM14";
	level.ruleset[level.ruleset.size] = &"AX_SPAM15";
	level.ruleset[level.ruleset.size] = &"AX_SPAM16";
}

miniscoreboard() {
	level endon("intermission");

	miniscore_seps();	// seperators
	miniscore_flags();	// team flags
	miniscore_teamscore();	// team score

	wait 0.05;

	while (1) {
		if (!isdefined(game["kills_allies"]) || !isdefined(game["kills_axis"]))
			continue;
		if (!isdefined(game["deaths_allies"]) || !isdefined(game["deaths_axis"]))
			continue;

		level.kdhud_kills[0] setValue(game["kills_allies"]);
		level.kdhud_kills[1] setValue(game["kills_axis"]);
		level.kdhud_deaths[0] setValue(game["deaths_allies"]);
		level.kdhud_deaths[1] setValue(game["deaths_axis"]);

		wait 0.5;
	}
}

miniscore_seps() {
	// setup the seperators
	sep_x = -24;
	sep_y = -208;
	//sep_x = 616;
	//sep_y = 32;

	level.kdhud_sep = [];
	level.kdhud_ratio = [];

	for (i = 0; i < 3; i++) {
		if (!isdefined(self.kdhud_sep[i])) {
			level.kdhud_sep[i] = newHudElem();
			level.kdhud_sep[i].archived = false;
			level.kdhud_sep[i].x = sep_x;
			level.kdhud_sep[i].y = sep_y;
			level.kdhud_sep[i].horzAlign = "right";
			level.kdhud_sep[i].vertAlign = "middle";
			level.kdhud_sep[i].alignX = "left";
			level.kdhud_sep[i].alignY = "top";
			level.kdhud_sep[i].fontScale = 0.6;
			level.kdhud_sep[i].sort = 1;
			level.kdhud_sep[i].color = (1, 1, 1);		
		}
		sep_y = sep_y + 10;
		level.kdhud_sep[i] setText(&"/");
	}
}
miniscore_flags() {
	if(!isdefined(level.kdhud_flag0))
	{
		level.kdhud_flag0 = newHudElem();
		level.kdhud_flag0.archived = false;
		level.kdhud_flag0.x = -54;
		level.kdhud_flag0.y = -201;
		level.kdhud_flag0.horzAlign = "right";
		level.kdhud_flag0.vertAlign = "middle";
		level.kdhud_flag0.alignX = "left";
		level.kdhud_flag0.alignY = "top";
		level.kdhud_flag0.sort = 1;
		level.kdhud_flag0.alpha = 1.5;
	}
	if(!isdefined(level.kdhud_flag1))
	{
		level.kdhud_flag1 = newHudElem();
		level.kdhud_flag1.archived = false;
		level.kdhud_flag1.x = -54;
		level.kdhud_flag1.y = -191;
		level.kdhud_flag1.horzAlign = "right";
		level.kdhud_flag1.vertAlign = "middle";
		level.kdhud_flag1.alignX = "left";
		level.kdhud_flag1.alignY = "top";
		level.kdhud_flag1.sort = 1;
		level.kdhud_flag1.alpha = 1.5;
	}
	level.kdhud_flag0 setShader(game["headicon_allies"], 12, 12);
	level.kdhud_flag1 setShader(game["headicon_axis"], 12, 12);

}
miniscore_teamscore() {
	// setup the column for kills
	sep_x = -27;
	sep_y = -200;
	level.kdhud_kills = [];

	for (i = 0; i < 2; i++) {
		if (!isdefined(level.kdhud_kills[i])) {
			level.kdhud_kills[i] = newHudElem();
			level.kdhud_kills[i].archived = false;
			level.kdhud_kills[i].x = sep_x;
			level.kdhud_kills[i].y = sep_y;
			level.kdhud_kills[i].horzAlign = "right";
			level.kdhud_kills[i].vertAlign = "middle";
			level.kdhud_kills[i].alignX = "right";
			level.kdhud_kills[i].alignY = "top";
			level.kdhud_kills[i].fontScale = 0.8;
			level.kdhud_kills[i].sort = 0.8;
			level.kdhud_kills[i].color = (1, 1, 1);		
		}
		sep_y = sep_y + 10;
	}

	// setup the column for deaths
	sep_x = -19;
	sep_y = -200;
	level.kdhud_deaths = [];

	for (i = 0; i < 3; i++) {
		if (!isdefined(level.kdhud_deaths[i])) {
			level.kdhud_deaths[i] = newHudElem();
			level.kdhud_deaths[i].archived = false;
			level.kdhud_deaths[i].x = sep_x;
			level.kdhud_deaths[i].y = sep_y;
			level.kdhud_deaths[i].horzAlign = "right";
			level.kdhud_deaths[i].vertAlign = "middle";
			level.kdhud_deaths[i].alignX = "left";
			level.kdhud_deaths[i].alignY = "top";
			level.kdhud_deaths[i].fontScale = 0.8;
			level.kdhud_deaths[i].sort = 0.8;
			level.kdhud_deaths[i].color = (1, 1, 1);		
		}
		sep_y = sep_y + 10;
	}
}
miniscore_myscore() {
	self endon("disconnect");
	level endon("intermission");
	if (!isdefined(self.kdhud_kills)) {
		self.kdhud_kills = newClientHudElem(self);
		self.kdhud_kills.archived = false;
		self.kdhud_kills.x = -27;
		self.kdhud_kills.y = -210;
		self.kdhud_kills.horzAlign = "right";
		self.kdhud_kills.vertAlign = "middle";
		self.kdhud_kills.alignX = "right";
		self.kdhud_kills.alignY = "top";
		self.kdhud_kills.fontScale = 0.8;
		self.kdhud_kills.sort = 0.8;
		self.kdhud_kills.color = (1, 1, 1);		
	}
	if (!isdefined(self.kdhud_deaths)) {
		self.kdhud_deaths = newClientHudElem(self);
		self.kdhud_deaths.archived = false;
		self.kdhud_deaths.x = -19;
		self.kdhud_deaths.y = -210;
		self.kdhud_deaths.horzAlign = "right";
		self.kdhud_deaths.vertAlign = "middle";
		self.kdhud_deaths.alignX = "left";
		self.kdhud_deaths.alignY = "top";
		self.kdhud_deaths.fontScale = 0.8;
		self.kdhud_deaths.sort = 0.8;
		self.kdhud_deaths.color = (1, 1, 1);		
	}
	if (level.gametype == "ctf") {
		if (!isdefined(self.kdhud_caps)) {
			self.kdhud_caps = newClientHudElem(self);
			self.kdhud_caps.archived = false;
			self.kdhud_caps.x = -45;
			self.kdhud_caps.y = -145;
			self.kdhud_caps.horzAlign = "right";
			self.kdhud_caps.vertAlign = "middle";
			self.kdhud_caps.alignX = "center";
			self.kdhud_caps.alignY = "middle";
			self.kdhud_caps.fontScale = 0.7;
			self.kdhud_caps.sort = 0.8;
			self.kdhud_caps.color = (1, 1, 1);
			self.kdhud_caps.alpha = 0.8;
			//self.kdhud_caps setText(&"Caps:");
			
		}
		if (!isdefined(self.kdhud_caps_count)) {
			self.kdhud_caps_count = newClientHudElem(self);
			self.kdhud_caps_count.archived = false;
			self.kdhud_caps_count.x = -24;
			self.kdhud_caps_count.y = -145;
			self.kdhud_caps_count.horzAlign = "right";
			self.kdhud_caps_count.vertAlign = "middle";
			self.kdhud_caps_count.alignX = "left";
			self.kdhud_caps_count.alignY = "middle";
			self.kdhud_caps_count.fontScale = 0.8;
			self.kdhud_caps_count.sort = 0.8;
			self.kdhud_caps_count.color = (1, 1, 1);
		}
	}
	if (level.show_headshots) {
		if (!isdefined(self.hud_headshot)) {
			self.hud_headshot = newClientHudElem(self);
			self.hud_headshot.archived = false;
			self.hud_headshot.x = -45;
			self.hud_headshot.y = -160;
			self.hud_headshot.horzAlign = "right";
			self.hud_headshot.vertAlign = "middle";
			self.hud_headshot.alignX = "center";
			self.hud_headshot.alignY = "middle";
			self.hud_headshot.fontScale = 0.7;
			self.hud_headshot.sort = 0.8;
			self.hud_headshot.color = (1, 1, 1);
			self.hud_headshot.alpha = 0.6;
			self.hud_headshot setShader("killiconheadshot", 11, 11);
		}
		if (!isdefined(self.hud_headshot_count)) {
			self.hud_headshot_count = newClientHudElem(self);
			self.hud_headshot_count.archived = false;
			self.hud_headshot_count.x = -24;
			self.hud_headshot_count.y = -160;
			self.hud_headshot_count.horzAlign = "right";
			self.hud_headshot_count.vertAlign = "middle";
			self.hud_headshot_count.alignX = "left";
			self.hud_headshot_count.alignY = "middle";
			self.hud_headshot_count.fontScale = 0.8;
			self.hud_headshot_count.sort = 0.8;
			self.hud_headshot_count.color = (1, 1, 1);
		}
	}

	wait 0.05;

	while (1) {
		if (!isdefined(self))
			return;

		if (!isdefined(self.pers["kills"]) || !isdefined(self.deaths) || !isdefined(self.pers["flag_caps"]))
			continue;

		self.kdhud_kills setValue(self.pers["kills"]);
		self.kdhud_deaths setValue(self.deaths);
		if (level.gametype == "ctf")
		{
			self.kdhud_caps_count setValue(self.pers["flag_caps"]);
			if (!isdefined(self.pers["team"]))
				continue;
			switch(self.pers["team"])
			{
				case "allies":
						icon = "compass_flag_" + game["axis"];
						break;
				case "axis":
						icon = "compass_flag_" + game["allies"];
						break;
					default:
						icon = "gfx/hud/death_suicide.tga";
			}
			self.kdhud_caps setShader(icon, 14, 14);
		}
		if (level.show_headshots)
			self.hud_headshot_count setValue(self.pers["headshots"]);
		wait 0.5;
	}

}