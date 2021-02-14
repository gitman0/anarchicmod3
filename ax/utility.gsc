// global function to define allowed gametype objects
allowedGameObjects()
{
	allowed = [];
	switch( level.gametype )
	{
		case "ctf":
			allowed[allowed.size] = "ctf";
			if ( level.ax_ctf_pressurecook > 0 )
				allowed[allowed.size] = "sd";
			break;
		case "hq":
		case "rtdm":
		case "tdm":
			allowed[allowed.size] = "tdm";
			break;
		case "lts":
			allowed[allowed.size] = "sd";
			allowed[allowed.size] = "tdm";
			break;
		case "sd":
			allowed[allowed.size] = "sd";
			allowed[allowed.size] = "bombzone";
			allowed[allowed.size] = "blocker";
			break;
		case "dm":
		default:
			allowed[allowed.size] =	"dm";
			break;
	}
	return allowed;
}	

// boolean if the server is full on the slots specified: public, private, or all
// can sweep multiple times and return based on average response
isServerFull( type, sweeps, delay )
{
	averageScore = 0.0;
	totalScore = 0;
	score = 0;

	if ( !isDefined( sweeps ) || sweeps < 1 )
		sweeps = 1;
	if ( !isDefined( delay ) || delay < 0 )
		delay = 1;

	for ( x = 0; x < sweeps; x++ )
	{
		totalClients = getCvarInt( "sv_maxClients" );

		switch( type )
		{
			case "public":
				privateClients = privateClients( 0 );
				for ( i = privateClients; i < ( totalClients - privateClients ); i++ )
				{
					player = getPlayerByNumber( i );
					if ( !isDefined( player ) || !isPlayer( player ) )
						break;
				}
				score = 1;
				break;
			case "private":
				if ( privateClients( 0 ) == privateClients( 1 ) )
					score = 1;
				break;
			case "all":
				for ( i = 0; i < totalClients; i++ )
				{
					player = getPlayerByNumber( i );
					if ( !isDefined( player ) || !isPlayer( player ) )
						break;
				}
				score = 1;
				break;
		}
		totalScore += score;
		score = 0;
	}
	averageScore = score / sweeps;
	if ( averageScore > 0.5 ) return true;
	else return false;
}

// returns number of allotted or connected private clients
privateClients( connected )
{
	privatePassword = getCvar( "sv_privatePassword" );
	privateClients = getCvarInt( "sv_privateClients" );
	totalClients = getCvarInt( "sv_maxClients" );

	if ( privatePassword != "" && privateClients > 0 )
	{
		if ( !isDefined(connected) || !connected )
		{
			if ( privateClients < totalClients ) return privateClients;
			else return totalClients;
		}
		else if ( connected )
		{
			privateClientsConnected = 0;
			for ( i = 0; i < privateClients; i++ )
			{
				player = getPlayerByNumber( i );
				if ( isPlayer( player ) ) privateClientsConnected++;
			}
			return privateClientsConnected;
		}
	}
	return 0;
}

// returns the player object which has entity number == num
getPlayerByNumber( num )
{
	players = getentarray("player", "classname");
	for (i = 0; i < players.size; i++)
	{
		this = players[i] getEntityNumber();
		if ( this == num )
			return players[i];
	}
	return;
}

// returns an array of players for a given team
getPlayersByTeam( team )
{
	result = [];
	players = getentarray( "player", "classname" );
	for ( i = 0; i < players.size; i++ )
		if ( players[i].pers["team"] == team )
			result[result.size] = players[i];
	return result;
}

// returns the localized string for a given team string
localizedTeam( team )
{
	switch( team )
	{
		case "american": return &"AX_AMERICAN";
		case "british": return &"AX_BRITISH";
		case "russian": return &"AX_RUSSIAN";
		case "german": return &"AX_GERMAN";
		default: return &"AX_UNKNOWN_NATIONALITY";
	}
}

// returns the localized string for a given gametype string
localizedGametype( gt )
{
	switch (gt)
	{
		case "tdm": return &"MPUI_TEAM_DEATHMATCH";
		case "dm": return &"MPUI_DEATHMATCH";
		case "ctf": return &"MPUI_CAPTURE_THE_FLAG";
		case "hq": return &"MPUI_HEADQUARTERS";
		case "sd": return &"MPUI_SEARCH_AND_DESTROY";
		case "rtdm": return "Rifles-Only TDM";
		case "lts": return "Last Team Standing";
	}
}

