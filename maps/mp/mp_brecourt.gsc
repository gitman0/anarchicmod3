main()
{
	maps\mp\mp_brecourt_fx::main();
	maps\mp\_load::main();

//	setCullFog(0, 7000, 0.30, 0.31, 0.34, 0);
	setExpFog(0.0001, 0.30, 0.31, 0.34, 0);
	ambientPlay("ambient_france");

	game["allies"] = "american";
	game["axis"] = "german";
	game["attackers"] = "allies";
	game["defenders"] = "axis";
	game["american_soldiertype"] = "normandy";
	game["german_soldiertype"] = "normandy";

	setcvar("r_glowbloomintensity0","1");
	setcvar("r_glowbloomintensity1","1");
	setcvar("r_glowskybleedintensity0",".25");

	if(getcvar("g_gametype") == "hq")
	{
		level.radio = [];
		level.radio[0] = spawn("script_model", (-2924.2, 1286.5, 25.6));
		level.radio[0].angles = (0, 315, 0);
		level.radio[1] = spawn("script_model", (2155.4, 675.6, -26.3));
		level.radio[1].angles = (0, 30, 0);
		level.radio[2] = spawn("script_model", (882.8, -243.1, 11));
		level.radio[2].angles = (0, 105, 0);
		level.radio[3] = spawn("script_model", (-1137.5, -2552.5, -15.9));
		level.radio[3].angles = (0, 151, 0);
		level.radio[4] = spawn("script_model", (1921.4, -2695, 35.7));
		level.radio[4].angles = (0, 108, 0);
		level.radio[5] = spawn("script_model", (1115.6, -1119.3, -3.2));
		level.radio[5].angles = (0, 1.5, 0);
		level.radio[6] = spawn("script_model", (2982.2, -828.7, -16.2));
		level.radio[6].angles = (0, 62, 0);
		level.radio[7] = spawn("script_model", (-1136.8, -740.3, 47.8));
		level.radio[7].angles = (0, 305, 0);
	}
}
