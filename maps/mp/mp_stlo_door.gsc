main() 
{ 
thread door1();
thread door2();
thread door3();
thread door4();
thread door5();
thread door6();
} 

door1()
{
level.door1_open = false;
thread door1_trigger_right();
thread door1_trigger_left();
}

door1_trigger_right() 
{ 
door1 = getent ("door1","targetname"); 
door1_trigger_right = getent ("door1_trigger_right","targetname");
while (1) 
{
door1_trigger_right waittill ("trigger");
if (level.door1_open == true)
{
thread door1_trigger_left();
return;
}
else if (level.door1_open == false)
{
level.door1_open = true;
door1 rotateyaw (-90,0.8);
door1 playsound ("door_open");
door1 waittill ("rotatedone");
wait 5;
door1 rotateyaw (90,0.8);
door1 playsound ("door_close");
door1 waittill ("rotatedone");
level.door1_open = false;
thread door1_trigger_right();
thread door1_trigger_left();
return;
}
}
}

door1_trigger_left() 
{ 
door1 = getent ("door1","targetname"); 
door1_trigger_left = getent ("door1_trigger_left","targetname");
while (1) 
{
door1_trigger_left waittill ("trigger");
if (level.door1_open == true)
{
thread door1_trigger_right();
return;
}
else if (level.door1_open == false)
{
level.door1_open = true;
door1 rotateyaw (90,0.8);
door1 playsound ("door_open");
door1 waittill ("rotatedone");
wait 5;
door1 rotateyaw (-90,0.8);
door1 playsound ("door_close");
door1 waittill ("rotatedone");
level.door1_open = false;
thread door1_trigger_left();
thread door1_trigger_right();
return;
}
}
}

door2()
{
level.door2_open = false;
thread door2_trigger_right();
thread door2_trigger_left();
}

door2_trigger_right() 
{ 
door2 = getent ("door2","targetname"); 
door2_trigger_right = getent ("door2_trigger_right","targetname");
while (1) 
{
door2_trigger_right waittill ("trigger");
if (level.door1_open == true)
{
thread door2_trigger_left();
return;
}
else if (level.door2_open == false)
{
level.door2_open = true;
door2 rotateyaw (-90,0.8);
door2 playsound ("door_open");
door2 waittill ("rotatedone");
wait 5;
door2 rotateyaw (90,0.8);
door2 playsound ("door_close");
door2 waittill ("rotatedone");
level.door2_open = false;
thread door2_trigger_right();
thread door2_trigger_left();
return;
}
}
}

door2_trigger_left() 
{ 
door2 = getent ("door2","targetname"); 
door2_trigger_left = getent ("door2_trigger_left","targetname");
while (1) 
{
door2_trigger_left waittill ("trigger");
if (level.door2_open == true)
{
thread door2_trigger_right();
return;
}
else if (level.door2_open == false)
{
level.door2_open = true;
door2 rotateyaw (90,0.8);
door2 playsound ("door_open");
door2 waittill ("rotatedone");
wait 5;
door2 rotateyaw (-90,0.8);
door2 playsound ("door_close");
door2 waittill ("rotatedone");
level.door2_open = false;
thread door2_trigger_left();
thread door2_trigger_right();
return;
}
}
}

door3()
{
level.door3_open = false;
thread door3_trigger_right();
thread door3_trigger_left();
}

door3_trigger_right() 
{ 
door3 = getent ("door3","targetname"); 
door3_trigger_right = getent ("door3_trigger_right","targetname");
while (1) 
{
door3_trigger_right waittill ("trigger");
if (level.door1_open == true)
{
thread door3_trigger_left();
return;
}
else if (level.door3_open == false)
{
level.door3_open = true;
door3 rotateyaw (-90,0.8);
door3 playsound ("door_open");
door3 waittill ("rotatedone");
wait 5;
door3 rotateyaw (90,0.8);
door3 playsound ("door_close");
door3 waittill ("rotatedone");
level.door3_open = false;
thread door3_trigger_right();
thread door3_trigger_left();
return;
}
}
}

door3_trigger_left() 
{ 
door3 = getent ("door3","targetname"); 
door3_trigger_left = getent ("door3_trigger_left","targetname");
while (1) 
{
door3_trigger_left waittill ("trigger");
if (level.door3_open == true)
{
thread door3_trigger_right();
return;
}
else if (level.door3_open == false)
{
level.door3_open = true;
door3 rotateyaw (90,0.8);
door3 playsound ("door_open");
door3 waittill ("rotatedone");
wait 5;
door3 rotateyaw (-90,0.8);
door3 playsound ("door_close");
door3 waittill ("rotatedone");
level.door3_open = false;
thread door3_trigger_left();
thread door3_trigger_right();
return;
}
}
}

