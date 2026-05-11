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

var string autocvar_editor_playerClass = "player_mp";

void
ncGameRule_Editor::ncGameRule_Editor(void)
{
}

void
ncGameRule_Editor::LevelDecodeParms(ncPlayer pl)
{
    g_landmarkpos[0] = parm1;
    g_landmarkpos[1] = parm2;
    g_landmarkpos[2] = parm3;
    pl.angles[0] = parm4;
    pl.angles[1] = parm5;
    pl.angles[2] = parm6;
    pl.velocity[0] = parm7;
    pl.velocity[1] = parm8;
    pl.velocity[2] = parm9;
    pl.flags = parm18;
}

void
ncGameRule_Editor::LevelChangeParms(ncPlayer pl)
{
    parm1 = g_landmarkpos[0];
    parm2 = g_landmarkpos[1];
    parm3 = g_landmarkpos[2];
    parm4 = pl.angles[0];
    parm5 = pl.angles[1];
    parm6 = pl.angles[2];
    parm7 = pl.velocity[0];
    parm8 = pl.velocity[1];
    parm9 = pl.velocity[2];
    parm18 = pl.flags;
}

void
ncGameRule_Editor::LevelNewParms(void)
{
    parm1 = parm2 = parm3 = parm4 = parm5 = parm6 = parm7 =
    parm8 = parm9 = 0;
    parm18 = 0;
}

void
ncGameRule_Editor::Save(float handle)
{

}

void
ncGameRule_Editor::Restore(string strKey, string strValue)
{

}

void
ncGameRule_Editor::Input(entity eAct, string strInput, string strData)
{
}

void
ncGameRule_Editor::RestoreComplete(void)
{
    g_grMode = this;
}

void
ncGameRule_Editor::InitPostEnts(void)
{
}

void
ncGameRule_Editor::Precache(void)
{
    precache.Entity("spectator");
}

void
ncGameRule_Editor::PlayerSpawn(ncPlayer pl)
{
    ents.ChangeToClass(pl, "spectator");
    game.TeleportToSpawn(pl);
}

void
ncGameRule_Editor::Shutdown(void)
{
}

void
ncGameRule_Editor::FrameStart(void)
{

}

string
ncGameRule_Editor::Title(void)
{
    return ("editor");
}


bool
ncGameRule_Editor::ConsoleCommand(ncPlayer pl, string cmd)
{
    return (false);
}

void
ncGameRule_Editor::EditorCommand_SpawnDef(ncActor spawnerEntity, string spawnDef, string spawnModel, vector endPos, vector endAng)
{
    if (NumActiveGamePlayers() > 0) {
        ncEntity newEnt = ents.Create(spawnDef, endPos);
        newEnt.SetAngles(endAng);
    } else {
        ncUserEntity_GameEntity::Place(spawnerEntity, spawnDef, spawnModel, endPos, endAng);
    }
}

bool
ncGameRule_Editor::PlayerRequestRespawn(ncPlayer pl)
{
    ents.ChangeToClass(pl, "spectator");
    return (true);
}

int ncGameRule_Editor::NumActiveGamePlayers(void)
{
    int otherCount = 0;

    for (entity entEnum; (entEnum = next.Player(entEnum));) {
        if (entEnum.movetype != MOVETYPE_NOCLIP) {
            otherCount++;
        }
    }

    return (otherCount);
}

int ncGameRule_Editor::NumActiveEditors(void)
{
    int spectatorCount = 0;

    for (entity entEnum; (entEnum = next.Player(entEnum));) {
        if (entEnum.movetype == MOVETYPE_NOCLIP) {
            spectatorCount++;
        }
    }

    return (spectatorCount);
}

void
ncGameRule_Editor::EditorCommand_CheckStart(ncPlayer playerEntity)
{
    /* session is already active. do not create a new one. */
    if (m_sessionCreator) {
        return;
    }

    /* create a new session */
    m_sessionCreator = playerEntity;
    ncUserEntity_GameEntity::InstatiateEntitiesByPlayer(playerEntity);
}
void
ncGameRule_Editor::EditorCommand_CheckEnd(ncPlayer playerEntity)
{
    int spectatorCount = 0;
    int otherCount = 0;

    for (entity entEnum; (entEnum = next.Player(entEnum));) {
        if (entEnum.movetype == MOVETYPE_NOCLIP) {
            spectatorCount++;
        } else {
            otherCount++;
        }
    }

    /* remove anything temporary or user instantiated */
    if (otherCount != 0) {
        return;
    }

    /* terminate session */
    game.CleanUpMap();
    ncUserEntity_GameEntity::DeinstatiateEntitiesByPlayer(playerEntity);
    m_sessionCreator = __NULL__;
}

bool
ncGameRule_Editor::ClientCommand(ncClient pl, string cmd)
{
    tokenize(cmd);
    switch (argv(0)) {
    case "switchToGame":
        ents.ChangeToClass(pl, autocvar_editor_playerClass);
        EditorCommand_CheckStart(pl);
        break;
    case "switchToEditor":
        pl.modelindex = 0;
        ents.ChangeToClass(pl, "spectator");
        EditorCommand_CheckEnd(pl);
        break;
    case "changePlayerClass":
        cvar_set("editor_playerClass", argv(1));
        break;
    case "cleanMap":
        game.CleanUpMap();
        break;
    case "shareEntity":
        EditorCommand_SpawnDef(pl, argv(1), argv(2), stov(argv(3)), stov(argv(4)));
        break;
    case "beginEntity":
        if (m_lastEntity) {
                ncError("Already building an entity.");
                return;
        }

        string entityClass = argv(1);
        m_lastEntity = ents.Create(entityClass, pl.origin);
        ncWarning("Starting new entity", entityClass);
        m_lastEntity.m_rawSpawnData = "{";
        break;
    case "buildEntity":
        if (!m_lastEntity) {
                ncError("No entity is being built");
                return;
        }

        string keyName = argv(1);
        string setValue = argv(2);
        m_lastEntity.SpawnKey(keyName, setValue);
        m_lastEntity.m_rawSpawnData = sprintf("%s %S %S", m_lastEntity.m_rawSpawnData, keyName, setValue);
        ncWarning("Inserting %s %s", keyName, setValue);
        break;
    case "finalizeEntity":
        if (!m_lastEntity) {
                ncError("No entity is being built");
                return;
        }

        m_lastEntity.m_rawSpawnData = sprintf("%s }", m_lastEntity.m_rawSpawnData);
        m_lastEntity.Respawn();
       // m_lastEntity.SetOrigin(stov(argv(1)));
        //m_lastEntity.SetAngles(stov(argv(2)));
        m_lastEntity.SetOrigin(pl.origin);
        m_lastEntity = 0;
        break;
    case "zoneAdd":
        ncZone::CreateZoneWithDescription(pl.GetOrigin(), argv(1));
        break;
    case "zoneDelete":
        ncZoneManager::DeleteNearPoint(pl.GetOrigin());
        break;
    default:
        return (false);
    }
    return (true);
}
