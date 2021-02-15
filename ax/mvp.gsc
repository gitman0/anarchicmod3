/* $Id: mvp.gsc 119 2011-03-26 19:51:39Z  $ */

#include ax\utility;

init()
{
	if ( !load_mvpPlayers() )
		iprintln( "Error: Unable to load MVP Player List" );

	level thread onMapEnded();
}

onMapEnded()
{
	level waittill( "intermission" );
	if ( !save_mvpPlayers() )
		iprintln( "Error: Unable to save MVP Player List" );
}

save_mvpPlayers()
{
	if ( level.mvpPlayers.size == 0 )
		return false;

	// increment score and death counts for existing MVP's
	players = getentarray( "player", "classname" );
	for ( i=0; i < players.size; i++ )
	{
		player = players[i];
		guid = player getGuid();
		score = player.score;
		deaths = player.deaths;

		for ( x=0; x < level.mvpPlayers.size; x++ )
		{
			if ( guid == level.mvpPlayers[i].guid )
			{
				level.mvpPlayers[i].score += score;
				level.mvpPlayers[i].deaths += deaths;
				break;
			}
		}
	}

	// store new MVP's assuming they don't already have MVP status
	scoreSortedPlayers = scoreSortedPlayers();
	if ( scoreSortedPlayers.size >= level.ax_mvp_system_minplayers )
	{
		leaders = [];
		if ( scoreSortedPlayers.size > level.ax_mvp_system_leader_count )
			level.ax_mvp_system_leader_count = scoreSortedPlayers.size;
		for ( i=0; i < level.ax_mvp_system_leader_count; i++ )
			leaders[i] = scoreSortedPlayers[i];
	}
	for ( i=0; i < leaders.size; i++ )
	{
		if ( !isMVP( leader ) )
		{
			level.mvpPlayers[level.mvpPlayers.size] = spawnstruct();
			level.mvpPlayers[level.mvpPlayers.size-1].guid = guid;
			level.mvpPlayers[level.mvpPlayers.size-1].score = score;
			level.mvpPlayers[level.mvpPlayers.size-1].deaths = deaths;
		}
	}

	mvpFile = openFile( "mvp.dat", "write" );
	if ( mvpFile < 0 ) return false;

	for ( i=0; i < level.mvpPlayers.size; i++ )
	{
		mvpStr = "\n" + level.mvpPlayers[i].guid + "," + level.mvpPlayers[i].score + "," + level.mvpPlayers[i].deaths;
		fprintln( mvpFile, mvpStr );
	}
	closeFile( mvpFile );
}

load_mvpPlayers()
{
	level.mvpPlayers = [];

	mvpFile = openFile( "mvp.dat", "read" );
        if ( mvpFile < 0 ) return false;

        numval = fReadLn( mvpFile );
        while ( numval > 0 )
        {
                if ( numval == 3 )
                {
			level.mvpPlayers[level.mvpPlayers.size] = spawnstruct();
                        level.mvpPlayers[level.mvpPlayers.size-1].guid = fGetArg( mvpFile, 0 );
                        level.mvpPlayers[level.mvpPlayers.size-1].points = fGetArg( mvpFile, 1 );
                        level.mvpPlayers[level.mvpPlayers.size-1].deaths = fGetArg( mvpFile, 2 );
		}
                numval = fReadLn( mvpFile );
        }
        closeFile( mvpFile );
}

mvpClearedForJoin( player, team )
{
	if ( !isdefined( level.mvpPlayers ) )
		return false;
	playerWeight = mvpWeight( player );
	teamWeight = mvpTeamWeight( team );
	otherTeamWeight = mvpTeamWeight( otherTeam( team ) );

	if ( ( teamWeight + playerWeight ) > otherTeamWeight && ( otherTeamWeight + playerWeight ) > teamWeight ) // evenly balanced
		return true;
	else if ( ( teamWeight + playerWeight ) > otherTeamWeight && ( otherTeamWeight + playerWeight ) < teamWeight ) // out of balance
		return false;
	else if ( ( teamWeight + playerWeight ) < otherTeamWeight )
		return true;
}

mvpTeamWeight( team )
{
	teamWeight = 0;
	if ( team != "allies" && team != "axis" )
		return teamWeight;
	players = getentarray( "player", "classname" );
	for ( i=0; i<players.size; i++ )
	{
		player = players[i];
		if ( player.pers["team"] == team )
			teamWeight += mvpWeight( player );
	}
	return teamWeight;
}

mvpWeight( player )
{
	mvpWeight = 0;
	guid = player getGuid();
	for ( i=0; i<level.mvpPlayers; i++ )
	{
		if ( guid == level.mvpPlayers[i].guid )
		{
			mvpWeight += 100 * ( level.mvpPlayers[i].points / level.mvpPlayers[i].deaths );
			break;
		}
	}
	return mvpWeight;
}

isMVP( player )
{
	if ( !isdefined( level.mvpPlayers ) )
		return false;
	guid = player getGuid();
	for ( i=0; i<level.mvpPlayers.size; i++ )
		if ( guid == level.mvpPlayers[i].guid ) return true;
	return false;
}
