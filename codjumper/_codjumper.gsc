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

// Admin Menu
//	- Rcon Login
//	- Change Map
//	- Restart Map
//	- Kick/Ban Player
//	- Enable/Disable Voting
//	- Promote/Demote
//	- Punishments
//	- Small/Big Say
//	- Time limit
// Send PM (P2P)

#include codjumper\_cj_utility;
#include maps\mp\gametypes\_hud_util;
#include common_scripts\utility;

init()
{
	level._author = "Drofder@CoDJumper.com";	// Author
	level._version = "3.12";									// Version
	level._date = "02.01.12";									// Date
	level._translators_german = "Lev!athan & TheDude";	// German
	level._translators_french = "BlueDamselfly";				// French
	level._translators_polish = "Tr4b4nt";							// Polish
	level._translators_dutch = "[SoE]_Zaitsev";					// Dutch
	level._specialthanks = "T3chn0r, Soviet@CoDJumper.com";		// www.openwarfaremod.com

	codjumper\_cj_setup::precacheStuff();						// Precache
	codjumper\_cj_setup::setupDvars(); 							// Dvars

	addons\addon::init();											// Custom Stuff

	thread codjumper\_cj_setup::setupWeapons();			// Weapons
	thread codjumper\_cj_setup::setupInfo();				// Mod Info
	thread codjumper\_cj_punishments::punishInit();	// Punish
	thread codjumper\_cj_admins::adminInit();				// Pro/Demote

	thread RemoveTurrets();		// Remove Turrets

	thread onPlayerConnect();	// OnPlayerConnect

	thread rotateMessage();		// Rotating Messages
	thread _svr_msg();				// Send Server Message
	thread _player_msg();			// Send Private Message

	thread codjumper\_cj_voting::voteCancelled();			// Waits for votes to be cancelled
	thread codjumper\_cj_voting::voteForced();				// Waits for votes to be forced
	thread codjumper\_cj_voting::getPlayerStatus();		// Creates an array of promoted players at map end
	thread codjumper\_cj_voting::playerStatusArray();	// Creates an array of promoted players at map start

	thread mapList();	// Creates an array of maps
	//thread bots();
}

onPlayerConnect()
{
	for(;;)
	{
		level waittill("connected", player);
		player codjumper\_cj_setup::setupPlayer();
		player codjumper\_cj_setup::setupLanguage();

		player thread codjumper\_cj_voting::checkPlayerStatus();
		player thread setupAdvert();

		if((getDvar("cj_adminguids") != "-1") && (getDvarInt("cj_autoadmin") == 1))
			player thread codjumper\_cj_admins::checkAdmin();

		player thread onPlayerSpec();
		player thread onPlayerSpawned();
		//player thread codjumper\_cj_admins::nameProtection();
		player thread codjumper\_cj_voting::playerList();
		player thread codjumper\_cj_voting::mapBrowse();
	}
}

onPlayerSpec()
{
	for(;;)
	{
		self waittill("joined_spectators");
		self thread changeAdvert();
		self thread codjumper\_cj_commands::onCustomMenuResponse();
	}
}

onPlayerSpawned()
{
	for(;;)
	{
		self waittill("spawned_player");
		self notify("endcommands");

		self thread _MeleeKey();						// Melee Key Watch
		self thread _UseKey();							// Use Key Watch

		self thread weaponSetup();					// Weapon Setup
		self thread removePerks();					// Remove Perks
		self thread checkSuicide();					// Check for Suicide

		self thread codjumper\_cj_commands::onCustomMenuResponse();	// Get Quick Commands Menu
		self thread doWelcomeMessages();		// Welcome Player

		self thread codjumper\_cj_voting::timeCount();	// Count for participation

		if(self.cj["status"] == 1)
			self setRank(level.maxrank+1, 0);
		else if(self.cj["status"] == 2)
			self setRank(level.maxrank+2, 0);
		else if(self.cj["status"] == 3)
			self setRank(level.maxrank+3, 0);
		else
		{
			rankId = self maps\mp\gametypes\_rank::getRankForXp( self maps\mp\gametypes\_rank::getRankXP() );
			if(rankId > level.maxrank)
				self setRank(level.maxrank, 0);
			else
				self setRank(rankId);
		}

		self thread changeAdvert();				// Modify Adverts
	}
}

