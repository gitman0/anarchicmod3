/*	Julian (oraco) 

	mp_chelm dev timeline:
	======================
	July 15 - July 25: 	Concept drawing, design, plan, mapping prefab, detailing, map structure complete
	July 25 - July 31: 	Portalling, scripting, final polishing, 4 day internal beta by Clan HR
	July 31 - Aug 7: 	Public Beta 1, fixing errors, adjusting for pro-S&D mode, scripting custom flak88
	Aug 7 - Aug 12: 	Public Beta 2 ... to be continued ...

	mp_chelm is designed, mapped, scripted and packaged by Julian (oraco). There are no stock house
	prefabs used in this map. All structures and scripts are my own. There is one texture used thats 
	extracted from lolv2_cod2 custom map and credit is given in the textureCredit.txt in the 
	images/materials folder.
	
	mp_chelm is a small polish village close to a city named chelm, the map is mapped according to
	descriptions from a polish friend of mine. Originally, I made this map for portfolio reasons, but
	later realized its potential to be a popular community map as well as pro-competition map.
	
	The map has high level of realism, complexity, random passages, and flak88 simulation done with 
	script brushes & scripting. The map is small sized, undesirable if played with more than
	28 people. The map supports all gametyes. 
	
	I tried to comment this script as much as possible so the people of this community might make some
	use of it. Anyone is free to use anything I have in this package as long as credit is given. If anyone
	wishes to modify my work, you may skip the credit if you have modified more than 70%. If anyone wish 
	to use my flak88 simulator, please contact me for prefab.
	
	- Julian (looking for level designer position)
	
	oraco81@yahoo.com
	http://www.hrgamers.com/oraco/
*/

main(){
	maps\mp\mp_chelm_fx::main();
	maps\mp\_load::main();
	
	setExpFog(0.0001, 0.55, 0.6, 0.55, 0);
	ambientPlay("ambient_chelm");
	
	game["allies"] = "american";
	game["axis"] = "german";
	game["attackers"] = "allies";
	game["defenders"] = "axis";
	game["american_soldiertype"] = "normandy";
	game["german_soldiertype"] = "normandy";
	
	setcvar("r_glowbloomintensity0","1");
	setcvar("r_glowbloomintensity1","1");
	setcvar("r_glowskybleedintensity0",".25");
	
	//plant radio array for HQ gametype
	doHQ();
	
	//off or on by cvar "/seta chelm_bomb 1" (1=on, 0=off, undefined=off, default=on)
	if(isdefined(getcvar("chelm_bomb")) && getcvar("chelm_bomb") == "0"){
		level thread dontChurchBomb();
	}
	else{
		//run shootable bomb at the church
		level thread doChurchBomb();
	}
	
	//dynamic lighting fx for Dynamic light enabled setting in DX9
	level thread doLantern();
	
	//dynamic lighting fx for Dynamic light enabled setting in DX9
	level thread doCanon_light();
	
	//thread doChandalier(); //FPS drops too much for me (geforceFx)
	
	//add smoke fx to set locations
	level thread doSmoke();

	//Random passage block loader
	level thread doRandom();
	
	level thread maps\mp\chelm_flak::main();
	level thread maps\mp\chelm_mortar::main();
}

