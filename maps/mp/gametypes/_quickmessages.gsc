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

init()
{
	game["menu_quickcommands"] = "quickcommands";
	game["menu_quickstatements"] = "quickstatements";
	game["menu_quickresponses"] = "quickresponses";
	game["menu_admin"] = "admin";

	precacheMenu(game["menu_quickcommands"]);
	precacheMenu(game["menu_quickstatements"]);
	precacheMenu(game["menu_quickresponses"]);
	precacheMenu(game["menu_admin"]);
	precacheHeadIcon("talkingicon");

	precacheString( &"QUICKMESSAGE_FOLLOW_ME" );
	precacheString( &"QUICKMESSAGE_MOVE_IN" );
	precacheString( &"QUICKMESSAGE_FALL_BACK" );
	precacheString( &"QUICKMESSAGE_SUPPRESSING_FIRE" );
	precacheString( &"QUICKMESSAGE_ATTACK_LEFT_FLANK" );
	precacheString( &"QUICKMESSAGE_ATTACK_RIGHT_FLANK" );
	precacheString( &"QUICKMESSAGE_HOLD_THIS_POSITION" );
	precacheString( &"QUICKMESSAGE_REGROUP" );
	precacheString( &"QUICKMESSAGE_ENEMY_SPOTTED" );
	precacheString( &"QUICKMESSAGE_ENEMIES_SPOTTED" );
	precacheString( &"QUICKMESSAGE_IM_IN_POSITION" );
	precacheString( &"QUICKMESSAGE_AREA_SECURE" );
	precacheString( &"QUICKMESSAGE_GRENADE" );
	precacheString( &"QUICKMESSAGE_SNIPER" );
	precacheString( &"QUICKMESSAGE_NEED_REINFORCEMENTS" );
	precacheString( &"QUICKMESSAGE_HOLD_YOUR_FIRE" );
	precacheString( &"QUICKMESSAGE_YES_SIR" );
	precacheString( &"QUICKMESSAGE_NO_SIR" );
	precacheString( &"QUICKMESSAGE_IM_ON_MY_WAY" );
	precacheString( &"QUICKMESSAGE_SORRY" );
	precacheString( &"QUICKMESSAGE_GREAT_SHOT" );
	precacheString( &"QUICKMESSAGE_TOOK_LONG_ENOUGH" );
	precacheString( &"QUICKMESSAGE_ARE_YOU_CRAZY" );
	precacheString( &"QUICKMESSAGE_WATCH_SIX" );
	precacheString( &"QUICKMESSAGE_COME_ON" );
}

quickcommands(response)
{
	self endon ( "disconnect" );

	if(!isdefined(self.pers["team"]) || self.pers["team"] == "spectator" || isdefined(self.spamdelay))
		return;

	self.spamdelay = true;

	switch(response)
	{
		case "1":
			soundalias = "mp_cmd_followme";
			saytext = &"QUICKMESSAGE_FOLLOW_ME";
			break;

		case "2":
			soundalias = "mp_cmd_holdposition"; // Move In
			saytext = &"QUICKMESSAGE_HOLD_THIS_POSITION";
			break;

		case "3":
			soundalias = "mp_stm_iminposition"; // Fall back
			saytext = &"QUICKMESSAGE_IM_IN_POSITION";
			break;

		case "4":
			soundalias = "mp_stm_needreinforcements"; // Suppressing Fire
			saytext = &"QUICKMESSAGE_NEED_REINFORCEMENTS";
			break;

		case "5":
			soundalias = "mp_rsp_yessir"; // Left Flank
			saytext = &"QUICKMESSAGE_YES_SIR";
			break;

		case "6":
			soundalias = "mp_rsp_nosir"; // Right Flank
			saytext = &"QUICKMESSAGE_NO_SIR";
			break;

		case "7":
			soundalias = "mp_rsp_onmyway"; // Hold Position
			saytext = &"QUICKMESSAGE_IM_ON_MY_WAY";
			break;

		default:
			assert(response == "8");
			soundalias = "mp_rsp_sorry"; // Regroup
			saytext = &"QUICKMESSAGE_SORRY";
			break;
	}

	self saveHeadIcon();
	self doQuickMessage(soundalias, saytext);

	wait 2;
	self.spamdelay = undefined;
	self restoreHeadIcon();
}