// Load, Save & Suicide //
_MeleeKey()
{
	self endon("disconnect");
	self endon("killed_player");
	self endon("joined_spectators");

	for(;;)
	{
		if(self meleeButtonPressed())
		{
			catch_next = false;
			count = 0;

			for(i=0; i<0.5; i+=0.05)
			{
				if(catch_next && self meleeButtonPressed() && self isOnGround())
				{
					self thread [[level._cj_save]](1);
					wait 1;
					break;
				}
				else if(catch_next && self attackButtonPressed() && self isOnGround())
				{
					while(self attackButtonPressed() && count < 1)
					{
						count+=0.1;
						wait 0.1;
					}
					if(count >= 1 && self isOnGround())
						self thread [[level._cj_save]](3);
					else if(count < 1 && self isOnGround())
						self thread [[level._cj_save]](2);

					wait 1;
					break;
				}
				else if(!(self meleeButtonPressed()) && !(self attackButtonPressed()))
					catch_next = true;

				wait 0.05;
			}
		}

		wait 0.05;
	}
}

_UseKey()
{
	self endon("disconnect");
	self endon("killed_player");
	self endon("joined_spectators");

	for(;;)
	{
		if(self useButtonPressed())
		{
			catch_next = false;
			count = 0;

			for(i=0; i<=0.5; i+=0.05)
			{
				if(catch_next && self useButtonPressed() && !(self isMantling()))
				{
					self thread [[level._cj_load]](1);
					wait 1;
					break;
				}
				else if(catch_next && self attackButtonPressed() && !(self isMantling()))
				{
					while(self attackButtonPressed() && count < 1)
					{
						count+= 0.1;
						wait 0.1;
					}
					if(count < 1 && self isOnGround() && !(self isMantling()))
						self thread [[level._cj_load]](2);
					else if(count >= 1 && self isOnGround() && !(self isMantling()))
						self thread [[level._cj_load]](3);

					wait 1;
					break;
				}
				else if(!(self useButtonPressed()))
					catch_next = true;

				wait 0.05;
			}
		}

		wait 0.05;
	}
}

checkSuicide()
{
	self endon("disconnect");
	self endon("joined_spectators");
	self endon("killed_player");

	while(1)
	{
		i = 0;

		while(!self meleeButtonPressed())
			wait 0.05;

		while(self meleeButtonPressed() && i <= 2)
		{
			wait 0.05;
			i+=0.05;
		}

		if(i >= 2)
			self suicide();
	}
}

// Loadout //
weaponSetup()
{
	self endon("disconnect");
	self endon("joined_spectators");
	self endon("killed_player");

	self takeAllWeapons();
	wait 0.05;

	if(isDefined(self.cj["status"]))
		self.cj["weapon"] = level.cjWeapons[self.cj["status"]];
	else
		self.cj["weapon"] = "beretta_mp";

	// RPG On/Off
	if(getDvarInt("cj_disablerpg") != 1)
	{
		self giveWeapon("rpg_mp");
		self SetActionSlot( 4, "weapon", "rpg_mp" );
		self thread rpgCheck();
	}

	// Frags On/Off
	if(getDvarInt("cj_enablenades") == 1)
	{
		self giveWeapon("frag_grenade_mp");
		self thread grenadeCheck();
	}
	else
		self setWeaponAmmoClip("frag_grenade_mp", 0);

	if(getDvarInt("cj_freerun") == 1)
		self giveWeapon("c4_mp");

	checkWeapons = strTok(self.cj["weapon"], ";;");
	if(checkWeapons.size > 1)
	{
		for(i=0;i<checkWeapons.size;i++)
			self giveWeapon(checkWeapons[i]);

		wait 0.05;
		self switchToWeapon(checkWeapons[checkWeapons.size-1]);
	}
	else
	{
		self giveWeapon(self.cj["weapon"]);
		wait 0.05;
		self switchToWeapon(self.cj["weapon"]);
	}

	if(self.cj["status"] > 0)
		self giveMaxAmmo(self.cj["weapon"]);
}

