/*
 * Copyright (c) 2022 Marco Cawthorne <marco@icculus.org>
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

/*QUAKED ncZone (0 0 0.8) (-16 -16 -36) (16 16 36)

Describes an area's bounds and description/name.

# KEYS
"targetname" : Name
"areaname"   : Name of the specified area
"mins"       : Mins of the area's bounding box
"maxs"       : Maxs of the area's bounding box
*/
class
ncZone:ncPointTrigger
{
public:
    void ncZone(void);

    nonvirtual ncZone CreateZoneBoundsWithDescription(vector minBox, vector maxBox, string zoneDescription);
    nonvirtual ncZone CreateZoneWithDescription(vector positionCoord, string zoneDescription);
    nonvirtual void ExpandZoneFromPoint(vector pointPosition);
    nonvirtual void LimitedZoneFromPoint(vector pointLocation, float limitedSize);

    /* overrides */
    virtual void Respawn(void);
    virtual void SpawnKey(string,string);
    virtual void Touch(entity);

private:
    string m_strDescription;
};

void
ncZone::ncZone(void)
{
    m_strDescription = __NULL__;
}
