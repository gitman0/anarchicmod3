// by RollinHard
// do not modify this script
// settings are precise for simmerath
// if you want to use this script please ask me
// contact www.anarchic-x.com

main()
{
        
        maps\mp\mp_simmerath_beta2_fx::main();
        maps\mp\_load::main();
        maps\mp\mp_simmerath_beta2_mustang::main();
        maps\mp\mp_simmerath_beta2_mortars::main();

        setCullFog(0, 3600, 0.30, 0.31, 0.36, 0);
        ambientPlay("simmerath_ambfix");

        game["allies"] = "american";
        game["axis"] = "german";
        game["attackers"] = "allies";
        game["defenders"] = "axis";
        game["american_soldiertype"] = "normandy";
        game["german_soldiertype"] = "normandy";
        
        setCvar("r_glowbloomintensity0", "1");
        setCvar("r_glowbloomintensity1", "1");
        setcvar("r_glowskybleedintensity0",".25");
        
        getent ("radio1","targetname") playloopsound ("radio1");
        getent ("radio2","targetname") playloopsound ("radio2");
        getent ("radio3","targetname") playloopsound ("radio3");
        getent ("cow1","targetname") playloopsound ("flies");
        getent ("cow2","targetname") playloopsound ("flies");
        getent ("cow3","targetname") playloopsound ("flies");
        getent ("cow4","targetname") playloopsound ("flies");
        getent ("cow5","targetname") playloopsound ("flies");
        getent ("cow6","targetname") playloopsound ("flies");
        getent ("germanvoices","targetname") playloopsound ("germanvoices");
        getent ("clock","targetname") playloopsound ("clock");
        getent ("clock2","targetname") playloopsound ("clock");
        getent ("waterdrops","targetname") playloopsound ("waterdrops");
        getent ("birds","targetname") playloopsound ("birds");

        if((getcvar("g_gametype") == "hq"))
	{      
		level.radio = [];
		level.radio[0] = spawn("script_model", (-377.207, -57.5, -96));
		level.radio[0].angles = (0, 315, 0);		
		
		level.radio[1] = spawn("script_model", (585.926, -1347.09, -187));
		level.radio[1].angles = (0, 279.3, 0);	

		level.radio[2] = spawn("script_model", (1518, -168, -87));
		level.radio[2].angles = (0, 90, 0);

		level.radio[3] = spawn("script_model", (2971.68, 77.817, -224));
		level.radio[3].angles = (0, 60, 0);

		level.radio[4] = spawn("script_model", (3872, -376, -352));
		level.radio[4].angles = (0, 180, 0);

		level.radio[5] = spawn("script_model", (5693, -943, -208));
		level.radio[5].angles = (0, 90, 0);

                level.radio[6] = spawn("script_model", (6039.79, 74.5, -200));
		level.radio[6].angles = (0, 315, 0);

                level.radio[7] = spawn("script_model", (6976, -472, -144));
		level.radio[7].angles = (0, 270, 0);
        }      

}



