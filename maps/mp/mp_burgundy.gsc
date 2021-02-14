main()
{
	maps\mp\mp_burgundy_fx::main();
	maps\mp\_load::main();

//	setCullFog (0, 16500, 0.7, 0.85, 1.0, 0);
	setExpFog(0.00015, 0.7, 0.85, 1.0, 0);
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

	if((getcvar("g_gametype") == "hq"))
	{
		level.radio = [];
		level.radio[0] = spawn("script_model", (768.8, 58.1, 83.1));
		level.radio[0].angles = (0, 295, 0);
		
		level.radio[1] = spawn("script_model", (428.8, 994.9, 0.1));
		level.radio[1].angles = (0, 70, 0);
		
		level.radio[2] = spawn("script_model", (1978.9, 2085.63, 0.864801));
		level.radio[2].angles = (0.851713, 120.007, 0.491852);
		
		level.radio[3] = spawn("script_model", (1030.3, 442.3, 151.9));
		level.radio[3].angles = (0, 13, 0);
		
		level.radio[4] = spawn("script_model", (226.6, 2515.6, 56));
		level.radio[4].angles = (0, 126, 0);
		
		level.radio[5] = spawn("script_model", (-415.364, 2474.61, -1.73221));
		level.radio[5].angles = (355.978, 180, -1.30946);
		
		
	}
}