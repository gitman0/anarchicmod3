// by RollinHard
// do not modify this script
// settings are precise for simmerath
// if you want to use this script please ask me
// contact www.anarchic-x.com

main()
{
             level._effect["mortar_explosion"][0] = loadfx("fx/explosions/mortarExp_dirt.efx");
             level._effect["mortar_explosion"][1] = loadfx("fx/explosions/mortarExp_mud.efx");

level thread simmerath_mortars();
}

simmerath_mortars()
{
             mortar = getentarray ("mortar1","targetname");
             while (1)
             {
             wait (5 + randomfloat(10));
             GoodPosition = false;
             while (!GoodPosition)
             {
             rand = randomint(mortar.size);
             GoodPosition = true;
             players = getentarray("player", "classname");
             for(i = 0; i < players.size; i++)
             {
             if (distance(mortar[rand].origin,players[i].origin) < 1)
             {
             GoodPosition = false;
             break;
             }
             }
             }
             rand = randomint(mortar.size);
             mortar[rand] playsound("mortar_incoming"); 
             wait 2;
             origin = mortar[rand] getorigin();
             playfx (level._effect["mortar_explosion"][randomint(2)], origin);
             mortar[rand] playsound("mortar_explosion");
             radiusDamage(mortar[rand].origin + (0,0,12), 300, 50, 30);
             }
}
 
             

 