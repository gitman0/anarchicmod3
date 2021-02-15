/* $Id: hud.gsc 112 2011-02-21 03:22:57Z  $ */

#include ax\utility;

init()
{
	level.modlabel_str = &"AX_MOD_STRING";

	defineRuleSet();

	if( !isDefined(game["gamestarted"]) || !game["gamestarted"] )
	{
		if ( level.ax_show_modlabel )
			precacheString(level.modlabel_str);

		if ( level.static_crosshair )
		{
			level.crosshair = "gfx/reticle/center_cross.tga";
			precacheShader(level.crosshair);
		}

		if ( level.ax_show_mini )
		{
			precacheString(&"MP_SLASH");

			if ( level.ax_show_mini_flags && level.gametype == "ctf" )
				precacheShader("gfx/hud/death_suicide.tga");

			if (level.gametype != "dm")
			{
				switch(game["allies"])
				{
					case "american":
						game["headicon_allies"] = "headicon_american";
						break;
					case "british":
						game["headicon_allies"] = "headicon_british";
						break;
					case "russian":
						game["headicon_allies"] = "headicon_russian";
						break;
				}
				game["headicon_axis"] = "headicon_german";
				precacheShader(game["headicon_allies"]);
				precacheShader(game["headicon_axis"]);
			}
			if ( level.ax_show_mini_headshots )
				precacheShader("killiconheadshot");
			if ( level.ax_show_mini_melees )
				precacheShader("killiconmelee");
		}

		if ( level.show_healthbar )
		{
			precacheShader("gfx/hud/hud@health_back.tga");
			precacheShader("gfx/hud/hud@health_bar.tga");
			precacheShader("gfx/hud/hud@health_cross.tga");
		}

		for ( i=0;i<level.ruleset.size;i++ )
			precacheString( level.ruleset[i] );
	}

	if ( level.ax_show_mini && level.gametype != "dm" )
		thread miniscoreboard();

	drawModLabel();
	level thread drawRuleHud();

	level thread onPlayerConnect();
}

