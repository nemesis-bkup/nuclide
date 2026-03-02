/*
 * Copyright (c) 2024-2026 Vera Visions LLC.
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

bool
Platform_ConsoleCommand(string commandString, int wordCount)
{
	switch (argv(0)) {
	case "richpresence_dump":
		RichPresence_DumpInfo();
		break;
	case "menu_musicstart":
		ncMusicController::Init();
		break;
	case "menu_musictrack":
		ncMusicController::ParseTrack(argv(1));
		break;
	case "menu_musicloop":
		ncMusicController::ParseLoop(argv(1));
		break;
	//case "togglemenu":
		//m_display();
	//	break;
	case "map_background":
		localcmd(sprintf("set g_gametype \"singleplayer\"\nset sv_playerslots 2\nset coop 1\nset sv_background 1\nmap %s\n",
			argv(1)));
		break;
	case "menu_refreshMapList":
		break;
	case "menu_refreshSavedGames":
		Saves_Init();
		SavesCallback_EntriesUpdated();
		break;
	case "listGameLibrary":
		GameLibrary_DebugList();
		break;
	case "ap_userID":
		ActivityPub_FetchAccountData(argv(1));
		break;
	case "matrix_userID":
		Matrix_FetchAccountData(argv(1));
		break;
	case "signOn":
		FragNet_SignOn();
		break;
	case "signOff":
		FragNet_SignOff();
		break;
	case "addFriend":
		FragNet_AddFriend(argv(1));
		break;
	case "removeFriend":
		FragNet_RemoveFriend(argv(1));
		break;
	case "reloadMenuLocale":
		Locale_Reload();
		break;
	case "listProfiles":
		ncProfileManager::ListProfiles();
		break;
	case "profile_create":
		ncProfileManager::CreateNamedProfile(argv(1));
		break;
	case "profile_delete":
		ncProfileManager::DeleteNamedProfile(argv(1));
		break;
	case "profile_select":
		ncProfileManager::SetProfileByName(argv(1));
		break;
	case "profile_save":
		ncProfileManager::SaveActiveProfile();
		break;
	case "gopherVisit":
		Gopher_RequestIndex(substring(commandString, 12, -1));
		break;
	case "gopherQuery":
		Gopher_QueryItem(argv(1), argv(2), argv(3), argv(4));
		break;
	case "gopherText":
		Gopher_RequestText(argv(1), argv(2), argv(3), argv(4));
		break;
	case "finger":
		Finger_RequestPlan(substring(commandString, 7, -1));
		break;
	case "mpd_connect":
		ncMPDController::Connect();
		break;
	case "mpd_nextSong":
		ncMPDController::Command_Next();
		break;
	case "mpd_prevSong":
		ncMPDController::Command_Previous();
		break;
	case "mpd_stopSong":
		ncMPDController::Command_Stop();
		break;
	case "mpd_playSong":
		ncMPDController::Command_Play();
		break;
	case "mpd_pauseSong":
		ncMPDController::Command_Pause();
		break;
	case "mpd_shuffle":
		ncMPDController::Command_SetShuffle(!cvar("ui_mpd_shuffle"));
		break;
	case "mpd_repeat":
		ncMPDController::Command_SetRepeat(!cvar("ui_mpd_repeat"));
		break;
	case "mpd_single":
		ncMPDController::Command_SetSingle(!cvar("ui_mpd_single"));
		break;
	case "spawnEditor":
		ncWorldSetup::Editor();
		break;
	case "home_set":
		ncWorldSetup::HomeSave();
		break;

	/* places you right at home */
	case "spawnHome":
		ncWorldSetup::Home();
		break;
	/* starts the singleplayer game */
	case "spawnSingle":
		ncWorldSetup::NewGame();
		break;
	/* goes to the training level */
	case "spawnTraining":
		ncWorldSetup::Training();
		break;
	/* spawns a multiplayer server */
	case "spawnServer":
		ncWorldSetup::SpawnServer();
		break;
	/* spawns a shutterbug session */
	case "spawnShutterbug":
		ncWorldSetup::Shutterbug();
		break;

	case "archiveSaveWeb":
		g_archive_sharing = false;
		Archive_SaveWeb(argv(1), argv(2));
		break;
	case "archiveSaveText":
		g_archive_sharing = false;
		Archive_SaveText(argv(1), argv(2));
		break;
	case "archiveSaveVideo":
		g_archive_sharing = false;
		Archive_SaveVideo(argv(1), argv(2));
		break;
	case "archiveSaveAudio":
		g_archive_sharing = false;
		Archive_SaveAudio(argv(1), argv(2));
		break;
	case "archiveSaveSoftware":
		g_archive_sharing = false;
		Archive_SaveSoftware(argv(1), argv(2));
		break;
	case "archiveSaveImage":
		g_archive_sharing = false;
		Archive_SaveImage(argv(1), argv(2));
		break;

	case "archiveShareWeb":
		g_archive_sharing = true;
		Archive_SaveWeb(argv(1), argv(2));
		break;
	case "archiveShareText":
		g_archive_sharing = true;
		Archive_SaveText(argv(1), argv(2));
		break;
	case "archiveShareVideo":
		g_archive_sharing = true;
		Archive_SaveVideo(argv(1), argv(2));
		break;
	case "archiveShareAudio":
		g_archive_sharing = true;
		Archive_SaveAudio(argv(1), argv(2));
		break;
	case "archiveShareSoftware":
		g_archive_sharing = true;
		Archive_SaveSoftware(argv(1), argv(2));
		break;
	case "archiveShareImage":
		g_archive_sharing = true;
		Archive_SaveImage(argv(1), argv(2));
		break;

	case "saveWeb":
		ncProfileManager::SaveWeb(argv(1), argv(2), argv(3), argv(4), argv(5));
		break;
	case "saveText":
		ncProfileManager::SaveText(argv(1), argv(2), argv(3), argv(4), argv(5));
		break;
	case "saveVideo":
		ncProfileManager::SaveVideo(argv(1), argv(2), argv(3), argv(4), argv(5));
		break;
	case "saveAudio":
		ncProfileManager::SaveAudio(argv(1), argv(2), argv(3), argv(4), argv(5));
		break;
	case "saveSoftware":
		ncProfileManager::SaveSoftware(argv(1), argv(2), argv(3), argv(4), argv(5));
		break;
	case "saveImage":
		ncProfileManager::SaveImage(argv(1), argv(2), argv(3), argv(4), argv(5));
		break;

	case "shareWeb":
		ncProfileManager::ShareWeb(argv(1));
		break;
	case "shareText":
		ncProfileManager::ShareText(argv(1));
		break;
	case "shareVideo":
		ncProfileManager::ShareVideo(argv(1));
		break;
	case "shareAudio":
		ncProfileManager::ShareAudio(argv(1));
		break;
	case "shareSoftware":
		ncProfileManager::ShareSoftware(argv(1));
		break;
	case "sharePicture":
		ncProfileManager::ShareImage(argv(1));
		break;
    case "listWorlds":
        break;
    case "worldFinderRefresh":
        break;
    case "worldFinderRefreshStop":
        break;
	default:
		return (false);
	}

	return (true);
}

