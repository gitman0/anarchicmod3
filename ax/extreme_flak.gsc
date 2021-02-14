        level.ex_effect["flak_smoke"]   = loadfx("fx/explosions/flak_puff.efx");
        level.ex_effect["flak_flash"]   = loadfx("fx/explosions/default_explosion.efx");
        level.ex_effect["flak_dust"]    = loadfx("fx/dust/flak_dust_blowback.efx");

        /* anti-air flak effects by extrememod
        getmapdim();
        getfielddim();
        level.ex_planes_flak    = 0;
        level.ex_flakfx         = 10;
        if(level.ex_flakfx < 10)
                level.ex_flak   = 10;
        level.ex_flakfxdelaymin = 5;
        level.ex_flakfxdelaymax = 15;

        if (level.ex_flakfx && !level.ex_planes_flak) {
                for(flak=0; flak < level.ex_flakfx; flak++)
                        level thread flakfx();
        }
	*/

GetMapDim()
{
	entitytypes = getentarray();

	xMax = -30000;
	xMin = 30000;

	yMax = -30000;
	yMin = 30000;

	zMax = -30000;
	zMin = 30000;

	xMin_e[0] = xMax;
	yMin_e[1] = yMax;
	zMin_e[2] = zMax;

	xMax_e[0] = xMin;
	yMax_e[1] = yMin;
	zMax_e[2] = zMin;       

	for(i = 1; i < entitytypes.size; i++)
	{
		trace = bulletTrace(entitytypes[i].origin, entitytypes[i].origin - (30000,0,0),false,undefined);
		if(trace["fraction"] != 1)  xMin_e  = trace["position"];

		trace = bulletTrace(entitytypes[i].origin, entitytypes[i].origin + (30000,0,0),false,undefined);
		if(trace["fraction"] != 1)  xMax_e  = trace["position"];

		trace = bulletTrace(entitytypes[i].origin, entitytypes[i].origin - (0,30000,0),false,undefined);
		if(trace["fraction"] != 1)  yMin_e  = trace["position"];

		trace = bulletTrace(entitytypes[i].origin, entitytypes[i].origin + (0,30000,0),false,undefined);
		if(trace["fraction"] != 1)  yMax_e  = trace["position"];

		trace = bulletTrace(entitytypes[i].origin, entitytypes[i].origin - (0,0,30000),false,undefined);
		if(trace["fraction"] != 1)  zMin_e  = trace["position"];

		trace = bulletTrace(entitytypes[i].origin, entitytypes[i].origin + (0,0,30000),false,undefined);
		if(trace["fraction"] != 1)  zMax_e  = trace["position"];

		if (xMin_e[0] < xMin)   xMin = xMin_e[0];
		if (yMin_e[1] < yMin)   yMin = yMin_e[1];
		if (zMin_e[2] < zMin)   zMin = zMin_e[2];

		if (xMax_e[0] > xMax)   xMax = xMax_e[0];
		if (yMax_e[1] > yMax)   yMax = yMax_e[1];
		if (zMax_e[2] > zMax)   zMax = zMax_e[2];       

		wait 0.05;
	}

	level.ex_mapArea_CentreX = int(xMax + xMin)/2;
	level.ex_mapArea_CentreY = int(yMax + yMin)/2;
	level.ex_mapArea_CentreZ = int(zMax + zMin)/2;
	level.ex_mapArea_Centre = (level.ex_mapArea_CentreX, level.ex_mapArea_CentreY, level.ex_mapArea_CentreZ);

	level.ex_mapArea_Max = (xMax, yMax, zMax);
	level.ex_mapArea_Min = (xMin, yMin, zMin);

	level.ex_mapArea_Width = int(distance((xMin,yMin,zMax),(xMax,yMin,zMax)));
	level.ex_mapArea_Length = int(distance((xMin,yMin,zMax),(xMin,yMax,zMax)));

	// Special Z coords for mp_carentan, mp_decoy, mp_railyard, mp_toujane
	level.ex_mapArea_PlaneZ = int(zMax + zMin)/1.35;

	entitytypes = [];
	entitytypes = undefined;
}
GetFieldDim()
{
	spawnpoints = [];

	spawnpoints_s1 = getentarray("mp_dm_spawn", "classname");
	spawnpoints_s2 = getentarray("mp_tdm_spawn", "classname");
	spawnpoints_s3 = getentarray("mp_ctf_spawn_allied", "classname");
	spawnpoints_s4 = getentarray("mp_ctf_spawn_axis", "classname");
	spawnpoints_s5 = getentarray("mp_sd_spawn_attacker", "classname");
	spawnpoints_s6 = getentarray("mp_sd_spawn_defender", "classname");

	for(i=0;i<spawnpoints_s1.size;i++) spawnpoints = maps\mp\gametypes\_spawnlogic::add_to_array(spawnpoints, spawnpoints_s1[i]);
	for(i=0;i<spawnpoints_s2.size;i++) spawnpoints = maps\mp\gametypes\_spawnlogic::add_to_array(spawnpoints, spawnpoints_s2[i]);
	for(i=0;i<spawnpoints_s3.size;i++) spawnpoints = maps\mp\gametypes\_spawnlogic::add_to_array(spawnpoints, spawnpoints_s3[i]);
	for(i=0;i<spawnpoints_s4.size;i++) spawnpoints = maps\mp\gametypes\_spawnlogic::add_to_array(spawnpoints, spawnpoints_s4[i]);
	for(i=0;i<spawnpoints_s5.size;i++) spawnpoints = maps\mp\gametypes\_spawnlogic::add_to_array(spawnpoints, spawnpoints_s5[i]);
	for(i=0;i<spawnpoints_s6.size;i++) spawnpoints = maps\mp\gametypes\_spawnlogic::add_to_array(spawnpoints, spawnpoints_s6[i]);

	xMax = spawnpoints[0].origin[0];
	xMin = spawnpoints[0].origin[0];

	yMax = spawnpoints[0].origin[1];
	yMin = spawnpoints[0].origin[1];

	zMax = spawnpoints[0].origin[2];
	zMin = spawnpoints[0].origin[2];

	for(i=1;i<spawnpoints.size;i++)
	{
		if (spawnpoints[i].origin[0] > xMax)     xMax = spawnpoints[i].origin[0];
		if (spawnpoints[i].origin[1] > yMax)     yMax = spawnpoints[i].origin[1];
		if (spawnpoints[i].origin[2] > zMax)     zMax = spawnpoints[i].origin[2];
		if (spawnpoints[i].origin[0] < xMin)     xMin = spawnpoints[i].origin[0];
		if (spawnpoints[i].origin[1] < yMin)     yMin = spawnpoints[i].origin[1];
		if (spawnpoints[i].origin[2] < zMin)     zMin = spawnpoints[i].origin[2];
	}

	level.ex_playArea_CentreX = int(int(xMax + xMin)/2);
	level.ex_playArea_CentreY = int(int(yMax + yMin)/2);
	level.ex_playArea_CentreZ = int(int(zMax + zMin)/2);
	level.ex_playArea_Centre = (level.ex_playArea_CentreX, level.ex_playArea_CentreY, level.ex_playArea_CentreZ);

	level.ex_playArea_Min = (xMin, yMin, zMin);
	level.ex_playArea_Max = (xMax, yMax, zMax);

	level.ex_playArea_Width = int(distance((xMin, yMin, 800),(xMax, yMin, 800)));
	level.ex_playArea_Length = int(distance((xMin, yMin, 800),(xMin, yMax, 800)));
}
flakfx()
{
	level endon("ex_gameover");
	level endon("stop_flak");
	level.ex_flakison = true;

	while(level.ex_flakison)
	{
		// wait a random delay
		delay = level.ex_flakfxdelaymin + randomint(level.ex_flakfxdelaymax - level.ex_flakfxdelaymin);
		wait delay;

		if(!level.ex_flakfx)
		{
			if(!level.ex_axisapinsky && !level.ex_allieapinsky && !level.ex_paxisapinsky && !level.ex_pallieapinsky)
				level.ex_flakison = false;
		}
	
		// spawn object that is used to play sound
		flak = spawn ( "script_model", ( 0, 0, 0) );

		//get a random position
		xpos = level.ex_playArea_Min[0] + randomInt(level.ex_playArea_Width);
		ypos = level.ex_playArea_Min[1] + randomInt(level.ex_playArea_Length);
		zpos =  level.ex_mapArea_Max[2] - randomInt(100);	

		position = ( xpos, ypos, zpos);

		flak.origin = position;
		wait .05;
		
		// play effect
		flak playsound("flak_explosion");

		playfx(level.ex_effect["flak_flash"], position);
		wait 0.25;
		playfx(level.ex_effect["flak_smoke"], position);
		wait 0.25;
		playfx(level.ex_effect["flak_dust"], position);
		wait 0.25;

		flak delete();
	}
}
