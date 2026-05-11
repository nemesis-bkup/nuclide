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

var string autocvar_home_playerClass = "player_home_qw";

void
ncGameRule_Home::ncGameRule_Home(void)
{
}

void
ncGameRule_Home::LevelDecodeParms(ncPlayer pl)
{
}

void
ncGameRule_Home::LevelChangeParms(ncPlayer pl)
{
}

void
ncGameRule_Home::LevelNewParms(void)
{
}

void
ncGameRule_Home::Save(float handle)
{

}

void
ncGameRule_Home::Restore(string strKey, string strValue)
{

}

void
ncGameRule_Home::Input(entity eAct, string strInput, string strData)
{
}

void
ncGameRule_Home::RestoreComplete(void)
{
    g_grMode = this;
}

void
ncGameRule_Home::InitPostEnts(void)
{
    super::InitPostEnts();
}

void
ncGameRule_Home::Precache(void)
{
    precache.Entity( "player_home_hl");
    precache.Entity( "player_home_qw");
}

void
ncGameRule_Home::PlayerSpawn(ncPlayer pl)
{
    string homeLocation = userinfo.GetString(pl, "home_org");
    vector homeAngle = userinfo.GetVector(pl, "home_ang");
    string playerModel = userinfo.GetString(pl, "model");

    if (STRING_SET(playerModel)) {
        ents.ChangeToClass(pl, "player_home_hl");
        playerModel = sprintf("models/player/%s/%s.mdl", playerModel, playerModel);

        /* fallback is always models/player.mdl for Half-Life */
        if (playerModel == "" || exists.InVFS(playerModel) == false) {
            playerModel = "progs/player.mdl";
        }

        pl.modelindex = getmodelindex(playerModel); /* keep OG size */
    } else {
        ents.ChangeToClass(pl, "player_home_qw");
    }

    if (!STRING_SET(homeLocation)) {
        game.TeleportToSpawn(pl);
    } else {
        setorigin(pl, stov(homeLocation));
    }

    pl.SetAngles(homeAngle);
    Client_FixAngle(pl, pl.GetAngles());
}

void
ncGameRule_Home::Shutdown(void)
{
}

void
ncGameRule_Home::FrameStart(void)
{

}

string
ncGameRule_Home::Title(void)
{
    return ("home");
}


void
ncGameRule_Home::ChatMessageAll(ncClient cl, string strMessage)
{
    float edictNum = num_for_edict(cl) - 1;
    float chatDistance = 512.0f;
    int reachedClients = 0i;


    for (entity a = world; (a = next.Player(a));) {
        /* not one of us! */
        if (distance(cl.origin, a.origin) > chatDistance) {
            continue;
        }

        if (cl != a) {
            reachedClients++;
        }
    }

    /* single handedly pick out team members */
    for (entity a = world; (a = next.Player(a));) {
        /* not one of us! */
        if (distance(cl.origin, a.origin) > chatDistance) {
            continue;
        }

        WriteByte(MSG_MULTICAST, SVC_CGAMEPACKET);
        WriteByte(MSG_MULTICAST, EV_CHAT_LOCAL);
        WriteByte(MSG_MULTICAST, edictNum);
        WriteByte(MSG_MULTICAST, cl.team);
        WriteInt(MSG_MULTICAST, reachedClients);
        WriteFloat(MSG_MULTICAST, chatDistance);
        WriteString(MSG_MULTICAST, strMessage);

        msg_entity = a;
        multicast([0,0,0], MULTICAST_ONE_R);
    }

    /* TODO: don't print on listen games */
    print(Util_ChatFormat(edictNum, 0, strMessage));
    print("\n");
}

void
ncGameRule_Home::ChatMessageTeam(ncClient cl, string strMessage)
{
    float edictNum = num_for_edict(cl) - 1;

    WriteByte(MSG_MULTICAST, SVC_CGAMEPACKET);
    WriteByte(MSG_MULTICAST, EV_CHAT);
    WriteByte(MSG_MULTICAST, edictNum);
    WriteByte(MSG_MULTICAST, cl.team);
    WriteString(MSG_MULTICAST, strMessage);
    multicast([0,0,0], MULTICAST_ALL_R);

    /* TODO: don't print on listen games */
    print("Global: ");
    print(Util_ChatFormat(edictNum, 0, strMessage));
    print("\n");
}

bool
ncGameRule_Home::ConsoleCommand(ncPlayer pl, string cmd)
{
    tokenize(cmd);
    switch (argv(0)) {
    case "saveStuff":
        filestream saveStream;
        saveStream = fopen("data/home.ent", FILE_WRITE);

        for (ncUserEntity e = __NULL__; (e = (ncUserEntity)nextent(e));) {

            switch (e.classname) {
            case "ncUserEntity_Brush":
            case "ncUserEntity_GameEntity":
            case "ncUserEntity_Picture":
            case "ncUserEntity_Object":
                break;
            default:
                continue;
            }

            fputs(saveStream, "{\n");
            fputs(saveStream, sprintf("%S %S\n", "classname", e.classname));
            e.Save(saveStream);
            fputs(saveStream, "}\n");
        }

        fclose(saveStream);
        break;
    case "loadStuff":
        ncMapDelegate::RestoreEntitiesFromFile("data/home.ent");
        break;
    default:
        return super::ConsoleCommand(pl, cmd);
    }
    return (true);
}


bool
ncGameRule_Home::PlayerRequestRespawn(ncPlayer pl)
{
    PlayerSpawn(pl);
    return (true);
}



