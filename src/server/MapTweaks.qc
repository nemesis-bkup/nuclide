/*
 * Copyright (c) 2016-2022 Vera Visions LLC.
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

/* early maptweaks implementation (RFC)

    design notes:

    needed system that handles entity renaming
    or edits in an easy to understand syntax

    replaces .ent file overrides for a lot of tasks
    and can apply rules on all relevant maps based on
    custom filters, either via serverinfo or via cvar.

# CVars

- "g_maptweaks" : Default is `scripts/maptweaks.txt`.

# Notes
    TODO: immediately throw out things where cvar/infokey
    checks fail and don't even cache them.

    Actually, what if someone wants to prod them on/off?
*/

static mapTweak_t *g_mapTweakTable;
static int g_mapTweakCount;
const string g_maptweakFile = "scripts/maptweaks.txt";
var string autocvar_g_maptweaks = g_maptweakFile;

static bool
MapTweaks_MatchInSpawnData(ncEntity targetEnt, string keyName, string valueMatch)
{
    for (int i = 1; i < (tokenize_console(targetEnt.m_rawSpawnData) - 1); i+= 2) {
        string testKey = argv(i);
        string testValue = argv(i+1);

        /* ignore this, always */
        if (keyName == testKey) {
            if (testValue == valueMatch) {
                return (true);
            }
        }
    }

    return (false);
}

void
ncMapTweakManager::Init(void)
{
    filestream tweakFile;
    string tempString;
    string newCvar, newInfo, newItem, newName, newSpawnKey, newAppend;
    int atTweak = 0i;

    InitStart();

    tweakFile = fopen(autocvar_g_maptweaks, FILE_READ);
    g_mapTweakCount = 0;
    newAppend = newSpawnKey = tempString = newCvar = newInfo = newItem = newName = "";

    /* count valid entries. */
    if (tweakFile >= 0) {
        while ((tempString = fgets(tweakFile))) {
            if (tokenize_console(tempString) == 1) {
                if (argv(0) == "}")
                    g_mapTweakCount += 1;
            }
        }
    } else {
        ncWarning("No map tweaks, missing %S", g_maptweakFile);
        InitEnd();
        return;
    }

    g_mapTweakTable = memalloc(sizeof(mapTweak_t) * g_mapTweakCount);
    fseek(tweakFile, 0);

    while ((tempString = fgets(tweakFile))) {
        int segments = tokenize_console(tempString);
        if (segments == 1) {
            if (argv(0) == "}") {
                g_mapTweakTable[atTweak].name = newName;
                g_mapTweakTable[atTweak].cvarCheck = newCvar;
                g_mapTweakTable[atTweak].serverinfoCheck = newInfo;
                g_mapTweakTable[atTweak].itemTable = newItem;
                g_mapTweakTable[atTweak].spawnDataCheck = newSpawnKey;
                g_mapTweakTable[atTweak].appendTable = newAppend;
                newAppend = newSpawnKey = newName = newCvar = newInfo = newItem = "";
                atTweak++;
            } else if (argv(0) == "{") {
                /* ??? */
            } else {
                newName = argv(0);
            }
        } else if (segments == 5) {
            switch (argv(0)) {
            case "append":
                newAppend = strcat(newAppend, argv(1), " ", argv(2), " \'", argv(3), "\' \'", argv(4), "\' ");
                break;
            }
        }  else if (segments == 4) {
            switch (argv(0)) {
            case "when-cvar":
                newCvar = strcat(newCvar, argv(1), " ", argv(2), " ", argv(3), " ");
                break;
            case "when-serverinfo":
                newInfo = strcat(newInfo, argv(1), " ", argv(2), " ", argv(3), " ");
                break;
            }
        } else if (segments == 3) {
            switch (argv(0)) {
            case "replace":
                newItem = strcat(newItem, argv(1), " ", argv(2), " ");
                break;
            case "when-spawnkey":
                newSpawnKey = strcat(newSpawnKey, argv(1), " ", argv(2), " ");
                break;
            }
        }
    }

    fclose(tweakFile);
    InitEnd();
}

