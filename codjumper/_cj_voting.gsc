#include codjumper\_cj_utility;

playerList()
{
	self endon("disconnect");
	i = 0;
	self.cj["vote"]["player"] = i;
	self setClientDvar("ui_cj_player", level.players[i].name);
	self.cj["vote"]["playerent"] = level.players[i] getEntityNumber();

	for(;;)
	{
		self waittill("playerlist");
		if(!isDefined(self.cj["vote"]["dir"]))
			self.cj["vote"]["dir"] = "next";

		if(self.cj["vote"]["dir"] == "next")
		{
			i++;
			if(i >= level.players.size)
			i = 0;
			self setClientDvar("ui_cj_player", level.players[i].name);
			self.cj["vote"]["playerent"] = level.players[i] getEntityNumber();
			self.cj["vote"]["player"] = i;
		}
		else if(self.cj["vote"]["dir"] == "prev")
		{
			i--;
			if(i < 0)
			i = level.players.size - 1;
			self setClientDvar("ui_cj_player", level.players[i].name);
			self.cj["vote"]["playerent"] = level.players[i] getEntityNumber();
			self.cj["vote"]["player"] = i;
		}
	}
}

mapBrowse()
{
	self endon("disconnect");
	i = 0;
	self.cj["vote"]["map"] = level.maplist[i];
	self setClientDvar("ui_cj_map", level.maplist[i]);

	for(;;)
	{
		self waittill("maplist");

		if(self.cj["vote"]["dir"] == "mnext")
		{
			i++;
			if(i >= level.maplist.size)
				i = 0;
			self setClientDvar("ui_cj_map", level.maplist[i]);
			self.cj["vote"]["map"] = level.maplist[i];
		}
		else if(self.cj["vote"]["dir"] == "mprev")
		{
			i--;
			if(i < 0)
				i = level.maplist.size - 1;
			self setClientDvar("ui_cj_map", level.maplist[i]);
			self.cj["vote"]["map"] = level.maplist[i];
		}
	}
}

cjVoteCalledPlayer(vote, player, arg)
{
	level endon ("votecancelled");
	level endon ("voteforce");

	if(voteInProgress())
		return;

	if(player.cj["vote"]["delayed"] && player.cj["status"] == 0)
	{
		player iPrintln("Vote Delay: ^1" + (level.cjvotedelay - player.cj["time"]["played"] + "^7 seconds remaining"));
		return;
	}

	if(player.cj["vote"]["novoting"] && player.cj["status"] == 0)
	{
		player iprintln("You are currently ^1locked^7 from voting");
		return;
	}

	if(!(player playerCheck(arg)))
	{
		player iprintln("^5* ^7Player cannot be kicked ^5*");
		return;
	}

	level.cjvoteinprogress = 1;

	level.cjvoteagainst = level.players[arg] getEntityNumber();
	level.cjvoteagainstname = level.players[arg].name;
	level.cjvotecalled = player getEntityNumber();
	level.cjvotearg = arg;

	switch(vote)
	{
		case "kick":
			level.cjvotetype = "Vote: Kick Player";
			break;
		default:
			level.cjvotetype = "Vote: Other";
			break;
	}

	iprintln("^5* ^7Vote called by:  ^7" + monotone(player.name) + " ^5*^7");
	player thread disableVoting();

	for(i=0;i<level.players.size;i++)
	{
		level.players[i] setClientDvar("ui_cj_player_vote",level.cjvoteagainstname);
		level.players[i] setClientDvar("ui_cj_votetype", level.cjvotetype);
		level.players[i] thread startCountdown(level.cjvoteduration);
		level.players[i] thread createVoteHud();
		if(i == arg)
			thread watchPlayer(level.players[i]);
	}

	if(player.cj["vote"]["voted"] == false)
	{
		player.cj["vote"]["voted"] = true; // [CJ] [Automatically vote yes for player]
		level.cjvoteyes+=1;
	}

	wait level.cjvoteduration;

	for(i=0;i<level.players.size;i++)
	{
		level.players[i] setClientDvar("ui_cj_player_vote", "");
		level.players[i] setClientDvar("ui_cj_votetype", "");
	}

	//Vote Ended Here
	iprintln("Voted - Yes: ^2" + level.cjvoteyes + "^7 No: ^1" + level.cjvoteno + " ^7Ratio: " + (level.cjvoteyes / (level.cjvoteyes + level.cjvoteno)));

	if((level.cjvoteyes / (level.cjvoteyes + level.cjvoteno)) > level.cjvotewinratio)
	{
		iprintln("^5V^7ote ^2Passed");
		thread compareAndAction(level.cjvotetype, level.cjvoteagainst, level.cjvotearg);
	}
	else
		iprintln("^5V^7ote ^1Failed");



	for(i=0;i<level.players.size;i++)
	{
		level.players[i].cj["vote"]["voted"] = false;
		level.players[i] thread removeVoteHud();
	}

	level.cjvoteinprogress = 0;
	level.cjvoteyes = 0;
	level.cjvoteno = 0;
	level.cjvotetype = "";
	level.cjvotecalled = "";
	level.cjvoteagainst = "";
	level.cjvoteagainstname = "";
	level.cjvotearg = undefined;
}

