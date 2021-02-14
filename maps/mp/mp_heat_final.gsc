main() 
{ 
maps\mp\_load::main(); 
maps\mp\mp_heat_final_fx::main(); 

// set background ambient noise 
ambientPlay("ambient_mp_heat_final");

if(getcvar("g_gametype") == "hq") 
{ 
level.radio = []; 
level.radio[0] = spawn("script_model", (2199, 610, 211)); 
level.radio[0].angles = (0, 90, 0); 

level.radio[1] = spawn("script_model", (664, 440, 161)); 
level.radio[1].angles = (0, 0, 0); 

level.radio[2] = spawn("script_model", (140, 3292, 216)); 
level.radio[2].angles = (0, 180, 0); 

level.radio[3] = spawn("script_model", (1342, 4157, 216)); 
level.radio[3].angles = (0, 180, 0); 

level.radio[4] = spawn("script_model", (1416, 2513, 161)); 
level.radio[4].angles = (0, 270, 0); 
} 

} 
