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

void
Archive_SaveWeb(string itemID, string videoFile)
{
	g_archive_specificItem = videoFile;
	uri_get(sprintf("https://archive.org/metadata/%s/", itemID), ARCHIVE_ITEM_WEB);
}
void
Archive_SaveText(string itemID, string videoFile)
{
	g_archive_specificItem = videoFile;
	uri_get(sprintf("https://archive.org/metadata/%s/", itemID), ARCHIVE_ITEM_TEXT);
}
void
Archive_SaveVideo(string itemID, string videoFile)
{
	g_archive_specificItem = videoFile;
	uri_get(sprintf("https://archive.org/metadata/%s/", itemID), ARCHIVE_ITEM_VIDEO);
}
void
Archive_SaveAudio(string itemID, string videoFile)
{
	g_archive_specificItem = videoFile;
	uri_get(sprintf("https://archive.org/metadata/%s/", itemID), ARCHIVE_ITEM_AUDIO);
}
void
Archive_SaveSoftware(string itemID, string videoFile)
{
	g_archive_specificItem = videoFile;
	uri_get(sprintf("https://archive.org/metadata/%s/", itemID), ARCHIVE_ITEM_SOFTWARE);
}
void
Archive_SaveImage(string itemID, string videoFile)
{
	g_archive_specificItem = videoFile;
	uri_get(sprintf("https://archive.org/metadata/%s/", itemID), ARCHIVE_ITEM_IMAGE);
}


void
Archive_ParseItemWeb(string jsonData)
{

}

void
Archive_ParseItemText(string jsonData)
{

}


void
Archive_ParseItemVideo(string jsonData)
{
	jsonnode acctNode = json_parse(jsonData);

	if (!acctNode) {
		ncError("Unable to parse Archive Item info.");
		return;
	}

	jsonnode acctFields = json_find_object_child(acctNode, "files");

	if (!acctFields) {
		json_free(acctNode);
		return;
	}

	jsonnode itemMetadata = json_find_object_child(acctNode, "metadata");

	if (!itemMetadata) {
		json_free(acctNode);
		return;
	}


	/* iterate over all activitypub profile fields */
	for (int i = 0i; i < json_get_length(acctFields); i++) {
		jsonnode fieldNode = json_get_child_at_index(acctFields, i);

		/* shouldn't happen, but yeah. */
		if (!fieldNode) {
			ncError("node corrupt");
			break;
		}

		string keyName = fieldNode["name"].s;
		string setValue = fieldNode["format"].s;

		if (STRING_SET(g_archive_specificItem)) {
			if (keyName != g_archive_specificItem) {
				continue;
			}
		}

		switch (setValue) {
		case "Cinepack":
		case "512Kb MPEG4":
		case "Ogg Video":
		case "h.264 IA":
		case "h.264":
		case "MPEG4":
			string newURL = strcat("avs:https://archive.org/download/", itemMetadata["identifier"].s, "/", strreplace(" ", "%20",keyName));
			string urlPreview = strcat("https://archive.org/download/", itemMetadata["identifier"].s, "/", "__ia_thumb.jpg");

			if (g_archive_sharing)
				localcmd(sprintf("cmd shareVideo %S '%s' %S %S %S\n", itemMetadata["identifier"].s, itemMetadata["identifier"].s, "", newURL, ""));
			else
				localcmd(sprintf("saveVideo %S '%s' %S %S %S\n", itemMetadata["identifier"].s, itemMetadata["title"].s, urlPreview, newURL, ""));

			json_free(acctNode);
			return;
			break;
		}

		printf("%S %S\n", keyName, setValue);
	}

	json_free(acctNode);
}

void
Archive_ParseItemAudio(string jsonData)
{
	jsonnode acctNode = json_parse(jsonData);

	if (!acctNode) {
		ncError("Unable to parse Archive Item info.");
		return;
	}

	jsonnode acctFields = json_find_object_child(acctNode, "files");

	if (!acctFields) {
		json_free(acctNode);
		return;
	}

	jsonnode itemMetadata = json_find_object_child(acctNode, "metadata");

	if (!itemMetadata) {
		json_free(acctNode);
		return;
	}

	if (itemMetadata["mediatype"].s == "software") {
		string newURL = strcat("https://archive.org/embed/", itemMetadata["identifier"].s);
		string urlPreview = strcat("https://archive.org/download/", itemMetadata["identifier"].s, "/", "__ia_thumb.jpg");
		string newInfo = sprintf("%s, %s", substring(itemMetadata["date"].s, 0, 4), itemMetadata["creator"].s);

		precache_pic(urlPreview);
		localcmd(sprintf("saveSoftware %S %S %S %S %S\n", itemMetadata["identifier"].s, itemMetadata["title"].s, urlPreview, newURL, newInfo));
	} else {
		ncWarning("Unsupported item type");
	}

	json_free(acctNode);
}

