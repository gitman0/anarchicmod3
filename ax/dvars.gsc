/* $Id: dvars.gsc 117 2011-02-22 06:39:21Z  $ */

#include ax\utility;

setupDvars()
{
	// static definitions
	level.gametype 					= getcvar("g_gametype");
	level.mapname					= getcvar("mapname");

	// HUD settings + notifications
	level.show_teamscore				= cvardef("scr_show_teamscore", 1, 0, 1, "int");
	level.disable_hitblip				= cvardef("scr_disable_hitblip", 1, 0, 1, "int");
	level.disable_deathicon				= cvardef("scr_disable_deathicon", 1, 0, 1, "int");
	level.ax_announce_next_map			= cvardef("ax_announce_next_map", 120, 0, 3600, "int");
	level.disable_waypoints				= cvardef("ax_disable_waypoints", 1, 0, 1, "int");
	level.disable_grenade_icons			= cvardef("ax_disable_grenade_icons", 1, 0, 1, "int");
	level.ax_show_modlabel				= cvardef("ax_show_modlabel", 1, 0, 1, "int");
	level.ax_show_mini				= cvardef("ax_show_mini", 1, 0, 1, "int");
	level.ax_show_mini_flags			= cvardef("ax_show_mini_flags", 1, 0, 1, "int");
	level.ax_show_mini_headshots			= cvardef("ax_show_mini_headshots", 1, 0, 1, "int");
	level.ax_show_mini_melees			= cvardef("ax_show_mini_melees", 1, 0, 1, "int");
	level.ax_show_rules				= cvardef("ax_show_rules", 1, 0, 1, "int");
	level.ax_show_rules_delay			= cvardef("ax_show_rules_delay", 10, 1, 60, "int");
	level.ax_show_rules_duration			= cvardef("ax_show_rules_duration", 5, 0, 60, "int");
	level.show_healthbar				= cvardef("ax_show_health", 1, 0, 1, "int");
	level.ax_show_players_alive			= cvardef("ax_show_players_alive", 0, 0, 4, "int");

	// gameplay settings
	level.allow_shellshock				= cvardef("ax_allow_shellshock", 1, 0, 1, "int");
	level.spawn_assist				= cvardef("ax_spawn_assist", 0, 0, 3600, "int");

	level.ax_idle_limit				= cvardef("ax_idle_limit", 0, 0, 3600, "int");
	level.ax_idle_warn_count			= cvardef("ax_idle_warn", 2, 0, 720, "int");
	level.voting_minplayers				= cvardef("ax_voting_minplayers", 2, 0, 64, "int");
	level.reverse_spawns				= cvardef("ax_reverse_spawns", 0, 0, 1, "int");
	level.sudden_death_timelimit			= cvardef("ax_sudden_death_timelimit", 0, -1, 1440, "float");
	level.sudden_death_disable_respawn_forced	= cvardef("ax_sudden_death_norespawn", 0, 0, 1, "int");
	level.sudden_death_suppress_tie			= cvardef("ax_sudden_death_notie", 0, 0, 1, "int");
	level.sudden_death_minplayers			= cvardef("ax_sudden_death_minplayers", 1, 0, 32, "int");
	level.ax_scoresave_expire			= cvardef("ax_scoresave_expire", 600, 0, 3600, "int");
	level.ax_teambalance_menu			= cvardef("ax_teambalance_menu", 1, 0, 99, "int");
	level.ax_mvp_system				= cvardef("ax_mvp_system", 1, 0, 1, "int");

	// ctf-specific modifications
	level.ax_ctf_pressurecook			= cvardef("ax_ctf_pressurecook", 0, 0, 86400, "int");	
	level.ax_ctf_warmup				= cvardef("ax_ctf_warmup", 50, 0, 300, "int");
	level.ax_autoreturn_delay			= cvardef("ax_ctf_autoreturn_delay", 120, 0, 86400, "int");
	level.ax_flag_offset				= cvardef("ax_flag_offset", 0, 0, 100, "int");
	level.ax_ctf_wait_for_players			= cvardef("ax_ctf_wait_for_players", 0, 0, 1440, "int");
	level.ax_ctf_round_delay			= cvardef("ax_ctf_round_delay", 10, 0, 300, "int");
	level.flag_hold_return				= cvardef("ax_ctf_flag_hold_return", 0, 0, 1, "int");
	level.flag_hold_return_radius			= cvardef("ax_ctf_flag_hold_return_radius", 100, 0, 5000, "int");
	level.flag_hold_return_time			= cvardef("ax_ctf_flag_hold_return_time", 100, 0, 1000000, "int");
	level.flag_hold_return_multi			= cvardef("ax_ctf_flag_hold_return_multiplier", 1.0, 0.0, 1000000.0, "float");

	// these are currently only supported in ctf
	level.ax_team_switch_delay			= cvardef("ax_team_switch_delay", 0, 0, 86400, "int");
	level.ax_autoassign_score_pct			= cvardef("ax_autoassign_pct_score", 60, 0, 100, "int");
	level.ax_autoassign_team_pct			= cvardef("ax_autoassign_pct_team", 30, 0, 100, "int");
	level.ax_autoassign_forced			= cvardef("ax_autoassign_forced", 0, 0, 1, "int");

	// teamkiller prevention
	level.team_damage_limit				= cvardef("ax_team_damage_limit", 150, 0, 100000, "int");
	level.team_kill_limit				= cvardef("ax_team_kill_limit", 2, 0, 100000, "int");
	level.team_kill_suicide_limit			= cvardef("ax_team_kill_suicide_limit", 4, 0, 100000, "int");
	level.team_kill_timeout				= cvardef("ax_team_kill_timeout", 3, 0, 86400, "int");
	level.team_kill_spawn_penalty			= cvardef("ax_team_kill_spawn_penalty", 10, 0, 600, "int");

	// weapons settings
	level.allied_sniper				= cvardef("ax_weapon_limit_sniper_allied", 64, 0, 64, "int");
	level.axis_sniper				= cvardef("ax_weapon_limit_sniper_axis", 64, 0, 64, "int");
	level.allied_shotty				= cvardef("ax_weapon_limit_shotgun_allied", 64, 0, 64, "int");
	level.axis_shotty				= cvardef("ax_weapon_limit_shotgun_axis", 64, 0, 64, "int");
	level.ax_limit_smokegrenades			= cvardef("ax_weapon_limit_smokegrenades", 0, 1, 128, "int");
	level.ax_scorereq_smokegrenades			= cvardef("ax_weapon_smokegrenade_minscore", 0, 0, 512, "int");
	level.ax_fraggrenade_count			= cvardef("ax_weapon_fraggrenade_count", 0, 0, 128, "int");
	level.ax_drop_grenades				= cvardef("ax_weapon_drop_grenades", 1, 0, 1, "int");
	level.allow_turrets				= cvardef("ax_weapon_allow_turrets", 1, 0, 1, "int");

	// AWE map voting
	level.awe_mapvote 				= cvardef("awe_map_vote", 0, 0, 1, "int");
	level.awe_mapvotetime				= cvardef("awe_map_vote_time", 20, 10, 180, "int");

	// rename unknown players
	level.rename_unknown				= cvardef("scr_rename_unknown_soldier", 0, 0, 1, "int");
	level.rename_unknown_prefix 			= getCvar("scr_rename_unknown_soldier_prefix");
	if ( level.rename_unknown_prefix == "" )	level.rename_unknown_prefix = "^2anarchic-x.com";

	// utilities
	level.ax_debug_spawns				= cvardef("ax_debug_spawns", 0, 0, 2, "int");
	level.ax_spawn_stats				= cvardef("ax_spawn_stats", 0, 0, 1, "int");
	level.ax_admin_chat_prefix			= cvardef("ax_admin_chat_prefix", "^1admin^7CHAT: ");
	level.ax_server_clantag				= cvardef("ax_server_clantag", "^1|^9ax^1|^7 ");

	// experimental
	level.static_crosshair				= cvardef("scr_static_crosshair", 0, 0, 1, "int");
	// level.ax_ctf_oneflag -  0: off, 1: allies defend, 2: axis defend, 3: random
	level.ax_ctf_oneflag				= cvardef("ax_ctf_one_flag", 0, 0, 3, "int");
	level.antiflop					= cvardef("scr_antiflop", 0, 0, 1, "int");
}