// returns the localized string for a given mapname string
localizedMap( map )
{
	switch (map)
	{
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

// prints the "joined team" messages, declares auto-assign (if chosen)
printJoinedTeam(team)
{
	if (!self.chose_auto_assign)
	{
		if(team == "allies")
			iprintln(&"MP_JOINED_ALLIES", self.name + "^7");
		else if(team == "axis")
			iprintln(&"MP_JOINED_AXIS", self.name + "^7");
	}
	else
	{
		if(team == "allies")
			iprintln(&"AX_JOINED_AUTO_ALLIES", self.name + "^7");
		else if(team == "axis")
			iprintln(&"AX_JOINED_AUTO_AXIS", self.name + "^7");
	}
	return;
}

// returns boolean true if flag is at the base for given team
flagAtHome(team)
{
	ent = team + "_flag";
	flag = getent(ent, "targetname");
	if ( !isDefined( flag.home_origin) )
		return true;
	if (flag.origin != flag.home_origin)
		return false;
	else return true;
}

//sets random allied team for rifles-only (rtdm)
setRandomAllied()
{
	switch (randomint(2)) {
		case 0:
			game["allies"] = "russian";
			game["russian_soldiertype"] = "padded";
			break;
		case 1:
			game["allies"] = "british";
			game["british_soldiertype"] = "normandy";
			break;
	}
}

// returns the opposing team of given team
otherTeam(team)
{
	if (team == "allies") return "axis";
	else return "allies";
}

// boolean if the given weapon is a turret
isTurret( weapon )
{
	switch(weapon)
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

// boolean if the given weapon is a grenade
isGrenade( weapon )
{
	switch(weapon)
	{
		case "frag_grenade_american_mp":
		case "frag_grenade_british_mp":
		case "frag_grenade_german_mp":
		case "frag_grenade_russian_mp":
			return true;
		default:
			return false;
	}
}

// boolean if the given weapon is a sniper rifle
isSniper( weapon )
{
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

// strips color codes from a string
nocolors( str )
{
	new_str = "";
	for ( i = 0; i < str.size; i++)
	{
		if ( str[i] == "^" && isNum(int(str[i+1])) ) // color code found
			i++;
		else new_str = new_str + str[i];
	}
	return new_str;
}

// boolean returns true if 'i' is a number
isNum( i )
{
	if (i >= 0 || i <= 0) return true;
	else return false;
}

// strip blanks at start and end of string (thanks AWE)
strip( str )
{
	if ( str == "" ) return str;
	s2 = "";
	s3 = "";
	i = 0;
	while ( i < str.size && str[i] == " " )
		i++;
	if ( i == str.size) return ""; // just blanks
	for ( ; i < str.size; i++ )
		s2 += str[i];
	i = s2.size - 1;
	while ( s2[i] == " " && i > 0 )
		i--;
	for ( j = 0; j <= i; j++ )
		s3 += s2[j];
	return s3;
}

// parses a string into an array using delimiter (thanks AWE)
explode( str, delim )
{
	j = 0;
	temparr[j] = "";	

	for ( i = 0; i < str.size; i++ )
	{
		if ( str[i] == delim )
		{
			j++;
			temparr[j] = "";
		}
		else temparr[j] += str[i];
	}
	return temparr;
}

// assists in creating a semi-colon-delimited string
appendLogStr( str, append )
{
	if ( !isDefined(str) )
		return "";
	if ( !isDefined(append) )
		return str;
	s = str + ";" + append;
	return s;
}

// unset specific key of an array after specified amount of time
expireOverTime( array, key, expireTime )
{
        level endon( "intermission" );
        wait expireTime;
        array[ key ] = undefined;
}

// registers a dvar so that an action occurs when a value is set
registerDvarEvent( dvarName, dvarType, dvarAction )
{
	level endon( "intermission" );

	level thread monitorDvar( dvarName, dvarType );

	for (;;)
	{
		level waittill( "dvar_" + dvarName, val );
		[[dvarAction]]( val );
	}
}

// helper function to registerDvarEvent
monitorDvar(name, type)
{
	level endon( "intermission" );

	setCvar( name, "" );
	for (;;)
	{
		if ( type == "float" )
		{
			val = getCvarFloat( name );
			if ( val > 0.0 )
				level notify( "dvar_" + name, val );
		}
		else if ( type == "int" )
		{
			val = getCvarInt( name );
			if ( val > 0 )
				level notify( "dvar_" + name, val );
		}
		else
		{
			val = getCvar( name );
			if ( val != "" )
				level notify( "dvar_" + name, val );
		}
		if ( getCvar( name ) != "" )
			setCvar( name, "" );
		wait 0.5;
	}
}

// enhanced dvar function, replacement for getCvar() & variants (thanks AWE?)
cvardef(varname, vardefault, min, max, type)
{
	mapname = getcvar("mapname");  // "mp_dawnville", "mp_rocket", etc.

	if(getcvar(varname) == "") // if the cvar is blank
		setcvar(varname, vardefault); // set the default

	mapvar = varname + "_" + mapname; // i.e., scr_teambalance becomes scr_teambalance_mp_dawnville
	if(getcvar(mapvar) != "") // if the map override is being used
		varname = mapvar; // use the map override instead of the standard variable

	if ( !isdefined(type) )
		type = "string";

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
