init()
{
	// turn on ambient mortars
	level.awe_mortar = awe\_util::cvardef("awe_mortar", 3, 0, 10, "int");

	if(!level.awe_mortar) 
		return;

	// quake?
	level.awe_mortar_quake 		= awe\_util::cvardef("awe_mortar_quake", 1, 0, 1, "int");
	// random?
	level.awe_mortar_random 	= awe\_util::cvardef("awe_mortar_random", 0, 0, 1, "int");
	// make them safe for players
	level.awe_mortar_safety 	= awe\_util::cvardef("awe_mortar_safety", 1, 0, 1, "int");
	// minimum delay between mortars
	level.awe_mortar_delay_min 	= awe\_util::cvardef("awe_mortar_delay_min", 20, 5, 179, "int");
	// maximum delay between mortars
	level.awe_mortar_delay_max 	= awe\_util::cvardef("awe_mortar_delay_max", 60, level.awe_mortar_delay_min+1, 180, "int");

	// Setup mortar model
	level.awe_mortarmodel = "xmodel/vehicle_halftrack_rockets_shell";

	// Set up mortar sounds
	level.awe_mortars = [];
	level.awe_mortars[level.awe_mortars.size]["incoming"] = "mortar_incoming2";
	level.awe_mortars[level.awe_mortars.size-1]["delay"] = 0.65;
	level.awe_mortars[level.awe_mortars.size]["incoming"] = "mortar_incoming1";
	level.awe_mortars[level.awe_mortars.size-1]["delay"] = 1.05;
	level.awe_mortars[level.awe_mortars.size]["incoming"] = "mortar_incoming3";
	level.awe_mortars[level.awe_mortars.size-1]["delay"] = 1.5;
	level.awe_mortars[level.awe_mortars.size]["incoming"] = "mortar_incoming4";
	level.awe_mortars[level.awe_mortars.size-1]["delay"] = 2.1;
	level.awe_mortars[level.awe_mortars.size]["incoming"] = "mortar_incoming5";
	level.awe_mortars[level.awe_mortars.size-1]["delay"] = 3.0;

	// load effects
	level.awe_mortarfx["sand"] 	= loadfx("fx/explosions/mortarExp_beach.efx");
	level.awe_mortarfx["snow"]	= loadfx("fx/explosions/large_snow_explode1.efx");
//Don't think there are any water on the stock maps	level.awe_mortarfx["water"]	= loadfx("fx/explosions/mortarExp_water.efx");
	level.awe_mortarfx["concrete"]= loadfx("fx/explosions/mortarExp_concrete.efx");
	level.awe_mortarfx["dirt"] 	= loadfx("fx/explosions/mortarExp_dirt.efx");
	level.awe_mortarfx["generic"] = loadfx("fx/explosions/mortarExp_mud.efx");
	level.awe_mortarfx["grass"] 	= loadfx("fx/explosions/artilleryExp_grass.efx");

	// Precache model
	if(!isdefined(game["gamestarted"]))
		precacheModel(level.awe_mortarmodel);
	
	thread StartThreads();
}

StartThreads()
{
	wait .05;

	level endon("awe_killthreads");

	// Start mortar threads
	for(i = 0; i < level.awe_mortar; i++)
		thread incoming();

}

