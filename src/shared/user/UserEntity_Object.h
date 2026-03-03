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

/** Shared: User Placed/Controlled Primitive

An in-world shape that has been placed down by
a player.

@ingroup userobjects
*/
class
ncUserEntity_Object:ncUserEntity
{
public:
	void ncUserEntity_Object(void);

#ifdef SERVER
	virtual void EvaluateEntity(void);
	virtual float SendEntity(entity ePEnt, float flChanged);
	virtual void Save(float handle);
	virtual void Restore(string keyName, string setValue);

	nonvirtual ncUserEntity_Object Place(ncPlayer videoSharer, string videoName, string videoURL, vector colorMod, float forceScale, vector newMins, vector newMaxs, string gui64, vector a, vector b, float c, vector guiRes);
#endif

#ifdef CLIENT
	virtual void ReceiveEntity(float flNew, float flChanged);
	virtual float predraw(void);
	virtual void RenderScene(void);
#endif

private:
	string m_userPictureURL;
	string m_userPosterName;

#ifdef CLIENT
	entity m_uiPic;
	entity m_uiLabel;
	ncMediaSurface m_guiSurface;
#endif
};
