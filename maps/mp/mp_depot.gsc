main()
{
	maps\mp\_load::main();
	maps\mp\mp_depot_fx::main();

	setExpFog(0.0001, 0.55, 0.7, 0.6, 0);
	ambientPlay("ambient_france");

	game["allies"] = "british";
	game["axis"] = "german";
	game["attackers"] = "allies";
	game["defenders"] = "axis";
	game["american_soldiertype"] = "normandy";
	game["german_soldiertype"] = "normandy";

	setCvar("r_glowbloomintensity0", ".25");
	setCvar("r_glowbloomintensity1", ".25");
	setcvar("r_glowskybleedintensity0",".3");

	if((getcvar("g_gametype") == "hq"))
	{
		level.radio = [];
		level.radio[0] = spawn("script_model", (335.768, -1812.82, 198));
		level.radio[0].angles = (0, 135, 0);
		
		level.radio[1] = spawn("script_model", (-166.328, -730.414, 323));
		level.radio[1].angles = (0, 90, 0);
		
		level.radio[2] = spawn("script_model", (-167.328, -1587.41, 323));
		level.radio[2].angles = (0, 90, 0);
		
		level.radio[3] = spawn("script_model", (-1659.41, -1811.67, 63));
		level.radio[3].angles = (0, 141.8, 0);
		
		level.radio[4] = spawn("script_model", (-1394.74, -1044.38, 63));
		level.radio[4].angles = (0, 180, 0);
		
		level.radio[5] = spawn("script_model", (5638, 4325, -2));
		level.radio[5].angles = (357.526, 275.319, 3.96995);
		
		level.radio[6] = spawn("script_model", (-1875.62, -1476.74, 14));
		level.radio[6].angles = (0, 270, 0);
		
		level.radio[7] = spawn("script_model", (-1402.9, -3429.47, 14));
		level.radio[7].angles = (0, 0, 0);
		
		level.radio[8] = spawn("script_model", (-70.6796, -3041.36, 14));
		level.radio[8].angles = (0, 30, 0);

		level.radio[8] = spawn("script_model", (-138.403, -1722.73, 14));
		level.radio[8].angles = (0, 225, 0);

		level.radio[9] = spawn("script_model", (304.597, -543.733, 76));
		level.radio[9].angles = (0, 225, 0);

		level.radio[10] = spawn("script_model", (-187.743, 489.327, 63));
		level.radio[10].angles = (0, 180, 0);
	}

}