rpgCheck()
{
	self endon("disconnect");
	self endon("joined_spectators");
	self endon("killed_player");

	while(1)
	{
		while(self getCurrentWeapon() != "rpg_mp")
			wait 0.05;

		if(self getAmmoCount("rpg_mp") < 2)
			self giveMaxAmmo("rpg_mp");
		wait 0.5;
	}
}

grenadeCheck()
{
	self endon("disconnect");
	self endon("joined_spectators");
	self endon("killed_player");

	while(1)
	{
		self SetWeaponAmmoClip( "frag_grenade_mp", 1 );
		self waittill ( "grenade_fire" );
		wait 1;
	}
}

removePerks()
{
	self endon("disconnect");
	self endon("joined_spectators");
	self endon("killed_player");

	self clearPerks();
	self setPerk("specialty_longersprint");
	self setPerk("specialty_armorvest");
	self setPerk("specialty_fastreload");

	if(self.cj["status"] >= 1)
	{
		self setPerk("specialty_holdbreath");
		self setPerk("specialty_quieter");
	}

	self showPerk( 0, "specialty_longersprint", -50 );
	self showPerk( 1, "specialty_armorvest", -50 );
	self showPerk( 2, "specialty_fastreload", -50 );
	self thread maps\mp\gametypes\_globallogic::hidePerksAfterTime( 3.0 );
	self thread maps\mp\gametypes\_globallogic::hidePerksOnDeath();
}

// Messaging //
doWelcomeMessages()
{
	if(isDefined(self.cj["welcome"]))
		return;

	msg = getDvar("cj_welcome");
	tokens = strTok(msg, "::");

	if(tokens.size == 1)
		self iprintlnbold("" + tokens[0]);
	else if(tokens.size > 1)
	{
		messages = [];

		for(i=0;i<tokens.size;i++)
		{
			if( isEven(i) )
				wait(int(tokens[i]));
			else
				self iprintlnbold("" + tokens[i]);
		}
	}

	self.cj["welcome"] = true;
}

rotateMessage()
{
	level endon ("game_ended");

	if(getDvar("cj_msg_rotate_1") == "")
		return;

	if(getDvar("cj_msg_delay") == "")
		setDvar("cj_msg_delay", 45);

	svrmsg = [];
	i = 1;

	for(;;)
	{
		temp = "cj_msg_rotate_" + i;
		if(getDvar(temp) != "")
			svrmsg[i-1] = getDvar(temp);
		else
			break;

		i++;
		wait 0.05;
	}

	if(svrmsg.size < 1)
		return;

	i = 0;

	delay = getDvarInt("cj_msg_delay");
	for(;;)
	{
		if(i >= svrmsg.size)
			i = 0;

		wait delay;
		iprintln(svrmsg[i]);
		i++;
	}
}
_svr_msg()
{
	level endon("game_ended");
	for(;;)
	{
		size = undefined;
		tokens = [];
		setDvar("cj_svr_msg", "");

		while(1)
		{
			if(getDvar("cj_svr_msg") != "")
				break;
			wait 0.5;
		}

		tokens = strTok(getDvar("cj_svr_msg"), "::");

		if(tokens.size < 1)
			continue;

		if(tokens.size == 1)
		{
			iprintlnbold("" + tokens[0]);
			continue;
		}

		if(tokens.size > 1)
		{
			switch(tokens[0])
			{
				case "bold":
				case "b":
				case "big":
				case "large":
				case "l":
					size = "bold";
					break;
				case "small":
				case "s":
					size = "small";
					break;
				default:
					size = "bold";
			}

			if(size == "small")
				iprintln("" + tokens[1]);
			else
				iprintlnbold("" + tokens[1]);

			continue;
		}

		wait 0.1;
	}
}