quickstatements(response)
{
//	if(!isdefined(self.pers["team"]) || self.pers["team"] == "spectator" || isdefined(self.spamdelay))
//		return;
//
//	self.spamdelay = true;
//
//	switch(response)
//	{
//		case "1":
//			//soundalias = "mp_stm_enemyspotted";
//			//saytext = &"QUICKMESSAGE_ENEMY_SPOTTED";
//			soundalias = undefined;
//			saytext = undefined;
//			break;
//
//		default:
//			break;
//	}
//
//	self saveHeadIcon();
//	self doQuickMessage(soundalias, saytext);
//
//	wait 2;
//	self.spamdelay = undefined;
//	self restoreHeadIcon();
}

quickresponses(response)
{
//	if(!isdefined(self.pers["team"]) || self.pers["team"] == "spectator" || isdefined(self.spamdelay))
//		return;
//
//	self.spamdelay = true;
//
//	switch(response)
//	{
//		case "1":
//			soundalias = "mp_rsp_yessir";
//			saytext = &"QUICKMESSAGE_YES_SIR";
//			break;
//
//		case "2":
//			soundalias = "mp_rsp_nosir";
//			saytext = &"QUICKMESSAGE_NO_SIR";
//			break;
//
//		case "3":
//			soundalias = "mp_rsp_onmyway";
//			saytext = &"QUICKMESSAGE_IM_ON_MY_WAY";
//			break;
//
//		case "4":
//			soundalias = "mp_rsp_sorry";
//			saytext = &"QUICKMESSAGE_SORRY";
//			break;
//
//		case "5":
//			soundalias = "mp_rsp_greatshot";
//			saytext = &"QUICKMESSAGE_GREAT_SHOT";
//			break;
//
//		default:
//			assert(response == "6");
//			soundalias = "mp_rsp_comeon";
//			saytext = &"QUICKMESSAGE_COME_ON";
//			break;
//	}
//
//	self saveHeadIcon();
//	self doQuickMessage(soundalias, saytext);
//
//	wait 2;
//	self.spamdelay = undefined;
//	self restoreHeadIcon();
}

doQuickMessage( soundalias, saytext )
{
	if(self.sessionstate != "playing")
		return;

	if ( self.pers["team"] == "allies" )
	{
		if ( game["allies"] == "sas" )
			prefix = "UK_";
		else
			prefix = "US_";
	}
	else
	{
		if ( game["axis"] == "russian" )
			prefix = "RU_";
		else
			prefix = "AB_";
	}

	if(isdefined(level.QuickMessageToAll) && level.QuickMessageToAll)
	{
		self.headiconteam = "none";
		self.headicon = "talkingicon";
		if(isDefined(soundalias) && soundalias != "")
			self playSound( prefix+soundalias );
		if(isDefined(sayText))
			self sayAll(saytext);
	}
	else
	{
		if(self.sessionteam == "allies")
			self.headiconteam = "allies";
		else if(self.sessionteam == "axis")
			self.headiconteam = "axis";

		self.headicon = "talkingicon";

		if(isDefined(soundalias) && soundalias != "")
			self playSound( prefix+soundalias );
		if(isDefined(sayText))
			self sayTeam( saytext );

		self pingPlayer();
	}
}

saveHeadIcon()
{
	if(isdefined(self.headicon))
		self.oldheadicon = self.headicon;

	if(isdefined(self.headiconteam))
		self.oldheadiconteam = self.headiconteam;
}

restoreHeadIcon()
{
	if(isdefined(self.oldheadicon))
		self.headicon = self.oldheadicon;

	if(isdefined(self.oldheadiconteam))
		self.headiconteam = self.oldheadiconteam;
}