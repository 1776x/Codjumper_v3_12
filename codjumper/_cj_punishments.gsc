/* ______      ____      __
  / ____/___  / __ \    / /_  ______ ___  ____  ___  _____ _________  ____ ___
 / /   / __ \/ / / /_  / / / / / __ `__ \/ __ \/ _ \/ ___// ___/ __ \/ __ `__ \
/ /___/ /_/ / /_/ / /_/ / /_/ / / / / / / /_/ /  __/ /  _/ /__/ /_/ / / / / / /
\____/\____/_____/\____/\__,_/_/ /_/ /_/ .___/\___/_/  (_)___/\____/_/ /_/ /_/
                                      /_/
   --------------------------------------------------
   - Thanks for taking an interest in OUR mod.      -
   - Feel free to borrow our code and claim it as   -
   - your own. It hasn't stopped you in the past.   -                                         -
   -               * CoDJumper Team *               -
   ------------------------------------------------*/

#include codjumper\_cj_utility;

punishInit()
{
	level endon("game_ended");
	while(1)
	{
		setDvar("punish", "");

		while(getDvar("punish") == "")
			wait 0.5;

		/* New Callback */
		[[level._cj_punish]]();
	}
}

punish()
{
	punishment = getDvar("punish");
	tokens = strTok(punishment, "::");

	/* Tokens:
	 * 0. Type
	 * 1. Player ID
	 * 2. Weapon (Used with type GIVE)
	 * 2. Time (Used with Freeze/Flash)
	 * 3. Ammo (Used with type GIVE)
	 */

	id = tokens[1];

	if(isDefined(id))
	{
		switch(tokens[0])
		{
			case "kill":
				thread kill(id);
				break;

			case "spec":
				thread spec(id);
				break;

			case "flash":
				thread flash(id, int(tokens[2]));
				break;

			case "give":
				thread give(id, tokens[2], tokens[3]);
				break;

			/*case "fade":
				thread fade(id);
				break;*/

			case "freeze":
				if(!isDefined(tokens[2]))
					tokens[2] = 0;
				thread freeze(id, int(tokens[2]));
				break;
		}
	}
}

/* Removed for now...
fade(id)
{
	players = getentarray("player", "classname");
	for(i=0;i<players.size;i++)
	{
		tempid = "" + players[i] getEntityNumber();
		if(tempid == id && players[i].cj["status"] <= 1)
			players[i] thread desaturate();
	}
}

desaturate()
{
	self iPrintln("desaturating...");
	for(i=1;i<26;i++)
	{
		self setClientDvar("r_desaturation", (1 + (0.12 * i)));
		wait 0.12;
	}
	for(i=10;i>0;i--)
	{
		if(i==5)
			self iPrintln("5 seconds...");
		else if(i==3)
			self iPrintln("3");
		else if(i==2)
			self iPrintln("2");
		else if(i==1)
			self iPrintln("1");
		wait 1;
	}
	self iPrintln("resaturating...");
	for(i=1;i<26;i++)
	{
		self setClientDvar("r_desaturation", (4 - (0.12 * i)));
		wait 0.12;
	}
	self setClientDvar("r_desaturation",1);
}*/

kill(id)
{
	players = getentarray("player", "classname");

	for(i=0;i<players.size;i++)
	{
		tempid = "" + players[i] getEntityNumber();
		if(tempid == id && (players[i].cj["status"] < level._cj_punishLevel))
			players[i] suicide();
	}
}

spec(id)
{
	players = getentarray("player", "classname");

	for(i=0;i<players.size;i++)
	{
		tempid = "" + players[i] getEntityNumber();
		if(tempid == id && (players[i].cj["status"] < level._cj_punishLevel))
			players[i] [[level.spectator]]();
	}
}

flash(id, time)
{
	if(!isDefined(time))
		time = 6;

	players = getentarray("player", "classname");

	for(i=0;i<players.size;i++)
	{
		tempid = "" + players[i] getEntityNumber();
		if(tempid == id && (players[i].cj["status"] < level._cj_punishLevel))
			players[i] thread maps\mp\_flashgrenades::applyFlash(time, 0.75);
	}
}

freeze(id, time)
{
	if(!isDefined(time))
		time = 5;

	players = getentarray("player", "classname");
	for(i=0;i<players.size;i++)
	{
		tempid = "" + players[i] getEntityNumber();
		if(tempid == id && (players[i].cj["status"] < level._cj_punishLevel))
		{
			if(time > 0)
			{
				players[i] freezecontrols(true);
				players[i].cj["admin"]["frozen"] = 1;
				players[i] thawPlayer(time);
				players[i].cj["admin"]["frozen"] = 0;
				players[i] freezecontrols(false);
			}
			else
			{
				if(players[i].cj["admin"]["frozen"] == 0)
				{
					players[i] freezecontrols(true);
					players[i] setClientDvar("r_blur", 4);
					players[i].cj["admin"]["frozen"] = 1;
				}
	      else if(players[i].cj["admin"]["frozen"] == 1)
	      {
	      	players[i] notify("stop_thaw");
	      	players[i] freezecontrols(false);
	      	players[i] setClientDvar("r_blur", 0);
	      	players[i].cj["admin"]["frozen"] = 0;
	      }
	    }
	    break;
		}
	}
}

thawPlayer(time)
{
	self endon("stop_thaw");

	blur = 4;
	newBlur = blur;
	loops = time / 0.05;

	for(i=0;i<loops;i++)
	{
		newBlur = newBlur - (blur / loops);
		self setClientDvar("r_blur", newBlur);
		wait 0.05;
	}
}

give(id, wep, ammo)
{
	wep = wep + "_mp";

	players = getentarray("player", "classname");
	for(i=0;i<players.size;i++)
	{
		if(!checkIfWep(wep))
			break;

		tempid = "" + players[i] getEntityNumber();
		if(tempid == id)
		{
			players[i] giveWeapon(wep);
			players[i] switchToWeapon(wep);
			if(isDefined(ammo) && (ammo == "no" || ammo == "n" ))
			{
				players[i] SetWeaponAmmoStock(wep, 0);
				players[i] SetWeaponAmmoClip(wep, 0);
			}
			else
				players[i] giveMaxAmmo(wep);
		}
	}
}