bool
ncGameRule_Home::ClientCommand(ncClient pl, string cmd)
{
    static ncEntity lastObject;
        tokenize(cmd);
        switch (argv(0)) {
        case "input":
                float entNum = stof(argv(1));
        string inputName = argv(2);
        string inputData = argv(3);
        ncEntity inputTarget = (ncEntity)edict_num(entNum);

        if (inputTarget) {
            inputTarget.Input(pl, inputName, inputData);
            printf("Sending input to %d, %S: %S\n", entNum, inputName, inputData);
        }
        break;
    case "switchToGame":
        PlayerSpawn(pl);
        break;
    case "switchToEditor":
        ents.ChangeToClass(pl, "spectator");
        break;
    case "cleanMap":
        game.CleanUpMap();
        break;
    case "placeVideo":
        ncUserEntity_Video::Place((ncPlayer)pl, argv(1), argv(2), argv(3), argv(4), argv(5));
        break;
    case "placeAudio":
        ncUserEntity_Audio::Place((ncPlayer)pl, argv(1), argv(2), argv(3));
        break;
    case "placePicture":
        vector realSize;
        realSize[0] = stof(argv(3));
        realSize[1] = stof(argv(4));
        ncUserEntity_Picture::Place((ncPlayer)pl, argv(1), argv(2), realSize, argv(5));
        break;
    case "placeObject":
        string objectTitle = argv(1);
        string objectFile = argv(2);
        vector colorMod = stov(argv(3));
        float scaleMod =  stof(argv(4));
        vector newMins = stov(argv(5));
        vector newMaxs = stov(argv(6));
        string gui64 = argv(7);
        vector guiOrg = stov(argv(8));
        vector guiAng = stov(argv(9));
        float guiScale = stof(argv(10));
        vector guiRes = stov(argv(11));

        printf("objectTitle %S objectFile %S colorMod %v scaleMod %f newMins %v ",  objectTitle, objectFile, colorMod, scaleMod, newMins);
        printf("newMaxs %v guiOrg %v guiAng %v guiScale %f guiRes %v\n",  newMaxs, guiOrg, guiAng, guiScale, guiRes);

        lastObject = ncUserEntity_Object::Place((ncPlayer)pl, objectTitle, objectFile, colorMod, scaleMod, newMins, newMaxs, gui64, guiOrg, guiAng, guiScale, guiRes);
        break;
    case "moveObject":
        lastObject.SetOrigin(stov(argv(1)));
        lastObject.SetAngles(stov(argv(2)));
        break;
    case "spawnPicture":
        vector worldPos = stov(argv(3));
        vector eulerAngle = stov(argv(4));
        vector worldSize = stov(argv(5));
        ncUserEntity_Picture::PlaceAtPositionWithSize((ncPlayer)pl, argv(1), argv(2), worldPos, eulerAngle, worldSize);
        break;
    case "carveBrush":
        vector brushMins = stov(argv(1));
        vector brushMaxs = stov(argv(2));
        string brushTex = argv(3);

        if (!STRING_SET(brushTex)) {
            brushTex = "detail_pbr/default";
        }

        ncBreakableBrushManager::CarveBrush(brushMins, brushMaxs, brushTex);
        break;
    case "createBrush":
        vector brushMins = stov(argv(1));
        vector brushMaxs = stov(argv(2));
        string brushTex = argv(3);

        if (!STRING_SET(brushTex)) {
            brushTex = "detail_pbr/default";
        }

        ncBreakableBrushManager::CreateBrush(brushMins, brushMaxs, brushTex);
        break;
    case "placeWeb":
        ncUserEntity_URL::Place((ncPlayer)pl, argv(1), argv(2), argv(3));
        break;
    case "shareData":
        ncMediaSource::ShareDataWithNamedSource(pl, argv(1), argv(2), argv(3));
        break;
    case "stopVideos":
        ncUserEntityManager::StopVideos();
        break;
    case "fixAngles":
        for (ncEntity e = __NULL__; (e = (ncEntity)nextent(e));) {

            if (e.classname == "ncUserEntity_Picture") {
                e.angles[0] += 90;
                e.angles[1] += 180;
            }
        }
        break;
    case "travelTo":
        clustertransfer(pl, strcat(":", argv(1)));
        break;
    case "teleportToPlayer":
        ncPlayer foundPlayer = edict_num(stof(argv(1)));

        if (foundPlayer) {
            if (is.Player(foundPlayer)) {
                pl.SetOrigin(foundPlayer.GetNearbySpot());
            }
        }
        break;
    case "dictStart":
        ncEntity foundEntity = edict_num(stof(argv(1)));
        string dataType = strtolower(argv(2));

        if (foundEntity) {
            foundEntity.Input(pl, "beginreceive", dataType);
        }
        break;
    case "dictLine":
        ncEntity foundEntity = edict_num(stof(argv(1)));
        string dataType = strtolower(argv(2));
        string setKey = strtolower(argv(3));
        string dataValue = argv(4);

        if (foundEntity) {
            if (dataType == setKey) {
                foundEntity.Input(pl, strcat("receive;", strtolower(argv(3))), argv(4));
            } else {
                foundEntity.Input(pl, strcat("receive;", strtolower(argv(2)), ";", strtolower(argv(3))), argv(4));
            }
        }
        break;
    case "dictEnd":
        break;
    default:
        return super::ClientCommand(pl, cmd);
    }
    return (true);
}
