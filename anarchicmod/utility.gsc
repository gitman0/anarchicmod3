check_ax()
{
	//self iprintln(nocolors(name));
	tags = "^7|^4ax^7|";
	nc = nocolors(self.name);
	if (nc.size > tags.size)
		return;
}

nocolors(str)
{
	tmp = "";
	for (i=0; i<str.size; i++) {
		if (str[i] == "^" && isnum(int(str[i+1]))) // color code found
			i++;
		else tmp = tmp + str[i];
	}
	return tmp;		
}

isnum(x)
{
	if (x >= 0 || x <= 0)
		return true;
	else return false;
}

isTurret(w)
{
	switch(w)
	{
		case "mg42_bipod_duck_mp":
		case "mg42_bipod_prone_mp":
		case "mg42_bipod_stand_mp":
		case "30cal_prone_mp":
		case "30cal_stand_mp":
			return true;
		default:
			return false;
	}
}

isSniper(weapon) {
	switch (weapon) {
		case "enfield_scope_mp":
		case "kar98k_sniper_mp":
		case "mosin_nagant_sniper_mp":
		case "springfield_mp":
			return true;
		default:
			return false;
	}
}

isProne() {
	switch (self getStance(0)) {
		case "prone":
			return true;
		default:
			return false;
	}
}



localizedGametype(gt) {
	switch (gt) {
		case "tdm": return &"MPUI_TEAM_DEATHMATCH";
		case "dm": return &"MPUI_DEATHMATCH";
		case "ctf": return &"MPUI_CAPTURE_THE_FLAG";
		case "hq": return &"MPUI_HEADQUARTERS";
		case "sd": return &"MPUI_SEARCH_AND_DESTROY";
		case "rtdm": return "Rifles-Only TDM";
	}
}
localizedMap(map) {
	switch (map) {
		case "mp_brecourt": return &"MENU_BRECOURT_FRANCE_MP";
		case "mp_burgundy": return &"MENU_BURGUNDY_FRANCE_MP";
		case "mp_trainstation": return &"MENU_CAEN_FRANCE_MP";
		case "mp_carentan": return &"MENU_CARENTAN_FRANCE_MP";
		case "mp_decoy": return &"MENU_EL_ALAMEIN_EGYPT_MP";
		case "mp_leningrad": return &"MENU_LENINGRAD_RUSSIA_MP";
		case "mp_matmata": return &"MENU_MATMATA_TUNISIA_MP";
		case "mp_downtown": return &"MENU_MOSCOW_RUSSIA_MP";
		case "mp_dawnville": return &"MENU_ST_MERE_EGLISE_FRANCE_MP";
		case "mp_railyard": return &"MENU_STALINGRAD_RUSSIA_MP";
		case "mp_toujane": return &"MENU_TOUJANE_TUNISIA_MP";
		case "mp_farmhouse": return &"MENU_BELTOT_FRANCE_MP";
		case "mp_breakout": return &"MENU_VILLERSBOCAGE_FRANCE_MP";
		case "mp_harbor": return &"AX_ROSTOV_RUSSIA_MP";
		case "mp_rhine": return &"AX_WALLENDER_GERMANY_MP";
		default: return map;
	}
}