void
Archive_ParseItemSoftware(string jsonData)
{
	jsonnode acctNode = json_parse(jsonData);

	if (!acctNode) {
		ncError("Unable to parse Archive Item info.");
		return;
	}

	jsonnode acctFields = json_find_object_child(acctNode, "files");

	if (!acctFields) {
		json_free(acctNode);
		return;
	}

	jsonnode itemMetadata = json_find_object_child(acctNode, "metadata");

	if (!itemMetadata) {
		json_free(acctNode);
		return;
	}

	if (itemMetadata["mediatype"].s == "software") {
		string newURL = strcat("https://archive.org/embed/", itemMetadata["identifier"].s);
		string urlPreview = strcat("https://archive.org/download/", itemMetadata["identifier"].s, "/", "__ia_thumb.jpg");
		string newInfo = sprintf("%s, %s", substring(itemMetadata["date"].s, 0, 4), itemMetadata["creator"].s);

		precache_pic(urlPreview);

		if (g_archive_sharing)
			localcmd(sprintf("cmd shareSoftware %S %S %S %S %S\n", itemMetadata["identifier"].s, itemMetadata["title"].s, urlPreview, newURL, newInfo));
		else
			localcmd(sprintf("saveSoftware %S %S %S %S %S\n", itemMetadata["identifier"].s, itemMetadata["title"].s, urlPreview, newURL, newInfo));
	} else {
		ncWarning("Unsupported item type");
	}

	json_free(acctNode);
}

void
Archive_ParseItemImage(string jsonData)
{
	jsonnode acctNode = json_parse(jsonData);

	if (!acctNode) {
		ncError("Unable to parse Archive Item info.");
		return;
	}

	jsonnode acctFields = json_find_object_child(acctNode, "files");

	if (!acctFields) {
		json_free(acctNode);
		return;
	}

	jsonnode itemMetadata = json_find_object_child(acctNode, "metadata");

	if (!itemMetadata) {
		json_free(acctNode);
		return;
	}

	/* iterate over all activitypub profile fields */
	for (int i = 0i; i < json_get_length(acctFields); i++) {
		jsonnode fieldNode = json_get_child_at_index(acctFields, i);

		/* shouldn't happen, but yeah. */
		if (!fieldNode) {
			ncError("node corrupt");
			break;
		}

		string keyName = fieldNode["name"].s;
		string setValue = fieldNode["format"].s;

		if (STRING_SET(g_archive_specificItem)) {
			if (keyName != g_archive_specificItem) {
				continue;
			}
		}

		switch (setValue) {
		case "JPEG Thumb":
		case "JPEG":
		case "Item Tile":
			string newURL = strcat("https://archive.org/download/", itemMetadata["identifier"].s, "/", strreplace(" ", "%20",keyName));
			string urlPreview = strcat("https://archive.org/download/", itemMetadata["identifier"].s, "/", "__ia_thumb.jpg");
			precache_pic(urlPreview);

			if (g_archive_sharing) {
				vector imageAspect = drawgetimagesize(urlPreview);

				/* 2d normalize */
				if (imageAspect[0] > imageAspect[1]) {
					imageAspect[1] = imageAspect[1] / imageAspect[0];
					imageAspect[0] = 1.0f;
				} else {
					imageAspect[0] = imageAspect[0] / imageAspect[1];
					imageAspect[1] = 1.0f;
				}

				float standardLength = 118.9;

				/* length * aspect = decent approximation for our image turned poster */
				vector realSize = [standardLength * imageAspect[0], standardLength * imageAspect[1]];

				/* to game units */
				realSize[0] *= (1/2.54);
				realSize[1] *= (1/2.54);

				localcmd(sprintf("cmd sharePicture %S %S %d %d %S\n", itemMetadata["identifier"].s, urlPreview, realSize[0], realSize[1], itemMetadata["title"].s));
			} else
				localcmd(sprintf("saveImage %S %S %S %S %S\n", itemMetadata["identifier"].s, itemMetadata["title"].s, urlPreview, newURL, ""));
			json_free(acctNode);

			return;
			break;
		}

		printf("%S %S\n", keyName, setValue);
	}

	json_free(acctNode);
}
