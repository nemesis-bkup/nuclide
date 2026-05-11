/*
 * Copyright (c) 2023 Vera Visions LLC.
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

/*! \brief Server-Entity: Takes Level Development Shots */
/*!QUAKED point_devshot_camera (1 .5 0) (-8 -8 -8) (8 8 8)
# OVERVIEW
Takes a screenshot, for development purposes.
Do not use this during actual gameplay.

# KEYS
- "targetname" : Name

# INPUTS
- "TakeScreenshot" : Takes a screenshot.

# NOTES

If there's no client directly activating this entity, it
will currently not take a screenshot.

# TRIVIA

This entity was introduced in Half-Life 2 (2004).

@ingroup serverentity
@ingroup pointentity
*/
class
point_devshot_camera:ncPointTrigger
{
public:
    void point_devshot_camera(void);
    virtual void Spawned(void);
    virtual void Respawn(void);
    
    /* overrides */
    virtual void Input(entity,string,string);
};

void
point_devshot_camera::point_devshot_camera(void)
{

}

void
point_devshot_camera::Spawned(void)
{
    super::Spawned();

    if (HasTargetname() == false) {
        targetname = (sprintf("DevCam_%i", num_for_edict(this)));
    }
}

void
point_devshot_camera::Respawn(void)
{
    SetOrigin(GetSpawnVector("origin"));
    SetAngles(GetSpawnVector("angles"));
}

void
point_devshot_camera::Input(entity eAct, string strInput, string strData)
{
    switch (strInput) {
    case "takescreenshot":
        if (is.Player(eAct)) {
            stuffcmd(eAct, sprintf("screenshot maps/%s/%s;wait;wait;bf\n", mapname, Name()));
        }
        break;
    default:
        super::Input(eAct, strInput, strData);
    }
}
