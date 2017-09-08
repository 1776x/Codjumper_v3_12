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

#include maps\mp\gametypes\_hud_util;

isEven(int)
{
	if(int % 2 == 0)
		return true;
	else
		return false;
}

monotone(str)
{
	if(!isdefined(str) || (str == ""))
		return ("");

	_s = "";

	_colorCheck = false;
	for (i=0;i<str.size;i++)
	{
		ch = str[i];
		if(_colorCheck)
		{
			_colorCheck = false;

			switch ( ch )
			{
			  case "0":	// black
			  case "1":	// red
			  case "2":	// green
			  case "3":	// yellow
			  case "4":	// blue
			  case "5":	// cyan
			  case "6":	// pink
			  case "7":	// white
			  case "8":
			  case "9":
			  	break;
			  default:
			  	_s += ("^" + ch);
			  	break;
			}
		}
		else if(ch == "^")
			_colorCheck = true;
		else
			_s += ch;
	}

	return (_s);
}

RemoveTurrets()
{
	deletePlacedEntity("misc_turret");
	deletePlacedEntity("misc_mg42");
}

deletePlacedEntity(entity)
{
	entities = getentarray(entity, "classname");
	for(i = 0; i < entities.size; i++)
		entities[i] delete();
}

setupAdvert()
{

	if ( !isDefined( self.cj["hud"] ) || !isDefined( self.cj["hud"]["advert"] ) )
	{
		self.cj["hud"]["advert"] = newclienthudelem(self);
		self.cj["hud"]["advert"].alignX = "left";
		self.cj["hud"]["advert"].alignY = "bottom";
		self.cj["hud"]["advert"].horzalign = "left";
		self.cj["hud"]["advert"].vertAlign = "bottom";
		self.cj["hud"]["advert"].x = 3;
		self.cj["hud"]["advert"].y = -3;
		self.cj["hud"]["advert"].alpha = 0.8;
		self.cj["hud"]["advert"].sort = 0;
		self.cj["hud"]["advert"] setShader("sponsor",234,30);
	}

	if ( !isDefined( self.cj["hud"] ) || !isDefined( self.cj["hud"]["logo"] ) )
	{
		self.cj["hud"]["logo"] = newclienthudelem(self);
		self.cj["hud"]["logo"].alignX = "left";
		self.cj["hud"]["logo"].alignY = "bottom";
		self.cj["hud"]["logo"].horzalign = "left";
		self.cj["hud"]["logo"].vertAlign = "bottom";
		self.cj["hud"]["logo"].x = 3;
		self.cj["hud"]["logo"].y = -3;
		self.cj["hud"]["logo"].alpha = 0.8;
		self.cj["hud"]["logo"].sort = 0;
		self.cj["hud"]["logo"] setShader("cjbanner",100,30);
	}

	if ( (!isDefined(self.cj["hud"]) || !isDefined(self.cj["hud"]["custom"])) && level._customlogo == 1 )
	{
		self.cj["hud"]["custom"] = newclienthudelem(self);
		self.cj["hud"]["custom"].alignX = "right";
		self.cj["hud"]["custom"].alignY = "bottom";
		self.cj["hud"]["custom"].horzalign = "right";
		self.cj["hud"]["custom"].vertAlign = "bottom";
		self.cj["hud"]["custom"].x = -3;
		self.cj["hud"]["custom"].y = -3;
		self.cj["hud"]["custom"].alpha = level._customlogo_a;
		self.cj["hud"]["custom"].sort = 0;
		self.cj["hud"]["custom"] setShader("custom",level._customlogo_w,level._customlogo_h);
	}
}

changeAdvert()
{
	//self endon("joined_spectators");

	self setupAdvert();

	self.cj["hud"]["logo"].y = -3;
	self.cj["hud"]["advert"] setShader("sponsor",234,30);
	self.cj["hud"]["logo"].alpha = 0;
	wait 10;
	self.cj["hud"]["advert"] setShader("sponsored",100,10);
	self.cj["hud"]["logo"].alpha = 0.8;
	self.cj["hud"]["logo"].y = -14;
}

setErr(err)
{
	setDvar("cj_errors", (getDvar("cj_errors") + "\n" + err));
}

setLog(str)
{
	logprint("|#CJ#|#" + str + "#|\n");
}

voteInProgress()
{
	return level.cjVoteInProgress;
}

disableVoting()
{
	self iPrintln("You have been ^1locked^7 from voting!");

	for(i=level.cjvotelockout;i>0;i--)
	{
		self.cj["vote"]["novoting"] = i;
		wait 1;
	}

	self.cj["vote"]["novoting"] = 0;
}