//bomb at the church that explodes on damage and makes a big hole
dontChurchBomb(){
	//get entities
	floor_trig = getent("floor_trig", "targetname");
	floor_bomb = getent("floor_bomb", "targetname");
	floor_good = getentarray("floor_good", "targetname");
	floor_bad = getentarray("floor_bad", "targetname");
	origin = floor_bomb.origin;
	floor_bomb delete(); //delete bomb model from map
	for(i=0; i<floor_good.size; i++)
		floor_good[i] delete(); //delete the good floor
	for(i=0; i<floor_bad.size; i++)
		floor_bad[i].origin += (0,0,256); //move the premade damaged floor from under the church
	//add smoke in the hole
	maps\mp\_fx::loopfx("thin_light_smoke_M", (origin-(0,0,100)), 1, (origin));
}
doChurchBomb(){
	//get entities
	floor_trig = getent("floor_trig", "targetname");
	floor_bomb = getent("floor_bomb", "targetname");
	floor_good = getentarray("floor_good", "targetname");
	floor_bad = getentarray("floor_bad", "targetname");
	//wait until bomb been shot/damaged
	floor_trig waittill ("damage");
	//since it was, now we explode
	playfx(level._effect["bombexplosion"], floor_bomb.origin);
	//anyone in range must die, cant hide!!
	players = getentarray("player", "classname");
	for(i=0; i<players.size; i++){
		if(isdefined(players[i]) && (distance(players[i].origin, floor_bomb.origin)<300)){
			radiusDamage(players[i].origin, 32, 1000, 1000);
			//players[i] iprintln("pwned!\n");
		}
	}
	floor_bomb playSound("building_explosion1");
	//quake the surrounding of 500 units.. uhm ok PWNED!
	earthquake(0.6, 1.5, floor_bomb.origin, 500); 
	//now we want to add smoke to the location of explosion
	origin = floor_bomb.origin;
	floor_bomb delete(); //delete bomb model from map
	for(i=0; i<floor_good.size; i++)
		floor_good[i] delete(); //delete the good floor
	for(i=0; i<floor_bad.size; i++)
		floor_bad[i].origin += (0,0,256); //move the premade damaged floor from under the church
	//add smoke in the hole
	maps\mp\_fx::loopfx("thin_light_smoke_M", (origin-(0,0,100)), 1, (origin));
}
//using script_origins in map "radio" as targetnames for the locations of HQ
doHQ(){
	if(getcvar("g_gametype") == "hq"){
		level.radio = [];
		radioloc = getentarray("radio", "targetname");
		logPrint("Number of radios: " + radioloc.size + "\n");
		println("Number of radios:: " + radioloc.size + "\n");
		for(i=0; i<radioloc.size; i++){
			level.radio[i] = spawn("script_model", (radioloc[i].origin));
			level.radio[i].angles = (radioloc[i].angles);
			logPrint("Radio " + i + " set at (" + radioloc[i].origin + "), angles of (" + radioloc[i].angles + ") \n");
			println("Radio " + i + " set at (" + radioloc[i].origin + "), angles of (" + radioloc[i].angles + ") \n");
		}
	}
}
doSmoke(){
	smokeorigin = getentarray("smoke", "targetname");
	for(i=0; i<smokeorigin.size; i++){
		maps\mp\_fx::loopfx("thin_light_smoke_M", (smokeorigin[i].origin), 1, (smokeorigin[i].origin+(0,0,100)));
	}
}

