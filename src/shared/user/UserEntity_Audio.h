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

/** Shared: User Placed/Controlled Audio Stream

An in-world audio stream that has been placed down by
a player.

It currently relies on the `cef` plugin for FTEQW to be installed.

*/
class
ncUserEntity_Audio:ncUserEntity
{
public:
	void ncUserEntity_Audio(void);

#ifdef SERVER
	virtual void EvaluateEntity(void);
	virtual float SendEntity(entity ePEnt, float flChanged);

	nonvirtual void Place(ncPlayer audioSharer, string audioName, string audioURL, string audioPreview);
#endif

#ifdef CLIENT
	virtual void ReceiveEntity(float flNew, float flChanged);
#endif

private:
	string m_userAudioURL;
	string m_userAudioPic;

#ifdef CLIENT
	entity m_audioPic;
#endif
};
