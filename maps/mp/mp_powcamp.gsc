main()
{
	maps\mp\_load::main();

	setExpFog(0.0001, 0.55, 0.6, 0.55, 0);
//	setCullFog(0, 16500, 0.55, 0.6, 0.55, 0);
	ambientPlay("ambient_mp_powcamp");

	game["allies"] = "american";
	game["axis"] = "german";
	game["attackers"] = "allies";
	game["defenders"] = "axis";
	game["american_soldiertype"] = "normandy";
	game["german_soldiertype"] = "normandy";

	setCvar("r_glowbloomintensity0", ".25");
	setCvar("r_glowbloomintensity1", ".25");
	setcvar("r_glowskybleedintensity0",".3");

	if(getcvar("g_gametype") == "hq") 
	{ 
	level.radio = []; 
	level.radio[0] = spawn("script_model", (-632, -2092, 8)); 
	level.radio[0].angles = (0, 0, 0); 
	level.radio[1] = spawn("script_model", (2128, 2089, 8)); 
	level.radio[1].angles = (0, 0, 0); 
	level.radio[2] = spawn("script_model", (823, 2654, 40)); 
	level.radio[2].angles = (0, 0, 0); 
	level.radio[3] = spawn("script_model", (1338, -1318, 8)); 
	level.radio[3].angles = (0, 0, 0); 
	level.radio[4] = spawn("script_model", (585, 348, 8)); 
	level.radio[4].angles = (0, 0, 0); 
	level.radio[5] = spawn("script_model", (934, 1284, 8)); 
	level.radio[5].angles = (0, 0, 0); 
	level.radio[6] = spawn("script_model", (-828, 1833, 8)); 
	level.radio[6].angles = (0, 0, 0); 
	level.radio[7] = spawn("script_model", (-261, -548, 8)); 
	level.radio[7].angles = (0, 0, 0);
	}
}