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