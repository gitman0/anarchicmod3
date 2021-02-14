#include ax\utility;

init()
{
	level thread showNextMap();
	level thread rotationHistory();
}

rotationHistory()
{
	level waittill("intermission");

	limit = cvardef("scr_past_rotation_mem", 10, 0, 30, "int");
	r = getcvar("scr_past_rotation");
	if ( r == "" )
		setcvar("scr_past_rotation", level.mapname);
	else
	{
		past = "";
		m = explode(r, ",");
		m[m.size] = level.mapname;

		if ( m.size <= limit ) i = 0;
		else i = ( m.size - limit );

		start = i;

		while ( i < m.size )
		{
			if ( i == start) s = m[i];
			else s = "," + m[i];
			past = past + s;
			i++;
		}
		setcvar("scr_past_rotation", past);
	}
}

showNextMap()
{
	level endon("intermission");

	if ( !level.nextmap_display || level.awe_mapvote )
		return;

	for (;;) {
		maprotcur = strip(getcvar("sv_maprotationcurrent"));
		if(maprotcur == "")
			maprotcur = strip(getcvar("sv_maprotation"));
		if (maprotcur != "") {
			temparr = explode(maprotcur," ");
			if(temparr[0]=="gametype") {
				nextgt=temparr[1];
				nextmap=temparr[3];
			}
			else {
				nextgt=getcvar("g_gametype");
				nextmap=temparr[1];
			}
			durr = nextmap + " (" + nextgt + ")";
			iprintln(&"AX_NEXTMAP", localizedMap(nextmap), &"AX_NEXTMAP_SEP1", localizedGametype(nextgt), &"AX_NEXTMAP_SEP2");
		}
		wait level.nextmap_delay;
	}
}

localizedGametype(gt) {
	switch (gt) {
		case "tdm": return &"MPUI_TEAM_DEATHMATCH";
		case "dm": return &"MPUI_DEATHMATCH";
		case "ctf": return &"MPUI_CAPTURE_THE_FLAG";
		case "hq": return &"MPUI_HEADQUARTERS";
		case "sd": return &"MPUI_SEARCH_AND_DESTROY";
		case "rtdm": return "Rifles-Only TDM";
		case "lts": return "Last Team Standing";
	}
}
localizedMap(map) {
	switch (map) {
		case "mp_brecourt": return &"MENU_BRECOURT_FRANCE_MP";
		case "mp_burgundy": return &"MENU_BURGUNDY_FRANCE_MP";
		case "mp_trainstation": return &"MENU_CAEN_FRANCE_MP";
		case "mp_carentan": return &"MENU_CARENTAN_FRANCE_MP";
		case "mp_decoy": return &"MENU_EL_ALAMEIN_EGYPT_MP";
		case "mp_leningrad": return &"MENU_LENINGRAD_RUSSIA_MP";
		case "mp_matmata": return &"MENU_MATMATA_TUNISIA_MP";
		case "mp_downtown": return &"MENU_MOSCOW_RUSSIA_MP";
		case "mp_dawnville": return &"MENU_ST_MERE_EGLISE_FRANCE_MP";
		case "mp_railyard": return &"MENU_STALINGRAD_RUSSIA_MP";
		case "mp_toujane": return &"MENU_TOUJANE_TUNISIA_MP";
		case "mp_farmhouse": return &"MENU_BELTOT_FRANCE_MP";
		case "mp_breakout": return &"MENU_VILLERSBOCAGE_FRANCE_MP";
		case "mp_harbor": return &"AX_ROSTOV_RUSSIA_MP";
		case "mp_rhine": return &"AX_WALLENDER_GERMANY_MP";
		default: return map;
	}
}

