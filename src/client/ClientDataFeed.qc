int
Feeder_Count(feederTypes_t typeFeed)
{
	switch (typeFeed) {
    case FEEDER_PLAYER_PROFILE_VIDEO_LIST:
		return ncUserInventory::GetItemCount(ITEM_VIDEO);
		break;
    case FEEDER_PLAYER_PROFILE_AUDIO_LIST:
		return ncUserInventory::GetItemCount(ITEM_AUDIO);
		break;
    case FEEDER_PLAYER_PROFILE_PICTURE_LIST:
		return ncUserInventory::GetItemCount(ITEM_PICTURE);
		break;
    case FEEDER_PLAYER_PROFILE_SOFTWARE_LIST:
		return ncUserInventory::GetItemCount(ITEM_APP);
		break;
    case FEEDER_PLAYER_PROFILE_WEB_LIST:
		return ncUserInventory::GetItemCount(ITEM_WEB);
		break;
    case FEEDER_PLAYER_PROFILE_TEXT_LIST:
		return ncUserInventory::GetItemCount(ITEM_TEXT);
		break;
    case FEEDER_PLAYER_PROFILE_OBJECT_LIST:
		return ncUserInventory::GetItemCount(ITEM_OBJECT);
		break;
	default:
		return 1;
		break;
	}
}

string
Feeder_StringAtIndex(int i, int column, feederTypes_t typeFeed)
{
    string outputResult;
    ncDict currentItem;

	switch (typeFeed) {
    case FEEDER_PLAYER_PROFILE_VIDEO_LIST:
		currentItem = ncUserInventory::GetItemDictByIndex(i, ITEM_VIDEO);
		break;
    case FEEDER_PLAYER_PROFILE_AUDIO_LIST:
		currentItem = ncUserInventory::GetItemDictByIndex(i, ITEM_AUDIO);
		break;
    case FEEDER_PLAYER_PROFILE_PICTURE_LIST:
		currentItem = ncUserInventory::GetItemDictByIndex(i, ITEM_PICTURE);
		break;
    case FEEDER_PLAYER_PROFILE_SOFTWARE_LIST:
		currentItem = ncUserInventory::GetItemDictByIndex(i, ITEM_APP);
		break;
    case FEEDER_PLAYER_PROFILE_WEB_LIST:
		currentItem = ncUserInventory::GetItemDictByIndex(i, ITEM_WEB);
		break;
    case FEEDER_PLAYER_PROFILE_TEXT_LIST:
		currentItem = ncUserInventory::GetItemDictByIndex(i, ITEM_TEXT);
		break;
    case FEEDER_PLAYER_PROFILE_OBJECT_LIST:
		currentItem = ncUserInventory::GetItemDictByIndex(i, ITEM_OBJECT);
		break;
	default:
        return "Dummy";
		break;
	}

	if (column == 0) {
        return currentItem.GetString("name");
	} else {
        return currentItem.Name();
	}
}