onPlayerConnect()
{
	for(;;)
	{
		level waittill("connected", player);

		if ( level.gametype != "dm" )
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

		if ( level.show_healthbar && !isdefined(self.healthbar) )
	        {
	                x = -138;
	                y = 231;
	                maxwidth = 128;

			self.healthbar_back = self doClientHudElem( x, y, "left", "top", "right", "middle" );
			self.healthbar_back setShader("gfx/hud/hud@health_back.tga", maxwidth + 2, 7);

			self.healthbar_cross = self doClientHudElem( (x - 1), y, "right", "top", "right", "middle" );
			self.healthbar_cross setShader("gfx/hud/hud@health_cross.tga", 7, 7);

			self.healthbar = self doClientHudElem( (x + 1), (y + 1), "left", "top", "right", "middle" );
			self.healthbar.color = ( 0, 1, 0);
			self.healthbar setShader("gfx/hud/hud@health_bar.tga", maxwidth, 5);
		}
		self thread updatehealthbar();
		self thread make_crosshair();
		self thread onPlayerKilled();
		self thread playersAlive();
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

		if ( isdefined( self.players_alive_team_flag ) )
			self.players_alive_team_flag destroy();
		if ( isdefined( self.players_alive_enemy_flag ) )
			self.players_alive_enemy_flag destroy();
		if ( isdefined( self.players_alive_team_counter ) )
			self.players_alive_team_counter destroy();
		if ( isdefined( self.players_alive_enemy_counter ) )
			self.players_alive_enemy_counter destroy();
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
	level.ruleset[level.ruleset.size] = &"AX_SPAM13";
	level.ruleset[level.ruleset.size] = &"AX_SPAM14";
}

// shows the server rules
drawRuleHud() {
	level endon("intermission");

	if ( !level.ax_show_rules )
		return;

	rule_duration = level.ax_show_rules_duration;
	rule_delay = level.ax_show_rules_delay;

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

	// game["state"] is being set after this thread starts
	while ( !isdefined(game["state"]) || game["state"] != "playing" )
		wait 0.05;

	while ( isdefined(game["state"]) && game["state"] == "playing" )
	{
		for (i=0; i<level.ruleset.size; i++)
		{
			level.rule_hud setText(level.ruleset[i]);
			level.rule_hud fadeOvertime(1);
			level.rule_hud.alpha = 1;
			wait ( rule_duration + 1 );
			level.rule_hud fadeOvertime(1);
			level.rule_hud.alpha = 0;
			wait ( rule_delay + 1 );
		}
	}
}

drawModLabel() {	
	if ( !level.ax_show_modlabel )
		return;

	if( !isdefined(level.mod_title) )
	{
		level.modlabel_hud = doHudElem( 10, 230, "left", "top", "left", "middle", 0.8 );
		level.modlabel_hud setText( level.modlabel_str );
	}
}

miniscoreboard() {
	level endon("intermission");

	miniscore_seps();	// seperators
	miniscore_flags();	// team flags
	miniscore_teamscore();	// team score

	wait 0.5;

	while (1)
	{
		wait 0.5;

		if ( !isdefined(game["kills_allies"]) || !isdefined(game["kills_axis"]) )
			continue;
		if ( !isdefined(game["deaths_allies"]) || !isdefined(game["deaths_axis"]) )
			continue;

		level.kdhud_kills[0] setValue( game["kills_allies"] );
		level.kdhud_kills[1] setValue( game["kills_axis"] );

		level.kdhud_deaths[0] setValue( game["deaths_allies"] );
		level.kdhud_deaths[1] setValue( game["deaths_axis"] );
	}
}

// setup the seperators (forward slashes)
miniscore_seps()
{
	if ( level.ax_show_players_alive > 0 )
		return;

	sep_x = -24;
	sep_y = -208;

	level.kdhud_sep = [];
	level.kdhud_ratio = [];

	for ( i = 0; i < 3; i++ )
	{
		if (!isdefined(level.kdhud_sep[i]))
		{
			level.kdhud_sep[i] = doHudElem( sep_x, sep_y, "left", "top", "right", "middle", 0.6 );
			level.kdhud_sep[i] setText(&"MP_SLASH");
		}
		sep_y = sep_y + 10;
	}
}

// draw the team flags
miniscore_flags()
{
	if ( !isdefined(level.kdhud_flag0) )
		level.kdhud_flag0 = doHudElem( -54, -201, "left", "top", "right", "middle", 1, 1.5 );

	if ( !isdefined(level.kdhud_flag1) )
		level.kdhud_flag1 = doHudElem( -54, -191, "left", "top", "right", "middle", 1, 1.5 );

	level.kdhud_flag0 setShader( game["headicon_allies"], 12, 12 );
	level.kdhud_flag1 setShader( game["headicon_axis"], 12, 12 );

}

// mini team scoreboard
miniscore_teamscore()
{
	// kills column
	sep_x = -27;
	sep_y = -200;
	level.kdhud_kills = [];

	for ( i = 0; i < 2; i++ )
	{
		if ( !isdefined(level.kdhud_kills[i]) )
			level.kdhud_kills[i] = doHudElem( sep_x, sep_y, "right", "top", "right", "middle", 0.8 );
		sep_y = sep_y + 10;
	}

	// deaths column
	sep_x = -19;
	sep_y = -200;
	level.kdhud_deaths = [];

	for ( i = 0; i < 3; i++ )
	{
		if ( !isdefined(level.kdhud_deaths[i]) )
			level.kdhud_deaths[i] = doHudElem( sep_x, sep_y, "left", "top", "right", "middle", 0.8 );
		sep_y = sep_y + 10;
	}
}

// personal scoreboard
miniscore_myscore() {
	self endon("disconnect");
	level endon("intermission");

        if ( !level.ax_show_mini || level.gametype == "cnq" )
		return;

	if ( level.gametype != "dm" )
	{
		if (!isdefined(self.kdhud_kills))
			self.kdhud_kills = self doClientHudElem( -27, -210, "right", "top", "right", "middle", 0.8 );

		if (!isdefined(self.kdhud_deaths))
			self.kdhud_deaths = self doClientHudElem( -19, -210, "left", "top", "right", "middle", 0.8 );
	}

	if ( level.ax_show_mini_flags && level.gametype == "ctf" ) // third
	{
		if ( !isdefined(self.kdhud_caps) )
			self.kdhud_caps = self doClientHudElem( -45, -130, "center", "middle", "right", "middle", 0.7, 0.8 );

		if ( !isdefined(self.kdhud_caps_count) )
			self.kdhud_caps_count = self doClientHudElem( -24, -130, "left", "middle", "right", "middle", 0.8 );
	}

	if ( level.ax_show_mini_headshots ) // second 
	{
		if ( !isdefined(self.hud_headshot) )
		{
			self.hud_headshot = self doClientHudElem( -45, -160, "center", "middle", "right", "middle", 0.7, 0.6 );
			self.hud_headshot setShader( "killiconheadshot", 11, 11 );
		}

		if ( !isdefined(self.hud_headshot_count) )
			self.hud_headshot_count = self doClientHudElem( -24, -160, "left", "middle", "right", "middle", 0.8 );
	}

	if ( level.ax_show_mini_melees ) // first 
	{
		if ( !isdefined(self.hud_melee) )
		{
			self.hud_melee = self doClientHudElem( -45, -145, "center", "middle", "right", "middle", 0.7, 0.6 );
			self.hud_melee setShader( "killiconmelee", 11, 11 );
		}

		if ( !isdefined(self.hud_melee_count) )
			self.hud_melee_count = self doClientHudElem( -24, -145, "left", "middle", "right", "middle", 0.8 );
	}

	wait 0.5;

	while (1)
	{
		wait 0.5;

		if (!isdefined(self))
			return;

		if (!isdefined(self.pers["kills"]) || !isdefined(self.deaths) || !isdefined(self.pers["flag_caps"]))
			continue;

		if ( isdefined( self.kdhud_kills ) )
			self.kdhud_kills setValue(self.pers["kills"]);
		if ( isdefined( self.kdhud_deaths ) )
			self.kdhud_deaths setValue(self.deaths);

		if ( level.ax_show_mini_flags && level.gametype == "ctf" )
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
		if ( level.ax_show_mini_headshots && isdefined( self.hud_headshot_count ) )
			self.hud_headshot_count setValue( self.pers["headshots"] );

		if ( level.ax_show_mini_melees && isdefined( self.hud_melee_count ) )
			self.hud_melee_count setValue( self.pers["melees"] );
	}

}

playersAlive()
{
	self endon("disconnect");
	self endon("killed_player");

	// 0 - off
	// 1 - your team only
	// 2 - both teams
	// 3 - your team only, sudden death only
	// 4 - both teams, sudden death only

	if ( !level.ax_show_players_alive )
		return;

	if ( level.ax_show_players_alive > 2 && !level.sudden_death_status )
		return;

	playersAliveHud();

	for (;;)
	{
		playersAliveUpdate();
		wait 0.5;
	}
}

playersAliveHud()
{
	flag_pos_team = [];
	flag_pos_enemy = [];

	if ( ( level.ax_show_players_alive % 2 ) == 0 )
	{
		flag_pos_team[0] = -5;
		flag_pos_team[1] = 228;
		flag_pos_enemy = undefined;
	}
	else
	{
		flag_pos_team[0] = -10;
		flag_pos_team[1] = 228;
		flag_pos_enemy[0] = 10;
		flag_pos_enemy[1] = 228;
	}
	
	self.players_alive_team_flag = doClientHudElem( flag_pos_team[0], flag_pos_team[1], "center", "top", "center", "middle", 1, 1.5 );
	self.players_alive_team_counter = doClientHudElem( (flag_pos_team[0] + 10), (flag_pos_team[1] + 2), "center", "top", "center", "middle", 0.7, 1.5 );

	if ( isdefined( flag_pos_enemy ) )
	{
		self.players_alive_enemy_flag = doClientHudElem( flag_pos_enemy[0], flag_pos_enemy[1], "center", "top", "center", "middle", 1, 1.5 );
		self.players_alive_enemy_counter = doClientHudElem( (flag_pos_enemy[0] + 10), (flag_pos_enemy[1] + 2), "center", "top", "center", "middle", 0.7, 1.5 );
	}

	self.players_alive_team_flag setShader( game["headicon_" + self.pers["team"]], 12, 12 );

	if ( isdefined( self.players_alive_enemy_flag ) )
		self.players_alive_enemy_flag setShader( game["headicon_" + otherTeam(self.pers["team"])], 12, 12 );
}

playersAliveUpdate()
{
	playersalive = [];
	playersalive["allies"] = 0;
	playersalive["axis"] = 0;

	players = getentarray("player", "classname");
	for ( i=0; i < players.size; i++ )
	{
		player = players[i];
		if ( isAlive(player) && ( player.pers["team"] == "allies" || player.pers["team"] == "axis" ) )
			playersalive[player.pers["team"]]++;
	}

	if ( isdefined( self.players_alive_team_counter ) )
		self.players_alive_team_counter setValue(playersalive[self.pers["team"]]);
	if ( isdefined( self.players_alive_enemy_counter ) )
		self.players_alive_enemy_counter setValue(playersalive[otherTeam(self.pers["team"])]);
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
