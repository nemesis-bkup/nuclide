/*
 * Copyright (c) 2024-2025 Marco Cawthorne <marco@icculus.org>
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

var int autocvar_ctf_scoreLimit = 5i;
var string autocvar_ctf_spawnPoint = "info_player_deathmatch";
var string autocvar_ctf_team1PlayerClass = "player_enforcer";
var string autocvar_ctf_team2PlayerClass = "player_mp";
entity ctf_team1ScoreMessage;
entity ctf_team2ScoreMessage;
entity ctf_team1WinMessage;
entity ctf_team2WinMessage;
entity ctf_team1TakesMessage;
entity ctf_team2TakesMessage;
entity ctf_team1ReturnedMessage;
entity ctf_team2ReturnedMessage;
entity ctf_team1DroppedMessage;
entity ctf_team2DroppedMessage;

void
CodeCallback_Precache(void)
{
	precache.Music("music/mp_capture_team1.wav");
	precache.Music("music/mp_capture_team2.wav");
	precache.Music("music/mp_yield.wav");
	precache.Music("music/mp_win.ogg");
	precache.Music("music/mp1.ogg");
	precache.Music("music/mp2.ogg");
	precache.Music("music/mp3.ogg");
	precache.Music("music/mp4.ogg");
	precache.Music("music/mp5.ogg");
}

void
CodeCallback_StartGameType(void)
{
    motd.LoadDefault();
    game.SetSpawnPoint("info_intermission");

    teams.SetUp(1, "Enforcers", [255, 64, 64], true);
    teams.SetUp(2, "Rangers", [155, 205, 255], true);

    teams.SetSpawnPoint(1, autocvar_ctf_spawnPoint);
    teams.SetSpawnPoint(2, autocvar_ctf_spawnPoint);

    ctf_team1ScoreMessage = ents.Create("ctf_team1score", [0, 0, 0] );
    ctf_team2ScoreMessage = ents.Create("ctf_team2score", [0, 0, 0] );

    ctf_team1WinMessage = ents.Create("domination_team1win", [0, 0, 0] );
    ctf_team2WinMessage = ents.Create("domination_team2win", [0, 0, 0] );

    ctf_team1TakesMessage = ents.Create("ctf_team1takes", [0, 0, 0] );
    ctf_team2TakesMessage = ents.Create("ctf_team2takes", [0, 0, 0] );

    ctf_team1ReturnedMessage = ents.Create("ctf_team1returned", [0, 0, 0] );
    ctf_team2ReturnedMessage = ents.Create("ctf_team2returned", [0, 0, 0] );

    ctf_team1DroppedMessage = ents.Create("ctf_team1dropped", [0, 0, 0] );
    ctf_team2DroppedMessage = ents.Create("ctf_team2dropped", [0, 0, 0] );

    /* from shared.qc */
    Util_RemoveAllMonsters();
    Util_SetItemRespawnTimers();

	for (entity s = world; (s = next.Item(s));) {
		string isWeapon = substring(s.classname, 0, 7);
		string isAmmo = substring(s.classname, 0, 5);

		if (isWeapon == "weapon_" || isAmmo == "ammo_") {
			ents.Input(s, "setrespawntime", "20.0f", world);
		} else {
			ents.Input(s, "setrespawntime", "30.0f", world);
		}
	}
}

float
HLDM_IndexForName(string modelName)
{
	float modelID = 0;

	if (modelName != "") {
		string playerModel = "";
		playerModel = sprintf("models/player/%s/%s.mdl", modelName, modelName);
		modelID = getmodelindex(playerModel);
	}

	if (modelID) {
		return (modelID);
	}

	return getmodelindex("models/player.mdl");
}

void
CodeCallback_PlayerSpawn(entity playerEntity)
{
    ents.ChangeToClass(playerEntity, "spectator");
    game.TeleportToSpawn(playerEntity);
}

.bool musicPlayed;
.float joinTime;
void
CodeCallback_PlayerPreFrame(entity playerEntity)
{
	if (!playerEntity.musicPlayed && playerEntity.joinTime < time) {
		float randomTrack = floor(random(1,6));
		music.PlayOnClient(precache.Music(sprintf("music/mp%d.ogg", randomTrack)), playerEntity);
		playerEntity.musicPlayed = true;
	}
}


void
CodeCallback_PlayerDisconnect(entity playerEntity)
{

}
static string g_tfPlayerColor[5] = {
    "0xffffff",
    "0xff1800"
    "0x9aff"
};

