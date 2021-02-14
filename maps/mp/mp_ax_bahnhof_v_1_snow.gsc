//by GER-Iceman & Rollin Hard
//www.anarchic-x.com
main()
      {
       level.trainyard_snow = loadfx ("fx/misc/snow_light_mp_railyard.efx");
       thread trainyard_snow();
      }
trainyard_snow()
      {
       zufall = RandomInt(200);
       while(1)
      {
       players = getentarray("player", "classname");
       if(players.size > 0)
      {
       max_nodes = 20;
       max_nodes_per_player = max_nodes/players.size;
       for(ii=0;ii<max_nodes_per_player;ii++)
      {
       for(i = 0; i < players.size; i++)
      {
       player = players[i];
       if(isAlive(player))
      {
       x= 500-randomfloat(1000);
       y= 500-randomfloat(1000);
       pos = player.origin +(x,y,200) ;
       trace = bulletTrace(pos,pos +(0,0,-250), true, undefined);
       if(trace["fraction"] != 1) playfx(level.trainyard_snow,trace["position"]);
       wait 0.05;
      }
      }
      }
      }
       wait 0.05;
      }
      }