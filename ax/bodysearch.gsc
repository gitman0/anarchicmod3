
bodySearch(player)
{
	body = self;
//	body.pack = player.ammo_pack;
	unique_id = randomint(10000);
//	while (!verifyBodyId(unique_id))
//		unique_id = randomint(10000);
	body.id = unique_id;
	wait 0.05;
	body thread waitForSearch();
	level thread expireBody(body);
	iprintln("body search thread kicked off");
}

expireBody(body)
{
	id = body.id;

	while (isdefined(body))
		wait 0.05;

/*	players = getentarray("player", "classname");
	for (i = 0; i < players.size; i++) {
		player = players[i];
		if (!isdefined(player))
			continue;
		if (isalive(player) && (isdefined(player.is_searching)) && (player.is_searching_from == id)) {
			player search_cleanup();
			player notify ("clear_search_hint");
			level notify("body_" + id + "_clear");
		}
			
	}
*/
	level notify("body_" + id + "_clear");
	iprintln("body with id " + id + " expired");
}

waitForSearch()
{
	level endon("body_" + self.id + "_clear");

	mindist = 64;
	minhold = 0.25;

	target = undefined;

	for (;;)
	{
		players = getentarray("player", "classname");

		for (i = 0; i < players.size; i++)
		{
			player = players[i];
			dist = distance(player.origin, self.origin);
			if ( ( dist < mindist ) && isPlayer( player ) && isAlive( player ) && ( player.sessionstate == "playing" ) && ( !player meleeButtonPressed() ) )
			{
				target = player;
				break;
			}
		}
		wait 0.05;
		if (isdefined(target))
			iprintln(target.name + " can search body " + self.id);
		target = undefined;
	}
}

displaySearchHint()
{
	if (!isdefined(self.search_hint1))
		self.search_hint1 = self ax\hud::hudelemText("center", "middle", 570, 192, 0.8, 0.75, (1, 1, 1), 1, level.search_hint1);

	if (!isdefined(self.search_hint2))
		self.search_hint2 = self ax\hud::hudelemText("center", "middle", 570, 202, 0.8, 0.75, (1, 1, 1), 1, level.search_hint2);

	if (!isdefined(self.search_icon))
		self.search_icon = self ax\hud::hudelemShader("center", "middle", 570, 221, 0.8, (1, 0, 0), level.search_icon, 20, 20);

	self waittill("clear_search_hint");

	self searchHudCleanup();
}

searchHudCleanup()
{
	if(isdefined(self.progressbackground))
		self.progressbackground destroy();
	if(isdefined(self.progressbar))
		self.progressbar destroy();
	if (isdefined(self.search_hint1))
		self.search_hint1 destroy();
	if (isdefined(self.search_hint2))
		self.search_hint2 destroy();
	if (isdefined(self.search_icon))
		self.search_icon destroy();
}