bool
CodeCallback_PlayerRequestRespawn(entity playerEntity)
{
    if (is.Alive(playerEntity) == false) {
        ents.ChangeToClass(playerEntity, playerEntity.classname);
        userinfo.SetString(playerEntity, "topcolor", g_tfPlayerColor[playerEntity.team]);
        userinfo.SetString(playerEntity, "bottomcolor", g_tfPlayerColor[playerEntity.team]);
        game.TeleportToSpawn(playerEntity);
        music.PlayOnceOnClient(precache.Music("music/track05.ogg"), playerEntity);
    }

    return (true);
}

void
CodeCallback_PlayerDamage(entity playerEntity, entity inflictor, entity attacker)
{

}


bool
CodeCallback_CallRequestTeam(entity playerEntity, int teamNum)
{
    ents.Input(playerEntity, "setteam", itos(teamNum), playerEntity);

    if (is.Alive(playerEntity) == false) {
        if (playerEntity.team == 1) {
            ents.ChangeToClass(playerEntity, autocvar_ctf_team1PlayerClass);
        } else {
            ents.ChangeToClass(playerEntity, autocvar_ctf_team2PlayerClass);
        }

        userinfo.SetString(playerEntity, "topcolor", g_tfPlayerColor[playerEntity.team]);
        userinfo.SetString(playerEntity, "bottomcolor", g_tfPlayerColor[playerEntity.team]);
        game.TeleportToSpawn(playerEntity);
        music.PlayOnceOnClient(precache.Music("music/track05.ogg"), playerEntity);
    } else {
        ents.Input(playerEntity, "damage", "1000", playerEntity);
    }

    return (true);
}

void
CodeCallback_PlayerKilled(entity playerEntity, entity inflictor, entity attacker, string weapon)
{
	combat.Obituary(playerEntity.netname, attacker.netname, weapon, "");

	/* death-counter */
	playerEntity.deaths++;

	/* update score-counter */
	if (is.Player(attacker)) {
		if (playerEntity == attacker || playerEntity.team == attacker.team) {
			attacker.frags--;
		} else {
			attacker.frags++;
		}
	}
}

bool
CodeCallback_ClientCommand(entity playerEntity, string command)
{
	float commandArgs = tokenize(command);

	switch (argv(0)) {
	case "join":
		string className = argv(1);
		if (is.Alive(playerEntity) == true) {
			break;
		}

		if (STRING_SET(className)) {
			ents.ChangeToClass(playerEntity, strcat("player_", className));
			game.TeleportToSpawn(playerEntity);
			music.PlayOnceOnClient(precache.Music("music/mp4.ogg"), playerEntity);
		}

		break;
	default:
		return (false);
	}

	return (true);
}

bool
CodeCallback_ImpulseCommand(entity playerEntity, float impulseNum)
{
	switch (impulseNum) {
	default:
		return (false);
	}

	return (true);
}


void
CodeCallback_Input(entity activator, string inputName, string dataString)
{
	switch (inputName) {
	case "capture":
		printf("Capture\n");
		music.PlayOnce(precache.Music("music/mp_win.ogg"));

		if (autocvar_ctf_scoreLimit > 0) {
			if (dataString == "1") {
				if (teams.Score(1) >= autocvar_ctf_scoreLimit) {
                    ents.Input(ctf_team1WinMessage, "display", "", world);
					//Overturn_EndRound();
				} else {
                    ents.Input(ctf_team1ScoreMessage, "display", "", world);
                }
			} else if (dataString == "2") {
				if (teams.Score(2) >= autocvar_ctf_scoreLimit) {
                    //Overturn_EndRound();
                    ents.Input(ctf_team2WinMessage, "display", "", world);
                } else {
                    ents.Input(ctf_team2ScoreMessage, "display", "", world);
                }
			}
		}

		break;
    case "drop":
        printf("Dropped\n");

        if (dataString == "1") {
            ents.Input(ctf_team1DroppedMessage, "display", "", world);
        } else if (dataString == "2") {
            ents.Input(ctf_team2DroppedMessage, "display", "", world);
        }
        break;
	case "return":
		printf("Return\n");
		music.PlayOnce(precache.Music("music/mp_yield.wav"));

        if (dataString == "1") {
            ents.Input(ctf_team1ReturnedMessage, "display", "", world);
        } else if (dataString == "2") {
            ents.Input(ctf_team2ReturnedMessage, "display", "", world);
        }
		break;
	case "take":
		printf("Take\n");
		if (dataString == "1") {
            music.PlayOnce(precache.Music("music/mp_capture_team1.wav"));
            ents.Input(ctf_team2TakesMessage, "display", "", world);
		} else if (dataString == "2") {
            music.PlayOnce(precache.Music("music/mp_capture_team2.wav"));
            ents.Input(ctf_team1TakesMessage, "display", "", world);
		}
		break;
	}
}
