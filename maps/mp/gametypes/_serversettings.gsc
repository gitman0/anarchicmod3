init()
{
	level.hostname = getCvar("sv_hostname");
	if(level.hostname == "")
		level.hostname = "CoDHost";
	setCvar("sv_hostname", level.hostname);
	setCvar("ui_hostname", level.hostname);
	makeCvarServerInfo("ui_hostname", "CoDHost");

	level.motd = getCvar("scr_motd");
	if(level.motd == "")
		level.motd = "";
	setCvar("scr_motd", level.motd);
	setCvar("ui_motd", level.motd);
	makeCvarServerInfo("ui_motd", "");

	level.allowvote = getCvar("g_allowvote");
	if(level.allowvote == "")
		level.allowvote = "1";
	setCvar("g_allowvote", level.allowvote);
	setCvar("ui_allowvote", level.allowvote);
	makeCvarServerInfo("ui_allowvote", "1");

	level.allowvotemaprestart = getCvar("g_allowvotemaprestart");
	if(level.allowvotemaprestart == "")
		level.allowvotemaprestart = "1";
	setCvar("g_allowvotemaprestart", level.allowvotemaprestart);
	setCvar("ui_allowvotemaprestart", level.allowvotemaprestart);
	makeCvarServerInfo("ui_allowvotemaprestart", "1");

	level.allowvotemaprotate = getCvar("g_allowvotemaprotate");
	if(level.allowvotemaprotate == "")
		level.allowvotemaprotate = "1";
	setCvar("g_allowvotemaprotate", level.allowvotemaprotate);
	setCvar("ui_allowvotemaprotate", level.allowvotemaprotate);
	makeCvarServerInfo("ui_allowvotemaprotate", "1");

	level.allowvotemap = getCvar("g_allowvotemap");
	if(level.allowvotemap == "")
		level.allowvotemap = "1";
	setCvar("g_allowvotemap", level.allowvotemap);
	setCvar("ui_allowvotemap", level.allowvotemap);
	makeCvarServerInfo("ui_allowvotemap", "1");

	level.allowvotetypemap = getCvar("g_allowvotetypemap");
	if(level.allowvotetypemap == "")
		level.allowvotetypemap = "1";
	setCvar("g_allowvotetypemap", level.allowvotetypemap);
	setCvar("ui_allowvotetypemap", level.allowvotetypemap);
	makeCvarServerInfo("ui_allowvotetypemap", "1");

	level.allowvotekick = getCvar("g_allowvotekick");
	if(level.allowvotekick == "")
		level.allowvotekick = "1";
	setCvar("g_allowvotekick", level.allowvotekick);
	setCvar("ui_allowvotekick", level.allowvotekick);
	makeCvarServerInfo("ui_allowvotekick", "1");

	level.friendlyfire = getCvar("scr_friendlyfire");
	if(level.friendlyfire == "")
		level.friendlyfire = "0";
	setCvar("scr_friendlyfire", level.friendlyfire, true);
	setCvar("ui_friendlyfire", level.friendlyfire);
	makeCvarServerInfo("ui_friendlyfire", "0");

	for(;;)
	{
		updateServerSettings();
		wait 5;
	}
}

updateServerSettings()
{
	sv_hostname = getCvar("sv_hostname");
	if(level.hostname != sv_hostname)
	{
		level.hostname = sv_hostname;
		setCvar("ui_hostname", level.hostname);
	}

	scr_motd = getCvar("scr_motd");
	if(level.motd != scr_motd)
	{
		level.motd = scr_motd;
		setCvar("ui_motd", level.motd);
	}

	g_allowvote = getCvar("g_allowvote");
	if( level.allowvote != g_allowvote || ( level.allowvote == "1" && !maps\mp\gametypes\_anarchic::isVotingAllowed() ) )
	{
		if (maps\mp\gametypes\_anarchic::isVotingAllowed())
			level.allowvote = g_allowvote;
		else level.allowvote = "0";
		if (getCvar("ui_allowvote") != level.allowvote)
			setCvar("ui_allowvote", level.allowvote);
	}

	g_allowvotemaprestart = getCvar("g_allowvotemaprestart");
	if(level.allowvotemaprestart != g_allowvotemaprestart)
	{
		level.allowvotemaprestart = g_allowvotemaprestart;
		setCvar("ui_allowvotemaprestart", level.allowvotemaprestart);
	}

	g_allowvotemaprotate = getCvar("g_allowvotemaprotate");
	if(level.allowvotemaprotate != g_allowvotemaprotate)
	{
		level.allowvotemaprotate = g_allowvotemaprotate;
		setCvar("ui_allowvotemaprotate", level.allowvotemaprotate);
	}

	g_allowvotemap = getCvar("g_allowvotemap");
	if(level.allowvotemap != g_allowvotemap)
	{
		level.allowvotemap = g_allowvotemap;
		setCvar("ui_allowvotemap", level.allowvotemap);
	}

	g_allowvotetypemap = getCvar("g_allowvotetypemap");
	if(level.allowvotetypemap != g_allowvotetypemap)
	{
		level.allowvotetypemap = g_allowvotetypemap;
		setCvar("ui_allowvotetypemap", level.allowvotetypemap);
	}

	g_allowvotekick = getCvar("g_allowvotekick");
	if(level.allowvotekick != g_allowvotekick)
	{
		level.allowvotekick = g_allowvotekick;
		setCvar("ui_allowvotekick", level.allowvotekick);
	}
	
	scr_friendlyfire = getCvar("scr_friendlyfire");
	if(level.friendlyfire != scr_friendlyfire)
	{
		level.friendlyfire = scr_friendlyfire;
		setCvar("ui_friendlyfire", level.friendlyfire);
	}
}
