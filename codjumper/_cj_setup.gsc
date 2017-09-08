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

precacheStuff()
{
	precacheMenu("cj");
	precacheMenu("graphics");
	precacheMenu("cjvote");
	precacheShader("sponsor");
	precacheShader("sponsored");
	precacheShader("cjbanner");
	precacheShader("custom");
	precacheShader("cj_frame");
	precacheShader("white");
	precacheItem("brick_blaster_mp");

	// Admin Model
	precacheModel("body_mp_sas_urban_assault");
	precacheModel("viewhands_black_kit");


}

setupDvars()
{
	mapname = getDvar("mapname");
	setDvar("newmap", "New map loaded: " + mapname);
	setDvar("pm", "Insert your message here.");
	setDvar("speed", 1);

	if(getDvar("cj_rename") == "")
		setDvar("cj_rename", "UnnamedPlayer");

	// Create Default Value list of map specific dvars
	if(getDvar("cj_default_welcome") == "")
	{
		if(getDvar("cj_welcome") != "")
			setDvar("cj_default_welcome", getDvar("cj_welcome"));
		else
			setDvar("cj_default_welcome", "1::CoD^8Jumper^7.com ^1Mod::2::^1Save Position^7 - DoubleTap ^2Melee^7::0.05::^1Load Position^7 - DoubleTap ^2Use^7::0.05::^1Suicide^7 - Hold ^2Melee^7 [3 seconds]");
	}
	if(getDvar("cj_default_disablerpg") == "")
		setDvar("cj_default_disablerpg", getDvarInt("cj_disablerpg"));
	if(getDvar("cj_default_deleteents") == "")
		setDvar("cj_default_deleteents", getDvarInt("cj_deleteents"));
	if(getDvar("cj_default_timelimit") == "")
		setDvar("cj_default_timelimit", getDvarFloat("cj_timelimit"));

	// Check for map specific welcome
	if(getDvar("cj_" + mapname + "_welcome") != "")
		setDvar("cj_welcome", getDvar("cj_" + mapname + "_welcome"));
	// If no map specific, reset value to default
	else if((getDvar("cj_" + mapname + "_welcome") == ""))
		setDvar("cj_welcome", getDvar("cj_default_welcome"));
	// If default was empty, use standard
	if(getDvar("cj_welcome") == "")
		setDvar("cj_welcome", "1::CoD^8Jumper^7.com ^1Mod::2::^1Save Position^7 - DoubleTap ^2Melee^7::0.05::^1Load Position^7 - DoubleTap ^2Use^7::0.05::^1Suicide^7 - Hold ^2Melee^7 [3 seconds]");

	// Map specific 'no-save'
	if(getDvarInt("cj_" + mapname + "_nosave") == 1)
		setDvar("cj_nosave", 1);
	else
		setDvar("cj_nosave", 0);

	/* 0 = Saving On | 1 = Saving Off */
	if(getDvar("cj_nosave") == "")
		setDvar("cj_nosave", 0);
	level._cj_nosave = getDvarInt("cj_nosave");

	/* 0 = No Damage | 1 = All Damage * | 2 = Damage Self */
	if(getDvar("cj_allowdamage") == "")
		setDvar("cj_allowdamage", 0);

	/* 1 = Show Damage | 0 = Damage hidden */
	if(getDvar("cj_showdamage") == "")
		setDvar("cj_showdamage", 1);

	/* 1 = Show Damage | 0 = Hide Damage */
	if(getDvar("cj_showdamage_trigger") == "")
		setDvar("cj_showdamage_trigger", 1);

	/* 0 = Disable Frags | 1 = Enable Frags */
	if(getDvar("cj_enablenades") == "")
		setDvar("cj_enablenades", 0);

	// Map specific RPG
	if(getDvar("cj_" + mapname + "_disablerpg") != "")
		setDvar("cj_disablerpg", getDvarInt("cj_" + mapname + "_disablerpg"));
	else if(getDvar("cj_" + mapname + "_disablerpg") == "")
		setDvar("cj_disablerpg", getDvarInt("cj_default_disablerpg"));
	if(getDvar("cj_disablerpg") == "")
		setDvar("cj_disablerpg", 0);

	// Map Specific ENTs
	if(getDvar("cj_" + mapname + "_deleteents") != "")
		setDvar("cj_deleteents", getDvarInt("cj_" + mapname + "_deleteents"));
	else if(getDvar("cj_" + mapname + "_deleteents") == "")
		setDvar("cj_deleteents", getDvarInt("cj_default_deleteents"));
	if(getDvar("cj_deleteents") == "")
		setDvar("cj_deleteents", 0);

	// Auto Admin GUID promote
	if(getDvar("cj_adminguids") == "")
		setDvar("cj_adminguids", "-1");

	// Auto Admin On/Off
	if(getDvar("cj_autoadmin") == "")
		setDvar("cj_autoadmin", 0);

	// Errors
	if(getDvar("cj_errors") == "")
		setDvar("cj_errors", "");

	// Vote Duration/Lockout/Ratio/Start
	if(getDvar("cj_voteduration") == "")
		setDvar("cj_voteduration", 30);
	level.cjvoteduration = getDvarInt("cj_voteduration");

	if(getDvar("cj_votelockout") == "")
		setDvar("cj_votelockout", 15);
	level.cjvotelockout = getDvarInt("cj_votelockout") + level.cjvoteduration;

	if(getDvar("cj_voteratio") == "")
		setDvar("cj_voteratio", 0.80);
	level.cjvotewinratio = getDvarFloat("cj_voteratio");

	if(getDvar("cj_votedelay") == "")
		setDvar("cj_votedelay", 180);
	level.cjvotedelay = getDvarFloat("cj_votedelay");

	// Map specific time
	if(getDvar("cj_" + mapname + "_timelimit") != "")
		setDvar("cj_timelimit", getDvarFloat("cj_" + mapname + "_timelimit"));
	// If non-map specific, set to default
	else if(getDvar("cj_" + mapname + "_timelimit") == "")
		setDvar("cj_timelimit", getDvarFloat("cj_default_timelimit"));

	// If default was empty, check scr value
	if(getDvar("cj_timelimit") == "" && getDvar("scr_cj_timelimit") != "")
		setDvar("cj_timelimit", getDvarFloat("scr_cj_timelimit"));
	// If all values empty
	else if(getDvar("cj_timelimit") == "")
		setDvar("cj_timelimit", 25);
	// Set scr value for future use
	setDvar("scr_cj_timelimit", getDvarInt("cj_timelimit"));


	// Custom Logo On/Off
	if(getDvar("cj_customlogo") == "")
		setDvar("cj_customlogo", 0);

	// Default custom logo values
	if(getDvar("cj_customlogo_width") == "")
		setDvar("cj_customlogo_width", 0);

	if(getDvar("cj_customlogo_height") == "")
		setDvar("cj_customlogo_height", 0);

	if(getDvar("cj_customlogo_alpha") == "")
		setDvar("cj_customlogo_alpha", 0);

	level._customlogo = getDvarInt("cj_customlogo");
	level._customlogo_w = getDvarInt("cj_customlogo_width");
	level._customlogo_h = getDvarInt("cj_customlogo_height");
	level._customlogo_a = getDvarFloat("cj_customlogo_alpha");

	// Undefined Promote Dvars
	setDvar("cj_promote", "");
	setDvar("cj_soviet_promote", "");
	setDvar("cj_demote", "");

	// Default Weapon Loadouts
	if(getDvar("cj_weapons") == "")
		setDvar("cj_weapons", "beretta::deserteagle::deserteaglegold::deserteaglegold");

	// CJ Freerun (C4)
	if(getDvar("cj_freerun") == "")
		setDvar("cj_freerun", 1);

	// Stop stock dvar
	setDvar("scr_cj_scorelimit", 0);

	// Default Vote values
	level.cjVoteInProgress = 0;
	level.cjVoteYes = 0;
	level.cjVoteNo = 0;
	level.cjVoteType = "";
	level.cjVoteCalled = "";
	level.cjVoteAgainst = "";
	level.cjVoteArg = undefined;

	// New Variables
	level._cj_MaxSaves = 3; /* Maximum amount of saves */
	level._cj_punishLevel = 1; /* 1 = Punish Non-Ranks * 2 = Punish VIP * 3 = Punish Admins * 4 = Punish Soviet?! */

}