static bool
MapTweak_Check(ncEntity targetEnt, int num)
{
    int segments = tokenize(g_mapTweakTable[num].cvarCheck);

    /* cvars first */
    for (int i = 0; i < segments; i += 3) {
        string cvarName = argv(i);
        string checkType = argv(i + 1);
        float cvarValue = stof(argv(i + 2));

        switch (checkType) {
        case "equals":
            if not (cvar(cvarName) == cvarValue)
                return (false);
            break;
        case "less-than":
            if not (cvar(cvarName) < cvarValue)
                return (false);
            break;
        case "greater-than":
            if not (cvar(cvarName) > cvarValue)
                return (false);
            break;
        case "is-not":
            if not (cvar(cvarName) != cvarValue)
                return (false);
            break;
        }
    }

    segments = tokenize(g_mapTweakTable[num].serverinfoCheck);

    /* infokeys second */
    for (int i = 0; i < segments; i += 3) {
        string infoName = argv(i);
        string checkType = argv(i + 1);
        string infoValueString = argv(i + 2);
        float infoValue = stof(infoValueString);

        switch (checkType) {
        case "equals":
            if not (serverkey(infoName) == infoValueString)
                return (false);
            break;
        case "less-than":
            if not (serverkeyfloat(infoName) < infoValue)
                return (false);
            break;
        case "greater-than":
            if not (serverkeyfloat(infoName) > infoValue)
                return (false);
            break;
        case "is-not":
            if not (serverkeyfloat(infoName) != infoValue)
                return (false);
            break;
        }
    }

    /* no key/value pair checks? allow by this point */
    if (!STRING_SET(g_mapTweakTable[num].spawnDataCheck)) {
        return (true);
    }

    /* anything with key/value checks NEEDS a valid target entity */
    if (targetEnt == __NULL__) {
        return (false);
    }

    segments = tokenize(g_mapTweakTable[num].spawnDataCheck);

    /* infokeys second */
    for (int i = 0; i < segments; i += 2) {
        string keyName = argv(i);
        string valueCheck = argv(i + 1);

        if not (MapTweaks_MatchInSpawnData(targetEnt, keyName, valueCheck)) {
            return (false);
        }
    }

    return (true);
}

static bool
MapTweak_FinishSpawn(entity targetEntity, string newClassname)
{
    /* found the edef alternative. */
    if (EntityDef_SwitchClass((ncEntity)targetEntity, newClassname) != __NULL__) {
        return (true);
    }

    return (false);
}

bool
ncMapTweakManager::EntitySpawn(entity targetEntity)
{
    string classCheck = targetEntity.classname;
    bool returnValue = false;

    if (g_mapTweakCount <= 0) {
        return (false);
    }

    for (int i = 0; i < g_mapTweakCount; i++) {
        bool checkEligibility = MapTweak_Check(targetEntity, i);

        /* replace entities */
        for (int y = 0; y < tokenize(g_mapTweakTable[i].itemTable); y += 2) {
            string newEnt, oldEnt;

            oldEnt = argv(y);
            newEnt = argv(y + 1);

            if (classCheck == oldEnt) {
                if (checkEligibility == true) {
                    returnValue = MapTweak_FinishSpawn(targetEntity, newEnt);
                } else {
                    break;
                }
            }
        }

        if (!targetEntity) {
            break;
        }

        /* add entities to the map */
        if (checkEligibility) {
            if (STRING_SET(g_mapTweakTable[i].appendTable)) {
                targetEntity.targetname = sprintf("%s_%d", targetEntity.classname, num_for_edict(targetEntity));
            }
        }

        for (int y = 0; y < tokenize(g_mapTweakTable[i].appendTable); y += 4) {
            string newEnt, oldEnt;
            vector addOrg, addAng;

            oldEnt = argv(y);
            newEnt = argv(y + 1);
            addOrg = stov(argv(y + 2));
            addAng = stov(argv(y + 3));

            if (classCheck == oldEnt) {
                if (MapTweak_Check(targetEntity, i) == true) {
                    void(void) spawnFunc = externvalue(-1, sprintf("spawnfunc_%s", newEnt));

                    if (!spawnFunc) {
                        spawnFunc = externvalue(-1, newEnt);
                    }
                    ncEntity addEntity = spawn(ncEntity);
                    vector newOrg, newAng, originOffset;
                    makevectors(targetEntity.angles);
                    originOffset = (v_forward * addOrg[0]);
                    originOffset += (v_right * addOrg[1]);
                    originOffset += (v_up * addOrg[2]);
                    newOrg = targetEntity.origin + originOffset;
                    newAng = targetEntity.angles + addAng;
                    addEntity = (ncEntity)ncMapDelegate::SpawnEntityWithSpawnData(newEnt, sprintf("{\n%S %S\n%S \"%v\"\n%S \"%v\"\n}", "input", targetEntity.targetname, "origin", newOrg, "angles", newAng), addEntity, spawnFunc);
                }
            }
        }
    }

    return (returnValue);
}

void
ncMapTweakManager::ListActive(void)
{
    for (int i = 0; i < g_mapTweakCount; i++) {
        if (MapTweak_Check(__NULL__, i) == true) {
            printf("%i %S:\n", i, g_mapTweakTable[i].name);

            for (int y = 0; y < tokenize(g_mapTweakTable[i].itemTable); y += 2) {
                string newEnt, oldEnt;

                oldEnt = argv(y);
                newEnt = argv(y + 1);

                printf("\t%s > %s\n", oldEnt, newEnt);
            }
        }
    }
}
