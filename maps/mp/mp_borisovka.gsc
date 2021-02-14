

main()
{
	maps\mp\mp_borisovka_fx::main();
	maps\mp\_load::main();

	setExpFog(0.00045, .58, .57, .57, 0);
	ambientPlay("ambient_mp_borisovka");
	
	game["allies"] = "american";
	game["axis"] = "german";
	game["attackers"] = "allies";
	game["defenders"] = "axis";
	game["american_soldiertype"] = "normandy";
	game["german_soldiertype"] = "winterlight";

	setcvar("r_glowbloomintensity0","1");
	setcvar("r_glowbloomintensity1","1");
	setcvar("r_glowskybleedintensity0",".5");

	if(getcvar("g_gametype") == "hq")
	{
		level.radio = [];
		level.radio[0] = spawn("script_model", (24, -976, 24));
		level.radio[0].angles = (0, 8, 0);

		level.radio[1] = spawn("script_model", (2768, -376, -144));
		level.radio[1].angles = (0, 308, 0);

		level.radio[2] = spawn("script_model", (-120, -2512, -148));
		level.radio[2].angles = (0, 68, 0);

		level.radio[3] = spawn("script_model", (1192, 352, -24));
		level.radio[3].angles = (0, 263, 0);

		level.radio[4] = spawn("script_model", (1280, -2768, -168));
		level.radio[4].angles = (0, 134, 0);

		level.radio[5] = spawn("script_model", (2648, -2336, -216));
		level.radio[5].angles = (0, 143, 0);

		level.radio[6] = spawn("script_model", (1360, -1488, -248));
		level.radio[6].angles = (0, 143, 0);
	}
}