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

#ifndef WEBMENU

/* Called as an eventual result of the uri_get builtin. */
void
URI_Get_Callback(float uriID, float code, string data, int resourcebytes)
{
	switch (uriID) {
	case ACTIVITYPUB_ACCOUNTS:
		ActivityPub_UpdatePlayerInfo(data);
		break;
    case MATRIX_ACCOUNTS:
        Matrix_UpdatePlayerInfo(data);
        break;
	case MATRIX_MXC:
        Matrix_UpdatePlayerAvatar(data);
		break;
	case ARCHIVE_ITEM_WEB:
        Archive_ParseItemWeb(data);
		break;
	case ARCHIVE_ITEM_TEXT:
        Archive_ParseItemText(data);
		break;
	case ARCHIVE_ITEM_VIDEO:
        Archive_ParseItemVideo(data);
		break;
	case ARCHIVE_ITEM_AUDIO:
        Archive_ParseItemAudio(data);
		break;
	case ARCHIVE_ITEM_SOFTWARE:
        Archive_ParseItemSoftware(data);
		break;
	case ARCHIVE_ITEM_IMAGE:
        Archive_ParseItemImage(data);
		break;
	default:
		ncError("Unknown request id %d with code %d", uriID, code);
	}
}
#endif