startCountdown(time)
{
	self endon("disconnect");
	level endon ("votecancelled");
	level endon ("voteforce");
	self.votetime = time;

	for(i=time;i>0;i-=0.5)
	{
		if(i == int(i))
			self.votetime--;

		self setClientDvar("ui_cj_countdown", self.votetime);
		self thread updateVoteHud();
		if(i == int(i) && i<=5)
			self playLocalSound("ui_mp_suitcasebomb_timer");

		wait 0.5;
	}
}

playerCheck(arg)
{
	if((level.players[arg] getEntityNumber()) == (self.cj["vote"]["playerent"]))
		if(level.players[arg].cj["status"] < 1)
			return true;

	return false;
}

createVoteHud()
{
	if(isDefined(self.cj["hud"]["custom"]))
		self.cj["hud"]["custom"].alpha = 0;

	if(!isDefined(self.cj["hud"]["vote"]))
	{
		self.cj["hud"]["vote"] = createFontString( "objective", 1.4 );
		self.cj["hud"]["vote"].alignx = "left";
		self.cj["hud"]["vote"].aligny = "bottom";
		self.cj["hud"]["vote"].horzAlign = "right";
		self.cj["hud"]["vote"].vertAlign = "bottom";
		self.cj["hud"]["vote"].x = -190;
		self.cj["hud"]["vote"].y = -50;
		self.cj["hud"]["vote"].sort = -1;
		switch(level.cjvotetype)
		{
			case "Vote: Kick Player":
				self.cj["hud"]["vote"] setText(&"CJ_VOTE_PLAYER_KICK");
				break;
			case "Vote: Extend Time":
				self.cj["hud"]["vote"] setText(&"CJ_VOTE_MAP_EXTEND");
				break;
			case "Vote: Rotate Map":
				self.cj["hud"]["vote"] setText(&"CJ_VOTE_MAP_ROTATE");
				break;
			case "Vote: Change Map":
				self.cj["hud"]["vote"] setText(&"CJ_VOTE_MAP_CHANGE");
				break;
		}
	}

	if(!isDefined(self.cj["hud"]["voteyes"]))
	{
		self.cj["hud"]["voteyes"] = createFontString( "default", 1.4 );
		self.cj["hud"]["voteyes"].alignx = "left";
		self.cj["hud"]["voteyes"].aligny = "bottom";
		self.cj["hud"]["voteyes"].horzAlign = "right";
		self.cj["hud"]["voteyes"].vertAlign = "bottom";
		self.cj["hud"]["voteyes"].x = -190;
		self.cj["hud"]["voteyes"].y = -20;
		self.cj["hud"]["voteyes"].sort = -1;
		self.cj["hud"]["voteyes"].label = &"CJ_VOTE_YES";
	}
	if(!isDefined(self.cj["hud"]["voteno"]))
	{
		self.cj["hud"]["voteno"] = createFontString( "default", 1.4 );
		self.cj["hud"]["voteno"].alignx = "left";
		self.cj["hud"]["voteno"].aligny = "bottom";
		self.cj["hud"]["voteno"].horzAlign = "right";
		self.cj["hud"]["voteno"].vertAlign = "bottom";
		self.cj["hud"]["voteno"].x = -190;
		self.cj["hud"]["voteno"].y = -5;
		self.cj["hud"]["voteno"].sort = -1;
		self.cj["hud"]["voteno"].label = &"CJ_VOTE_NO";
	}
	if(!isDefined(self.cj["hud"]["voteyeskey"]))
	{
		self.cj["hud"]["voteyeskey"] = createFontString( "default", 1.4 );
		self.cj["hud"]["voteyeskey"].alignx = "left";
		self.cj["hud"]["voteyeskey"].aligny = "bottom";
		self.cj["hud"]["voteyeskey"].horzAlign = "right";
		self.cj["hud"]["voteyeskey"].vertAlign = "bottom";
		self.cj["hud"]["voteyeskey"].x = -150;
		self.cj["hud"]["voteyeskey"].y = -20;
		self.cj["hud"]["voteyeskey"].sort = -1;
		self.cj["hud"]["voteyeskey"].label = &"CJ_VOTE_YES_KEY";
		self.cj["hud"]["voteyeskey"] setValue(level.cjvoteyes);
	}
	if(!isDefined(self.cj["hud"]["votenokey"]))
	{
		self.cj["hud"]["votenokey"] = createFontString( "default", 1.4 );
		self.cj["hud"]["votenokey"].alignx = "left";
		self.cj["hud"]["votenokey"].aligny = "bottom";
		self.cj["hud"]["votenokey"].horzAlign = "right";
		self.cj["hud"]["votenokey"].vertAlign = "bottom";
		self.cj["hud"]["votenokey"].x = -150;
		self.cj["hud"]["votenokey"].y = -5;
		self.cj["hud"]["votenokey"].sort = -1;
		self.cj["hud"]["votenokey"].label = &"CJ_VOTE_NO_KEY";
		self.cj["hud"]["votenokey"] setValue(level.cjvoteno);
	}
	if(!isDefined(self.cj["hud"]["votearg"]))
	{
		self.cj["hud"]["votearg"] = createFontString( "default", 1.4 );
		self.cj["hud"]["votearg"].alignx = "left";
		self.cj["hud"]["votearg"].aligny = "bottom";
		self.cj["hud"]["votearg"].horzAlign = "right";
		self.cj["hud"]["votearg"].vertAlign = "bottom";
		self.cj["hud"]["votearg"].x = -190;
		self.cj["hud"]["votearg"].y = -35;
		self.cj["hud"]["votearg"].sort = -1;
		switch(level.cjvotetype)
		{
			case "Vote: Kick Player":
				self.cj["hud"]["votearg"] setPlayerNameString(level.players[level.cjvotearg]);
				break;
			case "Vote: Change Map":
				self.cj["hud"]["votearg"] setText(level.cjvotearg);
				break;
		}
	}
	if(!isDefined(self.cj["hud"]["votetime"]))
	{
		self.cj["hud"]["votetime"] = createFontString( "default", 1.4 );
		self.cj["hud"]["votetime"].alignx = "right";
		self.cj["hud"]["votetime"].aligny = "bottom";
		self.cj["hud"]["votetime"].horzAlign = "right";
		self.cj["hud"]["votetime"].vertAlign = "bottom";
		self.cj["hud"]["votetime"].x = -45;
		self.cj["hud"]["votetime"].y = -12;
		self.cj["hud"]["votetime"].sort = -1;
		self.cj["hud"]["votetime"].color = (0, 1, 0);
		self.cj["hud"]["votetime"].glowColor = (0, 1, 1);
		self.cj["hud"]["votetime"].glowAlpha = 0.8;
		self.cj["hud"]["votetime"] setValue(self.votetime);
	}
	if(!isDefined(self.cj["hud"]["votebg"]))
	{
		self.cj["hud"]["votebg"] = NewClientHudElem( self );
		self.cj["hud"]["votebg"].alignx = "right";
		self.cj["hud"]["votebg"].aligny = "bottom";
		self.cj["hud"]["votebg"].horzAlign = "right";
		self.cj["hud"]["votebg"].vertAlign = "bottom";
		self.cj["hud"]["votebg"].x = -18;
		self.cj["hud"]["votebg"].y = -1;
		self.cj["hud"]["votebg"].sort = -2;
		self.cj["hud"]["votebg"].alpha = 0.6;
		self.cj["hud"]["votebg"] setShader("cj_frame", 195, 70 );
	}
}