setupLanguage()
{
		self.cj["local"]["NOPOS"] 		= &"CJ_NOPOS";
		self.cj["local"]["NOPOS2"]		= &"CJ_NOPOS2";
		self.cj["local"]["NOPOS3"] 		= &"CJ_NOPOS3";
		self.cj["local"]["POSLOAD"] 	= &"CJ_POSLOAD";
		self.cj["local"]["POS2LOAD"] 	= &"CJ_POS2LOAD";
		self.cj["local"]["POS3LOAD"] 	= &"CJ_POS3LOAD";
		self.cj["local"]["SAVED"] 		= &"CJ_SAVED";
		self.cj["local"]["SAVED2"] 		= &"CJ_SAVED2";
		self.cj["local"]["SAVED3"] 		= &"CJ_SAVED3";
		self.cj["local"]["PROMOTED"] 	= &"CJ_PROMOTED";
		self.cj["local"]["DEMOTED"]		= &"CJ_DEMOTED";
		self.cj["local"]["NOSAVE"] 		= &"CJ_NOSAVE";
}

setupWeapons()
{
	weapons = getDvar("cj_weapons");
	level.cjWeapons = strTok(weapons, "::");
	nextWep = undefined;

	for(i=0;i<4;i++)
	{
		if(!isDefined(level.cjWeapons[i]))
		{
			if(!isDefined(nextWep))
					level.cjWeapons[i] = "beretta_mp";
			else
					level.cjWeapons[i] = nextWep;
		}
		else // If weapon is defined
		{
			// Check for more weapons
			tempWeapons = strTok(level.cjWeapons[i], ";;");

			if(tempWeapons.size > 1)
			{
				level.cjWeapons[i] = "";

				for(j=0;j<tempWeapons.size;j++)
				{if(!isDefined(tempWeapons[j]))
						tempWeapons[j] = "beretta_mp";
					else
						tempWeapons[j] += "_mp";

					if( !checkIfWep(tempWeapons[j]) )
						tempWeapons[j] = "beretta_mp";

					level.cjWeapons[i] += tempWeapons[j];

					if(j != tempWeapons.size-1)
						level.cjWeapons[i] += ";;";
				}

				nextWep = tempWeapons[0];
			}
			else
			{
				level.cjWeapons[i] += "_mp"; // Add "_mp" value

				// check if weapon exists
				if( !checkIfWep(level.cjWeapons[i]) )
					level.cjWeapons[i] = "beretta_mp";

				// set current weapon
				nextWep = level.cjWeapons[i];
			}
		}
	}
}

