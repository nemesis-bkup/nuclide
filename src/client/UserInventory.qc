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

static ncUserInventory g_userInventory;

int
ncUserInventory::IndexInventoryForType(string subDirectory, string fileExtension)
{
    int itemCount;
    string profileName = cvars.GetString("cl_cred");

    if (!STRING_SET(profileName)) {
        profileName = "Default";
    }

    string libraryPath = sprintf("decls/%s/*.%s", subDirectory, fileExtension);
    string inventoryPath = sprintf("data/players/%s/decls/%s/*.%s", profileName, subDirectory, fileExtension);
    searchhandle shSearchItemLibrary = search_begin( libraryPath, SEARCH_NAMESORT | SEARCH_MULTISEARCH, TRUE );
    searchhandle shSearchItemInventory = search_begin( inventoryPath, SEARCH_NAMESORT | SEARCH_MULTISEARCH, TRUE );

    int invCount = search_getsize( shSearchItemInventory );
    int libCount = search_getsize( shSearchItemLibrary );

    if (invCount > 2048) {
        invCount = 2048;
    }
    if (libCount > 2048) {
        libCount = 2048;
    }

    for ( int i = 0; i < invCount; i++ ) {
        string dictName = substring(search_getfilename( shSearchItemInventory, i ), 28 + strlen(subDirectory), -2 - strlen(fileExtension));
        ncDict videoDict = ncDict::LoadDeclFromFile(dictName, sprintf("%s/%s.%s", subDirectory, dictName, fileExtension));
        ncLog("Cached %S %S", dictName, sprintf("%s/%s.%s", subDirectory, dictName, fileExtension));
    }

    for ( int i = 0; i < libCount; i++ ) {
        string dictName = substring(search_getfilename( shSearchItemLibrary, i ), 7 + strlen(subDirectory), -2 - strlen(fileExtension));
        ncDict videoDict = ncDict::LoadDeclFromFile(dictName, sprintf("%s/%s.%s", subDirectory, dictName, fileExtension));
        ncLog("Cached %S %S", dictName, sprintf("%s/%s.%s", subDirectory, dictName, fileExtension));
    }

    itemCount = invCount + libCount;
    search_end( shSearchItemLibrary );
    search_end( shSearchItemInventory );

    return (itemCount);
}

void
ncUserInventory::IndexInventory(void)
{
    if (!g_userInventory) {
        g_userInventory = spawn(ncUserInventory);
    }

    g_userInventory.m_pictureCount = IndexInventoryForType("pictures", "picture");
    g_userInventory.m_audioCount = IndexInventoryForType("audio", "audio");
    g_userInventory.m_videoCount = IndexInventoryForType("videos", "video");
    g_userInventory.m_objectCount = IndexInventoryForType("objects", "object");
    g_userInventory.m_appCount = IndexInventoryForType("apps", "app");
    g_userInventory.m_textCount = IndexInventoryForType("texts", "text");
}

int
ncUserInventory::GetItemCount(profileItem_t dictType)
{
    if (!g_userInventory) {
        return (0i);
    }

    switch (dictType) {
    case ITEM_PICTURE:
        return (g_userInventory.m_pictureCount);
    case ITEM_AUDIO:
        return (g_userInventory.m_audioCount);
    case ITEM_VIDEO:
        return (g_userInventory.m_videoCount);
    case ITEM_OBJECT:
        return (g_userInventory.m_objectCount);
    case ITEM_APP:
        return (g_userInventory.m_appCount);
    case ITEM_TEXT:
        return (g_userInventory.m_textCount);
    }

    return (0i);
}

ncDict
ncUserInventory::GetItemDictByIndex(int itemIndex, profileItem_t dictType)
{
    int itemCounter = 0i;
    string dictTypeName = g_string_null;

    switch (dictType) {
    case ITEM_PICTURE:
        dictTypeName = "picture";
        break;
    case ITEM_AUDIO:
        dictTypeName = "audio";
        break;
    case ITEM_VIDEO:
        dictTypeName = "video";
        break;
    case ITEM_OBJECT:
        dictTypeName = "object";
        break;
    case ITEM_APP:
        dictTypeName = "app";
        break;
    case ITEM_TEXT:
        dictTypeName = "text";
        break;
    default:
        return (__NULL__);
    }

    for (ncDict dictSearch = 0; (dictSearch = (ncDict)find(dictSearch, ::classname, "ncDict"));) {
        if (dictSearch.m_dictType == dictTypeName) {
            if (itemCounter == itemIndex) {
                return (dictSearch);
            }
            itemCounter++;
        }
    }

    return (__NULL__);
}

ncDict
ncUserInventory::GetItemDict(string dictName, profileItem_t dictType)
{
    string fileExtension = g_string_null;
    string subDirectory = g_string_null;

    switch (dictType) {
    case ITEM_PICTURE:
        fileExtension = "picture";
        subDirectory = "pictures";
        break;
    case ITEM_AUDIO:
        fileExtension = "audio";
        subDirectory = "audio";
        break;
    case ITEM_VIDEO:
        fileExtension = "video";
        subDirectory = "videos";
        break;
    case ITEM_OBJECT:
        fileExtension = "object";
        subDirectory = "objects";
        break;
    case ITEM_APP:
        fileExtension = "app";
        subDirectory = "apps";
        break;
    case ITEM_TEXT:
        fileExtension = "text";
        subDirectory = "texts";
        break;
    }

    return ncDict::LoadDeclFromFile(dictName, sprintf("%s/%s.%s", subDirectory, dictName, fileExtension));
}
