main()
{
setCullFog(0,8000,0.2,0.2,0.22,0);
ambientPlay("ambient_mp_schlossadler");

maps\mp\_load::main();

maps\mp\_mysound::main();

game["allies"]="american";
game["axis"]="german";

game["american_soldiertype"]="airborne";
game["american_soldiervariation"]="winter";
game["german_soldiertype"]="wehrmacht";
game["german_soldiervariation"]="winter";

game["attackers"]="allies";
game["defenders"]="axis";

maps\mp\mp_schlossadler_fx::main();
}