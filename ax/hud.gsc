init()
{
	level.modlabel_str = &"AX_MOD_STRING";

	defineRuleSet();

	if(!isDefined(game["gamestarted"]))
	{
		precacheString(level.modlabel_str);

		precacheString(&"MP_SLASH");

		precacheShader("gfx/hud/death_suicide.tga");

		if (level.static_crosshair) {
			level.crosshair = "gfx/reticle/center_cross.tga";
			precacheShader(level.crosshair);
		}
		if (level.gametype != "dm") {
			precacheShader(game["headicon_allies"]);
			precacheShader(game["headicon_axis"]);
		}
		precacheShader("killiconheadshot");
		precacheShader("killiconmelee");

		if(level.show_healthbar)
		{
			precacheShader("gfx/hud/hud@health_back.tga");
			precacheShader("gfx/hud/hud@health_bar.tga");
			precacheShader("gfx/hud/hud@health_cross.tga");
		}

		for (i=0;i<level.ruleset.size;i++)
			precacheString(level.ruleset[i]);
	}

	if ((level.show_kdhud) && (level.gametype != "dm"))
		thread miniscoreboard();

	drawModLabel();
	level thread drawRuleHud();

	level thread onPlayerConnect();
}

onPlayerConnect()
{
	for(;;)
	{
		level waittill("connecting", player);

		player thread miniscore_myscore();
		player thread onPlayerSpawned();
	}
}

onPlayerSpawned()
{
	self endon("disconnect");

	for(;;)
	{
		self waittill("spawned_player");

		if(level.show_healthbar && !isdefined(self.healthbar))
	        {
	                x = -138;
	                y = 231;
	                maxwidth = 128;

			self.healthbar_back = newClientHudElem( self );
			self.healthbar_back setShader("gfx/hud/hud@health_back.tga", maxwidth + 2, 7);
			self.healthbar_back.alignX = "left";
			self.healthbar_back.alignY = "top";
			self.healthbar_back.horzAlign = "right";
			self.healthbar_back.vertAlign = "middle";
			self.healthbar_back.x = x;
			self.healthbar_back.y = y;
	
			self.healthbar_cross = newClientHudElem( self );
			self.healthbar_cross setShader("gfx/hud/hud@health_cross.tga", 7, 7);
			self.healthbar_cross.alignX = "right";
			self.healthbar_cross.alignY = "top";
			self.healthbar_cross.horzAlign = "right";
			self.healthbar_cross.vertAlign = "middle";
			self.healthbar_cross.x = x - 1;
			self.healthbar_cross.y = y;
        
			self.healthbar = newClientHudElem( self );
			self.healthbar setShader("gfx/hud/hud@health_bar.tga", maxwidth, 5);
			self.healthbar.color = ( 0, 1, 0);
			self.healthbar.alignX = "left";
			self.healthbar.alignY = "top";
			self.healthbar.horzAlign = "right";
			self.healthbar.vertAlign = "middle";
			self.healthbar.x = x + 1;
			self.healthbar.y = y + 1;
		}
		self thread updatehealthbar();
		self thread make_crosshair();
		self thread onPlayerKilled();
	}
}

onPlayerKilled()
{
	self endon("disconnect");

	for(;;)
	{
		self waittill("killed_player");

		if (isdefined(self.healthbar))
			self.healthbar destroy();
		if (isdefined(self.healthbar_back))
			self.healthbar_back destroy();
		if (isdefined(self.healthbar_cross))
			self.healthbar_cross destroy();
	}
}

