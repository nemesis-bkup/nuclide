/*
 * Copyright (c) 2026 Vera Visions LLC.
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
