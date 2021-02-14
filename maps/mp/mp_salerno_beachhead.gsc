//[Nip] Spawn fixes, higgins boat movement, and bombing run changes by bionic.nipple@gmail.com
main(){
       maps\mp\mp_salerno_beachhead_fx::main();
       maps\mp\sal_planes::main();
       maps\mp\_waterfields::main();
       maps\mp\_load::main();


       setcullfog (1000, 5000, 209/255, 216/255, 222/255, 0 ); 
       ambientPlay("ambient_mp_salerno_beachhead");

       game["allies"] = "american";
       game["axis"] = "german";
       game["attackers"] = "allies"; 
       game["defenders"] = "axis";
       game["american_soldiertype"] = "normandy";
       game["german_soldiertype"] = "normandy";

		if(getcvar("g_gametype") == "hq")
		{
			level.radio = [];
			level.radio[0] = spawn("script_model", (1944, 280, 90));
			level.radio[0].angles = (353, 138, -18);
		
			level.radio[1] = spawn("script_model", (104, 1338, 246));
			level.radio[1].angles = (352, 134, 0);
		
			level.radio[2] = spawn("script_model", (-1200, 2622, 388));
			level.radio[2].angles = (0, 184, 0);
		
			level.radio[3] = spawn("script_model", (-580, 3788, 390));
			level.radio[3].angles = (0, 36, 0);
			
			level.radio[4] = spawn("script_model", (806, 5388, 330));
			level.radio[4].angles = (0, 312, 0);
		
			level.radio[5] = spawn("script_model", (248, 3539, 399));
			level.radio[5].angles = (0, 2, 0);
		
			level.radio[6] = spawn("script_model", (2200, 2708, 264));
			level.radio[6].angles = (0, 212, 0);
		
			level.radio[7] = spawn("script_model", (3082, 3656, 318));
			level.radio[7].angles = (355, 187, 0);
		
			level.radio[8] = spawn("script_model", (2629, 4336, 360));
			level.radio[8].angles = (352, 352, 0);
		
			level.radio[9] = spawn("script_model", (3876, 4568, 336));
			level.radio[9].angles = (0, 310, 0);
		
			level.radio[10] = spawn("script_model", (4058, 3706, 234));
			level.radio[10].angles = (357, 292, -3);
		
			level.radio[11] = spawn("script_model", (3980, 2692, 284));
			level.radio[11].angles = (0, 102, 0);
		
			level.radio[12] = spawn("script_model", (3164, 1756, 276));
			level.radio[12].angles = (0, 282, 0);
		
			level.radio[13] = spawn("script_model", (3020, 916, 188));
			level.radio[13].angles = (0, 0, 0);		
	}


       //[Nip] The attackers get to the beach at different times depending on the server (w\ sprint, etc.), 
       //      so allow the servers to adjust the speed slightly to even things out.


       switch (getcvar("salerno_boat_speed")){
               case "fast":
                       level.boat_speed = 14;
                       level.boat_delay = 5;
                       break;
               case "slow":
                       level.boat_speed = 14;
                       level.boat_delay = 15; 
                       break;
               default:
                       level.boat_speed = 14;
                       level.boat_delay = 10;
                       break;
       }

       //[Nip] Adjust spawns, move boats, and blow stuff up. 
       spawnfix();
       thread monitorBoat(1);
       thread monitorBoat(2);
       thread monitorBoat(3);
       thread monitorBoat(4);
       thread monitorBoat(5);
       thread bombingRun();
	if (getcvar("g_gametype") == "ctf")
	{
		axis_flag = getentarray("axis_flag", "targetname");
		for (i=0;i<axis_flag.size;i++)
			axis_flag[i].origin = (-228, 3916, 385);
	}
}

//[Nip] Fix the attacker's spawns, so they don't spawn in the ocean
//      or fall out of the boat.
spawnFix(){

if(getcvar("g_gametype") == "sd")
{
       level.boatspawns = [];
       spawns = getentarray("mp_sd_spawn_attacker", "classname"); 
       for (i=0; i<5; i++){
               //[Nip] For each boat
               level.boatspawns[i] = [];
               boat = getent("hig_coll" + (i+1), "targetname");
               for (j=0; j< spawns.size; j++){
                   //[Nip] Find the spawnpoints inside the boat (or near)
                       if (distance(spawns[j].origin, boat.origin) < 1024){
                           //[Nip] And create a new fake spawnpoint that we can link to the boat 
                               //      (normal spawnpoints can't be linked for some reason)
                               spawnpoint = spawn("script_origin", spawns[j].origin);
                               level.boatspawns[i][level.boatspawns[i].size] = spawnpoint;
                               spawnpoint linkTo(boat);
                       }
               }
       }
}

       thread monitorPlayerSpawns(); 
}