UpdateHealthBar()
{       
	level endon("intermission");
	self endon("killed_player");

	if (!level.show_healthbar)
		return;
	
	for (;;) {

		wait 0.05;

	        if(!isdefined(self.healthbar))
        	        continue;  
         
	        maxwidth = 128;

	        health = self.health / self.maxhealth;
                
        	hud_width = int(health * maxwidth);
                        
	        if ( hud_width < 1 )
        	        hud_width = 1;
                                
	        self.healthbar setShader("gfx/hud/hud@health_bar.tga", hud_width, 5);
        	self.healthbar.color = ( 1.0 - health, health, 0);
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
}

// shows the server rules
drawRuleHud() {
	level endon("intermission");

	if (level.show_rulehud != 1)
		return;

	rule_duration = 4;
	rule_delay = 3;

	if (!isdefined(level.rule_hud))
	{
		level.rule_hud = newHudElem();
		level.rule_hud.archived = false;
		level.rule_hud.x = 320;
		level.rule_hud.y = 8;
		level.rule_hud.alignx = "center";
		level.rule_hud.aligny = "top";
		level.rule_hud.fontscale = 0.9;
	}
	while ( isdefined(game["state"]) && game["state"] == "playing" )
	{
		for (i=0; i<level.ruleset.size; i++)
		{
			level.rule_hud setText(level.ruleset[i]);
			level.rule_hud fadeOvertime(1);
			level.rule_hud.alpha = 1;
			wait rule_duration;
			level.rule_hud fadeOvertime(1);
			level.rule_hud.alpha = 0;
			wait rule_delay;
		}
	}
}

drawModLabel() {	
	if (level.show_modlabel != 1)
		return;

	if(!isdefined(level.mod_title))
	{
		level.modlabel_hud = newHudElem();
		level.modlabel_hud.archived = false;
		level.modlabel_hud.x = 10;
		level.modlabel_hud.y = 230;
		level.modlabel_hud.horzAlign = "left";
		level.modlabel_hud.vertAlign = "middle";
		level.modlabel_hud.alignX = "left";
		level.modlabel_hud.alignY = "top";
		level.modlabel_hud.fontScale = 0.8;
		level.modlabel_hud.sort = 1;
		level.modlabel_hud.color = (1, 1, 1);
	}
	level.modlabel_hud setText(level.modlabel_str);
}

miniscoreboard() {
	level endon("intermission");

	miniscore_seps();	// seperators
	miniscore_flags();	// team flags
	miniscore_teamscore();	// team score

	wait 0.5;

	while (1) {
		wait 0.5;

		if (!isdefined(game["kills_allies"]) || !isdefined(game["kills_axis"]))
			continue;
		if (!isdefined(game["deaths_allies"]) || !isdefined(game["deaths_axis"]))
			continue;

		level.kdhud_kills[0] setValue(game["kills_allies"]);
		level.kdhud_kills[1] setValue(game["kills_axis"]);
		level.kdhud_deaths[0] setValue(game["deaths_allies"]);
		level.kdhud_deaths[1] setValue(game["deaths_axis"]);
	}
}

// setup the seperators
miniscore_seps() {
	sep_x = -24;
	sep_y = -208;

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
		level.kdhud_sep[i] setText(&"MP_SLASH");
	}
}

// draw the team flags
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

// mini team scoreboard
miniscore_teamscore() {
	// kills column
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

	// deaths column
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

// personal scoreboard
miniscore_myscore() {
	self endon("disconnect");
	level endon("intermission");

        if ( !level.show_kdhud || level.gametype == "cnq" )
		return;

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

	wait 0.5;

	while (1) {
		wait 0.5;

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
	}

}

make_crosshair()
{
	if (!level.static_crosshair)
		return;
	if (!isdefined(self.crosshair))
	{
		self.crosshair = newClientHudElem(self);
		self.crosshair.x = 320;
		self.crosshair.y = 240;
		self.crosshair.alignx = "center";
		self.crosshair.aligny = "middle";
		self.crosshair setshader(level.crosshair, 64, 64);
	}
}

hudelemText(alignx, aligny, x, y, alpha, fontscale, color, sort, textval)
{
	text = newClientHudElem( self );
	text.alignX = alignx;
	text.alignY = aligny;
	text.X = x;
	text.Y = y;
	text.alpha = alpha;
	text.fontScale = fontscale;
	text.color = color;
	text.sort = sort;
	text setText(textval);
	return text;
}

hudelemShader(alignx, aligny, x, y, alpha, color, shaderval, w, h)
{
	shader = newClientHudElem( self );
	shader.alignX = alignx;
	shader.alignY = aligny;
	shader.X = x;
	shader.Y = y;
	shader.alpha = alpha;
	shader.color = color;
	shader setShader(shaderval, w, h);
	return shader;
}
