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

/** Shared: User Placed/Controlled Picture

An in-world picture that has been placed down by
a player.

Can be a local or remote image source.

@ingroup userobjects
*/
class
ncUserEntity_Picture:ncUserEntity
{
public:
    void ncUserEntity_Picture(void);

#ifdef SERVER
    virtual void Save(float handle);
    virtual void Restore(string, string);
    virtual void EvaluateEntity(void);
    virtual float SendEntity(entity ePEnt, float flChanged);

    nonvirtual void Place(ncPlayer videoSharer, string videoName, string videoURL, vector realSize, string optionalDescription);
    nonvirtual void PlaceAtPositionWithSize(ncPlayer pictureSharer, string pictureName, string pictureURL, vector worldPos, vector eulerAngle, vector realSize);
#endif

#ifdef CLIENT
    virtual void ReceiveEntity(float flNew, float flChanged);
    virtual void ReloadVideoResources(void);
    virtual float predraw(void);
    virtual void RenderScene(void);
#endif

private:
    string m_userPictureURL;
    string m_userPosterName;
    string m_userPosterTitle;

#ifdef CLIENT
    entity m_uiPic;
    entity m_uiLabel;
#endif
};
