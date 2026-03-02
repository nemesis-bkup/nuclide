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

/**
@defgroup archive Internet Archive
@brief Internet Archive Item Retrieval & Integration
@ingroup menu

To be written.

@{
*/

void Archive_SaveWeb(string itemID, string videoFile);
void Archive_SaveText(string itemID, string videoFile);
void Archive_SaveVideo(string itemID, string videoFile);
void Archive_SaveAudio(string itemID, string videoFile);
void Archive_SaveSoftware(string itemID, string videoFile);
void Archive_SaveImage(string itemID, string videoFile);

void Archive_ParseItemWeb(string jsonData);
void Archive_ParseItemText(string jsonData);
void Archive_ParseItemVideo(string jsonData);
void Archive_ParseItemAudio(string jsonData);
void Archive_ParseItemSoftware(string jsonData);
void Archive_ParseItemImage(string jsonData);

var bool g_archive_sharing = false;
var string g_archive_specificItem;

/** @} */ // end of archive
