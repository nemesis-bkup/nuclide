/*
 * Copyright (c) 2016-2025 Vera Visions LLC.
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
@defgroup matrix Matrix
@brief Matrix protocol integration
@ingroup menu

The console command `matrix_userID` can be used
to set certain infokeys of the local user to mimic
that of a certain Matrix profile. An example format
would look like: `/matrix_userID @johndoe:example.com`

https://spec.matrix.org/latest/

@{
*/

#define ACTIVITYPUB_ACCOUNTS 400
#define MATRIX_ACCOUNTS 401
#define MATRIX_MXC 402

#define ARCHIVE_ITEM_WEB 403
#define ARCHIVE_ITEM_TEXT 404
#define ARCHIVE_ITEM_VIDEO 405
#define ARCHIVE_ITEM_AUDIO 406
#define ARCHIVE_ITEM_SOFTWARE 407
#define ARCHIVE_ITEM_IMAGE 408


void Matrix_FetchAccountData(string apUserID);
void Matrix_UpdatePlayerInfo(string jsonData);
void Matrix_UpdatePlayerAvatar(string jsonData);

/** @} */ // end of matrix