updateVoteHud()
{
	i = 1 / getDvarFloat("cj_voteduration");

	if(isDefined(self.cj["hud"]["voteyeskey"]))
		self.cj["hud"]["voteyeskey"] setValue(level.cjvoteyes);

	if(isDefined(self.cj["hud"]["votenokey"]))
		self.cj["hud"]["votenokey"] setValue(level.cjvoteno);

	if(self.cj["vote"]["voted"] == true)
	{
		self.cj["hud"]["votenokey"].color = (0.24, 0.62, 0.62);
		self.cj["hud"]["voteyeskey"].color = (0.24, 0.62, 0.62);
	}

	if(isDefined(self.cj["hud"]["votetime"]))
	{
		self.cj["hud"]["votetime"] setValue(self.votetime);
		green = i * self.votetime;
		red = 1 - (green);
		self.cj["hud"]["votetime"].color = (red, green, 0);
	}

}

removeVoteHud()
{
	if(isDefined(self.cj["hud"]["vote"]))
		self.cj["hud"]["vote"] destroy();

	if(isDefined(self.cj["hud"]["voteno"]))
		self.cj["hud"]["voteno"] destroy();

	if(isDefined(self.cj["hud"]["voteyes"]))
		self.cj["hud"]["voteyes"] destroy();

	if(isDefined(self.cj["hud"]["votenokey"]))
		self.cj["hud"]["votenokey"] destroy();

	if(isDefined(self.cj["hud"]["voteyeskey"]))
		self.cj["hud"]["voteyeskey"] destroy();

	if(isDefined(self.cj["hud"]["votetime"]))
		self.cj["hud"]["votetime"] destroy();

	if(isDefined(self.cj["hud"]["votearg"]))
		self.cj["hud"]["votearg"] destroy();

	if(isDefined(self.cj["hud"]["votebg"]))
		self.cj["hud"]["votebg"] destroy();

	if(isDefined(self.cj["hud"]["custom"]))
		self.cj["hud"]["custom"].alpha = level._customlogo_a;
}

maplist()
{
	rotation = getDvar("sv_maprotation");
	rotation = strTok(rotation, " ");

	level.maplist = [];

	for(i=0; i<rotation.size; i++)
		if(rotation[i] == "map")
			level.maplist[level.maplist.size] = rotation[i+1];
}

