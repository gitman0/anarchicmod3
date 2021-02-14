main() 
{ 
	for (i=1;i<7;i++)
		thread door(i);
} 
door(num)
{
	door = getent("door" + num, "targetname");
	door.open = false;
	trig_left  = getent("door" + num + "_trigger_left", "targetname");
	trig_right = getent("door" + num + "_trigger_right", "targetname");
	door thread movewait(trig_left, 90, -90);
	door thread movewait(trig_right, -90, 90);
}

movewait(trigger, openPos, closePos)
{
	for(;;)
	{
		trigger waittill("trigger");
		if (!self.open) 
		{
			self.open = true;
			self rotateyaw (openPos,0.8);
			self playsound ("door_open");
			self waittill ("rotatedone");
			//iprintln(self.angles);
		}
		else
		{
			self.open = false;
			if (self.angles == (0, 90, 0))
				self rotateyaw (-90,0.8);
			else self rotateyaw (90,0.8);
			self playsound ("door_close");
			self waittill ("rotatedone");
			//iprintln(self.angles);
		}


	}
}