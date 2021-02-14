#include anarchicmod\utility;

/////////////////////////////////////////
// code loosely based on PRM for CoD 1.1
/////////////////////////////////////////
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

checkSnipers() {

	allied_sniper 	= 0;
	allied_shotty	= 0;

	axis_sniper	= 0;
	axis_shotty	= 0;

	no_weapon = 0;

	lplayers = getentarray("player", "classname");

	for(i = 0; i < lplayers.size; i++) {
		lplayer = lplayers[i];

		if(!isdefined(lplayer.pers["weapon"])) {
			no_weapon++;
		}
		
		else {
			switch(lplayer.pers["weapon"]) {

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

	switch (game["allies"]) {
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

limitweapon(weapon, count, limit) {
	if (count < limit) {
		if (getcvarint("scr_allow_" + weapon) != 1)
			setcvar("scr_allow_" + weapon, 1);
	}
	else {
		if (getcvarint("scr_allow_" + weapon) != 0)
			setcvar("scr_allow_" + weapon, 0);
	}
	maps\mp\gametypes\_weapons::updateallowed();
}