//dynamic lights for the church chandaliers !!!high graphic requirement!!!
doChandalier(){
	chan_light = loadfx("fx/chelm/chandalier_light.efx");
	chandalier_light = getentarray("fx_chandalier", "targetname");
	while(1){
		if(!isdefined(chandalier_light)) break;
		for(k=0; k<chandalier_light.size; k++){
			if(isdefined(chandalier_light[k]))
				playfx(chan_light, chandalier_light[k].origin+(0,0,72));
			else 
				continue;
		}
		wait 20;
	}
}
//dynamic lights for arty canon lights
doCanon_light(){
	c_light = loadfx("fx/chelm/canon_light.efx");
	canon_light = getentarray("fx_canon_light", "targetname");
	while(1){
		if(!isdefined(canon_light)) break;
		for(k=0; k<canon_light.size; k++){
			if(isdefined(canon_light[k]))
				playfx(c_light, canon_light[k].origin);
			else 
				continue;
		}
		wait 20;
	}
}
//==============================Lantern fx starts============================
/*	lantern fx func with lantern flame, dynamic lighting, and off if damaged(off delay 2sec max)
	MAP REQUIREMENTS:
	make script_model, model:xmodel/light_lantern_on, targetname: fx_lantern#, #=unique lantern count
	make damage_trigger, target: fx_lantern#, fx_lantern_trig, linked with the script_model lantern
	place the damage trigger where the lantern model is, if done correctly, u see a red link between them
*/
doLantern(){
	//get all lantern damage triggers in the map
	lantern_trig = getentarray("fx_lantern_trig", "targetname");
	if(isdefined(lantern_trig)){
		//for each lantern damage trigger in map we spawn thread to think
		for(k=0; k<lantern_trig.size; k++){
			if(isdefined(lantern_trig[k])){
				//set lantern on at first
				lantern_trig[k].pers["switch"] = 1;
				lantern_trig[k] thread lantern_think();
				lantern_trig[k] thread lantern_switch();
			}
		}
	}
}
//thread to check if lantern is being destroyed, if so respawn in 2 mins
lantern_switch(){
	respawntime = 120;
	//loop damage check forever
	while(1){
		self.pers["switch"] = 1;
		self waittill ("damage", amount ,attacker);
		self.pers["switch"] = 0;
		wait respawntime;
	}
}
//lantern fx loop
lantern_think(){
	//get entity of the damage trigger's target, which is the lantern script model
	lantern = getent(self.target, "targetname");
	smallfire = loadfx("fx/chelm/lantern.efx");
	lanternlight = loadfx("fx/chelm/lantern_light.efx");
	//loop fx forever
	while(1){
		if(!isdefined(lantern)) break;
		//if the switch is on then we display fx, else we dont
		if(self.pers["switch"]==1){
			playfx(smallfire, lantern.origin+(0,0,7));
			playfx(lanternlight, lantern.origin+(randomInt(8)-4,randomInt(8)-4,randomInt(8)+3));
			wait 2;
		}
		else
			wait 1;
	}
}
//================================Lantern fx ends=============================
//==============================Random passage/element starts=========================
/* 	oraco -	Preset obstacles loaded into the map outside players view will be randomly
			selected to obstruct passages or place objects at each round/map load.
	Map Requirement:
		Select the brush/brushes that you want to remove and make script_brushmodel, set its targetname
		to something unique such as "blockage1", make a script_origin somewhere near this script brush and set its
		targetname to "ran_passage" for passage and "ran_element" for element placement; set its target to "blockage1"
		the same name as your script origin's targetname, if all done correctly you will see the origin points to one
		of the models or brushes. Thats it!
*/
doRandom(){
	level endon("intermission");
	ran_passage = getentarray("ran_passage", "targetname");
	ran_element = getentarray("ran_element", "targetname");
	
	//init random passage obstruct
	for(k=0; k<ran_passage.size; k++){
		//initialize all random passage obstacles to set = true
		ran_passgroup = getentarray(ran_passage[k].target, "targetname");
		for(i=0; i<ran_passgroup.size; i++){
			ran_passgroup[i].set = true;
			ran_passgroup[i].setloc = ran_passgroup[i].origin;
		}
	}
	//init random element placement
	for(j=0; j<ran_element.size; j++){
		//initialize all random elements to set = true
		ran_elegroup = getentarray(ran_element[j].target, "targetname");
		for(i=0; i<ran_elegroup.size; i++){
			ran_elegroup[i].set = true;
			ran_elegroup[i].setloc = ran_elegroup[i].origin;
		}
	}
	//main loop for random generation
	while(1){
		//pass chance of blockage to each obstacle's script origin
		for(k=0; k<ran_passage.size; k++){
			if(isdefined(ran_passage[k].chance))
				chance = randomInt(ran_passage[k].chance);
			else{
				//1/3 chance of obstruct
				chance = randomInt(2);
					//SD pro-mode, no random
					if(getcvar("g_gametype") == "sd")
						chance = 0;
					//disable random, need map_restart
					if(isdefined(getcvar("chelm_random")))
						if(getcvar("chelm_random") == "0")
							chance = 0;
			}
			ran_passage[k] thread ran_think(chance);
		}
		//pass chance of appearing of each element's script origin
		for(k=0; k<ran_element.size; k++){
			//1/3 chance of appearing
			if(isdefined(ran_element[k].chance))
				chance = randomInt(ran_element[k].chance);
			else{
				//1/3 chance of obstruct
				chance = randomInt(2);
			}
			ran_element[k] thread ran_think(chance);
		}
		self waittill("round_started");
	}
}
//set or unset think
ran_think(chance){
	ran_group = getentarray(self.target, "targetname");
	if(chance == 1){
		for(k=0; k<ran_group.size; k++){
			ran_group[k] thread ran_set(ran_group[k].setloc);
		}
	}
	else{
		for(k=0; k<ran_group.size; k++){
			ran_group[k] thread ran_unset(ran_group[k].setloc);
		}
	}
}
//set the obstacle to obstruct this passage
ran_set(oldloc){
	if(!(self.origin == oldloc))
		self.origin = oldloc;
}
//collect all obstacles into the bag under the map		
ran_unset(oldloc){
	if(self.origin == oldloc)
		self.origin += (0,0,-1000);
}
//==============================Random passage/element ends=========================