_player_msg()
{
	level endon("game_ended");
	for(;;)
	{
		size = undefined;
		name = undefined;
		tokens = [];
		setDvar("cj_player_msg", "");

		while(1)
		{
			if(getDvar("cj_player_msg") != "")
				break;

			wait 0.5;
		}

		tokens = strTok(getDvar("cj_player_msg"), "::");

		// If there are no tokens, then there is an error.
		if(tokens.size < 1)
			continue;

		// If there is only 1 token, then there is an error.
		if(tokens.size == 1)
			continue;

		// If there is only 2 tokens, assume first is player name.
		if(tokens.size == 2)
		{
			players = getentarray("player", "classname");
			name = tokens[0];

			for(i=0;i<players.size;i++)
			{
				tempname = monotone(players[i].name);
				if(isSubStr(tempname, name))
					players[i] iprintlnbold("" + tokens[1]);
			}
		}

		// Correct ammount of tokens.
		if(tokens.size > 2)
		{
			switch(tokens[0])
			{
				case "big":
				case "bold":
				case "b":
				case "large":
					size = "bold";
					break;
				case "small":
				case "s":
					size = "small";
					break;
				default:
					size = "bold";
			}

			players = getentarray("player", "classname");
			name = tokens[1];

			for(i=0;i<players.size;i++)
			{
				tempname = monotone(players[i].name);
				if(isSubStr(tempname, name))
				{
					if(size == "small")
						players[i] iprintln("" + tokens[2]);
					else
						players[i] iprintlnbold("" + tokens[2]);
				}
			}
		}

		wait 0.1;
	}
}

// Admin //

adminCommand(command, arg)
{
	if(level.players[self.cj["admin"]["playerent"]].cj["status"] < 1 && (command == "kick" || command == "ban"))
	{
		switch(command)
		{
			case "kick":
				self notify("adminclose");
				self iPrintln(level.players[self.cj["admin"]["playerent"]].name+" has been kicked");
				kick(level.players[self.cj["admin"]["playerent"]] getEntityNumber());
				break;
			case "ban":
				self notify("adminclose");
				self iPrintln(level.players[self.cj["admin"]["playerent"]].name+" has been banned");
				ban(level.players[arg] getEntityNumber());
				break;
		}
	}
	else
	{
		switch(command)
			{
				case "promote":
					setDvar("cj_promote", arg);
					break;
				case "demote":
					self notify("adminclose");
					setDvar("cj_demote", arg);
					break;
				case "teletoplayer":
					self setOrigin(level.players[self.cj["admin"]["playerent"]].origin);
					break;
				case "playertele":
					level.players[self.cj["admin"]["playerent"]] setOrigin(self.origin);
					break;
			}
	}
}

textCommand(command, arg)
{
	/***/if(command == "playermessage")
		setDvar("cj_player_msg", self.cj["admin"]["player"]+"::"+arg);
	else if(command == "setspeed")
		level.players[arg] SetMoveSpeedScale(getDvarInt("speed"));
	else if(command == "setname")
		level.players[arg] setClientDvar("name", getDvar("cj_rename"));
}