void
Platform_RegisterCommands(void)
{
	registercommand("spawnEditor");
	registercommand("spawnHome");
	registercommand("spawnSingle");
	registercommand("spawnTraining");
	registercommand("spawnShutterbug");
	registercommand("spawnServer");

	registercommand("reloadMenuLocale");

	registercommand("richpresence_dump");
	registercommand("menu_musicstart");
	registercommand("menu_musictrack");
	registercommand("menu_musicloop");
	registercommand("map_background");
	registercommand("home_set");
	registercommand("listGameLibrary");

	registercommand("menu_refreshMapList");
	registercommand("menu_refreshSavedGames");

	/* gopher protocol */
	registercommand("gopherVisit");
	registercommand("gopherQuery");

	/* finger protocol */
	registercommand("finger");

	/* online service */
	registercommand("signOn");
	registercommand("signOff");
	registercommand("addFriend");
	registercommand("removeFriend");

	registercommand("listProfiles");
	registercommand("profile_create");
	registercommand("profile_delete");
	registercommand("profile_select");
	registercommand("profile_save");

	/* profile specific collections */
	registercommand("saveWeb");
	registercommand("saveText");
	registercommand("saveVideo");
	registercommand("saveAudio");
	registercommand("saveSoftware");
	registercommand("saveImage");

	/* share collection item from profile */
	registercommand("shareWeb");
	registercommand("shareText");
	registercommand("shareVideo");
	registercommand("shareAudio");
	registercommand("shareSoftware");
	registercommand("sharePicture");

	/* ! extra client features start here ! */

	/* profile import: activitypub protocol */
	registercommand("ap_userID");

	/* profile import: matrix protocol */
	registercommand("matrix_userID");

	/* item import: internet archive; 2 args max: itemname [filename optional] */
	registercommand("archiveSaveWeb");
	registercommand("archiveSaveText");
	registercommand("archiveSaveVideo");
	registercommand("archiveSaveAudio");
	registercommand("archiveSaveSoftware");
	registercommand("archiveSaveImage");

	registercommand("archiveShareWeb");
	registercommand("archiveShareText");
	registercommand("archiveShareVideo");
	registercommand("archiveShareAudio");
	registercommand("archiveShareSoftware");
	registercommand("archiveShareImage");

	/* remote control: music player daemon protocol */
	registercommand("mpd_connect");
	registercommand("mpd_nextSong");
	registercommand("mpd_prevSong");
	registercommand("mpd_stopSong");
	registercommand("mpd_playSong");
	registercommand("mpd_pauseSong");
	registercommand("mpd_shuffle");
	registercommand("mpd_loop");
	registercommand("mpd_single");
}
