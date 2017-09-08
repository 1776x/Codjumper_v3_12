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

onCustomMenuResponse()
{
	self endon("disconnect");
	self endon("killed_player");
	self endon("endcommands");

	decaltoggle = 1;
	brighttoggle = 0;
	fxtoggle = 1;
	drawtoggle = 0;
	thirdtoggle = 0;
	fogtoggle = 1;

	for(;;)
	{
		self waittill("menuresponse", menu, response);
		if(self.sessionstate == "spectator" && response == "admin" && self.cj["status"] >= 2)
		{
			self thread codjumper\_codjumper::fullPlayerList();
			self openMenu("admin");
		}
		if(menu == "cj" && self.sessionstate != "spectator" && game["state"] != "postgame")
		{
			switch(response)
			{
				case "save":
					if(self isOnGround())
						self [[level._cj_save]](1);
					wait 1;
					break;
				case "save2":
					if(self isOnGround())
						self [[level._cj_save]](2);
					wait 1;
					break;
				case "save3":
					if(self isOnGround())
						self [[level._cj_save]](3);
					wait 1;
					break;
				case "load":
					self [[level._cj_load]](1);
					wait 1;
					break;
				case "load2":
					self [[level._cj_load]](2);
					wait 1;
					break;
				case "load3":
					self [[level._cj_load]](3);
					wait 1;
					break;
				case "suicide":
					self suicide();
					break;
				case "admin":
					if(self.cj["status"] >= 2)
					{
						self thread codjumper\_codjumper::fullPlayerList();
						self openMenu("admin");
					}
					else
					{
						self iprintln("^5*^7You do not have ^1access ^7 to that command^5*");
					}
					break;
				default:
					break;
			}
		}
		else if( menu == "graphics" )
		{
			switch(response)
			{
				case "decals":
					if(decaltoggle == 0)
					{
						decaltoggle = 1;
						self setClientDvar("r_drawdecals", decaltoggle);
						self setClientDvar("gdecalstate", "^2");
					}
					else
					{
						decaltoggle = 0;
						self setClientDvar("r_drawdecals", decaltoggle);
						self setClientDvar("gdecalstate", "^1");
					}
					break;

				case "bright":
					if(brighttoggle == 0)
					{
						brighttoggle = 1;
						self setClientDvar("r_fullbright", brighttoggle);
						self setClientDvar("gfullbrightstate", "^2");
					}
					else
					{
						brighttoggle = 0;
						self setClientDvar("r_fullbright", brighttoggle);
						self setClientDvar("gfullbrightstate", "^1");
					}
					break;

				case "fx":
					if(fxtoggle == 0)
					{
						fxtoggle = 1;
						self setClientDvar("fx_enable", fxtoggle);
						self setClientDvar("gfxstate", "^2");
					}
					else
					{
						fxtoggle = 0;
						self setClientDvar("fx_enable", fxtoggle);
						self setClientDvar("gfxstate", "^1");
					}
					break;

				case "draw":
					if(drawtoggle == 0)
						drawtoggle = 250;
					else if(drawtoggle == 250)
						drawtoggle = 500;
					else if(drawtoggle == 500)
						drawtoggle = 1000;
					else if(drawtoggle == 1000)
						drawtoggle = 2000;
					else if(drawtoggle == 2000)
						drawtoggle = 4000;
					else
						drawtoggle = 0;
					if(drawtoggle==0)
						self setClientDvar("gdrawstate", "^1off");
					else
						self setClientDvar("gdrawstate", ""+drawtoggle);
					self setClientDvar("r_zfar", drawtoggle);
					break;

				case "fog":
					if(fogtoggle == 0)
					{
						fogtoggle = 1;
						self setClientDvar("r_fog", fogtoggle);
						self setClientDvar("gfogstate", "^2");
					}
					else
					{
						fogtoggle = 0;
						self setClientDvar("r_fog", fogtoggle);
						self setClientDvar("gfogstate", "^1");
					}
					break;

				case "thirdperson":
					if(thirdtoggle == 0)
					{
						thirdtoggle = 1;
						self setClientDvar("cg_thirdperson", thirdtoggle);
						self setClientDvar("gthirdstate", "^2");
					}
					else
					{
						thirdtoggle = 0;
						self setClientDvar("cg_thirdperson", thirdtoggle);
						self setClientDvar("gthirdstate", "^1");
					}
					break;

				case "angle_cw":
					self.cj["third"]["ang"] += 10;
					if(self.cj["third"]["ang"] > 359)
						self.cj["third"]["ang"] = 0;

					self setClientDvar("cg_thirdpersonangle", self.cj["third"]["ang"]);
					break;

				case "angle_ccw":
					self.cj["third"]["ang"] -= 10;
					if(self.cj["third"]["ang"] < 0)
						self.cj["third"]["ang"] = 360;

					self setClientDvar("cg_thirdpersonangle", self.cj["third"]["ang"]);
					break;

				case "angle_reset":
					self.cj["third"]["ang"] = 0;
					self setClientDvar("cg_thirdpersonangle", self.cj["third"]["ang"]);
					break;

				case "range_add":
					self.cj["third"]["range"] += 32;
					if(self.cj["third"]["range"] > 1024)
						self.cj["third"]["range"] = 1024;

					self setClientDvar("cg_thirdpersonrange", self.cj["third"]["range"]);
					break;

				case "range_minus":
					self.cj["third"]["range"] -= 32;
					if(self.cj["third"]["range"] < 0)
						self.cj["third"]["range"] = 0;

					self setClientDvar("cg_thirdpersonrange", self.cj["third"]["range"]);
					break;

				case "range_reset":
					self.cj["third"]["range"] = 120;
					self setClientDvar("cg_thirdpersonrange", self.cj["third"]["range"]);
					break;
			}
		}
		else if(response == "next" && self.sessionstate != "spectator")
		{
			self.cj["vote"]["dir"] = response;
			self notify("playerlist");
		}
		else if(response == "prev" && self.sessionstate != "spectator")
		{
			self.cj["vote"]["dir"] = response;
			self notify("playerlist");
		}
		else if(response == "mnext" && self.sessionstate != "spectator")
		{
			self.cj["vote"]["dir"] = response;
			self notify("maplist");
		}
		else if(response == "mprev" && self.sessionstate != "spectator")
		{
			self.cj["vote"]["dir"] = response;
			self notify("maplist");
		}

		else if( menu == "admin" && (level.players[self.cj["admin"]["playerent"]].sessionstate != "spectator" || response == "akick" || response == "aban" || response == "apromote" || response == "ademote") )
		{
			if(self.cj["status"] >= 2)
			{
				if(response == "aflash")
				{
					id = ""+level.players[self.cj["admin"]["playerent"]] getEntityNumber();
					thread codjumper\_cj_punishments::flash(id);
				}
				else if(response == "akill")
				{
					id = ""+level.players[self.cj["admin"]["playerent"]] getEntityNumber();
					thread codjumper\_cj_punishments::kill(id);
				}
				else if(response == "aspec")
				{
					if(level.players[self.cj["admin"]["playerent"]].cj["status"] < 1)
					{
						self notify("adminclose");
						self closeMenu("admin");
					}
					id = ""+""+level.players[self.cj["admin"]["playerent"]] getEntityNumber();
					thread codjumper\_cj_punishments::spec(id);
				}
				else if(response == "afreeze")
				{
					id = ""+level.players[self.cj["admin"]["playerent"]] getEntityNumber();
					thread codjumper\_cj_punishments::freeze(id);
				}
				/*else if(response == "afade")
				{
					id = ""+level.players[self.cj["admin"]["playerent"]] getEntityNumber();
					thread codjumper\_cj_punishments::fade(id);
				}*/
				else if(response == "akick")
				{
					arg = ""+level.players[self.cj["admin"]["playerent"]] getEntityNumber();
					command = "kick";
					thread codjumper\_codjumper::adminCommand(command, arg);
				}
				else if(response == "aban")
				{
					arg = ""+level.players[self.cj["admin"]["playerent"]] getEntityNumber();
					command = "ban";
					thread codjumper\_codjumper::adminCommand(command, arg);
				}
				else if(response == "apromote")
				{
					arg = ""+level.players[self.cj["admin"]["playerent"]] getEntityNumber();
					command = "promote";
					thread codjumper\_codjumper::adminCommand(command, arg);
				}
				else if(response == "ademote")
				{
					arg = ""+level.players[self.cj["admin"]["playerent"]] getEntityNumber();
					command = "demote";
					thread codjumper\_codjumper::adminCommand(command, arg);
				}
				else if(response == "teletoplayer")
				{
					arg = ""+level.players[self.cj["admin"]["playerent"]] getEntityNumber();
					command = "teletoplayer";
					thread codjumper\_codjumper::adminCommand(command, arg);
				}
				else if(response == "playertele")
				{
					arg = ""+level.players[self.cj["admin"]["playerent"]] getEntityNumber();
					command = "playertele";
					thread codjumper\_codjumper::adminCommand(command, arg);
				}
				else if(response == "give_ammo")
				{
					level.players[self.cj["admin"]["playerent"]] giveMaxAmmo(level.players[self.cj["admin"]["playerent"]] getCurrentWeapon());
				}
				else if(response == "atakeweapon")
				{
					level.players[self.cj["admin"]["playerent"]] takeWeapon(level.players[self.cj["admin"]["playerent"]] getCurrentWeapon());
				}
				else if(response == "opengivemenu")
				{
					self.cj["admin"]["givemenu"] = 1;
				}
				else if(response == "closegivemenu")
				{
					self.cj["admin"]["givemenu"] = 0;
				}
				else if(self.cj["admin"]["givemenu"] == 1)
				{
					if(response == "give_ak47")										{ self.cj["admin"]["weapfinal"]="ak47"; }
					else if(response == "give_rpd")								{ self.cj["admin"]["weapfinal"]="rpd"; }
					else if(response == "give_brick_blaster")			{ self.cj["admin"]["weapfinal"]="brick_blaster"; }
					else if(response == "give_claymore")					{ self.cj["admin"]["weapfinal"]="claymore"; }
					else if(response == "give_defaultweapon")			{ self.cj["admin"]["weapfinal"]="defaultweapon"; }
					else if(response == "give_deserteagle")				{ self.cj["admin"]["weapfinal"]="deserteagle"; }
					else if(response == "give_deserteaglegold")		{ self.cj["admin"]["weapfinal"]="deserteaglegold"; }
					else if(response == "give_flash_grenade")			{ self.cj["admin"]["weapfinal"]="flash_grenade"; }
					else if(response == "give_frag_grenade")			{ self.cj["admin"]["weapfinal"]="frag_grenade"; }
					else if(response == "give_g36c")							{ self.cj["admin"]["weapfinal"]="g36c"; }
					else if(response == "give_m1014")							{ self.cj["admin"]["weapfinal"]="m1014"; }
					else if(response == "give_m16")								{ self.cj["admin"]["weapfinal"]="m16"; }
					else if(response == "give_m4")								{ self.cj["admin"]["weapfinal"]="m4"; }
					else if(response == "give_m60e4")							{ self.cj["admin"]["weapfinal"]="m60e4"; }
					else if(response == "give_m40a3")							{ self.cj["admin"]["weapfinal"]="m40a3"; }
					else if(response == "give_mp44")							{ self.cj["admin"]["weapfinal"]="mp44"; }
					else if(response == "give_mp5")								{ self.cj["admin"]["weapfinal"]="mp5"; }
					else if(response == "give_p90")								{ self.cj["admin"]["weapfinal"]="p90"; }
					else if(response == "give_remington700")			{ self.cj["admin"]["weapfinal"]="remington700"; }
					else if(response == "give_skorpion")					{ self.cj["admin"]["weapfinal"]="skorpion"; }
					else if(response == "give_uzi")								{ self.cj["admin"]["weapfinal"]="uzi"; }
					else if(response == "give_winchester1200")		{ self.cj["admin"]["weapfinal"]="winchester1200"; }

					else if(response == "attach_none")						{ self.cj["admin"]["attachfinal"]=""; }
					else if(response == "attach_silencer")				{ self.cj["admin"]["attachfinal"]="_silencer"; }
					else if(response == "attach_acog")						{ self.cj["admin"]["attachfinal"]="_acog"; }
					else if(response == "attach_reflex")					{ self.cj["admin"]["attachfinal"]="_reflex"; }
					else if(response == "attach_grip")						{ self.cj["admin"]["attachfinal"]="_grip"; }

					else if(response == "give_weapon")
					{
						thread codjumper\_cj_punishments::give("" + level.players[self.cj["admin"]["playerent"]] getEntityNumber(), self.cj["admin"]["weapfinal"] + self.cj["admin"]["attachfinal"]);
					}
				}
				/////////////////
				//TEXT COMMANDS//
				/////////////////
				else if(response == "playermsg")
				{
					command = "playermessage";
					arg = self.cj["admin"]["pm"];
					thread codjumper\_codjumper::textCommand(command, arg);
				}
				else if(response == "setspeed")
				{
					command = "setspeed";
					arg = self.cj["admin"]["playerent"];
					thread codjumper\_codjumper::textCommand(command, arg);
				}
				else if(response == "setname")
				{
					command = "setname";
					arg = self.cj["admin"]["playerent"];
					thread codjumper\_codjumper::textCommand(command, arg);
				}
			}
			else
			{
					self iprintln("^5* ^7You do not have ^1access ^7 to that command ^5*");
			}
		}

		else if(response == "kick" && self.sessionstate != "spectator")
		{
			if(voteInProgress())
				self iprintln("A vote is currently in progress");
			else
			{
				player = self;
				arg = self.cj["vote"]["player"];
				thread codjumper\_cj_voting::cjVoteCalledPlayer(response, player, arg);
			}
		}
		else if(response == "rotate" && self.sessionstate != "spectator")
		{
			if(voteInProgress())
				self iprintln("A vote is currently in progress");
			else
			{
				player = self;
				arg = "";
				thread codjumper\_cj_voting::cjVoteCalledMap(response, player, arg);
			}
		}
		else if(response == "extend" && self.sessionstate != "spectator")
		{
			if(voteInProgress())
				self iprintln("A vote is currently in progress");
			else
			{
				player = self;
				arg = "";
				thread codjumper\_cj_voting::cjVoteCalledMap(response, player, arg);
			}
		}
		else if(response == "change" && self.sessionstate != "spectator")
		{
			if(voteInProgress())
				self iprintln("A vote is currently in progress");
			else
			{
				player = self;
				arg = self.cj["vote"]["map"];
				thread codjumper\_cj_voting::cjVoteCalledMap(response, player, arg);
			}
		}
		else if(response == "cjvoteyes" && self.sessionstate != "spectator")
		{
			if(level.cjvoteinprogress == 1)
			{
				if(self.cj["vote"]["voted"] == true)
					self iprintln("You have already voted!");
				else
				{
					level.cjvoteyes+=1;
					self.cj["vote"]["voted"] = true;
					self iprintln("Vote Cast");
				}
			}
			else
				self iprintln("There is no vote in progress");
		}
		else if(response == "cjvoteno" && self.sessionstate != "spectator")
		{
			if(level.cjvoteinprogress == 1)
			{
				if(self.cj["vote"]["voted"] == true)
					self iprintln("You have already voted!");
				else
				{
					level.cjvoteno+=1;
					self.cj["vote"]["voted"] = true;
					self iprintln("Vote Cast");
				}
			}
			else
				self iprintln("There is no vote in progress");
		}
		else if(response == "cjcancel")
		{
			if(level.cjvoteinprogress == 1)
			{
				if(self.cj["status"] < 2)
				{
					self iprintln("You do not have privileges to cancel votes");
				}
				else
					level notify("votecancelled");
			}
			else
				self iprintln("There is no vote in progress");
		}
		else if(response == "cjforce")
		{
			if(level.cjvoteinprogress == 1)
			{
				if(self.cj["status"] < 2)
				{
					self iprintln("You do not have privileges to force votes");
				}
				else
					level notify("voteforce");
			}
			else
				self iprintln("There is no vote in progress");
		}
		//////////////////
		//ADMIN SECURITY//
		//////////////////
		if(response == "adminmenuclose")
			self notify("adminclose");

		if		 (response == "player0" ){self.cj["admin"]["playerent"] = self.cj["admin"]["list_id_0"];}
		else if(response == "player1" ){self.cj["admin"]["playerent"] = self.cj["admin"]["list_id_1"];}
		else if(response == "player2" ){self.cj["admin"]["playerent"] = self.cj["admin"]["list_id_2"];}
		else if(response == "player3" ){self.cj["admin"]["playerent"] = self.cj["admin"]["list_id_3"];}
		else if(response == "player4" ){self.cj["admin"]["playerent"] = self.cj["admin"]["list_id_4"];}
		else if(response == "player5" ){self.cj["admin"]["playerent"] = self.cj["admin"]["list_id_5"];}
		else if(response == "player6" ){self.cj["admin"]["playerent"] = self.cj["admin"]["list_id_6"];}
		else if(response == "player7" ){self.cj["admin"]["playerent"] = self.cj["admin"]["list_id_7"];}
		else if(response == "player8" ){self.cj["admin"]["playerent"] = self.cj["admin"]["list_id_8"];}
		else if(response == "player9" ){self.cj["admin"]["playerent"] = self.cj["admin"]["list_id_9"];}
		else if(response == "player10"){self.cj["admin"]["playerent"] = self.cj["admin"]["list_id_10"];}
		else if(response == "player11"){self.cj["admin"]["playerent"] = self.cj["admin"]["list_id_11"];}
		else if(response == "player12"){self.cj["admin"]["playerent"] = self.cj["admin"]["list_id_12"];}
		else if(response == "player13"){self.cj["admin"]["playerent"] = self.cj["admin"]["list_id_13"];}
		else if(response == "player14"){self.cj["admin"]["playerent"] = self.cj["admin"]["list_id_14"];}
		else if(response == "player15"){self.cj["admin"]["playerent"] = self.cj["admin"]["list_id_15"];}
		else if(response == "player16"){self.cj["admin"]["playerent"] = self.cj["admin"]["list_id_16"];}
		else if(response == "player17"){self.cj["admin"]["playerent"] = self.cj["admin"]["list_id_17"];}
		else if(response == "player18"){self.cj["admin"]["playerent"] = self.cj["admin"]["list_id_18"];}
		else if(response == "player19"){self.cj["admin"]["playerent"] = self.cj["admin"]["list_id_19"];}
		else if(response == "player20"){self.cj["admin"]["playerent"] = self.cj["admin"]["list_id_20"];}
		else if(response == "player21"){self.cj["admin"]["playerent"] = self.cj["admin"]["list_id_21"];}
		else if(response == "player22"){self.cj["admin"]["playerent"] = self.cj["admin"]["list_id_22"];}
		else if(response == "player23"){self.cj["admin"]["playerent"] = self.cj["admin"]["list_id_23"];}
		else if(response == "player24"){self.cj["admin"]["playerent"] = self.cj["admin"]["list_id_24"];}
		else if(response == "player25"){self.cj["admin"]["playerent"] = self.cj["admin"]["list_id_25"];}
		else if(response == "player26"){self.cj["admin"]["playerent"] = self.cj["admin"]["list_id_26"];}
		else if(response == "player27"){self.cj["admin"]["playerent"] = self.cj["admin"]["list_id_27"];}
	}
}