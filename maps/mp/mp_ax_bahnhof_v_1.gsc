//by GER-Iceman & Rollin Hard
//www.anarchic-x.com
main()
{
	maps\mp\mp_ax_bahnhof_v_1_fx::main();
	maps\mp\_load::main();
        maps\mp\mp_ax_bahnhof_v_1_snow::main();
        maps\mp\mp_ax_bahnhof_v_1_trigger::main();
	
        setCullFog(0, 4000, .562, .57, .59, 0);
	ambientPlay("ambient_russia");

	game["allies"] = "russian";
	game["axis"] = "german";
	game["attackers"] = "allies";
	game["defenders"] = "axis";
	game["russian_soldiertype"] = "coats";
	game["german_soldiertype"] = "winterlight";

	setcvar("r_glowbloomintensity0",".1");
	setcvar("r_glowbloomintensity1",".1");
	setcvar("r_glowskybleedintensity0","0");

        if((getcvar("g_gametype") == "hq"))
       {      
	level.radio = [];
	level.radio[0] = spawn("script_model", (2927, 3608, -19));
	level.radio[0].angles = (0, 90, 0);		
		
	level.radio[1] = spawn("script_model", (36.9895, 2292.99, 120));
	level.radio[1].angles = (0, 276.2, 0);	

	level.radio[2] = spawn("script_model", (1056.05, 1399, 361));
	level.radio[2].angles = (0, 140.6, 0);

	level.radio[3] = spawn("script_model", (-491.068, -946.922, -19));
	level.radio[3].angles = (0, 351.6, 0);

	level.radio[4] = spawn("script_model", (2149.98, -948.02, 24));
	level.radio[4].angles = (0, 87.7, 0);

	level.radio[5] = spawn("script_model", (1039.55, -2918.5, 236));
	level.radio[5].angles = (0, 274.7, 0);

        level.radio[6] = spawn("script_model", (2654.01, -3618, 76));
	level.radio[6].angles = (0, 224.6, 0);

        level.radio[7] = spawn("script_model", (-369.999, -4654, -3));
	level.radio[7].angles = (0, 90, 0);
       }
}