getMapName(map)
{
	if (!isdefined(map))
		return;

	switch(map)
	{
		case "mp_farmhouse":
			return "Beltot, France";
		case "mp_brecourt":
			return "Brecourt, France";
		case "mp_burgundy":
			return "Burgundy, France";
		case "mp_trainstation":
			return "Caen, France";
		case "mp_carentan":
			return "Carentan, France";
		case "mp_decoy":
			return "El Alamein, Egypt";
		case "mp_leningrad":
			return "Leningrad, Russia";
		case "mp_matmata":
			return "Matmata, Tunisia";
		case "mp_downtown":
			return "Moscow, Russia";
		case "mp_dawnville":
			return "St. Mere Eglise, France";
		case "mp_railyard":
			return "Stalingrad, Russia";
		case "mp_toujane":
			return "Toujane, Tunisia";
		case "mp_breakout":
			return "Villers-Bocage, France";
		case "mp_rhine":
			return "Wallendar, Germany";
		case "mp_harbor":
			return "Rostov, Russia";
		case "mp_borisovka":
			return "Borisovka, Russia";
		case "mp_bridge":
			return "The Bridge";
		case "mp_depot":
			return "Depot, Germany";
		case "mp_flakbatterie_v1_0":
		case "mp_flakbatterie":
			return "Flakbatterie, Germany";
		case "mp_heat_final":
			return "Heat, Normandy";
		case "mp_sabes_du_mot_beta":
			return "Sabes Du Mot, France";
		case "mp_buhlert":
			return "Buhlert, Germany";
		case "mp_siegfriedline":
			return "Westwall, Germany";
		case "mp_st-gatien":
			return "St-Gatien, France";
		case "mp_simmerath_beta2":
			return "Simmerath, Germany";
		case "mp_tobruk":
			return "Tobruk, Libya";
		case "mp_docks":
			return "Murmansk [BetaV2]";
		case "mp_farm_assault_beta2":
			return "Farm Assault beta2";
		case "mp_chelm":
			return "Chelm, Poland (Beta 1)";
		case "mp_d-day+7.2":
			return "D-day+7.2 Final";
		case "mp_neuville":
			return "Neuville, France";
		case "mp_townville":
			return "Townville";
		case "mp_cassino":
			return "Cassino, Italy";
		case "mp_commando":
			return "Commando";
		case "mp_salerno_beachhead_b":
		case "mp_salerno_beachhead":
			return "Salerno Beachhead Beta, Italy";
				
		default:
			return map;
	}
}

// Following code courtesy of AWE by bell

GetStance(checkjump) 
{ 
	if( checkjump && !self isOnGround() ) 
		return "jump"; 
	
	if(isdefined(self.awe_spinemarker)) 
	{ 
		distance = self.awe_spinemarker.origin[2] - self.origin[2]; 
		if(distance<18) 
			return "prone"; 
		else if(distance<43) 
			return "crouch"; 
		else 
			return "stand"; 
	} 
	else 
	{ 
		return 0; 
	} 
}

strip(s)
{
	if(s=="")
		return "";

	s2="";
	s3="";

	i=0;
	while(i<s.size && s[i]==" ")
		i++;

	// String is just blanks?
	if(i==s.size)
		return "";
	
	for(;i<s.size;i++)
	{
		s2 += s[i];
	}

	i=s2.size-1;
	while(s2[i]==" " && i>0)
		i--;

	for(j=0;j<=i;j++)
	{
		s3 += s2[j];
	}
		
	return s3;
}

explode(s,delimiter)
{
	j=0;
	temparr[j] = "";	

	for(i=0;i<s.size;i++)
	{
		if(s[i]==delimiter)
		{
			j++;
			temparr[j] = "";
		}
		else
			temparr[j] += s[i];
	}
	return temparr;
}

cvardef(varname, vardefault, min, max, type)
{
	mapname = getcvar("mapname");  // "mp_dawnville", "mp_rocket", etc.

	if(getcvar(varname) == "") // if the cvar is blank
		setcvar(varname, vardefault); // set the default

	mapvar = varname + "_" + mapname; // i.e., scr_teambalance becomes scr_teambalance_mp_dawnville
	if(getcvar(mapvar) != "") // if the map override is being used
		varname = mapvar; // use the map override instead of the standard variable

	// get the variable's definition
	switch(type)
	{
		case "int":
			definition = getcvarint(varname);
			break;
		case "float":
			definition = getcvarfloat(varname);
			break;
		case "string":
		default:
			definition = getcvar(varname);
			break;
	}

	// if it's a number, with a minimum, that violates the parameter
	if((type == "int" || type == "float") && !isdefined(min) && definition < min)
		definition = min;

	// if it's a number, with a maximum, that violates the parameter
	if((type == "int" || type == "float") && !isdefined(max) && definition > max)
		definition = max;

	return definition;
}