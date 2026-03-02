/*
 * Copyright (c) 2024 Marco Cawthorne <marco@icculus.org>
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


var string autocvar_invasion_monsterClass = "monster_enforcer";
var string autocvar_invasion_spawnPoint = "info_player_deathmatch";
var string autocvar_invasion_playerClass = "player_mp";

var int autocvar_invasion_monsterCount = 12;

void
WaveTimer_Tick(void)
{
	int monsterCount = actor.TotalActors();

	/* spawn a new monster */
	if (monsterCount < autocvar_invasion_monsterCount) {
        float r = tokenize(autocvar_invasion_monsterClass);
        string monsterClass = argv(floor(random(0, r+1)));
		entity zombie = ents.Create(monsterClass, [0,0,0]);
		ents.Input(zombie, "SetTeam", "1", self);
		game.TeleportToSpawn(zombie);
		ents.Input(zombie, "ChangeMindset", "search", self);
	}

	self.nextthink = time + 2.0f;
}

bool
AllowFlashlight(void)
{
	return cvars.GetBool("mp_flashlight");
}

void
CodeCallback_Precaches(void)
{
	Util_SharedPrecaches();

	precache.Entity(autocvar_invasion_playerClass);
	precache.Entity(autocvar_invasion_spawnPoint);
	precache.Entity(autocvar_invasion_monsterClass);
}

void
CodeCallback_StartGameType(void)
{
	precache.Entity(autocvar_invasion_monsterClass);
	motd.LoadDefault();
	game.SetSpawnPoint(autocvar_invasion_spawnPoint);

	teams.SetUp(1, "Enemies", [255, 0, 0], false);
	teams.SetUp(2, "Players", [255, 255, 255], false);
	teams.SetSpawnPoint(1, autocvar_invasion_spawnPoint);
	teams.SetSpawnPoint(2, autocvar_invasion_spawnPoint);

	entity tick = spawn();
	tick.think = WaveTimer_Tick;
	tick.nextthink = time + 1.0f;
}

void
CodeCallback_PlayerSpawn(entity playerEntity)
{
	ents.ChangeToClass(playerEntity, autocvar_invasion_playerClass);
	ents.Input(playerEntity, "SetTeam", "2", world);
	game.TeleportToSpawn(playerEntity);
}

void
CodeCallback_PlayerDisconnect(entity playerEntity)
{

}

bool
CodeCallback_PlayerRequestRespawn(entity playerEntity)
{
	CodeCallback_PlayerSpawn(playerEntity);
	return (true);
}

void
CodeCallback_PlayerDamage(entity playerEntity, entity inflictor, entity attacker)
{

}

void
CodeCallback_PlayerKilled(entity playerEntity, entity inflictor, entity attacker, string weapon)
{
	if (playerEntity == attacker)
		combat.Obituary(playerEntity.netname, attacker.netname, weapon, "self");
	else
		combat.Obituary(playerEntity.netname, attacker.netname, weapon, "");

	/* death-counter */
	playerEntity.deaths++;

	/* update score-counter */
	if (is.Player(attacker)) {
		if (playerEntity == attacker) {
			attacker.frags--;
		} else {
			attacker.frags++;
		}
	} else if (is.Sentient(attacker)) {
		teams.AddScore(attacker.team, 1);
	}
}

void
CodeCallback_NPCKilled(entity npcEntity, entity inflictor, entity attacker, string weapon)
{
	string npcName;
	string attackerName;

	if (npcEntity) {
		npcName = npcEntity.netname;

		if (!STRING_SET(npcName)) {
			npcName = npcEntity.classname;
		}
	} else {
		npcName = "Unknown";
	}

	if (attacker) {
		if (!STRING_SET(attacker.netname)) {
			attackerName = attacker.classname;
		} else {
			attackerName = attacker.netname;
		}

        /* update score-counter */
        if (is.Player(attacker)) {
            if (npcEntity == attacker) {
                attacker.frags--;
            } else {
                attacker.frags++;
            }
        }
	} else {
		attackerName = "Unknown";
	}

	if (npcEntity == attacker)
		combat.Obituary(npcName, attackerName, weapon, "self");
	else
		combat.Obituary(npcName, attackerName, weapon, "");

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
