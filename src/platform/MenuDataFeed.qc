int
Feeder_Count(feederTypes_t typeFeed)
{
	switch (typeFeed) {
	case FEEDER_HEADS:
		return 1;
		break;
	case FEEDER_MAPS:
	case FEEDER_ALLMAPS:
		return MapLibrary_GetMapCount();
		break;
	case FEEDER_SERVERS:
		return Master_GetTotalServers();
		break;
    case FEEDER_REDTEAM_LIST:
		return 1;
		break;
    case FEEDER_BLUETEAM_LIST:
		return 1;
		break;
    case FEEDER_PLAYER_LIST:
		return 1;
		break;
	case FEEDER_TEAM_LIST:
		return 1;
		break;
	case FEEDER_MODS:
		return GameLibrary_GetGameCount();
		break;
	case FEEDER_DEMOS:
		return 1;
		break;
	case FEEDER_SCOREBOARD:
		return 1;
		break;
	case FEEDER_Q3HEADS:
		return 1;
		break;
	case FEEDER_SERVERSTATUS:
		return 1;
		break;
	case FEEDER_FINDPLAYER:
		return 1;
		break;
	case FEEDER_CINEMATICS:
		return 1;
		break;
	case FEEDER_SAVEGAMES:
		return 1;
		break;
	case FEEDER_PICKSPAWN:
		return 1;
		break;
	case FEEDER_PARTY_MEMBERS:
		return 1;
		break;
	case FEEDER_PARTY_MEMBERS_TALK:
		return 1;
		break;
	case FEEDER_MUTELIST:
		return 1;
		break;
	case FEEDER_PLAYERSTALKING:
		return 1;
		break;
	case FEEDER_SPLITSCREENPLAYERS:
		return 1;
		break;
	case FEEDER_PARTY_MEMBERS_READY:
		return 1;
		break;
	case FEEDER_PLAYER_PROFILES:
		return 1;
		break;
    case FEEDER_GAMETYPES:
        return ncGametypeLibrary::Count();
        break;
    case FEEDER_PLAYERMODELS:
        return ncPlayerModelLibrary::Count();
        break;
    case FEEDER_PLAYERSKINS:
        return ncPlayerModelLibrary::SkinCount();
        break;
    case FEEDER_PLAYERSPRAYS:
        return ncPlayerModelLibrary::SprayCount();
        break;
	case FEEDER_CONTROLS:
		return ncControlBindingsManager::Count();
		break;
	case FEEDER_VIDEO_RESOLUTIONS:
		return ncRenderingManager::Count(RENDERER_RESOLUTION);
		break;
	case FEEDER_VIDEO_DISPLAYMODES:
		return ncRenderingManager::Count(RENDERER_DISPLAYMODE);
		break;
	case FEEDER_VIDEO_RENDERINGAPIS:
		return ncRenderingManager::Count(RENDERER_API);
		break;
	case FEEDER_VIDEO_ASPECTRATIOS:
		return ncRenderingManager::Count(RENDERER_ASPECTRATIO);
		break;
	default:
		break;
	}
}

string
Feeder_StringAtIndex(int i, int column, feederTypes_t typeFeed)
{
	switch (typeFeed) {
	case FEEDER_HEADS:
		return "Head";
		break;
	case FEEDER_ALLMAPS:
	case FEEDER_MAPS:
		return MapLibrary_GetInfo(i, MAPINFO_TITLE);
		break;
	case FEEDER_SERVERS:
		return Servers_GetInfo(i, SERVERGAME_TITLE);
		break;
    case FEEDER_CONTROLS:
        if (column == 1i) {
            return ncControlBindingsManager::GetInfo(i, BIND_KEYCOMMAND);
        } else if (column == 2i) {
            return ncControlBindingsManager::GetInfo(i, BIND_ALL_KEYS);
        } else if (column == 3i) {
            return ncControlBindingsManager::GetInfo(i, BIND_FIRST_KEY);
        } else if (column == 4i) {
            return ncControlBindingsManager::GetInfo(i, BIND_SECOND_KEY);
        } else {
            return ncControlBindingsManager::GetInfo(i, BIND_DESCRIPTION);
        }
        break;
    case FEEDER_REDTEAM_LIST:
		return "Dummy Red Team Player";
		break;
    case FEEDER_BLUETEAM_LIST:
		return "Dummy Red Team Player";
		break;
    case FEEDER_PLAYER_LIST:
		return "Dummy Player";
		break;
	case FEEDER_TEAM_LIST:
		return "Dummy Team";
		break;
	case FEEDER_MODS:
		return GameLibrary_GetInfo(i, GAMEINFO_NAME);
		break;
	case FEEDER_DEMOS:
		return "Dummy Demo";
		break;
	case FEEDER_SCOREBOARD:
		return "Head";
		break;
	case FEEDER_Q3HEADS:
		return "Dummy Head";
		break;
	case FEEDER_SERVERSTATUS:
		return "ServerInfoHere";
		break;
	case FEEDER_FINDPLAYER:
		return "Player 1";
		break;
	case FEEDER_CINEMATICS:
		return "Dummy Cinematic";
		break;
	case FEEDER_SAVEGAMES:
		return "Dummy Save";
		break;
	case FEEDER_PICKSPAWN:
		return "Dummy Spawn";
		break;
	case FEEDER_PARTY_MEMBERS:
		return "Dummy Party Member";
		break;
	case FEEDER_PARTY_MEMBERS_TALK:
		return "Dummy Talking Party Member";
		break;
	case FEEDER_MUTELIST:
		return "Dummy Muted Player";
		break;
	case FEEDER_PLAYERSTALKING:
		return "Dummy Talking Player";
		break;
	case FEEDER_SPLITSCREENPLAYERS:
		return "Dummy Splitscreen Player";
		break;
	case FEEDER_PARTY_MEMBERS_READY:
		return "Dummy Ready Party Member";
		break;
	case FEEDER_PLAYER_PROFILES:
		return "Dummy Profile";
		break;
    case FEEDER_GAMETYPES:
        return ncGametypeLibrary::GetInfo(i, GAMETYPE_NAME);
        break;
    case FEEDER_PLAYERMODELS:
        if (column == 1i) {
            return ncPlayerModelLibrary::GetInfo(i, PLAYERMODEL_PATH);
        } else {
            return ncPlayerModelLibrary::GetInfo(i, PLAYERMODEL_NAME);
        }
        break;
    case FEEDER_PLAYERSKINS:
        return ncPlayerModelLibrary::SkinName(i);
        break;
    case FEEDER_PLAYERSPRAYS:
        return ncPlayerModelLibrary::SprayName(i);
        break;
	case FEEDER_VIDEO_RESOLUTIONS:
		return ncRenderingManager::GetInfo(i, RENDERER_RESOLUTION);
		break;
	case FEEDER_VIDEO_DISPLAYMODES:
		return ncRenderingManager::GetInfo(i, RENDERER_DISPLAYMODE);
		break;
	case FEEDER_VIDEO_RENDERINGAPIS:
		return ncRenderingManager::GetInfo(i, RENDERER_API);
		break;
	case FEEDER_VIDEO_ASPECTRATIOS:
		return ncRenderingManager::GetInfo(i, RENDERER_ASPECTRATIO);
		break;
	default:
		break;
	}
}
