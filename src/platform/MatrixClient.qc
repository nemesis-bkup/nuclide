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

/* apUserID is argv(1) from a console command */
void
Matrix_FetchAccountData(string apUserID)
{
	string userID = __NULL__;
	string apInstance = __NULL__;

	if (!STRING_SET(apUserID)) {
		return;
	}

	tokenizebyseparator(apUserID, ":");
	apInstance = argv(1);

	if (!STRING_SET(apInstance)) {
        ncWarning("Invalid instance URL https://%s/_matrix/client/v3/profile/%s", apInstance, apUserID);
		return;
	}

	uri_get(sprintf("https://%s/_matrix/client/v3/profile/%s", apInstance, apUserID), MATRIX_ACCOUNTS);
}

void
Matrix_MXCtoURL(string mxcURL)
{

	string mediaURL = __NULL__;
	string apInstance = __NULL__;

	if (!STRING_SET(mxcURL)) {
		return;
	}

	tokenizebyseparator(mxcURL, "/");
	apInstance = argv(2);
	mediaURL = argv(3);

	uri_get(sprintf("https://%s/_matrix/client/v1/media/thumbnail/%s/%s", apInstance, apInstance, mediaURL), MATRIX_MXC);
}

/* the json string passed from uri's callback function as data */
void
Matrix_UpdatePlayerInfo(string jsonData)
{
	jsonnode acctNode = json_parse(jsonData);

	if (!acctNode) {
		ncError("Unable to parse Matrix info.");
		return;
	}

	string stringName = acctNode["displayname"].s;
	string stringAvatar = acctNode["avatar_url"].s;

	if (!stringName) {
		ncError("Matrix display name invalid.");
	} else {
		cvar_set("name", stringName);
	}

	if (!stringAvatar) {
		ncError("Matrix avatar invalid.");
	} else {
		Matrix_MXCtoURL(stringAvatar);
	}

	json_free(acctNode);
}

void
Matrix_UpdatePlayerAvatar(string jsonData)
{

}