triggerWait()
{
	wait 10;
	self.cj["trigWait"] = 0;
}

wrongGametype()
{
	if(getDvar("g_gametype") != "cj")
	{
		wait 5;

		changeRotation();
		iPrintlnbold("^1*** ^5Incorrect Gametype Loaded ^1***");
		iPrintlnbold("^2*** ^5Loading CoDJumper Gametype ^2***");
		wait 1;
		iPrintlnbold("5..");
		wait 1;
		iPrintlnbold("   4..");
		wait 1;
		iPrintlnbold("      3..");
		wait 1;
		iPrintlnbold("         2..");
		wait 1;
		iPrintlnbold("            1..");
		setDvar("g_gametype", "cj");
		wait 0.5;
		exitLevel(false);
	}
}

changerotation()
{
	rot = getDvar("sv_maprotation");
	new = "";

	for(i=0;i<rot.size;i++)
	{
		if(rot[i] != "d")
			new+=rot[i];
		else if((i+2) < rot.size)
		{
			if(rot[i+1] == "m" && rot[i+2] == " ")
			{
				new+="cj ";
				i+=2;
			}
			else
				new+=rot[i];
		}
	}
	setDvar("sv_maprotationcurrent", "");
	setDvar("sv_maprotation", new);
}

checkIfWep(wep)
{
	switch(wep)
	{
		case "ak47_acog_mp":
		case "ak47_gl_mp":
		case "ak47_mp":
		case "ak47_reflex_mp":
		case "ak47_silencer_mp":
		case "ak74u_acog_mp":
		case "ak74u_reflex_mp":
		case "ak74u_silencer_mp":
		case "ak74u_mp":
		case "aw50_acog_mp":
		case "aw50_mp":
		case "barrett_acog_mp":
		case "barrett_mp":
		case "beretta_mp":
		case "beretta_silencer_mp":
		case "brick_blaster_mp":
		case "brick_bomb_mp":
		case "c4_mp":
		case "claymore_mp":
		case "colt45_mp":
		case "colt45_silencer_mp":
		case "concussion_grenade_mp":
		case "defaultweapon_mp":
		case "deserteagle_mp":
		case "deserteaglegold_mp":
		case "dragunov_mp":
		case "dragunov_acog_mp":
		case "flash_grenade_mp":
		case "frag_grenade_mp":
		case "g36c_acog_mp":
		case "g36c_reflex_mp":
		case "g36c_silencer_mp":
		case "g36c_gl_mp":
		case "g36c_mp":
		case "g3_acog_mp":
		case "g3_reflex_mp":
		case "g3_silencer_mp":
		case "g3_gl_mp":
		case "g3_mp":
		case "gl_ak47_mp":
		case "gl_g36c_mp":
		case "gl_g3_mp":
		case "gl_m14_mp":
		case "gl_m4_mp":
		case "gl_mp":
		case "m1014_reflex_mp":
		case "m1014_grip_mp":
		case "m1014_mp":
		case "m14_acog_mp":
		case "m14_reflex_mp":
		case "m14_silencer_mp":
		case "m14_gl_mp":
		case "m14_mp":
		case "m16_acog_mp":
		case "m16_reflex_mp":
		case "m16_silencer_mp":
		case "m16_gl_mp":
		case "m16_mp":
		case "m21_acog_mp":
		case "m21_mp":
		case "m40a3_acog_mp":
		case "m40a3_mp":
		case "m4_acog_mp":
		case "m4_reflex_mp":
		case "m4_silencer_mp":
		case "m4_gl_mp":
		case "m4_mp":
		case "m60e4_acog_mp":
		case "m60e4_reflex_mp":
		case "m60e4_grip_mp":
		case "m60e4_mp":
		case "mp44_mp":
		case "mp5_acog_mp":
		case "mp5_reflex_mp":
		case "mp5_silencer_mp":
		case "mp5_mp":
		case "p90_acog_mp":
		case "p90_reflex_mp":
		case "p90_silencer_mp":
		case "p90_mp":
		case "remington700_acog_mp":
		case "remington700_mp":
		case "rpd_mp":
		case "saw_acog_mp":
		case "saw_reflex_mp":
		case "saw_silencer_mp":
		case "saw_mp":
		case "skorpion_acog_mp":
		case "skorpion_reflex_mp":
		case "skorpion_silencer_mp":
		case "skorpion_mp":
		case "usp_mp":
		case "usp_silencer_mp":
		case "uzi_acog_mp":
		case "uzi_reflex_mp":
		case "uzi_silencer_mp":
		case "uzi_mp":
		case "winchester1200_reflex_mp":
		case "winchester1200_grip_mp":
		case "winchester1200_mp":
			return true;
		default:
			return false;
	}
}