cjVoteCalledMap(vote, player, arg)
{
	level endon ("votecancelled");
	level endon ("voteforce");

	if(voteInProgress())
		return;

	if(player.cj["vote"]["delayed"] && player.cj["status"] == 0)
	{
		player iPrintln("Vote Delay: ^1" + (level.cjvotedelay - player.cj["time"]["played"] + "^7 seconds remaining"));
		return;
	}

	if(player.cj["vote"]["novoting"] > 0 && player.cj["status"] == 0)
	{
		player iPrintln("Vote Lockout: ^1" + player.cj["vote"]["novoting"] + "^7 seconds remaining");
		return;
	}

	level.cjvoteinprogress = 1;
	level.cjvotearg = arg;

	switch(vote)
	{
		case "change":
			level.cjvotetype = "Vote: Change Map";
			break;
		case "extend":
			level.cjvotetype = "Vote: Extend Time";
			break;
		case "rotate":
			level.cjvotetype = "Vote: Rotate Map";
			break;
		default:
			level.cjvotetype = "Vote: Other";
			break;
	}

	iprintln("^5* ^7Vote called by:  ^7" + monotone(player.name) + " ^5*^7");
	player thread disableVoting();

	for(i=0;i<level.players.size;i++)
	{
		level.players[i] setClientDvar("ui_cj_player_vote", level.cjvotearg);
		level.players[i] setClientDvar("ui_cj_votetype", level.cjvotetype);
		level.players[i] thread startCountdown(level.cjvoteduration);
		level.players[i] thread createVoteHud();
	}

	if(player.cj["vote"]["voted"] == false)
	{
		player.cj["vote"]["voted"] = true; // [CJ] [Automatically vote yes for player]
		level.cjvoteyes+=1;
	}

	wait level.cjvoteduration;

	for(i=0;i<level.players.size;i++)
	{
		level.players[i] setClientDvar("ui_cj_player_vote", "");
		level.players[i] setClientDvar("ui_cj_votetype", "");
	}

	//Vote Ended Here
	iprintln("Voted - Yes: ^2" + level.cjvoteyes + "^7 No: ^1" + level.cjvoteno + " ^7Ratio: " + (level.cjvoteyes / (level.cjvoteyes + level.cjvoteno)));

	if((level.cjvoteyes / (level.cjvoteyes + level.cjvoteno)) > level.cjvotewinratio)
	{
		iprintln("^5V^7ote ^2Passed");
		thread compareAndAction(level.cjvotetype, undefined, level.cjvotearg);
	}
	else
		iprintln("^5V^7ote ^1Failed");

	for(i=0;i<level.players.size;i++)
	{
		level.players[i] thread removeVoteHud();
		level.players[i].cj["vote"]["voted"] = false;
	}

	level.cjvoteinprogress = 0;
	level.cjvoteyes = 0;
	level.cjvoteno = 0;
	level.cjvotetype = "";
	level.cjvotecalled = "";
	level.cjvotearg = undefined;
}

watchPlayer(player)
{
	while(level.cjvoteinprogress)
	{
		if(!isDefined(player))
			level notify("votecancelled");
		wait 0.5;
	}
}

compareAndAction(vote, against, arg)
{
	switch(vote)
	{
		case "Vote: Kick Player":
			if(against == (level.players[arg] getEntityNumber()))
				kick(level.players[arg] getEntityNumber());
			else
				iprintln("Something went wrong");
			wait 0.05;
			for(i=0;i<level.players.size;i++)
				level.players[i] notify("playerlist");
			break;
		case "Vote: Extend Time":
			temp = getDvarInt("scr_cj_timelimit");
			setDvar("scr_cj_timelimit", (temp + 10));
			break;
		case "Vote: Rotate Map":
			thread maps\mp\gametypes\_globallogic::endGame(undefined, "Vote Passed - Rotating Map");
			break;
		case "Vote: Change Map":
			rotation = " map " + arg + " " + getDvar("sv_mapRotationCurrent");
			setDvar( "sv_mapRotationCurrent", rotation);
			wait 3;
			thread maps\mp\gametypes\_globallogic::endGame(undefined, "Vote Passed - Changing Map");
			break;
		default:
			iprintlnbold("Report Error ["+vote+"]");
	}
}

