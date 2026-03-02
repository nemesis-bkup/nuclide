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

/** Shared: User Placed/Controlled Video

An in-world video stream that has been placed down by
a player.

For remote video sources, it currently relies on the `ffmpeg` plugin for FTEQW to be installed.
Local videos work fine, as long as they're in the RoQ format.

*/
class
ncUserEntity_Video:ncUserEntity
{
public:
	void ncUserEntity_Video(void);

#ifdef SERVER
	virtual void Spawned(void);
	virtual void EvaluateEntity(void);
	virtual float SendEntity(entity ePEnt, float flChanged);

	nonvirtual void Stop(void);

	nonvirtual void Place(ncPlayer videoSharer, string videoName, string videoTitle, string videoPreview, string videoURL, string audioURL);
#endif

#ifdef CLIENT
	virtual void ReceiveEntity(float flNew, float flChanged);
#endif

private:
	string m_userVideoTitle;
	string m_userVideoName;
	string m_userVideoPreview;
	string m_userVideoURL;
	string m_userVideoAudio;

#ifdef CLIENT
	entity m_videoPic;
	entity m_videoLabel;
#endif
};
