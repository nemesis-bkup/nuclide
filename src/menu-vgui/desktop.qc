/*
 * Copyright (c) 2016-2022 Vera Visions LLC.
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

#define UI_OWNERDRAW_BASE 200
#define UI_HANDICAP 200
#define UI_EFFECTS 201
#define UI_PLAYERMODEL 202
#define UI_CLANNAME 203
#define UI_CLANLOGO 204
#define UI_GAMETYPE 205
#define UI_MAPPREVIEW 206
#define UI_SKILL 207
#define UI_BLUETEAMNAME 208
#define UI_REDTEAMNAME 209
#define UI_BLUETEAM1 210
#define UI_BLUETEAM2 211
#define UI_BLUETEAM3 212
#define UI_BLUETEAM4 213
#define UI_BLUETEAM5 214
#define UI_REDTEAM1 215
#define UI_REDTEAM2 216
#define UI_REDTEAM3 217
#define UI_REDTEAM4 218
#define UI_REDTEAM5 219
#define UI_NETSOURCE 220
#define UI_NETMAPPREVIEW 221
#define UI_NETFILTER 222
#define UI_TIER 223
#define UI_OPPONENTMODEL 224
#define UI_TIERMAP1 225
#define UI_TIERMAP2 226
#define UI_TIERMAP3 227
#define UI_PLAYERLOGO 228
#define UI_OPPONENTLOGO 229
#define UI_PLAYERLOGO_METAL 230
#define UI_OPPONENTLOGO_METAL 231
#define UI_PLAYERLOGO_NAME 232
#define UI_OPPONENTLOGO_NAME 233
#define UI_TIER_MAPNAME 234
#define UI_TIER_GAMETYPE 235
#define UI_ALLMAPS_SELECTION 236
#define UI_OPPONENT_NAME 237
#define UI_VOTE_KICK 238
#define UI_BOTNAME 239
#define UI_BOTSKILL 240
#define UI_REDBLUE 241
#define UI_CROSSHAIR 242
#define UI_SELECTEDPLAYER 243
#define UI_MAPCINEMATIC 244
#define UI_NETGAMETYPE 245
#define UI_NETMAPCINEMATIC 246
#define UI_SERVERREFRESHDATE 247
#define UI_SERVERMOTD 248
#define UI_GLINFO  249
#define UI_KEYBINDSTATUS 250
#define UI_CLANCINEMATIC 251
#define UI_MAP_TIMETOBEAT 252
#define UI_JOINGAMETYPE 253
#define UI_PREVIEWCINEMATIC 254
#define UI_STARTMAPCINEMATIC 255
#define UI_MAPS_SELECTION 256

__weak __variant
MenuGame_OwnerDrawValueForType(entity clientSlot, int ownerDraw, int typeValue)
{
	/* update all ownerdraw items */
	switch (ownerDraw) {
	default:
		/* unimplemented, you can warn here if you don't mind spam */
		break;
	}


	return (__NULL__);
}

__weak bool
MenuGame_OwnerDrawItemRect(entity clientSlot, vguiScriptedItem drawItem, int ownerDraw, int drawType)
{
	switch (ownerDraw) {
	case UI_MAPPREVIEW:
	case UI_STARTMAPCINEMATIC:
	case UI_MAPCINEMATIC:
		draw.Pic(drawItem.GetItemPosition(), MapLibrary_GetInfo(g_ui_map_create_preview, MAPINFO_PREVIEW), drawItem.GetItemSize(), [1,1,1], 1.0f, 0);
		break;
	case UI_NETMAPPREVIEW:
	case UI_NETMAPCINEMATIC:
		draw.Pic(drawItem.GetItemPosition(), MapLibrary_GetInfo(g_ui_map_net_preview, MAPINFO_PREVIEW), drawItem.GetItemSize(), [1,1,1], 1.0f, 0);
		break;
	default:
		return (false);
	}

	return (true);
}

__weak bool
MenuGame_OwnerDrawMenuRect(entity clientSlot, vguiScriptedMenu drawMenu)
{
	return (false);
}


