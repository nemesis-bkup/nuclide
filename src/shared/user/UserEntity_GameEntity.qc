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

void
ncUserEntity_GameEntity::ncUserEntity_GameEntity(void)
{
}

#ifdef SERVER
void
ncUserEntity_GameEntity::EvaluateEntity(void)
{
	EVALUATE_VECTOR(origin, 0, UISURFACEFL_ORIGIN)
	EVALUATE_VECTOR(origin, 1, UISURFACEFL_ORIGIN)
	EVALUATE_VECTOR(origin, 2, UISURFACEFL_ORIGIN)
	EVALUATE_VECTOR(angles, 0, UISURFACEFL_ANGLES)
	EVALUATE_VECTOR(angles, 1, UISURFACEFL_ANGLES)
	EVALUATE_VECTOR(angles, 2, UISURFACEFL_ANGLES)
	EVALUATE_FIELD(m_gameEntClass, UISURFACEFL_INTERFACE)
	EVALUATE_FIELD(modelindex, UISURFACEFL_INTERFACE)
}

float
ncUserEntity_GameEntity::SendEntity(entity ePEnt, float flChanged)
{
	/* only network the gameents to their owners */
	if (ePEnt != real_owner) {
		return (false);
	}

	WriteByte(MSG_ENTITY, ENT_USERENTITY);
	WriteFloat(MSG_ENTITY, flChanged);
	SENDENTITY_COORD(origin[0], UISURFACEFL_ORIGIN)
	SENDENTITY_COORD(origin[1], UISURFACEFL_ORIGIN)
	SENDENTITY_COORD(origin[2], UISURFACEFL_ORIGIN)
	SENDENTITY_ANGLE(angles[0], UISURFACEFL_ANGLES)
	SENDENTITY_ANGLE(angles[1], UISURFACEFL_ANGLES)
	SENDENTITY_ANGLE(angles[2], UISURFACEFL_ANGLES)
	SENDENTITY_FLOAT(size[0], UISURFACEFL_ANGLES)
	SENDENTITY_FLOAT(size[1], UISURFACEFL_ANGLES)
	SENDENTITY_INT(num_for_edict(this), UISURFACEFL_INTERFACE)
	SENDENTITY_STRING(m_gameEntClass, UISURFACEFL_INTERFACE)
	SENDENTITY_INT(modelindex, UISURFACEFL_INTERFACE)
	return (1);
}
#endif

#ifdef CLIENT
var bool autocvar_editor_hideProxies = false;

float
ncUserEntity_GameEntity::predraw(void)
{
	if (autocvar_editor_hideProxies == true) {
		return (PREDRAW_NEXT);
	}

	if (pSeat->m_ePlayer.movetype != MOVETYPE_NOCLIP) {
		return (PREDRAW_NEXT);
	}

	colormod = [1,1,1];
	alpha = 1.0f;
	addentity(this);
	return (PREDRAW_NEXT);
}

void
ncUserEntity_GameEntity::ReceiveEntity(float flNew, float flChanged)
{
	READENTITY_COORD(origin[0], UISURFACEFL_ORIGIN)
	READENTITY_COORD(origin[1], UISURFACEFL_ORIGIN)
	READENTITY_COORD(origin[2], UISURFACEFL_ORIGIN)
	READENTITY_ANGLE(angles[0], UISURFACEFL_ANGLES)
	READENTITY_ANGLE(angles[1], UISURFACEFL_ANGLES)
	READENTITY_ANGLE(angles[2], UISURFACEFL_ANGLES)
	READENTITY_FLOAT(size[0], UISURFACEFL_ANGLES)
	READENTITY_FLOAT(size[1], UISURFACEFL_ANGLES)
	READENTITY_INT(m_serverSideNum, UISURFACEFL_INTERFACE)
	READENTITY_STRING(m_gameEntClass, UISURFACEFL_INTERFACE)
	READENTITY_INT(modelindex, UISURFACEFL_INTERFACE)
}
#endif

#ifdef SERVER
void
ncUserEntity_GameEntity::Place(ncPlayer entityCreator, string className, string modelPath, vector atPos, vector withAngle)
{
	ncUserEntity_GameEntity userEntity;

	/* spawn the new one */
	userEntity = spawn(ncUserEntity_GameEntity);
	userEntity.Spawn();

	userEntity.real_owner = entityCreator;
	userEntity.m_gameEntClass = className;
	userEntity.SetModel(modelPath);
	userEntity.SetOrigin(atPos);
	userEntity.SetAngles(withAngle);
}

void
ncUserEntity_GameEntity::Instantiate(void)
{
	if (m_spawnedEntity) {
		return;
	}

	m_spawnedEntity = ents.Create(m_gameEntClass, origin);
	setorigin(m_spawnedEntity, origin);
	m_spawnedEntity.ReleaseThink();
	m_spawnedEntity.SetAngles(GetAngles());
}

void
ncUserEntity_GameEntity::Deinstantiate(void)
{
	if (!m_spawnedEntity) {
		return;
	}

	m_spawnedEntity.Hide();
	m_spawnedEntity.Destroy();
	m_spawnedEntity = 0;
}

void
ncUserEntity_GameEntity::InstatiateEntitiesByPlayer(ncPlayer entityCreator)
{
	for (ncUserEntity_GameEntity e = __NULL__; (e = (ncUserEntity_GameEntity)nextent(e));) {
		if (e.classname != "ncUserEntity_GameEntity") {
			continue;
		}

		if (e.real_owner == entityCreator) {
			e.Instantiate();
		}
	}
}

void
ncUserEntity_GameEntity::Respawn(void)
{
	/* never do anything here! */
}

void
ncUserEntity_GameEntity::DeinstatiateEntitiesByPlayer(ncPlayer entityCreator)
{
	for (ncUserEntity_GameEntity e = __NULL__; (e = (ncUserEntity_GameEntity)nextent(e));) {
		if (e.classname != "ncUserEntity_GameEntity") {
			continue;
		}

		if (e.real_owner == entityCreator) {
			e.Deinstantiate();
		}
	}
}
#endif
