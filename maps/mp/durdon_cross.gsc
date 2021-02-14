main()
{
         maps\mp\Durdon_cross_fx::main();
         maps\mp\Durdon_cross_rain::main();
         maps\mp\_load::main();

         setExpFog(0.00015, 0.8, 0.8, 0.8, 0);
         ambientPlay("ambient_Durdon_cross");



       //Soldier Settings
         game["allies"] = "british";
         game["axis"] = "german";
         game["attackers"] = "allies";
         game["defenders"] = "axis";
         game["british_soldiertype"] = "normandy";
         game["german_soldiertype"] = "normandy";
         

         setcvar("r_glowbloomintensity0","1");
	 setcvar("r_glowbloomintensity1","1");
	 setcvar("r_glowskybleedintensity0",".25");



}

