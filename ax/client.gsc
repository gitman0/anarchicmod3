/* $Id */

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

		player thread fixClientCvars(60);

		player.pers["hop_denial"] = 0.0;
		player thread hopwatch();
	}
}

onPlayerSpawned()
{
	self endon("disconnect");

	for(;;)
	{
		self waittill("spawned_player");
		self thread idleWatchDog();
	}
}

onPlayerKilled()
{
	self endon("disconnect");

	for (;;)
	{
		self waittill("killed_player");
	}
}

fixClientCvars(interval)
{
	self endon("disconnect");

	if (!isdefined(interval))
		interval = 60;

	// reset the chat position in case we forced it off-screen
	self setClientCvar( "cg_hudchatposition", "5 85" );

	// chat stays on screen for 12 seconds
	self setClientCvar( "cg_chattime", 12000 );

	// make sure the compass is scaled properly
	self setClientCvar( "cg_hudCompassSize", 1 );

	// modded servers show up in server browser
	self setClientCvar( "ui_browserMod", 1 );

	// make sure autodownloads are enabled
	self setClientCvar( "cl_allowdownload", 1 );

	// set rate to cable/dsl
	self setClientCvar( "rate", 25000 );

	if ( level.rename_unknown && self.name == "Unknown Soldier" )
	{
		rand = level.rename_unknown_prefix + "..." + randomint(30) + "_" + randomint(3000);
		self setClientCvar("name", rand);
	}

	for (;;)
	{
		// increase the range of the compass for objpoints
		self setClientCvar( "cg_hudObjectiveMaxRange", 10000 );

		// scale the headicons like classic call of duty
		self setClientCvar( "cg_headiconminscreenradius", 0.003 );

		if (level.disable_grenade_icons)
		{
			self setClientCvar( "cg_hudGrenadeIconHeight", 0 );
			self setClientCvar( "cg_hudGrenadeIconWidth", 0 );
			self setClientCvar( "cg_hudGrenadePointerHeight", 0 );
			self setClientCvar( "cg_hudGrenadePointerWidth", 0 );
		}
		wait interval;
	}
}

idleWatchdog()
{
	if ( !level.ax_idle_limit || !isdefined(game["matchstarted"]) || !game["matchstarted"] )
		return;

	self endon("disconnect");
	self endon("killed_player");

	warn_interval = ( level.ax_idle_limit / (level.ax_idle_warn_count + 1) );

	origin_current = self.origin;
	angles_current = self getplayerangles();

	last_warn = 0;
	watch_delay = 1;
	spec_delay = 5;

	idle_time = 0;

	while ( isplayer(self) && isalive(self) && (self.sessionstate == "playing") )
	{
		wait watch_delay;

		origin_latest = self.origin;
		angles_latest = self getplayerangles();

		if ( (origin_current == origin_latest) && (angles_current == angles_latest) )
			idle_time++;
		else {
			idle_time = 0;
			last_warn = 0;
			origin_current = origin_latest;
			angles_current = angles_latest;
			continue;
		}

		if (idle_time > level.ax_idle_limit)
		{
			clientAnnouncement(self, "^1Attention!");
			clientAnnouncement(self, "You are being forced to spectate because you are not playing!");
			iprintln("^5Idle Watchdog^7: " + self.name + "^7 has been idle too long - moving to spectate.");
			wait spec_delay;
			self thread moveToSpectate();
			return;
		}
		else if (idle_time > warn_interval && ( (idle_time - last_warn) > warn_interval ) )
		{
			clientAnnouncement(self, "^1Attention!");
			clientAnnouncement(self, "Please go to spectate if you are not playing!");
			last_warn = idle_time;
		}
		// new values become old values
		origin_current = origin_latest;
		angles_current = angles_latest;
	}
}

moveToSpectate()
{
	self.pers["team"] = "spectator";
	self.sessionteam = "spectator";
	[[level.spawnspectator]]();
}

hopwatch()
{
	self endon("disconnect");
	self thread hop_deny_notify();
	self.hopping = false;

	for (;;)
	{
		i = 0.0;
		z_old = self.origin[2];
		while (!self isonground() && i < 0.5)
		{
			if (self.origin[2] < z_old && i < 0.15)
				break;
			self.hopping = true;
			i += 0.05;
			z_old = self.origin[2];
			wait 0.05;
		}
		self.hopping = false;

		while (!self isonground())
			wait 0.05;
		wait 0.05;
	}
}

hop_deny_notify()
{
	self endon("disconnect");
	total = 0.0;
	for (;;)
	{
		wait 45;
		if (self.pers["hop_denial"] > 0)
		{
			total += self.pers["hop_denial"];
			self iprintln(&"AX_HOPPER_MISSED_POINTS", total);
			self.pers["hop_denial"] = 0.0;
		}
	}
}

isVotingAllowed()
{
	if (level.gametype == "ctf")
	{
		if ( !isdefined(game["matchstarted"]) || !game["matchstarted"] )
			return false;
	}
	if (level.voting_minplayers > 0)
	{
		m = level.voting_minplayers % 2;
		if (m > 0) level.voting_minplayers += m;
		per_team = level.voting_minplayers / 2;
		players = maps\mp\gametypes\_teams::CountPlayers();
		if ( ( players["allies"] < per_team && players["axis"] < per_team ) || players.size < level.voting_minplayers )
			return false;
	}
	return true;
}