door4()
{
level.door4_open = false;
thread door4_trigger_right();
thread door4_trigger_left();
}

door4_trigger_right() 
{ 
door4 = getent ("door4","targetname"); 
door4_trigger_right = getent ("door4_trigger_right","targetname");
while (1) 
{
door4_trigger_right waittill ("trigger");
if (level.door1_open == true)
{
thread door4_trigger_left();
return;
}
else if (level.door4_open == false)
{
level.door4_open = true;
door4 rotateyaw (-90,0.8);
door4 playsound ("door_open");
door4 waittill ("rotatedone");
wait 5;
door4 rotateyaw (90,0.8);
door4 playsound ("door_close");
door4 waittill ("rotatedone");
level.door4_open = false;
thread door4_trigger_right();
thread door4_trigger_left();
return;
}
}
}

door4_trigger_left() 
{ 
door4 = getent ("door4","targetname"); 
door4_trigger_left = getent ("door4_trigger_left","targetname");
while (1) 
{
door4_trigger_left waittill ("trigger");
if (level.door4_open == true)
{
thread door4_trigger_right();
return;
}
else if (level.door4_open == false)
{
level.door4_open = true;
door4 rotateyaw (90,0.8);
door4 playsound ("door_open");
door4 waittill ("rotatedone");
wait 5;
door4 rotateyaw (-90,0.8);
door4 playsound ("door_close");
door4 waittill ("rotatedone");
level.door4_open = false;
thread door4_trigger_left();
thread door4_trigger_right();
return;
}
}
}

door5()
{
level.door5_open = false;
thread door5_trigger_right();
thread door5_trigger_left();
}

door5_trigger_right() 
{ 
door5 = getent ("door5","targetname"); 
door5_trigger_right = getent ("door5_trigger_right","targetname");
while (1) 
{
door5_trigger_right waittill ("trigger");
if (level.door1_open == true)
{
thread door5_trigger_left();
return;
}
else if (level.door5_open == false)
{
level.door5_open = true;
door5 rotateyaw (-90,0.8);
door5 playsound ("door_open");
door5 waittill ("rotatedone");
wait 5;
door5 rotateyaw (90,0.8);
door5 playsound ("door_close");
door5 waittill ("rotatedone");
level.door5_open = false;
thread door5_trigger_right();
thread door5_trigger_left();
return;
}
}
}

door5_trigger_left() 
{ 
door5 = getent ("door5","targetname"); 
door5_trigger_left = getent ("door5_trigger_left","targetname");
while (1) 
{
door5_trigger_left waittill ("trigger");
if (level.door5_open == true)
{
thread door5_trigger_right();
return;
}
else if (level.door5_open == false)
{
level.door5_open = true;
door5 rotateyaw (90,0.8);
door5 playsound ("door_open");
door5 waittill ("rotatedone");
wait 5;
door5 rotateyaw (-90,0.8);
door5 playsound ("door_close");
door5 waittill ("rotatedone");
level.door5_open = false;
thread door5_trigger_left();
thread door5_trigger_right();
return;
}
}
}

door6()
{
level.door6_open = false;
thread door6_trigger_right();
thread door6_trigger_left();
}

door6_trigger_right() 
{ 
door6 = getent ("door6","targetname"); 
door6_trigger_right = getent ("door6_trigger_right","targetname");
while (1) 
{
door6_trigger_right waittill ("trigger");
if (level.door1_open == true)
{
thread door6_trigger_left();
return;
}
else if (level.door6_open == false)
{
level.door6_open = true;
door6 rotateyaw (-90,0.8);
door6 playsound ("door_open");
door6 waittill ("rotatedone");
wait 5;
door6 rotateyaw (90,0.8);
door6 playsound ("door_close");
door6 waittill ("rotatedone");
level.door6_open = false;
thread door6_trigger_right();
thread door6_trigger_left();
return;
}
}
}

door6_trigger_left() 
{ 
door6 = getent ("door6","targetname"); 
door6_trigger_left = getent ("door6_trigger_left","targetname");
while (1) 
{
door6_trigger_left waittill ("trigger");
if (level.door6_open == true)
{
thread door6_trigger_right();
return;
}
else if (level.door6_open == false)
{
level.door6_open = true;
door6 rotateyaw (90,0.8);
door6 playsound ("door_open");
door6 waittill ("rotatedone");
wait 5;
door6 rotateyaw (-90,0.8);
door6 playsound ("door_close");
door6 waittill ("rotatedone");
level.door6_open = false;
thread door6_trigger_left();
thread door6_trigger_right();
return;
}
}
}