void Desktop_Init ( void )
{

    if (fileExists("ui/menus.txt")) {
        g_uiDesktop = spawn(vguiRootWindow);
        g_uiDesktop.Add(vguiScriptedView::CreateFromMenuFile(g_uiDesktop, "ui/menus.txt"));
        return;
    }

	static vguiMenuButton btnNewgame;
	static vguiMenuButton btnLoadgame;
	static vguiMenuButton btnFindserver;
	static vguiMenuButton btnCreateserver;
	static vguiMenuButton btnOptions;
	static vguiMenuButton btnQuit;
	static vguiMenuButton btnMPlayer;
	static vguiMenuButton btnPlayerList;
	static vguiMenuButton btnResume;
	static vguiMenuButton btnDisconnect;
	static vguiMenuButton btnMods;
	static vguiMenuButton btnFriends;
	static vguiMenuButton btnPackages;
    static vguiMenuButton btnProfiles;
	static vguiMenuTitle title;
	static vguiPic fnIcon;

	static void Desktop_ResumeGame ( void ) {
		m_toggle( 0 );
	}
	static void Desktop_DisconnectGame ( void ) {
		localcmd( "disconnect\n" );
	}
	static void Desktop_PlayerList ( void ) {
		m_toggle( 0 );
		localcmd( "showPlayerList\n" );
	}

	g_uiDesktop = spawn( vguiRootWindow );

	btnNewgame = spawn( vguiMenuButton );
	btnNewgame.SetTitle( "New Game" );
	btnNewgame.SetSize( '128 24' );
	btnNewgame.SetPosition( 1 );
	btnNewgame.SetFunc( UI_NewGame_Show );
	btnNewgame.FlagRemove( MBUTTON_SHOWSP | MBUTTON_SHOWMP );
	btnNewgame.SetIcon( "gfx/icon16/new" );

	btnDisconnect = spawn( vguiMenuButton );
	btnDisconnect.SetTitle( "Disconnect" );
	btnDisconnect.SetSize( '128 24' );
	btnDisconnect.SetPosition( 1 );
	btnDisconnect.SetFunc( Desktop_DisconnectGame );
	btnDisconnect.FlagRemove( MBUTTON_SHOWOFFLINE );
	btnDisconnect.SetIcon( "gfx/icon16/disconnect" );

	btnLoadgame = spawn( vguiMenuButton );
	btnLoadgame.SetTitle( "Load Game" );
	btnLoadgame.SetSize( '128 24' );
	btnLoadgame.SetPosition( 2 );
	btnLoadgame.SetIcon( "gfx/icon16/book_edit" );
	btnLoadgame.SetFunc( UI_LoadGame_Show );

	btnFindserver = spawn( vguiMenuButton );
	btnFindserver.SetTitle( "Find World" );
	btnFindserver.SetSize( '128 24' );
	btnFindserver.SetPosition(3 );
	btnFindserver.SetFunc( UI_FindServers_Show );
	btnFindserver.SetIcon( "gfx/icon16/world_go" );

	btnCreateserver = spawn( vguiMenuButton );
	btnCreateserver.SetTitle( "Create World" );
	btnCreateserver.SetSize( '128 24' );
	btnCreateserver.SetPosition( 4 );
	btnCreateserver.SetFunc( UI_CreateServer_Show );
	btnCreateserver.SetIcon( "gfx/icon16/world_add" );

	btnMods = spawn( vguiMenuButton );
	btnMods.SetTitle( "Change Game" );
	btnMods.SetSize( '128 24' );
	btnMods.SetPosition( 5 );
	btnMods.SetIcon( "gfx/icon16/rainbow" );
	btnMods.SetFunc( UI_CustomGame_Show );
	btnMods.FlagRemove( MBUTTON_SHOWSP | MBUTTON_SHOWMP );

	btnOptions = spawn( vguiMenuButton );
	btnOptions.SetTitle( "Options" );
	btnOptions.SetSize( '128 24' );
	btnOptions.SetPosition( 6 );
	btnOptions.SetFunc( UI_Options_Show );
	btnOptions.SetIcon( "gfx/icon16/cog" );

	btnQuit = spawn( vguiMenuButton );
	btnQuit.SetTitle( "Quit Game" );
	btnQuit.SetSize( '128 24' );
	btnQuit.SetPosition( 7 );
	btnQuit.SetFunc( UI_QuitGame_Show );
	btnQuit.SetIcon( "gfx/icon16/stop" );

	btnMPlayer = spawn( vguiMenuButton );
	btnMPlayer.SetTitle( "Music Player" );
	btnMPlayer.SetSize( '128 24' );
	btnMPlayer.SetPosition( 8 );
	btnMPlayer.SetFunc( UI_MusicPlayer_Show );
	btnMPlayer.SetIcon( "gfx/icon16/ipod" );

	btnPlayerList = spawn( vguiMenuButton );
	btnPlayerList.SetTitle( "Player List" );
	btnPlayerList.SetSize( '128 24' );
	btnPlayerList.SetPosition( 9 );
	btnPlayerList.SetFunc( Desktop_PlayerList );
	btnPlayerList.FlagRemove( MBUTTON_SHOWOFFLINE );
	btnPlayerList.SetIcon( "gfx/icon16/user" );

	btnResume = spawn( vguiMenuButton );
	btnResume.SetTitle( "Resume Game" );
	btnResume.SetSize( '128 24' );
	btnResume.SetPosition( 10 );
	btnResume.SetFunc( Desktop_ResumeGame );
	btnResume.FlagRemove( MBUTTON_SHOWOFFLINE );
	btnResume.SetIcon( "gfx/icon16/control_play" );

	/* auth only */
	btnProfiles = spawn( vguiMenuButton );
	btnProfiles.SetTitle( "Profiles" );
	btnProfiles.SetSize( '128 24' );
	btnProfiles.SetPosition( 8 );
	btnProfiles.SetFunc( UI_Profiles_Show );
	btnProfiles.SetIcon( "gfx/icon16/status_online" );
	btnProfiles.FlagRemove( MBUTTON_SHOWSP | MBUTTON_SHOWMP );
	//btnProfiles.FlagAdd( MBUTTON_AUTHONLY );

	/* auth only */
	btnFriends = spawn( vguiMenuButton );
	btnFriends.SetTitle( "Friends" );
	btnFriends.SetSize( '128 24' );
	btnFriends.SetPosition( 9 );
	btnFriends.SetFunc( UI_Friends_Show );
	btnFriends.SetIcon( "gfx/icon16/status_online" );
	btnFriends.FlagAdd( MBUTTON_AUTHONLY );

	btnPackages = spawn( vguiMenuButton );
	btnPackages.SetTitle( "Packages" );
	btnPackages.SetSize( '128 24' );
	btnPackages.SetPosition( 10 );
	btnPackages.SetFunc( UI_Packages_Show );
	btnPackages.SetIcon( "gfx/icon16/package" );
	btnPackages.FlagRemove( MBUTTON_SHOWSP | MBUTTON_SHOWMP );

	title = spawn(vguiMenuTitle);

	g_uiDesktop.Add( title );

	if (GameLibrary_GetInfo(GAMEINFO_TYPE) != "Multiplayer")
		g_uiDesktop.Add( btnNewgame );

	if (GameLibrary_GetInfo(GAMEINFO_TYPE) != "Multiplayer")
		g_uiDesktop.Add( btnLoadgame );

	if (GameLibrary_GetInfo(GAMEINFO_TYPE) != "Singleplayer")
		g_uiDesktop.Add( btnFindserver );

	if (GameLibrary_GetInfo(GAMEINFO_TYPE) != "Singleplayer")
		g_uiDesktop.Add( btnCreateserver );

	g_uiDesktop.Add( btnOptions );
	g_uiDesktop.Add( btnQuit );
	//g_uiDesktop.Add( btnMPlayer );
	g_uiDesktop.Add( btnPlayerList );
	g_uiDesktop.Add( btnResume );
	g_uiDesktop.Add( btnDisconnect );
	g_uiDesktop.Add( btnMods );
	g_uiDesktop.Add( btnFriends );
	g_uiDesktop.Add( btnPackages );
	g_uiDesktop.Add( fnIcon );
    g_uiDesktop.Add(btnProfiles);
}

void Desktop_Draw ( void )
{
	g_uiDesktop.Draw();
}

void Desktop_CanvasChanged ( void )
{
	g_uiDesktop.Reposition();
}

void
Desktop_Add( vguiWidget toAdd )
{
	g_uiDesktop.Add(toAdd);
}
