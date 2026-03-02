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

ncZone
ncZone::CreateZoneWithDescription(vector positionCoord, string zoneDescription)
{
    ncZone newZone = spawn(ncZone);
    newZone.Spawn();

    newZone.SetOrigin(positionCoord);
    newZone.SetSize([-128,-128,-128], [128,128,128]);
  //  newZone.LimitedZoneFromPoint(positionCoord, 128);
    newZone.m_strDescription = zoneDescription;
}

ncZone
ncZone::CreateZoneBoundsWithDescription(vector minBox, vector maxBox, string zoneDescription)
{
    ncZone newZone = spawn(ncZone);
    newZone.Spawn();
    newZone.SetOrigin([0,0,0]);
    newZone.SetSize(minBox, maxBox);
    newZone.m_strDescription = zoneDescription;
}

void
ncZone::SpawnKey(string strKey, string strValue)
{
	switch (strKey) {
    case "message": /* Q3A */
    case "location_name": /* DoD */
	case "areaname": /* TFC */
		m_strDescription = strtoupper(strValue);
		m_strDescription = strreplace("BLUE", "^x99FBLUE^7", m_strDescription);
		m_strDescription = strreplace("RED", "^xF66RED^7", m_strDescription);
		m_strDescription = strreplace("GREEN", "^x4F4GREEN^7", m_strDescription);
		m_strDescription = strreplace("YELLOW", "^xFF4YELLOW^7", m_strDescription);
		break;
	default:
		super::SpawnKey(strKey, strValue);
	}
}

void
ncZone::LimitedZoneFromPoint(vector pointLocation, float limitedSize)
{
    vector newMins = g_vec_null;
    vector newMaxs = g_vec_null;

    SetOrigin(pointLocation);

    traceline(pointLocation, pointLocation + [-limitedSize, 0, 0], MOVE_NORMAL, this);
    newMins[0] = trace_endpos[0];
    traceline(pointLocation, pointLocation + [0, -limitedSize, 0], MOVE_NORMAL, this);
    newMins[1] = trace_endpos[1];
    traceline(pointLocation, pointLocation + [0, 0, -limitedSize], MOVE_NORMAL, this);
    newMins[2] = trace_endpos[2];

    traceline(pointLocation, pointLocation + [limitedSize, 0, 0], MOVE_NORMAL, this);
    newMaxs[0] = trace_endpos[0];
    traceline(pointLocation, pointLocation + [0, limitedSize, 0], MOVE_NORMAL, this);
    newMaxs[1] = trace_endpos[1];
    traceline(pointLocation, pointLocation + [0, 0, limitedSize], MOVE_NORMAL, this);
    newMaxs[2] = trace_endpos[2];

    SetOrigin([0,0,0]);
    SetSize(newMins, newMaxs);
}

void
ncZone::ExpandZoneFromPoint(vector pointLocation)
{
    vector newMins = g_vec_null;
    vector newMaxs = g_vec_null;

    SetOrigin(pointLocation);

    traceline(pointLocation, pointLocation + [-1024, 0, 0], MOVE_NORMAL, this);
    newMins[0] = trace_endpos[0];
    traceline(pointLocation, pointLocation + [0, -1024, 0], MOVE_NORMAL, this);
    newMins[1] = trace_endpos[1];
    traceline(pointLocation, pointLocation + [0, 0, -1024], MOVE_NORMAL, this);
    newMins[2] = trace_endpos[2];

    traceline(pointLocation, pointLocation + [1024, 0, 0], MOVE_NORMAL, this);
    newMaxs[0] = trace_endpos[0];
    traceline(pointLocation, pointLocation + [0, 1024, 0], MOVE_NORMAL, this);
    newMaxs[1] = trace_endpos[1];
    traceline(pointLocation, pointLocation + [0, 0, 1024], MOVE_NORMAL, this);
    newMaxs[2] = trace_endpos[2];

    SetOrigin([0,0,0]);
    SetSize(newMins, newMaxs);
}

void
ncZone::Respawn(void)
{
	super::Respawn();

	/* set up our volume */
	SetSolid(SOLID_TRIGGER);
    vector zoneMins = GetSpawnVector("mins");
    vector zoneMaxs = GetSpawnVector("maxs");

    if ((vlen(zoneMins) < 1) && (vlen(zoneMaxs) < 1))
        ExpandZoneFromPoint(GetSpawnVector("origin"));
    else
        SetSize(zoneMins, zoneMaxs);

	serverinfo.SetBool("areadefs", true);
    classname = "ncZone";
}

void
ncZone::Touch(entity touchingEntity)
{
	if (is.Player(touchingEntity) == false) {
		return;
	}

	userinfo.SetString(touchingEntity, "*areadef", m_strDescription);
}
