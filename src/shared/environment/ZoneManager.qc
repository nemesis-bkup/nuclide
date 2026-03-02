/*
 * Copyright (c) 2026 Marco Cawthorne <marco@icculus.org>
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
ncZoneManager::Init(void)
{
    LoadZonesFromHLLocFile(sprintf("maps/%s.loc", mapname));
    LoadZonesFromQWLocFile(sprintf("locs/%s.loc", mapname));
}

void
ncZoneManager::Shutdown(void)
{

}

void
ncZoneManager::LoadZonesFromLocFile(string fileName)
{

}

void
ncZoneManager::LoadZonesFromHLLocFile(string fileName)
{
	filestream locFile;
	string line;
	int zonesCount = 0i;

	locFile = fopen(fileName, FILE_READ);

	if (locFile < 0) {
		ncError("failed to load %S for reading!", fileName);
		return;
	}

	/* count surfaceproperty definitions */
	while ((line = fgets(locFile))) {
        ncZone lineResult = __NULL__;
        vector positionCoord = g_vec_null;
		string zoneDescription = g_string_null;
		int segments = tokenize(line);
        positionCoord[0] = stof(argv(0));
        positionCoord[1] = stof(argv(1));
        positionCoord[2] = stof(argv(2));

		if (segments == 4) { /* X Y Z "Description" */
            zoneDescription = argv(3);
            lineResult = ncZone::CreateZoneWithDescription(positionCoord, zoneDescription);
		} else { /* X Y Z Description That's Only Terminated By Newline */
            int thirdSpace = -1;
            int stringLength = strlen(line);
            int counter;

            for (int i = 0; i < stringLength; i++) {
                if (substring(line, i, 1) == " ") {
                    counter++;

                    /* third space */
                    if (counter == 3) {
                        thirdSpace = i;
                        break;
                    }
                }
            }

            zoneDescription = substring(line, thirdSpace, -1);
            lineResult = ncZone::CreateZoneWithDescription(positionCoord, zoneDescription);
		}

		if (lineResult) {
            zonesCount++;
		}
	}

	ncLogAlways("... %i zones read from loc file %S", zonesCount, fileName);
	fclose(locFile);
}


void
ncZoneManager::LoadZonesFromQWLocFile(string fileName)
{
	filestream locFile;
	string line;
	int zonesCount = 0i;

	locFile = fopen(fileName, FILE_READ);

	if (locFile < 0) {
		ncError("failed to load %S for reading!", fileName);
		return;
	}

	/* count surfaceproperty definitions */
	while ((line = fgets(locFile))) {
        ncZone lineResult = __NULL__;
        vector positionCoord = g_vec_null;
		string zoneDescription = g_string_null;
		int segments = tokenize(line);
        positionCoord[0] = stof(argv(0)) / 8.0;
        positionCoord[1] = stof(argv(1)) / 8.0;
        positionCoord[2] = stof(argv(2)) / 8.0;

        float thirdSpace = -1;
        float stringLength = strlen(line);
        int counter = 0i;

        for (float i = 0; i < stringLength; i++) {
            if (substring(line, i, 1) == " ") {
                counter++;

                /* third space */
                if (counter == 3i) {
                    thirdSpace = i;
                    break;
                }
            }
        }

        zoneDescription = substring(line, thirdSpace + 1, -1);
        lineResult = ncZone::CreateZoneWithDescription(positionCoord, zoneDescription);

		if (lineResult) {
            zonesCount++;
		}
	}

	ncLogAlways("... %i zones read from loc file %S", zonesCount, fileName);
	fclose(locFile);
}


void
ncZoneManager::LoadZonesFromPQLocFile(string fileName)
{
	filestream locFile;
	string line;
	int zonesCount = 0i;

	locFile = fopen(fileName, FILE_READ);

	if (locFile < 0) {
		ncError("failed to load %S for reading!", fileName);
		return;
	}

	/* count surfaceproperty definitions */
	while ((line = fgets(locFile))) {
        ncZone lineResult = __NULL__;
        vector minBox = g_vec_null;
        vector maxBox = g_vec_null;
		string zoneDescription = g_string_null;
		int segments = tokenizebyseparator(line, ",");
        minBox[0] = stof(argv(0));
        minBox[1] = stof(argv(1));
        minBox[2] = stof(argv(2));
        maxBox[0] = stof(argv(3));
        maxBox[1] = stof(argv(4));
        maxBox[2] = stof(argv(5));
        tokenize_console(argv(6));
        zoneDescription = argv(0);

        lineResult = ncZone::CreateZoneBoundsWithDescription(minBox, maxBox, zoneDescription);

		if (lineResult) {
            zonesCount++;
		}
	}

	ncLogAlways("... %i zones read from loc file %S", zonesCount, fileName);
	fclose(locFile);
}

void
ncZoneManager::SaveZonesToFile(string fileName)
{
	filestream locFile;
	string line;
	int zonesCount = 0i;

	locFile = fopen(fileName, FILE_WRITE);

	if (locFile < 0) {
		ncError("failed to load %S for writing!", fileName);
		return;
	}

    for (ncZone vars = __NULL__;(vars = (ncZone)find(vars, ::classname, "ncZone"));) {
        line = sprintf("%d %d %d %S\n", vars.origin[0], vars.origin[1], vars.origin[2], vars.m_strDescription);
		fputs(locFile, line);
		zonesCount++;
	}

	ncLogAlways("... %i zones written to loc file %S", zonesCount, fileName);
	fclose(locFile);
}

void
ncZoneManager::DeleteNearPoint(vector pointLocation)
{
    float closestDist = 99999;
    ncZone closestZone = __NULL__;

    for (ncZone vars = __NULL__;(vars = (ncZone)find(vars, ::classname, "ncZone"));) {
        float zoneDist = distance(pointLocation, vars.WorldSpaceCenter());

        if (zoneDist < closestDist) {
            closestDist = zoneDist;
            closestZone = vars;
        }
	}

	if (closestZone) {
        closestZone.Destroy();
    }
}

void
ncZoneManager::PrintZones(void)
{
	int zonesCount = 0i;

    for (ncZone vars = __NULL__;(vars = (ncZone)find(vars, ::classname, "ncZone"));) {
        ncLogAlways("%i: (%d %d %d) %S (%v) (%v)", zonesCount + 1i, vars.origin[0], vars.origin[1], vars.origin[2], vars.m_strDescription, vars.mins, vars.maxs);
		zonesCount++;
	}

	ncLogAlways("... %i zones in total", zonesCount);
}


void
ncZoneManager::DrawDebugInfo(void)
{
    for (ncZone vars = __NULL__;(vars = (ncZone)find(vars, ::classname, "ncZone"));) {
      	makevectors(self.v_angle);
      	vector v1 = vars.WorldSpaceCenter();
		R_BeginPolygon("textures/dev/model_bone", 0, 0);
		R_PolygonVertex(v1 + v_right * 16 - v_up * 16, [1,1], [1,1,1], 1.0f);
		R_PolygonVertex(v1 - v_right * 16 - v_up * 16, [0,1], [1,1,1], 1.0f);
		R_PolygonVertex(v1 - v_right * 16 + v_up * 16, [0,0], [1,1,1], 1.0f);
		R_PolygonVertex(v1 + v_right * 16 + v_up * 16, [1,0], [1,1,1],1.0f);
		R_EndPolygon();
	}


}
