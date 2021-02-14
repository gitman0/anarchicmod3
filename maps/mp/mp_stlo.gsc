main()
{
	maps\mp\_load::main();
	maps\mp\mp_stlo_fx::main();
	maps\mp\mp_stlo_door::main();

	ambientPlay("ambient_mp_stlo");

	game["allies"] = "american";
	game["axis"] = "german";
	game["attackers"] = "allies";
	game["defenders"] = "axis";
	game["american_soldiertype"] = "normandy";
	game["german_soldiertype"] = "normandy";

	setcvar("r_glowbloomintensity0","1");
	setcvar("r_glowbloomintensity1","1");
	setcvar("r_glowskybleedintensity0",".25");

	getent ("radio1","targetname") playloopsound ("radio1");
	getent ("radio2","targetname") playloopsound ("radio2");


	if((getcvar("g_gametype") == "hq"))
	{
	level.radio = [];
	level.radio[0] = spawn("script_model", (-23.9736, 23.8731, 42));
	level.radio[0].angles = (0, 15, 0); 

	level.radio[1] = spawn("script_model", (560.005, -679.997, -150));
	level.radio[1].angles = (0, 360, 0); 

	level.radio[2] = spawn("script_model", (-327.995, -1200, -110));
	level.radio[2].angles = (0, 360, 0);

	level.radio[3] = spawn("script_model", (864.497, -1153.5, -144));
	level.radio[3].angles = (0, 90, 0);

	level.radio[4] = spawn("script_model", (-711.995, -3697, -104));
	level.radio[4].angles = (0, 360, 0);

	level.radio[5] = spawn("script_model", (344.005, -3889, -64));
	level.radio[5].angles = (0, 360, 0);
	}
}

