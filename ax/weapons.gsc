#include ax\utility;

init()
{
	if (!level.allow_turrets)
		thread delete_turrets();

	publishWeaponLimits();
	updateAvailableWeapons();

	level thread onPlayerConnect();
}

onPlayerConnect()
{
	for(;;)
	{
		level waittill("connected", player);
		player thread onPlayerSpawned();
		player thread onPlayerKilled();
		player thread onJoinedTeam();
		player thread onJoinedSpectators();
		player thread onPlayerDisconnect();
	}
}

onPlayerSpawned()
{
	self endon("disconnect");

	for(;;)
	{
		self waittill("spawned_player");
		updateAvailableWeapons();
	}
}

onJoinedTeam()
{
	self endon("disconnect");
        
	for(;;)
	{
		self waittill("joined_team");
		updateAvailableWeapons();
	}
}

onJoinedSpectators()
{
	self endon("disconnect");
        
	for(;;)
	{
		self waittill("joined_spectators");
		updateAvailableWeapons();
	}
}

onPlayerKilled()
{
	self endon("disconnect");
        
	for(;;)
	{
		self waittill("killed_player");
		updateAvailableWeapons();
	}
}

onPlayerDisconnect()
{
	self waittill("disconnect");
	updateAvailableWeapons();
}

publishWeaponLimits()
{
	setCvar("ui_limit_sniper_allied", level.allied_sniper);
	makeCvarServerInfo("ui_limit_sniper_allied");
	setCvar("ui_limit_sniper_axis", level.axis_sniper);
	makeCvarServerInfo("ui_limit_sniper_axis");
	setCvar("ui_limit_shotgun_allied", level.allied_shotty);
	makeCvarServerInfo("ui_limit_shotgun_allied");
	setCvar("ui_limit_shotgun_axis", level.axis_shotty);
	makeCvarServerInfo("ui_limit_shotgun_axis");
}

updateAvailableWeapons() {

	allied_sniper 	= 0;
	allied_shotty	= 0;

	axis_sniper	= 0;
	axis_shotty	= 0;

	no_weapon = 0;

	lplayers = getentarray("player", "classname");

	for(i = 0; i < lplayers.size; i++)
	{
		lplayer = lplayers[i];

		if ( !isdefined(lplayer.pers["weapon"]) )
			no_weapon++;
		
		else
		{
			switch(lplayer.pers["weapon"])
			{
				// allied sniper weapons
				case "springfield_mp":
				case "mosin_nagant_sniper_mp":
				case "enfield_scope_mp":
					allied_sniper++;
					break;

				// axis sniper
				case "kar98k_sniper_mp":
					axis_sniper++;
					break;

				// global shotgun
				case "shotgun_mp":
					if (lplayer.pers["team"] == "axis")
						axis_shotty++;
					else allied_shotty++;
					break;
				default:
					no_weapon++;
					break;
			}		
		}
	}

	switch (game["allies"])
	{
		case "american":
			limitweapon("springfield", allied_sniper, level.allied_sniper);
			break;
		case "russian":
			limitweapon("nagantsniper", allied_sniper, level.allied_sniper);
			break;
		case "british":
			limitweapon("enfieldsniper", allied_sniper, level.allied_sniper);
			break;
	}
	limitweapon("kar98ksniper", axis_sniper, level.axis_sniper);

	// shotty gets treated a little differently
	limitShotgun(level.axis_shotty, level.allied_shotty, axis_shotty, allied_shotty);

}
	
limitweapon(weapon, count, limit) {
	if (count < limit) {
		if (getcvarint("scr_allow_" + weapon) != 1)
			setcvar("scr_allow_" + weapon, 1);
	}
	else {
		if (getcvarint("scr_allow_" + weapon) != 0)
			setcvar("scr_allow_" + weapon, 0);
	}
	if ( isDefined(level.weaponnames) )
		maps\mp\gametypes\_weapons::updateallowed();
}

limitShotgun(axis_limit, allied_limit, axis_count, allied_count) {
	if (axis_count >= axis_limit)
		updateAllowedByTeam("axis", "shotgun", 0);
	else updateAllowedByTeam("axis", "shotgun", 1);

	if (allied_count >= allied_limit)
		updateAllowedByTeam("allies", "shotgun", 0);
	else updateAllowedByTeam("allies", "shotgun", 1);
}

updateAllowedByTeam(team, weapon, val) {
	players = getentarray("player", "classname");
	for(i = 0; i < players.size; i++) {
		if (players[i].pers["team"] == team)
			players[i] setClientCvar("ui_allow_" + weapon, val);
	}
}

dropsniper(weapon, team)
{
	hard_limit = 0;
	level.sniper_soft = 2;
	if (!issniper(weapon))
		return true;

	count = 0;
	no_weapon = 0;

	lplayers = getentarray("player", "classname");

	for(i = 0; i < lplayers.size; i++) {
		lplayer = lplayers[i];

		if (lplayer.pers["team"] == team)
		{
			if (team == "axis")
				hard_limit = level.axis_sniper;
			else hard_limit = level.allied_sniper;
			if(!isdefined(lplayer.pers["weapon"]))
				no_weapon++;
			else if (issniper(lplayer.pers["weapon"]))
				count++;
			else if (issniper(weapon))
				count++;
		}
	}
	if (count >= (level.sniper_soft + hard_limit))
		return false;
	else return true;
}



delete_turrets()
{
	_turret	= getentarray("misc_turret", "classname");
	for (i=0;i<_turret.size;i++)
		_turret[i] delete();
	_mg42	= getentarray("misc_mg42", "classname");
	for (i=0;i<_mg42.size;i++)
		_mg42[i] delete();
}

getGrenadeType()
{
	if(self.pers["team"] == "allies")
	{
                switch(game["allies"])
                {
	                case "american":
        	                return "frag_grenade_american_mp";
	                case "british":
        	                return "frag_grenade_british_mp";
	                default:
        	                assert(game["allies"] == "russian");
                	        return "frag_grenade_russian_mp";
                }
        }
        else
        {
                assert(self.pers["team"] == "axis");
                switch(game["axis"])
                {
	                default:
        	                assert(game["axis"] == "german");
                	        return "frag_grenade_german_mp";
                }
        }
}

takeFrags()
{
	self takeWeapon("frag_grenade_american_mp");
	self takeWeapon("frag_grenade_british_mp");
	self takeWeapon("frag_grenade_russian_mp");
	self takeWeapon("frag_grenade_german_mp");
}

giveFrags()
{
	if(getcvarint("scr_allow_fraggrenades"))
	{
		if (level.static_nade_count > 0)
			fraggrenadecount = level.static_nade_count;
		else fraggrenadecount = maps\mp\gametypes\_weapons::getWeaponBasedGrenadeCount(self.pers["weapon"]);
		if(fraggrenadecount)
		{
			grenadetype = self getGrenadeType();
			self giveWeapon(grenadetype);
			self setWeaponClipAmmo(grenadetype, fraggrenadecount);
		}
	}
}


