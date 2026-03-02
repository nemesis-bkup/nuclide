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
ncGameRule_DevShutterbug::ncGameRule_DevShutterbug(void)
{
	m_shotTaken = false;
}

/*
 * Copyright (c) 2016-2024 Vera Visions LLC.
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
ncGameRule_DevShutterbug::LevelDecodeParms(ncPlayer pl)
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
ncGameRule_DevShutterbug::LevelChangeParms(ncPlayer pl)
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
ncGameRule_DevShutterbug::LevelNewParms(void)
{
	parm1 = parm2 = parm3 = parm4 = parm5 = parm6 = parm7 =
	parm8 = parm9 = 0;
	parm18 = 0;
}

void
ncGameRule_DevShutterbug::Save(float handle)
{

}

void
ncGameRule_DevShutterbug::Restore(string strKey, string strValue)
{

}

void
ncGameRule_DevShutterbug::Input(entity eAct, string strInput, string strData)
{
}

void
ncGameRule_DevShutterbug::RestoreComplete(void)
{
	g_grMode = this;
}

void
ncGameRule_DevShutterbug::InitPostEnts(void)
{
	string cycleFile = autocvar(dev_shutterbugFile, "shutterbug.txt");

	/* by default, this will be multiplayer only */
	if (cvars.GetInteger("sv_playerslots") <= 1i) {
		return;
	}

	InitStart();

	/* in case some server admin wants a map to continously loop */
	if (!STRING_SET(cycleFile)) {
		ncLog("MapCycle disabled via cvar. Skipping.");
		localcmd("alias nextmap map_restart 0\n");
		return;
	}

	filestream fs_mapcycle;
	string temp;
	int mapCount = 0i;
	string lastMap = "";
	int nextMapID = 0i;

	fs_mapcycle = fopen(cycleFile, FILE_READ);

	if (fs_mapcycle < 0) {
		ncError("Missing file %s", cycleFile);
		return;
	}

	/* read the lines in, see if the map exists and define an enumerated alias */
	while ((temp = fgets(fs_mapcycle))) {
		tokenize_console(temp);
		string mapName = argv(0);

		if (fileExists(strcat("maps/", mapName, ".bsp")) == false) {
			continue;
		}

		localcmd(sprintf("alias mc_%i \"map %s;alias nextmap mc_%i\"\n", mapCount, mapName, mapCount + 1i));

		if (mapname == lastMap) {
			nextMapID = mapCount;
		}

		lastMap = mapName;
		mapCount++;
	}

	fclose(fs_mapcycle);

	if (mapCount <= 0i) {
		return;
	}

	/* override the last map so that it goes back to m0 */
	localcmd(sprintf("alias mc_%i \"map %s;alias nextmap mc_0\"\n", mapCount - 1i, lastMap));

	/* the current map in the list will decide the nextmap */
	localcmd(sprintf("alias nextmap mc_%i\n", nextMapID));

	ncLog("...MapCycle initialized with %i entries.", mapCount);
}

void
ncGameRule_DevShutterbug::Precache(void)
{
	precache.Entity("spectator");
}

void
ncGameRule_DevShutterbug::PlayerSpawn(ncPlayer pl)
{
	ents.ChangeToClass(pl, "spectator");
	game.TeleportToSpawn(pl);
	IntermissionStart();
	m_shotTaken = false;
}

void
ncGameRule_DevShutterbug::IntermissionEnd(void)
{
	if (!m_iIntermission)
		return;

	if (time < m_flIntermissionTime)
		return;

	if (!(input_buttons & INPUT_PRIMARY))
		return;

	if (m_shotTaken == true) {
		localcmd("nextmap\n");
	} else {
		for (entity entEnum; (entEnum = next.Player(entEnum));) {
			stuffcmd(entEnum, sprintf("screenshot maps/%s;wait;wait;bf\n", mapname));
		}
		m_shotTaken = true;
		printf("Shot %S taken.\n", mapname);
		m_flIntermissionTime = time + 1.0f;
		return;
	}

	m_iIntermission = 0;
	m_flIntermissionTime = -1;
}

void
ncGameRule_DevShutterbug::OnIntermissionCycle(void)
{

}

void
ncGameRule_DevShutterbug::Shutdown(void)
{
}

void
ncGameRule_DevShutterbug::FrameStart(void)
{
	IntermissionCycle();
}

string
ncGameRule_DevShutterbug::Title(void)
{
	return ("shutterbug");
}


bool
ncGameRule_DevShutterbug::ConsoleCommand(ncPlayer pl, string cmd)
{
	return (false);
}

void
ncGameRule_DevShutterbug::EditorCommand_SpawnDef(ncActor spawnerEntity, string spawnDef, string spawnModel, vector endPos, vector endAng)
{
	if (NumActiveGamePlayers() > 0) {
		ncEntity newEnt = ents.Create(spawnDef, endPos);
		newEnt.SetAngles(endAng);
	} else {
		ncUserEntity_GameEntity::Place(spawnerEntity, spawnDef, spawnModel, endPos, endAng);
	}
}

bool
ncGameRule_DevShutterbug::PlayerRequestRespawn(ncPlayer pl)
{
	ents.ChangeToClass(pl, "spectator");
	return (true);
}

int ncGameRule_DevShutterbug::NumActiveGamePlayers(void)
{
	int otherCount = 0;

	for (entity entEnum; (entEnum = next.Player(entEnum));) {
		if (entEnum.movetype != MOVETYPE_NOCLIP) {
			otherCount++;
		}
	}

	return (otherCount);
}

int ncGameRule_DevShutterbug::NumActiveEditors(void)
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
ncGameRule_DevShutterbug::EditorCommand_CheckStart(ncPlayer playerEntity)
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
ncGameRule_DevShutterbug::EditorCommand_CheckEnd(ncPlayer playerEntity)
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
ncGameRule_DevShutterbug::ClientCommand(ncClient pl, string cmd)
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
	default:
		return (false);
	}
	return (true);
}
