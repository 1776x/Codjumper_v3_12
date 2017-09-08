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

#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;
/*
	Deathmatch
	Objective: 	Score points by eliminating other players
	Map ends:	When one player reaches the score limit, or time limit is reached
	Respawning:	No wait / Away from other players

	Level requirements
	------------------
		Spawnpoints:
			classname		mp_dm_spawn
			All players spawn from these. The spawnpoint chosen is dependent on the current locations of enemies at the time of spawn.
			Players generally spawn away from enemies.

		Spectator Spawnpoints:
			classname		mp_global_intermission
			Spectators spawn from these and intermission is viewed from these positions.
			Atleast one is required, any more and they are randomly chosen between.

	Level script requirements
	-------------------------
		Team Definitions:
			game["allies"] = "marines";
			game["axis"] = "opfor";
			Because Deathmatch doesn't have teams with regard to gameplay or scoring, this effectively sets the available weapons.

		If using minefields or exploders:
			maps\mp\_load::main();

	Optional level script settings
	------------------------------
		Soldier Type and Variation:
			game["american_soldiertype"] = "normandy";
			game["german_soldiertype"] = "normandy";
			This sets what character models are used for each nationality on a particular map.

			Valid settings:
				american_soldiertype	normandy
				british_soldiertype		normandy, africa
				russian_soldiertype		coats, padded
				german_soldiertype		normandy, africa, winterlight, winterdark
*/

/*QUAKED mp_dm_spawn (1.0 0.5 0.0) (-16 -16 0) (16 16 72)
Players spawn away from enemies at one of these positions.*/

main()
{
	maps\mp\gametypes\_globallogic::init();
	maps\mp\gametypes\_callbacksetup::SetupCallbacks();
	maps\mp\gametypes\_globallogic::SetupCallbacks();

	codjumper\_codjumper::init();
	/* CoDJumper Callbacks */
	level._cj_save = codjumper\_cj_functions::savePos;
	level._cj_load = codjumper\_cj_functions::loadPos;
	level._cj_punish = codjumper\_cj_punishments::punish;

	//level._cj_onPlayerConnect = codjumper\_codjumper::onPlayerConnect;
	//level._cj_onPlayerSpawn = codjumper\_codjumper::onPlayerSpawn;

	maps\mp\gametypes\_globallogic::registerTimeLimitDvar( level.gameType, 10, 0, 1440 );
	maps\mp\gametypes\_globallogic::registerScoreLimitDvar( level.gameType, 1000, 0, 5000 );
	maps\mp\gametypes\_globallogic::registerRoundLimitDvar( level.gameType, 1, 0, 10 );
	maps\mp\gametypes\_globallogic::registerNumLivesDvar( level.gameType, 0, 0, 10 );

	level.onStartGameType = ::onStartGameType;
	level.onSpawnPlayer = ::onSpawnPlayer;

	game["dialog"]["gametype"] = "freeforall";
}

onStartGameType()
{
	setClientNameMode("auto_change");

	maps\mp\gametypes\_globallogic::setObjectiveText( "allies", &"CJ_NULL" );
	maps\mp\gametypes\_globallogic::setObjectiveText( "axis", &"CJ_NULL" );

	maps\mp\gametypes\_globallogic::setObjectiveScoreText( "allies", &"CJ_NULL" );
	maps\mp\gametypes\_globallogic::setObjectiveScoreText( "axis", &"CJ_NULL" );

	maps\mp\gametypes\_globallogic::setObjectiveHintText( "allies", &"CJ_NULL" );
	maps\mp\gametypes\_globallogic::setObjectiveHintText( "axis", &"CJ_NULL" );

	level.spawnMins = ( 0, 0, 0 );
	level.spawnMaxs = ( 0, 0, 0 );
	maps\mp\gametypes\_spawnlogic::addSpawnPoints( "allies", "mp_dm_spawn" );
	maps\mp\gametypes\_spawnlogic::addSpawnPoints( "axis", "mp_dm_spawn" );
	level.mapCenter = maps\mp\gametypes\_spawnlogic::findBoxCenter( level.spawnMins, level.spawnMaxs );
	setMapCenter( level.mapCenter );

	allowed[0] = "dm";
	if(getDvarInt("cj_deleteents") != 1)
	{
		allowed[1] = "war";
		allowed[2] = "sd";
		allowed[3] = "dom";
		allowed[4] = "sab";
		allowed[5] = "hq";
		allowed[6] = "bombzone";
		allowed[7] = "blocker";
		allowed[8] = "hardpoint";
	}
	maps\mp\gametypes\_gameobjects::main(allowed);

	level.displayRoundEndText = false;
	level.QuickMessageToAll = true;
}


onSpawnPlayer()
{
	spawnPoints = maps\mp\gametypes\_spawnlogic::getTeamSpawnPoints( self.pers["team"] );
	spawnPoint = maps\mp\gametypes\_spawnlogic::getSpawnpoint_DM( spawnPoints );

	self spawn( spawnPoint.origin, spawnPoint.angles );
}


onEndGame()
{
	//if ( isDefined( winningPlayer ) )
	//	[[level._setPlayerScore]]( winningPlayer, winningPlayer [[level._getPlayerScore]]() + 1 );
}