fullPlayerList()
{
	self endon("adminclose");
	self endon("disconnect");
	self endon("killed_player");

	self.cj["admin"]["player"] = level.players[0].name;
	self.cj["admin"]["playerent"] = level.players[0] getEntityNumber();
	self.cj["admin"]["pm"] = "send a private message";
	self.cj["admin"]["speed"] = "1";
	self.cj["admin"]["rename"] = level.players[0].name;
	self.cj["admin"]["givemenu"] = 0;
	self.cj["admin"]["weapfinal"] = "";
	self.cj["admin"]["attachfinal"] = "";
	self.cj["admin"]["maxent"] = 0;

	self setClientDvar("pm", self.cj["admin"]["pm"]);
	self setClientDvar("speed", self.cj["admin"]["speed"]);
	self setClientDvar("rename", self.cj["admin"]["rename"]);
	self setClientDvar("ui_cj_client", "^7"+level.players[0].name);
	self setClientDvar("ui_cj_client_id", self.cj["admin"]["playerent"]);
	self setClientDvar("ui_cj_client_guid", level.players[0] getGuid());
	self setClientDvar("ui_cj_give_menu", self.cj["admin"]["givemenu"]);
	self setClientDvar("ui_cj_give_weapon", self.cj["admin"]["weapfinal"]);
	self setClientDvar("ui_cj_give_attachment", self.cj["admin"]["attachfinal"]);
	self setClientDvar("ui_cj_give_valid_check", "");
	self setClientDvar("ui_cj_hintstring", "^5>>^7");

	for(;;)
	{
		for(i=0;i<level.players.size;i++)
		{
			if(level.players[i].cj["status"]==1)
			{
				self setClientDvar("ui_cj_player_list_"+level.players[i] getEntityNumber(), "^3"+level.players[i].name);
				self.cj["admin"]["list_id_"+level.players[i] getEntityNumber()] = i;
				if(level.players[i] getEntityNumber()>self.cj["admin"]["maxent"])
					self.cj["admin"]["maxent"]=level.players[i] getEntityNumber()+1;
			}
			else if(level.players[i].cj["status"]>=2)
			{
				self setClientDvar("ui_cj_player_list_"+level.players[i] getEntityNumber(), "^1"+level.players[i].name);
				self.cj["admin"]["list_id_"+level.players[i] getEntityNumber()] = i;
				if(level.players[i] getEntityNumber()>self.cj["admin"]["maxent"])
					self.cj["admin"]["maxent"]=level.players[i] getEntityNumber()+1;
			}
			else if(level.players[i].cj["status"]==0)
			{
				self setClientDvar("ui_cj_player_list_"+level.players[i] getEntityNumber(), "^7"+level.players[i].name);
				self.cj["admin"]["list_id_"+level.players[i] getEntityNumber()] = i;
				if(level.players[i] getEntityNumber()>self.cj["admin"]["maxent"])
					self.cj["admin"]["maxent"]=level.players[i] getEntityNumber()+1;
			}
			else
			{
				self setClientDvar("ui_cj_player_list_"+level.players[i] getEntityNumber(), "");
				self.cj["admin"]["list_id_"+level.players[i] getEntityNumber()] = i;
			}
		}

		self setClientDvar("ui_cj_player_count", self.cj["admin"]["maxent"]);

		/***/if(level.players[self.cj["admin"]["playerent"]].cj["status"] == 1)
			self setClientDvar("ui_cj_client", "^3"+level.players[self.cj["admin"]["playerent"]].name);
		else if(level.players[self.cj["admin"]["playerent"]].cj["status"] >= 2)
			self setClientDvar("ui_cj_client", "^1"+level.players[self.cj["admin"]["playerent"]].name);
		else
			self setClientDvar("ui_cj_client", "^7"+level.players[self.cj["admin"]["playerent"]].name);

		self.cj["admin"]["pm"] = getDvar("pm");
		self.cj["admin"]["speed"] = getDvar("speed");
		self.cj["admin"]["rename"] = getDvar("rename");

		self setClientDvar("pm", self.cj["admin"]["pm"]);
		self setClientDvar("speed", self.cj["admin"]["speed"]);
		self setClientDvar("rename", self.cj["admin"]["rename"]);

		self.cj["admin"]["player"] = level.players[self.cj["admin"]["playerent"]].name;

		self setClientDvar("ui_cj_client_id", level.players[self.cj["admin"]["playerent"]] getEntityNumber());
		self setClientDvar("ui_cj_client_guid", level.players[self.cj["admin"]["playerent"]] getGuid());
		self setClientDvar("ui_cj_give_menu", self.cj["admin"]["givemenu"]);
		self setClientDvar("ui_cj_give_weapon", self.cj["admin"]["weapfinal"]);
		self setClientDvar("ui_cj_give_attachment", self.cj["admin"]["attachfinal"]);

		if(checkIfWep(self.cj["admin"]["weapfinal"]+self.cj["admin"]["attachfinal"]+"_mp") == true)
			self setClientDvar("ui_cj_give_valid_check", "^2");
		else
			self setClientDvar("ui_cj_give_valid_check", "^1");
		wait 2;
	}
}

bots()
{
	wait 5;
	iNumBots = 5;
	bots = [];

	for(i = 0; i < iNumBots; i++)
	{
	  bots[i] = addtestclient();
	  bots[i].pers["isBot"] = true;
	  wait 0.05;
	  bots[i] notify("menuresponse", "bot",  "player");
	}
}
