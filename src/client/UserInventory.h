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

typedef enum
{
    ITEM_PICTURE,
    ITEM_AUDIO,
    ITEM_VIDEO,
    ITEM_OBJECT,
    ITEM_APP,
    ITEM_TEXT,
    ITEM_WEB,
} profileItem_t;

string g_profileItems[] = {
  "picture",
  "audio",
  "video",
  "object",
  "app",
  "text",
  "web"
};

class
ncUserInventory
{
public:
    nonvirtual int IndexInventoryForType(string subDirectory, string fileExtension);
    nonvirtual void IndexInventory(void);

    nonvirtual int GetItemCount(profileItem_t);
    nonvirtual ncDict GetItemDict(string, profileItem_t);
    nonvirtual ncDict GetItemDictByIndex(int, profileItem_t);

private:
    int m_pictureCount;
    int m_audioCount;
    int m_videoCount;
    int m_objectCount;
    int m_appCount;
    int m_textCount;
};

