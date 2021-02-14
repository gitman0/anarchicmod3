#include ax\utility;

// majority of antiflop code courtesy of AWE

init()
{
	level thread onPlayerConnect();
}

onPlayerConnect()
{
	for(;;)
	{
		level waittill("connected", player);
		player thread onPlayerSpawned();
		player thread onPlayerKilled();
	}
}

onPlayerSpawned()
{
	self endon("disconnect");

	for(;;)
	{
		self waittill("spawned_player");
		self thread start_antiflop();
	}
}

onPlayerKilled()
{
	self endon("disconnect");

	for(;;)
	{
		self waittill("killed_player");
		if(isdefined(self.awe_spinemarker)) 
		{ 
			self.awe_spinemarker unlink(); 
			self.awe_spinemarker delete(); 
		}
	}
}

start_antiflop() {
	self endon("killed_player");

	if (!level.antiflop)
		return;

	wait 0.5;
	self.awe_spinemarker = spawn("script_origin",(0,0,0)); 
	self.awe_spinemarker linkto (self, "J_Spine4",(0,0,0),(0,0,0));
	wait 0.05;
	self thread antiflop();
}

antiflop() {
	self endon("killed_player");

	self.is_prone = self isProne();
	
	while (1) {
		wait 0.02;
		if ( !isalive(self) || !isplayer(self) || self.sessionstate != "playing" )
			continue;
		if ((self.is_prone == false) && (self isProne())) // just went prone
		{
			current = self getcurrentweapon();
			primary = self getWeaponSlotWeapon("primary");

			if (isdefined(primary) && (current == primary)) {
				reloading = self getWeaponSlotClipAmmo("primary");
			}
			else reloading = 1;

			if (reloading == 0)
				isreload = true;
			else isreload = false;

			if ((!isreload) && (!isSniper(self getcurrentweapon()))) {
				self disableweapon();
				switch (self.prior_stance) {
					case "stand":
						wait 0.6;
						break;
					case "crouch":
						wait 0.4;
						break;
					default:
						break;
				}
				self enableweapon();
			}
		}
		self.is_prone = self isProne();
		self.prior_stance = self getstance(0);
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

GetStance(checkjump) 
{ 
	if( checkjump && !self isOnGround() ) 
		return "jump"; 
	
	if(isdefined(self.awe_spinemarker)) 
	{ 
		distance = self.awe_spinemarker.origin[2] - self.origin[2]; 
		if ( distance < 18 ) return "prone"; 
		else if ( distance < 43 ) return "crouch"; 
		else return "stand"; 
	} 
	else return 0;
}
