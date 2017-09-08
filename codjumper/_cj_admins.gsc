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

adminInit()
{
	if((getDvar("cj_adminguids") != "-1") && (getDvarInt("cj_autoadmin") == 1))
		getAdmins();

	thread adminPromote();
	thread adminDemote();
}

getAdmins()
{
	admins = getDvar("cj_adminguids");
	tokens = strTok(admins, ",");
	if(tokens.size < 3)
	{
		setErr("Admin GUID list badly formed");
		return;
	}
	else if((tokens.size % 3) != 0)
	{
		setErr("Admin GUID list contains too few tokens");
		return;
	}

	level.cjAdmin = [];
	level.cjAdmin["guids"] = [];
	level.cjAdmin["names"] = [];
	level.cjAdmin["ranks"] = [];

	for(i=0;i<tokens.size;i++)
	{
		/***/if((i % 3) == 0)
			level.cjAdmin["guids"][level.cjAdmin["guids"].size] = tokens[i];
		else if((i % 3) == 1)
			level.cjAdmin["names"][level.cjAdmin["names"].size] = tokens[i];
		else if((i % 3) == 2)
			level.cjAdmin["ranks"][level.cjAdmin["ranks"].size] = tokens[i];
	}
}

checkAdmin()
{
	tempGuid = self getGuid();
	tempName = monotone(self.name);


	for(i=0;i<level.cjAdmin["guids"].size;i++)
	{
		if(tempGUID == level.cjAdmin["guids"][i])
			break;
	}

	if(i >= level.cjAdmin["guids"].size)
		return;

	if(level.cjAdmin["guids"][i] == tempGUID)
	{
		if(level.cjAdmin["names"][i] != tempName)
			self thread waitForNameChange(i);
		else if(level.cjAdmin["names"][i] == tempName)
			self thread promotePlayer(level.cjAdmin["ranks"][i]);
	}
}

waitForNameChange(num)
{
	self endon("disconnect");
	self iprintlnbold("^1*** ^2GUID Detected - Name Incorrect^1***^7");

	while(self.name != level.cjAdmin["names"][num])
		wait 1;

	self thread promotePlayer(level.cjAdmin["ranks"][num]);
}

adminPromote()
{
	level endon ("game_ended");

	while(1)
	{
		while(getDvar("cj_promote") == "" && getDvar("cj_soviet_promote") == "")
			wait 0.1;

		if(getDvar("cj_soviet_promote") == "")
		{
			promote = getDvarInt("cj_promote");
			pto = 1;
		}
		else
		{
			promote = getDvarInt("cj_soviet_promote");
			pto = 3;
		}

		players = getentarray("player","classname");
		for(i=0;i<players.size;i++)
		{
			temp = players[i] getEntityNumber();
			if(temp == promote)
				players[i] promotePlayer(pto);
		}

		setDvar("cj_promote", "");
		setDvar("cj_soviet_promote", "");
	}
}

promotePlayer(rank)
{
	self.cj["status"] = int(rank);
	self iPrintlnbold(self.cj["local"]["PROMOTED"]);
}

adminDemote()
{
	level endon ("game_ended");

	while(1)
	{
		while(getDvar("cj_demote") == "")
			wait 0.1;

		demote = getDvarInt("cj_demote");

		players = getentarray("player","classname");
		for(i=0;i<players.size;i++)
		{
			temp = players[i] getEntityNumber();
			if(temp == demote)
			{
				players[i] demotePlayer();
				players[i] suicide();
			}
		}
		setDvar("cj_demote", "");
	}
}

demotePlayer()
{
	self.cj["status"] = 0;
	self iPrintlnbold(self.cj["local"]["DEMOTED"]);
}

nameProtection()
{
	self endon("disconnect");
	if(getDvarInt("cj_autoadmin") != 1 && getDvar("cj_adminguids") == "-1")
		return;

	while(1)
	{
		tempGuid = self getGuid();
		tempName = monotone(self.name);

		for(i=0;i<level.cjAdmin["names"].size;i++)
		{
			if(tempName == level.cjAdmin["names"][i])
				break;
		}

		if(i >= level.cjAdmin["names"].size)
			return;

		if(level.cjAdmin["names"][i] == tempName)
		{
			if(level.cjAdmin["guids"][i] != tempGUID)
				self reservedNameChange();
			else
				while(tempName == monotone(self.name))
					wait 2;
		}
		wait 0.05;
	}
}

reservedNameChange()
{
	self setClientDvar("name", getDvar("cj_rename"));
}