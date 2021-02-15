/* $Id: dvars.gsc 86 2010-10-02 01:28:00Z  $ */

#include ax\utility;

setupDvars()
{
	// static definitions
	level.gametype 			= getcvar("g_gametype");
	level.mapname			= getcvar("mapname");

	// HUD settings + notifications
	level.show_rulehud		= cvardef("scr_show_rules", 1, 0, 1, "int");
	level.show_teamscore		= cvardef("scr_show_teamscore", 1, 0, 1, "int");
	level.show_healthbar		= cvardef("scr_show_healthbar", 1, 0, 1, "int");
	level.static_crosshair		= cvardef("scr_static_crosshair", 0, 0, 1, "int");
	level.old_headicons		= cvardef("scr_old_headicons", 1, 0, 1, "int");
	level.nextmap_display		= cvardef("scr_show_nextmap", 1, 0, 1, "int");
	level.nextmap_delay		= cvardef("scr_show_nextmap_delay", 120, 60, 900, "int");
	level.disable_red_crosshair	= cvardef("scr_disable_red_crosshair", 1, 0, 1, "int");
	level.disable_hitblip		= cvardef("scr_disable_hitblip", 1, 0, 1, "int");
	level.disable_deathicon		= cvardef("scr_disable_deathicon", 1, 0, 1, "int");
	level.disable_waypoints		= cvardef("ax_disable_waypoints", 1, 0, 1, "int");
	level.disable_grenade_icons	= cvardef("ax_disable_grenade_icons", 1, 0, 1, "int");
	level.ax_show_modlabel		= cvardef("ax_show_modlabel", 1, 0, 1, "int");
	level.ax_show_mini		= cvardef("ax_show_mini", 1, 0, 1, "int");
	level.ax_show_mini_flags	= cvardef("ax_show_mini_flags", 1, 0, 1, "int");
	level.ax_show_mini_headshots	= cvardef("ax_show_mini_headshots", 1, 0, 1, "int");
	level.ax_show_mini_melees	= cvardef("ax_show_mini_melees", 1, 0, 1, "int");
	level.ax_show_rules		= cvardef("ax_show_rules", 1, 0, 1, "int");
	level.ax_show_rules_delay	= cvardef("ax_show_rules_delay", 10, 1, 60, "int");
	level.ax_show_rules_duration	= cvardef("ax_show_rules_duration", 5, 0, 60, "int");

	// gameplay settings
	level.allow_shellshock		= cvardef("ax_allow_shellshock", 1, 0, 1, "int");
	level.antiflop			= cvardef("scr_antiflop", 0, 0, 1, "int");
	level.spawn_assist		= cvardef("scr_spawn_assist", 0, 0, 99, "int");
	level.static_nade_count		= cvardef("scr_static_nades", 0, 0, 99, "int");
	level.dropnades			= cvardef("scr_dropnades", 1, 0, 1, "int");
	level.allow_turrets		= cvardef("scr_allow_turrets", 1, 0, 1, "int");
	level.ctf_warmup		= cvardef("scr_ctf_warmup", 50, 0, 300, "int");
	level.ctf_autoreturn_delay	= cvardef("scr_ctf_autoreturn_delay", 120, 0, 1440, "int");
	level.idle_limit		= cvardef("scr_idle_limit", 0, 0, 3600, "int");
	level.idle_warn_count		= cvardef("scr_idle_warn", 2, 0, 720, "int");
	level.voting_minplayers		= cvardef("ax_voting_minplayers", 2, 0, 64, "int");
	level.reverse_spawns		= cvardef("ax_reverse_spawns", 0, 0, 1, "int");
	level.sudden_death_timelimit	= cvardef("ax_sudden_death_timelimit", 0, -1, 1440, "int");
	level.sudden_death_f_norespawn	= cvardef("ax_sudden_death_norespawn", 0, 0, 1, "int");
	level.sudden_death_notie	= cvardef("ax_sudden_death_notie", 0, 0, 1, "int");
	level.sudden_death_minplayers	= cvardef("ax_sudden_death_minplayers", 1, 0, 32, "int");
	level.ax_scoresave_expire	= cvardef("ax_scoresave_expire", 600, 0, 3600, "int");
	level.ax_teambalance_menu	= cvardef("ax_teambalance_menu", 1, 0, 99, "int");
	level.ax_ctf_pressurecook	= cvardef("ax_ctf_pressurecook", 0, 0, 1440, "float");	

	// teamkiller prevention
	level.team_damage_limit		= cvardef("scr_team_damage_limit", 150, 0, 9999, "int");
	level.team_kill_limit		= cvardef("scr_team_kill_limit", 2, 0, 9999, "int");
	level.team_kill_suicide_limit	= cvardef("scr_team_kill_suicide_limit", 4, 0, 9999, "int");
	level.team_kill_timeout		= cvardef("scr_team_kill_timeout", 3, 0, 9999, "int");

	// weapon limits
	level.allied_sniper		= cvardef("scr_limit_sniper_allied", 99, 0, 99, "int");
	level.allied_shotty		= cvardef("scr_limit_shotgun_allied", 99, 0, 99, "int");
	level.axis_sniper		= cvardef("scr_limit_sniper_axis", 99, 0, 99, "int");
	level.axis_shotty		= cvardef("scr_limit_shotgun_axis", 99, 0, 99, "int");

	// AWE map voting
	level.awe_mapvote 		= cvardef("awe_map_vote", 0, 0, 1, "int");
	level.awe_mapvotetime		= cvardef("awe_map_vote_time", 20, 10, 180, "int");

	// rename unknown players
	level.rename_unknown		= cvardef("scr_rename_unknown_soldier", 0, 0, 1, "int");
	level.rename_unknown_prefix 	= getCvar("scr_rename_unknown_soldier_prefix");
	if (level.rename_unknown_prefix == "")
		level.rename_unknown_prefix = "^2anarchic-x.com";

	// anarchicmod utilities
	level.ax_debug_spawns		= cvardef("ax_debug_spawns", 0, 0, 2, "int");
	level.ax_spawn_stats		= cvardef("ax_spawn_stats", 0, 0, 1, "int");
	level.ax_flag_offset		= cvardef("ax_flag_offset", 0, 0, 100, "int");
	level.ax_admin_chat_prefix	= cvardef("ax_admin_chat_prefix", "^1admin^7CHAT: ");
	level.ax_server_clantag		= cvardef("ax_server_clantag", "^1|^9ax^1|^7 ");
}
