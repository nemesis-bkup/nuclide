/*
 * Copyright (c) 2023-2025 Vera Visions LLC.
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
ncMapDelegate::ncMapDelegate(void)
{
}

void
ncMapDelegate::Input(entity eAct, string strInput, string strData)
{
}

void
ncMapDelegate::Precache(void)
{
}

void
ncMapDelegate::InitPostEnts(void)
{
}

void
ncMapDelegate::Shutdown(void)
{
}

void
ncMapDelegate::FrameStart(void)
{

}

void
ncMapDelegate::PlayerConnect(ncPlayer pl)
{

}
void
ncMapDelegate::PlayerDisconnect(ncPlayer pl)
{
}

void
ncMapDelegate::NPCDeath(ncActor npc, ncEntity attacker, ncEntity inflictor)
{
}

void
ncMapDelegate::PlayerDeath(ncPlayer deadPlayer, ncEntity inflictor, ncEntity attacker, string weaponDef)
{
}

void
ncMapDelegate::PlayerPain(ncPlayer pl, ncActor attacker, ncDict damageDecl)
{
}

void
ncMapDelegate::PlayerSpawn(ncPlayer pl)
{
}


ncMapDelegate
ncMapDelegate::ActiveInstance(void)
{
	return (g_grMap);
}

void
ncMapDelegate::LinkProgs(void)
{
	ncMapDelegate newRule = spawn(ncMapDelegate);

	if (g_mapCProgs) {
		MAPLINK(newRule, Input, "CodeCallback_Input")
		MAPLINK(newRule, Precache, "CodeCallback_Precache")
		MAPLINK(newRule, FrameStart, "CodeCallback_FrameStart")
		MAPLINK(newRule, PlayerConnect, "CodeCallback_PlayerConnect")
		MAPLINK(newRule, PlayerDisconnect, "CodeCallback_PlayerDisconnect")
		MAPLINK(newRule, PlayerDeath, "CodeCallback_PlayerKilled")
		MAPLINK(newRule, NPCDeath, "CodeCallback_NPCKilled")
		MAPLINK(newRule, PlayerPain, "CodeCallback_PlayerDamage")
		MAPLINK(newRule, PlayerSpawn, "CodeCallback_PlayerSpawn")
	}

	g_grMap = newRule;
}

/* Map specific Scripting, nicknamed 'MapC' after TF2's cancelled system */
var float g_mapCProgs;
void
MapC_Init(void)
{
	string mapProgs;

	/* mapname global is not set yet in init() */
	mapProgs = Util_ChangeExtension(strcat("maps/", cvar_string("mapname")), "dat");

	/* No mapname.dat, exit out */
	if (fileExists(mapProgs) == false) {
		ncLogAlways("Active MapC progs: None for level %s", cvar_string("mapname"));
		return;
	}

	ncLogAlways("Active MapC progs: %S", mapProgs);
	g_mapCProgs = addprogs(mapProgs);

	if (g_mapCProgs > 0) {
		void(void) mainFunction;
		mainFunction = externvalue(g_mapCProgs, "main");

		if (mainFunction) {
			mainFunction();
		} else {
			ncError("%s does not have a main function.", mapProgs);
		}
	}
}

ncEntity
ncMapDelegate::SpawnEntityWithSpawnData(string desiredClass, string spawnData, entity entRef, void() spawnfunc)
{
    bool skipLoad;
	static string lastClass;

    /* give it a copy of its spawndata. */
    ncEntity ent = entRef;
	ent.m_rawSpawnData = spawnData;
	ent.spawnclass = desiredClass; /* EntityDef_ will override this later, needed for saves */

	/* Quake compat: spawnflag filter compatibility */
	if (cvars.GetBool("g_spawnflagFilter") == true) {
		bool discardEntity = false;

		if (serverinfo.GetString("mode") == "deathmatch") {
			if (ent.spawnflags & 2048) {
				discardEntity = true;
			}
		} else if (serverinfo.GetString("mode") == "singleplayer") {
			if (ent.spawnflags & 256 && cvars.GetInteger("skill") == 0i) {
				discardEntity = true;
			} else if (ent.spawnflags & 512 && cvars.GetInteger("skill") == 1i) {
				discardEntity = true;
			} else if (ent.spawnflags & 1024 && cvars.GetInteger("skill") == 2i) {
				discardEntity = true;
			}
		}

		if (discardEntity == true) {
			ncLog("...discarded %s (%d) due to spawnflag rules", ent.classname, num_for_edict(ent));
			remove(ent);
			return (__NULL__);
		}
	}

	/* no longer needed, immediately discard. */
	__fullspawndata = "";
	g_ents_initialized = false;

	/* we have to diverge here in order to support in-code class entities,
	   decl entities and overrides of both.

	   this switch also controls the priority:

	   1. maptweaks, can override anything.
	   2. entitydef, can even override built-in class names
	      2.0 entitydef, defined in a map (maps/foobar.def)
		  2.1 entitydef, defined within decls/def/X.def
	   3. in-code classes */
	if (MapTweak_EntitySpawn(ent) == true) {
		skipLoad = true;
	} else if (EntityDef_SwitchClass(ent, desiredClass) != __NULL__) {
		skipLoad = true;
	} else if (spawnfunc) {
		CallFunctionAsEntity(ent, spawnfunc);
		ent.classname = desiredClass;
	} else {
		ent.identity = 0;
	}
	g_ents_initialized = true;

	/* check if this entity was meant to spawn on the client-side only */
	if (ent.identity) {
		if (ent.CanSpawn(false) == false) {
			ent.Destroy();
		}
	} else {
		/* don't need to spam repetitive messages */
		if (lastClass != desiredClass) {
			ncError("Unimplemented entity class %S.", desiredClass);
		}

		lastClass = desiredClass;
		remove(ent);
		return (__NULL__);
	}

	ent._mapspawned = true;
	ent._loading = true;

	if (skipLoad == false) {
		/* this entity is good, attempt to spawn it. */
		if (STRING_SET(ent.m_rawSpawnData)) {
			for (int i = 1; i < (tokenize(ent.m_rawSpawnData) - 1); i += 2) {
				ent.SpawnKey(argv(i), argv(i+1));
			}
		}

		if (STRING_SET(ent.m_gameModeFilter)) {
			if (ent.m_gameModeFilter != g_ruleCName) {
				ent._loading = false;

				if (ent.identity) {
					ent.ScheduleThink(ent.Destroy, 0.0f);
				} else {
					remove(ent);
				}
				return (__NULL__);
			}
		}

		ent._loading = false;
		g_ents_initialized = false;
		ent.Spawn();
		g_ents_initialized = true;
	}

	/* count and mark as map spawned */
	g_mapSpawnEntityCount++;
    return (ent);
}

