
main()
{

	maps\mp\_load::main();
	maps\mp\mp_mariupol_v2_fx::main();
	maps\mp\mp_mariupol_v2_elevator::main();
	maps\mp\mp_mariupol_v2_doors::main();
	maps\mp\mp_mariupol_v2_stuka::main();
	maps\mp\mp_mariupol_v2_toilet::main();
	maps\mp\mp_mariupol_v2_bomb::main();
	maps\mp\mp_mariupol_v2_shields::main();
	maps\mp\mp_mariupol_v2_mortars::main();


	setExpFog(0.00015, 0.8, 0.8, 0.8, 0);
	ambientPlay("ambient_mp_mariupol_v2");
		
	game["allies"] = "russian";
	game["axis"] = "german";
	game["attackers"] = "allies";
	game["defenders"] = "axis";
	game["russian_soldiertype"] = "coats";
	game["german_soldiertype"] = "winterlight";

	setcvar("r_glowbloomintensity0","1");
	setcvar("r_glowbloomintensity1","1");
	setcvar("r_glowskybleedintensity0",".5");


	if(getcvar("g_gametype") == "hq")
	{
		level.radio = [];
		level.radio[0] = spawn("script_model", (2000, -5520, -72));
		level.radio[0].angles = (0, 90, 0);
		
		level.radio[1] = spawn("script_model", (553, -5741, 195));
		level.radio[1].angles = (0, 180, 0);
		
		level.radio[2] = spawn("script_model", (923, -4965, -96));
		level.radio[2].angles = (0, 225, 0);
		
		level.radio[3] = spawn("script_model", (1237, -3401, 21));
		level.radio[3].angles = (0, 270, 0);
		
		level.radio[4] = spawn("script_model", (156, -3677, 3));
		level.radio[4].angles = (0, 180, 0);
		
		level.radio[5] = spawn("script_model", (-204, -5452, -57));
		level.radio[5].angles = (0, 180, 0);
		
		level.radio[6] = spawn("script_model", (2030, -3782, -114));
		level.radio[6].angles = (0, 0, 0);
		
		level.radio[7] = spawn("script_model", (1861, -6590, -259));
		level.radio[7].angles = (0, 0, 0);
		
		level.radio[8] = spawn("script_model", (1592, -5872, 96));
		level.radio[8].angles = (0, 0, 0);
		
		level.radio[9] = spawn("script_model", (1172, -7283, -400));
		level.radio[9].angles = (0, 0, 0);
		
		level.radio[10] = spawn("script_model", (784, -3240, -128));
		level.radio[10].angles = (0, 225, 0);
		
		level.radio[11] = spawn("script_model", (1592, -5872, 16));
		level.radio[11].angles = (0, 0, 0);
	}


}