voteCancelled()
{
	level endon ("game_ended");
	while(1)
	{
		level waittill("votecancelled");
		for(i=0;i<level.players.size;i++)
		{
			level.players[i] setClientDvar("ui_cj_player_vote", "");
			level.players[i] setClientDvar("ui_cj_votetype", "");
		}

		for(i=0;i<level.players.size;i++)
		{
			level.players[i].cj["vote"]["voted"] = false;
			level.players[i] thread removeVoteHud();
		}

		level.cjvoteinprogress = 0;
		level.cjvoteyes = 0;
		level.cjvoteno = 0;
		level.cjvotetype = "";
		level.cjvotecalled = "";
		level.cjvoteagainst = "";
		level.cjvoteagainstname = "";
		level.cjvotearg = undefined;

		iprintln("^5V^7ote ^1Cancelled");
	}
}

voteForced()
{
	level endon ("game_ended");
	while(1)
	{
		level waittill("voteforce");
		for(i=0;i<level.players.size;i++)
		{
			level.players[i] setClientDvar("ui_cj_player_vote", "");
			level.players[i] setClientDvar("ui_cj_votetype", "");
		}

		for(i=0;i<level.players.size;i++)
		{
			level.players[i].cj["vote"]["voted"] = false;
			level.players[i] thread removeVoteHud();
		}

		level.cjvoteinprogress = 0;
		level.cjvoteyes = 0;
		level.cjvoteno = 0;

		thread compareAndAction(level.cjvotetype, level.cjvoteagainst, level.cjvotearg);

		level.cjvotetype = "";
		level.cjvotecalled = "";
		level.cjvoteagainst = "";
		level.cjvoteagainstname = "";
		level.cjvotearg = undefined;
		iprintln("^5V^7ote ^2Forced");
	}
}

timeCount()
{
	self endon("disconnect");
	self endon("killed_player");
	self endon("joined_spectators");
	level endon ("game_ended");

	self thread voteDelayCheck(); // Start lockout check loop

	while(1) // If player has played enough
	{
		self.cj["time"]["played"]++;

		i = floor(self.cj["time"]["played"] / 30); // CHANGE TO 300
		if(i > self.cj["time"]["count"])
		{
				self thread maps\mp\gametypes\_rank::giveRankXP("time", 1 );
				self.cj["time"]["count"]++;
		}

		self setClientDvar("player_summary_time", self.cj["time"]["played"]);
		wait 1;
	}
}

voteDelayCheck()
{
	self endon("disconnect");
	self endon("killed_player");
	self endon("joined_spectators");
	level endon ("game_ended");

	while((self.cj["time"]["played"] < level.cjvotedelay) && self.cj["status"] == 0)
	{
		self.cj["vote"]["delayed"] = true;
		wait 1;
	}
		self.cj["vote"]["delayed"] = false;
}

getPlayerStatus()
{
	level waittill ("game_ended");
	players = getentarray("player", "classname");

	for(i=0;i<players.size;i++)
	{
		if(isDefined(players[i]) && players[i].cj["status"] > 0)
			setDvar("cj_player_" + i, players[i].name + "::" + players[i] getGUID() + "::" + players[i].cj["status"]);
	}
}

checkPlayerStatus()
{
	for(i=0;i<level.cjstatus.size;i++)
	{
		if(level.cjstatus[i].name == self.name)
			if(level.cjstatus[i].guid == self getGUID())
			{
				self.cj["status"] = int(level.cjstatus[i].status);
				break;
			}
	}
}

playerStatusArray()
{
	level.cjstatus = [];
	i = 0;

	for(;;)
	{
		if(isDefined(getDvar("cj_player_" + i)) && getDvar("cj_player_" + i) != "")
		{
			tokens = strTok(getDvar("cj_player_" + i), "::");
			size = level.cjstatus.size;
			level.cjstatus[size] = spawnstruct();
			level.cjstatus[size].name = tokens[0];
			level.cjstatus[size].guid = tokens[1];
			level.cjstatus[size].status = tokens[2];

			setDvar("cj_player_" + i, "");
		}
		else
			break;

		i++;
	}
}