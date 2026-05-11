/*
 * Copyright (c) 2025 Vera Visions LLC.
 *
 * Permission to use, copy, modify, and distribute this software for any
 * purpose with or without fee is hereby granted, provided that the above
 * copyright notice and this permission notice appear in all copies.
 *
 * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
 * WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
 * MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
 * ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
 * WHATSOEVER RESULTING FROM LOSS OF MIND, USE, DATA OR PROFITS, WHETHER
 * IN AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING
 * OUT OF OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
*/

/** Call to start a new game, at a set skill value. */
void
ncWorldSetup::NewGame(void)
{
    int skillValue = (int)cvar("skill");

    if (fileExists("cfg/chapter1.cfg")) {
        localcmd("set sv_background 0\nset sv_playerslots 1\nset maxclients 1\nset deathmatch 0\nset coop 0\nset g_gametype singleplayer\nexec cfg/chapter1.cfg");
    } else {
        localcmd( sprintf("set sv_background 0\nset skill %i\nset sv_playerslots 1\nset maxclients 1\nset deathmatch 0\nset coop 0\nset g_gametype singleplayer\n%s", skillValue, GameLibrary_GetInfo(GAMEINFO_STARTMAP)) );
    }

    RichPresence_Clear();
    switch (skillValue) {
    case 1i:
        RichPresence_Set("status", "Singleplayer: Normal");
        break;
    case 2i:
        RichPresence_Set("status", "Singleplayer: Medium");
        break;
    case 3i:
        RichPresence_Set("status", "Singleplayer: Hard");
        break;
    }
}

void
ncWorldSetup::Editor(void)
{
    if (!STRING_SET(argv(1))) {
        string mapName = "new.hmp";
        localcmd(sprintf("mod_terrain_create %S\nwait\nset g_gametype editor;maxplayers 1;maxclients 1;devmap %S\n", mapName, mapName));
        return;
    }

    localcmd(sprintf("set g_gametype editor;maxplayers 1;maxclients 1;devmap %S\n", argv(1)));
}

/** Called to load the training level. */
void
ncWorldSetup::Training(void)
{
    RichPresence_Clear();
    RichPresence_Set("status", "Training");
    localcmd( sprintf("set sv_background 0\nset maxplayers 1\nset maxclients 1\nset deathmatch 0\nset coop 0\nset skill 2\nset g_gametype singleplayer\n%s", GameLibrary_GetInfo(GAMEINFO_TRAININGMAP)) );
}

/** Call to spawn a server with a desired level and gamemode. */
void
ncWorldSetup::SpawnServer(void)
{
    string serverName = cvar_string("ui_servername");
    string playerCount = cvar_string("ui_numPlayers");
    string gameType = cvar_string("ui_gameType");
    string mapName = cvar_string("ui_map");

    if (!STRING_SET(serverName)) {
        serverName = "Unnamed Server";
    }

    if (!STRING_SET(playerCount)) {
        playerCount = "8";
    }

    if (!STRING_SET(gameType)) {
        gameType = "deathmatch";
    }

    if (!STRING_SET(mapName)) {
        mapName = skimFile("mapcycle.txt");

        /* last resort */
        if (!STRING_SET(mapName)) {
            mapName = "start";
        }
    }

    localcmd( sprintf( "set sv_background 0\nhostname %s\n", serverName ) );
    localcmd( sprintf( "set maxplayers %s\n", playerCount ) );
    localcmd( sprintf( "set maxclients %s\n", playerCount ) );
    //localcmd( sprintf( "set sv_password %s\n", passWord ) );
    localcmd( sprintf( "set g_gametype %s\n", gameType ) );
    localcmd( sprintf( "map %s\n", mapName ) );
    RichPresence_Clear();
    RichPresence_Set("status", sprintf("Multiplayer: %s", mapName));
}

void
ncWorldSetup::Shutterbug(void)
{
    string mapName = g_string_null;

    if (!fileExists("shutterbug.txt")) {
        ncLogAlways("Missing 'shutterbug.txt' file! Create one with one map name per-line (without extension)");
        return;
    }

    if (!STRING_SET(mapName)) {
        mapName = skimFile("shutterbug.txt");

        /* last resort */
        if (!STRING_SET(mapName)) {
            mapName = "start";
        }
    }

    localcmd(sprintf("set g_gametype shutterbug;maxplayers 1;maxclients 1;devmap %S\n", mapName));
}

/* when called, will teleport you to the home location (can be a map, or a server) */
void
ncWorldSetup::Home(void)
{
    int maxPlayers = 12;
    string hostName = sprintf("^3Home:^7: %s", cvar_string("name"));
    string passWord = cvar_string("home_password");
    string gameType = "home";
    string mapName = cvar_string("home_location");

    /* home isn't set */
    if (!STRING_SET(mapName)) {
        ncWarning("Home environment isn't set.");
        return;
    }

    if (!fileExists(strcat("maps/", mapName, ".bsp"))) {
        /* map doesn't exist. try connecting to it as a server */
        localcmd(strcat("connect ", mapName, "\n"));
        return;
    }

    localcmd( sprintf( "set sv_background 0\nhostname %s\n", hostName ) );
    localcmd( sprintf( "set maxplayers %i\n", maxPlayers ) );
    localcmd( sprintf( "set maxclients %i\n", 1 ) );
    localcmd( sprintf( "set sv_password %s\n", passWord ) );
    localcmd( sprintf( "set g_gametype %s\n", gameType ) );
    localcmd( sprintf( "map %s\n", mapName ) );
    RichPresence_Clear();
    RichPresence_Set("status", "Home");
}

/* reads cvars set by the client, stores it somewhere permanently (other cvars...) */
void
ncWorldSetup::HomeSave(void)
{
    localcmd(sprintf("seta home_location %S\n", cvar_string("ui_home_location")));
    localcmd(sprintf("setinfo home_org %S\n", cvar_string("ui_home_org")));
    localcmd(sprintf("setinfo home_ang %S\n", cvar_string("ui_home_ang")));
}

