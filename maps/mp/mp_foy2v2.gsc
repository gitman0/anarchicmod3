#include ax\exploit_blocker;

main()
{
	maps\mp\mp_foy2v2_fx::main();
	maps\mp\_load::main();

	setEXPFog (.00044, .5254, .6117, .7215, 40 );

	ambientPlay("mp_foy2v2");

	game["allies"] = "american";
	game["axis"] = "german";
	game["attackers"] = "allies";
	game["defenders"] = "axis";
	game["american_soldiertype"] = "normandy";
	game["german_soldiertype"] = "winterlight";

	setCvar("r_glowbloomintensity0", ".25");
	setCvar("r_glowbloomintensity1", ".25");
	setcvar("r_glowskybleedintensity0",".3");

	if(getcvar("g_gametype") == "hq")
	{
		level.radio = [];

		level.radio[0] = spawn("script_model", (-105.645, 928, 1.00341));
		level.radio[0].angles = (358.9, 0, 0);

		level.radio[1] = spawn("script_model", (-759.323, -111, 7.9941));
		level.radio[1].angles = (359.9, 0.000708397, -0.00012213);

		level.radio[2] = spawn("script_model", (-1728, -1092, 9));
		level.radio[2].angles = (0, 90, 0);

		level.radio[3] = spawn("script_model", (-2457, -2712, 8));
		level.radio[3].angles = (0, 90, 0);

		level.radio[4] = spawn("script_model", (2406, -3112, 8));
		level.radio[4].angles = (0, 90, 0);

		level.radio[5] = spawn("script_model", (2653, -1781, 72));
		level.radio[5].angles = (0, 90, 0);

		level.radio[6] = spawn("script_model", (2863, -655, 72));
		level.radio[6].angles = (0, 90, 0);

		level.radio[7] = spawn("script_model", (3713.96, 650, 66.4503));
		level.radio[7].angles = (0, 90, 0);

		level.radio[8] = spawn("script_model", (1122.96, -928, 0.450348));
		level.radio[8].angles = (0, 90, 0);
	}

	thread blockBox((3715, -5473, 40), 20);
}
