main()
{



maps\mp\mp_wspawn_fx::main();
maps\mp\wheels1::main();
maps\mp\lift_move::main(); 
maps\mp\shutter::main();
maps\mp\toilet::main();
maps\mp\barrels::barrelInit();
maps\mp\window_slide::main();
maps\mp\dish::main();
maps\mp\gangway::main();

maps\mp\_load::main();
  
ambientPlay("ambient_mp_wspawn");

 
game["allies"] = "british";
game["axis"] = "german";
game["attackers"] = "allies";
game["defenders"] = "axis";
game["british_soldiertype"] = "africa";
game["german_soldiertype"] = "africa";

	setCvar("r_glowbloomintensity0", ".25");
	setCvar("r_glowbloomintensity1", ".25");
	setcvar("r_glowskybleedintensity0",".3");


getent ("menu_bhd","targetname") playloopsound ("menu_bhd");

getent ("fire","targetname") playloopsound("medfire");
} 





