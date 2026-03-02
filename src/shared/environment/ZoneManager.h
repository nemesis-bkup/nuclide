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

/**

Zone Manager is responsible for managing all zones/locations
in a level.

We support the QW .loc format, and a variant that can be
seen in various HL mods.

`maps/mapname.loc`:

```
0 0 0 Center of Map
0 0 0 "Center of Map"
```

Point definitions, space separated. The last argument can be in quotes.

There's a variant of location files out there popularized by ProQuake **we do not currently support**:

``
-128,-128,-128, 128,128,128, "Center of Map"
```
*/
class
ncZoneManager
{
    nonvirtual void Init(void);
    nonvirtual void Shutdown(void);

    /** Will load from QW and AHL styled loc files */
    nonvirtual void LoadZonesFromLocFile(string fileName);
    nonvirtual void LoadZonesFromHLLocFile(string fileName);
    nonvirtual void LoadZonesFromPQLocFile(string fileName);
    nonvirtual void LoadZonesFromQWLocFile(string fileName);
    nonvirtual void DeleteNearPoint(vector pointLocation);
    nonvirtual void SaveZonesToFile(string fileName);
    nonvirtual void PrintZones(void);
    nonvirtual void DrawDebugInfo(void);
};

#if 0
void
ncZoneManager::ncZoneManager(void)
{

}
#endif