setupPlayer()
{
	// Personal Array
	self.cj = [];

	// Saves
	self.cj["save"] = [];

	// HUD
	self.cj["hud"] = [];

	// Third person
	self.cj["third"] = [];
	self.cj["third"]["ang"] = 0;
	self.cj["third"]["range"] = 120;

	// Admin Status
	self.cj["status"] = 0;

	// Voting
	self.cj["vote"] = [];
	self.cj["vote"]["novoting"] = false;
	self.cj["vote"]["delayed"] = true;
	self.cj["vote"]["voted"] = false;

	// Times
	self.cj["time"] = [];
	self.cj["time"]["played"] = 0;
	self.cj["time"]["count"] = 0;

	// Admin Menu
	self.cj["admin"] = [];

	// Punishment - Freeze
	self.cj["admin"]["frozen"] = 0;

	// Trigger Damage
	self.cj["trigWait"] = 0;

	// Default Weapon
	self.cj["weapon"] = "beretta_mp";

	// Client Dvars
	self setClientDvar( "player_summary_time", self.cj["time"]["played"]);
	self setClientDvar( "aim_automelee_range", 0);		// Remove melee lunge
	self setClientDvar( "gdecalstate", "^2");					// Decals On/Off
	self setClientDvar( "gfullbrightstate", "^1");		// Fullbright On/Off
	self setClientDvar( "gfxstate", "^2");						// FX On/Off
	self setClientDvar( "gdrawstate", "^1off");				// Draw Distance
	self setClientDvar( "gfogstate", "^2");						// Fog On/Off
	self setClientDvar( "gthirdstate", "^1");					// Thirdperson On/Off
}

setupInfo()
{
	for(;;)
	{
		while(infoCheck())
			wait 5;

		setDvar("cj__author", level._author);
		setDvar("cj__version", level._version);
		setDvar("cj__date", level._date);
		setDvar("cj__specialthanks", level._specialthanks);
		wait 0.05;
	}
}

infoCheck()
{

	return true; // Stop spam

	if(level._author != getDvar("cj__author"))
		return false;
	else if(level._author != getDvar("cj__author"))
		return false;
	else if(level._version != getDvar("cj__version"))
		return false;
	else if(level._date != getDvar("cj__date"))
		return false;
	else if(level._translators_german != getDvar("cj__translation_german"))
		return false;
	else if(level._translators_french != getDvar("cj__translation_french"))
		return false;
	else if(level._translators_polish != getDvar("cj__translation_polish"))
		return false;
	else if(level._translators_dutch != getDvar("cj__translation_dutch"))
		return false;
	else if(level._specialthanks != getDvar("cj__specialthanks"))
		return false;
	else
		return true;
}