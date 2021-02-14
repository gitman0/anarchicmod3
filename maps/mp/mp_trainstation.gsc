main()
{
	maps\mp\mp_trainstation_fx::main();
	maps\mp\_load::main();

//	setCullFog (0, 10000, 0.7, 0.85, 1.0, 0);
	setExpFog(0.000125, 0.7, 0.85, 1.0, 0);
	ambientPlay("ambient_france");

	game["allies"] = "american";
	game["axis"] = "german";
	game["attackers"] = "allies";
	game["defenders"] = "axis";
	game["american_soldiertype"] = "normandy";
	game["german_soldiertype"] = "normandy";

	setcvar("r_glowbloomintensity0","1");
	setcvar("r_glowbloomintensity1","1");
	setcvar("r_glowskybleedintensity0",".5");

	if(getcvar("g_gametype") == "hq")
	{
	level.radio = [];
		level.radio[0] = spawn("script_model", (7680.83, -3602.28, 18));
		level.radio[0].angles = (0, 297.2, 0);

		level.radio[1] = spawn("script_model", (6954, -3052, -5));
		level.radio[1].angles = (0.000130414, 314.6, 1.64352);

		level.radio[2] = spawn("script_model", (6883, -2418, 23));
		level.radio[2].angles = (0, 348.4, 0);

		level.radio[3] = spawn("script_model", (5689, -2117, 30));
		level.radio[3].angles = (0, 227, 0);

		level.radio[4] = spawn("script_model", (6688.13, -4136.62, -32));
		level.radio[4].angles = (- 0, 109.379, 0);

		level.radio[5] = spawn("script_model", (5598, -4975, -8));
		level.radio[5].angles = (0, 350.4, 0);

		level.radio[6] = spawn("script_model", (5289, -3530, 40));
		level.radio[6].angles = (0, 223.8, 0);

		level.radio[7] = spawn("script_model", (4415, -3532, -32));
		level.radio[7].angles = (0, 316.6, 0);
		
		level.radio[8] = spawn("script_model", (5769.37, -3350.22, 25));
		level.radio[8].angles = (0, 197.179, 0);
		
		level.radio[9] = spawn("script_model", (3787.95, -4388.3, 0.598343));
		level.radio[9].angles = (357.615, 359.479, 0.843511);
		
	}
}