incoming()
{
	level endon("awe_killthreads");

	// Get max altitude
//	if(level.awe_bombers_altitude)
//		maxz = level.awe_bombers_altitude;
//	else
		maxz = level.awe_vMax[2];	

	surfaces = [];
	surfaces[surfaces.size] = "concrete";
	surfaces[surfaces.size] = "dirt";
	surfaces[surfaces.size] = "generic";
	surfaces[surfaces.size] = "grass";
	surfaces[surfaces.size] = "sand";

	// Init some local variables
	endorigin = (0,0,0);
	m = 0;
	pc = 0;
	x = 0;
	y = 0;
	trace = [];
	surface = "generic";

	// Do an endless loop
	for(;;)
	{
		// Get a random delay
		range = int(level.awe_mortar_delay_max - level.awe_mortar_delay_min);
		delay = randomInt(range);
		delay = level.awe_mortar_delay_min + delay;

		wait delay;

		// Spawn mortar model
		mortar = spawn("script_model", (0,0,0));
		mortar setModel(level.awe_mortarmodel);
		mortar hide();	// Hide it until we need it


		// Get a random mortar incoming sound
		m = randomInt(level.awe_mortars.size);

		// Random strength
		pc = randomInt(100);

		// Get it's damage range
		range = int(200 + pc*360*0.01);

		// Make sure loop is run at least once
		distance = -1;

		// Loop until we find a safe spot if safety is 1
		while(distance < (level.awe_mortar_safety * range * 2))
		{

			// Get all alive players
			players = [];
			for(i=0;i<level.awe_allplayers.size;i++)
				if(isdefined(level.awe_allplayers[i]))
					if(level.awe_allplayers[i].sessionstate == "playing")
						players[players.size] = level.awe_allplayers[i];
	
			// Find a random target if there is any alive players
			if(!level.awe_mortar_random && players.size)
			{
				// Get a random player
				p = randomInt(players.size);
				// Get a random angle			
				angle = (0,randomInt(360),0);
				// Convert to vector
				vector = anglesToForward(angle);
				// Scale vector differently depending on safety
				variance = maps\mp\_utility::vectorScale(vector, range*level.awe_mortar_safety*2 + randomInt(range*3) );
				// Set mortar origin;
				endorigin = players[p].origin + variance;
			}
			else	// Use a random impact point
			{
				x = level.awe_vMin[0] + randomInt(int(level.awe_vMax[0]-level.awe_vMin[0]));
				y = level.awe_vMin[1] + randomInt(int(level.awe_vMax[1]-level.awe_vMin[1]));
				z = level.awe_vMin[2];
				endorigin = (x,y,z);
			}

			// find the impact point
			trace = bulletTrace((endorigin[0],endorigin[1],maxz),(endorigin[0],endorigin[1],level.awe_vMin[2]), false, undefined);
			endorigin = trace["position"];

			// Check if any other player is within range
			if(level.awe_mortar_safety && players.size)
			{
				bplayers = awe\_util::sortByDist(players, mortar);
				distance = distance(endorigin, bplayers[0].origin);
			}
			else	// No safety on = end loop
				break;

			wait 0.2;  // in case it has to loop a lot because of safety
		}

		// Get surfacetype
		surface = trace["surfacetype"];

		// Start point for mortar
		startpoint = ( (endorigin[0] - 200 + randomInt(400)) , (endorigin[1] - 200 + randomInt(400)) ,maxz);

		mortar.origin = startpoint;

		wait .05;

		// play the incoming sound
		mortar playsound(level.awe_mortars[m]["incoming"]);

/*		// Make closest player yell warning
		if(isdefined(level.awe_teamplay) && !level.awe_mortar_safety)
		{
//			allplayers = getentarray("player", "classname");
			players = [];
			for(i=0;i<level.awe_allplayers.size;i++)
				if(isdefined(level.awe_allplayers[i]))
					if(level.awe_allplayers[i].sessionstate == "playing")
						players[players.size] = level.awe_allplayers[i];

			if(players.size)
			{
				bplayers = awe\_util::sortByDist(players, mortar);
				distance = distance(mortar.origin, bplayers[0].origin);
				if(distance<range*2 && randomInt(2) && bplayers[0] awe\_util::TeamMateInRange(range*2))
					bplayers[0] playsound("awe_" + game[bplayers[0].sessionteam] + "_incoming");
			}
		}*/

		falltime = .5;

		// wait for it to hit
		wait level.awe_mortars[m]["delay"] - 0.05 - falltime;

		// Show visible mortar object
		mortar.angles = vectortoangles(vectornormalize(mortar.origin - startpoint));
		mortar show();
		wait .05;

		// Move visible mortar
		mortar moveto(endorigin, falltime);

		// wait for it to hit
		wait falltime;

		if(level.awe_debug) iprintln("Existing surface:" + trace["surfacetype"]);
		// play the visual effect if we have a suitable loaded
		if(!isdefined(level.awe_mortarfx[surface]))
		{
			if(level.awe_wintermap)
				surface = "snow";
			else
				surface = surfaces[randomInt(surfaces.size)];

			if(level.awe_debug)
				iprintln("Random surface:" + surface);
		}

		playfx(level.awe_mortarfx[surface], endorigin);

		// Play explosion sound
		mortar playsound("mortar_explosion" + (randomInt(5) + 1));

		// Hide visible mortar
		mortar hide();

		// just to be extra safe, since a player MIGHT move in range during the "incoming" sound
		if(!level.awe_mortar_safety)
		{
			// do the damage
			max = 200 + 200*pc*0.01;
			min = 10;
			radiusDamage(endorigin + (0,0,12), range, max, min);
		}

		if(level.awe_mortar_quake)
		{
			// rock their world
			strength = 0.5 + 0.5 * pc * 0.01;
			length = 1 + 3*pc*0.01;
			range = int(600 + 600*pc*0.01);
			earthquake(strength, length, endorigin, range); 
		}

		mortar delete();
	}
}