//[Nip] Monitor each players spawning
monitorPlayerSpawns(){
       while(1){
               level waittill("connecting", player);
               player thread onPlayerSpawn();
       } 
}

//[Nip] Wait for a player to spawn and make adjustments if necessary
onPlayerSpawn(){

if(getcvar("g_gametype") == "sd")
{
       while (true){
               self waittill("spawned_player");
               if (self.pers["team"] != game["attackers"]) continue; //[Nip] Only attackers (boat people - Ahhhh!) get adjusted 

               //[Nip] Find one of our faux spawnpoints ( created in spawnFix() ) and move the player there.
               boatnum = randomint(5);
               spawnpoints = level.boatspawns[boatnum];
               spawnpoint = spawnpoints[randomint(spawnpoints.size)];

               if (true){ //[Nip] Change to false to freeze the player until the boats land
                       self setOrigin(spawnpoint.origin );// + (0, 0, 12));
               }else{
                       origin = physicstrace(spawnpoint.origin + (0, 0, 100), spawnpoint.origin - (0, 0, 100)); //[Nip] Make sure the player is on the floor
                       self setOrigin(origin); 
                       self linkTo(getent("higgins" + boatnum, "targetname")); //[Nip] Stick the player to the boat, so they can't fall out.
               }
               while (!isDefined( level.boatlanded) || level.boatlanded != true)
                       wait .1;
               //[Nip] Once the boats have landed, let the player move feely
               self unlink();
       }
}
}


//[Nip] Move the Higgins boats to shore. 
monitorBoat(id){
       model = getent("higgins" + id, "targetname");
       //[Nip] Link the collmap to the model, so we only have one thing to move.
       colmap = getent("hig_coll" + id, "targetname"); 
       //colmap linkTo(model);

       model playLoopSound("higgins_engine");

       //[Nip] The boats wait a bit in the ocean, before they move in. I'm not sure why this was put in
       //      the original. It may have been to allow slow spawners to still land in the boat, but 
       //      since we fixed that problem, is it still needed? Run on sentences rock!
       wait level.boat_delay;

       //[Nip] Depending on the boat, find where it should land and start a-movin'.
       switch (id){ 
               case 1: dest = (640,-616,-24); break;
               case 2: dest = (-408,-616,-16); break;
               case 3: dest = (1808,-576, -16); break;
               case 4: dest = (2672,-664, -16); break; 
               default: dest = (3520, -648, -16); //[Nip] Must be #5
       }

       model thread move(dest, level.boat_speed, 3, 5);
       colmap thread move(dest, level.boat_speed, 3, 5);

       //[Nip] Wait for the boat to land. We're going to signal that the boats have landed 
       //      a second early, so the players can move just before getting out.
       wait level.boat_speed - 1;
       level.boatlanded = true;
       wait 1;

       model stopLoopSound();


}

//[Nip] This is a dummy function who's sole purpose is to allow us to thread the moveTo calls.
//      When moveTo isn't threaded it can do some weird mis-alignment stuff on moving entities.
move(dest, time, acc, dec){ 
       self moveTo(dest, time, acc, dec);
}

//[Nip] Make a bombing run across the beach
bombingRun(){
if(getcvar("g_gametype") == "sd")
{
       level._effect["bomb_explosion"] = loadfx ("fx/explosions/artilleryExp_duhoc_clifftop.efx"); 

       wait 23.5;
       shell(1);
       wait .5;
       shell(2);
       wait .3;
       shell(3);
       wait .3;
       shell(4);
}
}

//[Nip] Play an explosion on the beach.
shell(id){ 
if(getcvar("g_gametype") == "sd")
{
       bomb = getent ("bomb" + id,"targetname");

       playfx(level._effect["bomb_explosion"], bomb.origin);
       bomb playsound("bomb_explosion");
   radiusDamage( bomb.origin+(0,0,12), 500, 2000, 50);
       earthquake(0.3, 3, bomb.origin, 2096);
}
}