bool
ncMapDelegate::RestoreEntitiesFromFile( string fileName )
{
	filestream addEntitiesFileStream;
	string temp;
	int c = 0;
	int mp = 0;
	bool isBraced = false;
	string desiredClass = __NULL__;
	string constructedSpawnData = __NULL__;

	addEntitiesFileStream = fopen(fileName, FILE_READ);

	if (addEntitiesFileStream < 0) {
		ncWarning("Can't append entities from %S", fileName);
		return (false);
	}

	while ((temp = fgets(addEntitiesFileStream))) {
		c = tokenize_console(temp);

		switch(argv(0)) {
		case "{":
			isBraced = true;
			constructedSpawnData = "{\n";
			break;
		case "}":
			/* skip broken syntax */
			if (isBraced == false) {
				break;
			}
			if (STRING_SET(desiredClass)) {
				constructedSpawnData = sprintf("%s}", constructedSpawnData);
				void(void) spawnFunc = externvalue(-1, sprintf("spawnfunc_%s", desiredClass));

				if (!spawnFunc) {
					spawnFunc = externvalue(-1, desiredClass);
				}

				ncEntity newEntity = spawn(ncEntity);
				SpawnEntityWithSpawnData(desiredClass, "", newEntity, spawnFunc);

				if (STRING_SET(constructedSpawnData)) {
					for (int i = 1; i < (tokenize(constructedSpawnData) - 1); i += 2) {
						newEntity.Restore(argv(i), argv(i+1));
					}
				}

                if (newEntity) {
                    ncLog("imported %s as edict %d @ %v, %v", newEntity.classname, num_for_edict(newEntity), newEntity.origin, newEntity.angles);
                } else {
                    ncWarning("failed to import %s", desiredClass);
                }

				constructedSpawnData = "";
				desiredClass = "";
				isBraced = false;
			}
			break;
		case "classname":
			if (isBraced == true) {
				desiredClass = argv(1);
			}
			break;
		default:
			if (isBraced == true) {
				/* append string entry after another */
				constructedSpawnData = sprintf("%s%s\n", constructedSpawnData, temp);
			}
		}
	}

	fclose(addEntitiesFileStream);
	return (true);
}

bool
ncMapDelegate::AppendEntitiesFromFile( string fileName )
{
	filestream addEntitiesFileStream;
	string temp;
	int c = 0;
	int mp = 0;
	bool isBraced = false;
	string desiredClass = __NULL__;
	string constructedSpawnData = __NULL__;

	addEntitiesFileStream = fopen(fileName, FILE_READ);

	if (addEntitiesFileStream < 0) {
		ncWarning("Can't append entities from %S", fileName);
		return (false);
	}

	while ((temp = fgets(addEntitiesFileStream))) {
		c = tokenize_console(temp);
		
		switch(argv(0)) {
		case "{":
			isBraced = true;
			constructedSpawnData = "{\n";
			break;
		case "}":
			/* skip broken syntax */
			if (isBraced == false) {
				break;
			}
			if (STRING_SET(desiredClass)) {
				constructedSpawnData = sprintf("%s}", constructedSpawnData);
				void(void) spawnFunc = externvalue(-1, sprintf("spawnfunc_%s", desiredClass));

				if (!spawnFunc) {
					spawnFunc = externvalue(-1, desiredClass);
				}

				ncEntity newEntity = spawn(ncEntity);
				SpawnEntityWithSpawnData(desiredClass, constructedSpawnData, newEntity, spawnFunc);

                if (newEntity) {
                    ncLog("imported %s as edict %d @ %v, %v", newEntity.classname, num_for_edict(newEntity), newEntity.origin, newEntity.angles);
                } else {
                    ncWarning("failed to import %s", desiredClass);
                }

				constructedSpawnData = "";
				desiredClass = "";
				isBraced = false;
			}
			break;
		case "classname":
			if (isBraced == true) {
				desiredClass = argv(1);
			}
			break;
		default:
			if (isBraced == true) {
				/* append string entry after another */
				constructedSpawnData = sprintf("%s%s\n", constructedSpawnData, temp);
			}
		}
	}

	fclose(addEntitiesFileStream);
	return (true);
}

void
ncMapDelegate::InitialRespawn(void)
{
	/* append entities from external .add file */
	string appendEntitiesFile = strcat("maps/", mapname, ".add");

	if (fileExists(appendEntitiesFile)) {
		ncLog("Loading extra entities for %s from %S", mapname, appendEntitiesFile);
		ncMapDelegate::AppendEntitiesFromFile(appendEntitiesFile);
	} else {
		ncLog("No entity additions exist for %s under %S", mapname, appendEntitiesFile);
	}
}
