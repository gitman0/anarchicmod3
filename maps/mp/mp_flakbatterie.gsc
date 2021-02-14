main()
{
       maps\mp\mp_flakbatterie_fx::main();
       maps\mp\_load::main(); 

ambientPlay("ambient_mp_flakbatterie");

setExpFog(0.0001, 0.30, 0.31, 0.34, 0);

game["allies"] = "american"; // or british or russian
game["axis"] = "german";

	game["sd_attackers_obj_text"] = &"SD_OBJ_ATTACKERS";
	game["sd_defenders_obj_text"] = &"SD_OBJ_DEFENDERS";

	setcvar("r_glowbloomintensity0",".25");
	setcvar("r_glowbloomintensity1",".25");
	setcvar("r_glowskybleedintensity0",".4");

	if(getcvar("g_gametype") == "hq")
      {
		level.radio = [];
		level.radio[0] = spawn("script_model", (-940.818, -1780.13, 50));
		level.radio[0].angles = (0, 18.3, 0);

		level.radio[1] = spawn("script_model", (1053.97, -708.164, 84));
		level.radio[1].angles = (0, 179.1, 0);

		level.radio[2] = spawn("script_model", (1284.16, 2466.44, 53));
		level.radio[2].angles = (0, 313, 0);

		level.radio[3] = spawn("script_model", (-2648.28, -1687.42, 43));
		level.radio[3].angles = (0, 75.8, 0);

		level.radio[4] = spawn("script_model", (2892.17, 1208.35, 11));
		level.radio[4].angles = (0, 270.9, 0);

		level.radio[5] = spawn("script_model", (1826.83, -2763.35, 94));
		level.radio[5].angles = (0, 90.9, 0);

		level.radio[6] = spawn("script_model", (-857.825, 1909.35, 12));
		level.radio[6].angles = (0, 270.9, 0);

		level.radio[7] = spawn("script_model", (-4040.91, 1138.11, -2));
		level.radio[7].angles = (0, 101.9, 0);

		level.radio[8] = spawn("script_model", (3582.13, -1965.9, 56));
		level.radio[8].angles = (0, 256.8, 0);
      }

game["american_soldiertype"] = "normandy";
game["german_soldiertype"] = "normandy";

game["attackers"] = "allies";
game["defenders"] = "axis";


 }