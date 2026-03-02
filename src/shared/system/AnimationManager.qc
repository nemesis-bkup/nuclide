/*
 * Copyright (c) 2026 Vera Visions LLC.
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

ncAnimationManager
ncAnimationManager::ManagerForEntity(entity actorEntity)
{
    /* find an existing linked dict */
    for (ncAnimationManager vars = __NULL__;(vars = (ncAnimationManager)find(vars, ::classname, "ncAnimationManager"));) {
#ifdef CLIENT
		ncPlayer targetPlayer = (ncItem)findentity(world, ::entnum, vars.m_targetEntityEntityNum);

		/* we have a match */
		if (targetPlayer == actorEntity) {
			vars.m_targetEntity = actorEntity;
            return (vars);
        }
#endif

#ifdef SERVER
		if (vars.m_targetEntity == actorEntity) {
            return (vars);
        }
#endif
	}

	ncAnimationManager newVars = __NULL__;

	/* only allocate them on the server */
#ifdef SERVER
	newVars = spawn(ncAnimationManager);
	newVars.Spawn();
    newVars.m_targetEntity = actorEntity;
	newVars.SetAnimationPrefix("");
	newVars.SendFlags = -1;
#endif

    return (newVars);
}

void
ncAnimationManager::AdvanceAnimation(float timelength)
{
	ncPlayer targetActor = (ncPlayer)m_targetEntity;
	/* timer update last */
	/* top animation is always just being incremented */
	anim_top_time += timelength;
	anim_top_delay -= timelength;

	/* we may be walking backwards, thus decrement bottom */
	if (dotproduct(targetActor.velocity, anglesToForward([0, targetActor.v_angle[1], 0])) < 0) {
		anim_bottom_time -= timelength;
	} else {
		anim_bottom_time += timelength;
	}
}


float
ncAnimationManager::__ActForPrefix(string actName, string animPrefix, string emotionString)
{
	float returnValue = Activities_GetSequenceForEntity(m_targetEntity, sprintf("%s_%s_%s", actName, animPrefix, emotionString));

	if (returnValue != ACTIVITY_NOTFOUND) {
		return (returnValue);
	}

	returnValue = Activities_GetSequenceForEntity(m_targetEntity, sprintf("%s_%s", actName, animPrefix));

	if (returnValue != ACTIVITY_NOTFOUND) {
		return (returnValue);
	}

	returnValue = Activities_GetSequenceForEntity(m_targetEntity, actName);

	return (returnValue);
}

void
ncAnimationManager::SetAnimationPrefix(string animPrefix)
{
	string stanceString = "";
	string emotionString = "stimulated"; /* Future plans: angry, relaxed, stimulated, agitated, USER DEFINED! */

	/* bottom/body */
	m_animBackend = stof(EntityDef_GetKeyValue(m_targetEntity.declclass, "animBackend"));
	m_boneSpine = gettagindex(m_targetEntity, EntityDef_GetKeyValue(m_targetEntity.declclass, "spine"));
	m_torsoFirst = gettagindex(m_targetEntity, EntityDef_GetKeyValue(m_targetEntity.declclass, "torsoStart"));
	m_torsoLast = gettagindex(m_targetEntity, EntityDef_GetKeyValue(m_targetEntity.declclass, "torsoEnd"));
	m_torsoTwistYaw = gettagindex(m_targetEntity, EntityDef_GetKeyValue(m_targetEntity.declclass, "twistYaw"));

	m_actIdle = __ActForPrefix("idle", animPrefix, emotionString);
	m_actIdleCrouch = __ActForPrefix("idle_crouch", animPrefix, emotionString);
	m_actIdleProne = __ActForPrefix("idle_prone", animPrefix, emotionString);
	m_actWalk = __ActForPrefix("walk", animPrefix, emotionString);
	m_actWalkCrouch = __ActForPrefix("walk_crouch", animPrefix, emotionString);
	m_actWalkProne = __ActForPrefix("walk_prone", animPrefix, emotionString);
	m_actRun = __ActForPrefix("run", animPrefix, emotionString);
	m_actJump = __ActForPrefix("jump", animPrefix, emotionString);

	/* top 'gestures' */
	m_actAim = __ActForPrefix("aim", animPrefix, emotionString);
	m_actDraw = __ActForPrefix("draw", animPrefix, emotionString);
	m_actAttack = __ActForPrefix("attack", animPrefix, emotionString);
	m_actReload = __ActForPrefix("reload", animPrefix, emotionString);
	m_actReloadStart = __ActForPrefix("reloadStart", animPrefix, emotionString);
	m_actReloadEnd = __ActForPrefix("reloadEnd", animPrefix, emotionString);

	if (m_actDraw == -1) {
		m_actDraw = m_actAim;
	}

#ifdef SERVER
	EntLog("%s activity set for prefix %S:", m_targetEntity.netname, animPrefix);
	EntLog("\tm_boneSpine: %d", m_boneSpine);
	EntLog("\tm_torsoFirst: %d", m_torsoFirst);
	EntLog("\tm_torsoLast: %d", m_torsoLast);
	EntLog("\tm_torsoTwistYaw: %d", m_torsoTwistYaw);
	EntLog("\tm_actIdle: %d", m_actIdle);
	EntLog("\tm_actIdleCrouch: %d", m_actIdleCrouch);
	EntLog("\tm_actIdleProne: %d", m_actIdleProne);
	EntLog("\tm_actWalk: %d", m_actWalk);
	EntLog("\tm_actWalkCrouch: %d", m_actWalkCrouch);
	EntLog("\tm_actWalkProne: %d", m_actWalkProne);
	EntLog("\tm_actRun: %d", m_actRun);
	EntLog("\tm_actAim: %d", m_actAim);
	EntLog("\tm_actDraw: %d", m_actDraw);
	EntLog("\tm_actAttack: %d", m_actAttack);
	EntLog("\tm_actReload: %d", m_actReload);
#endif
}

void
ncAnimationManager::TransferAnimationData(entity targetE)
{
	float maxTopTime;
	float maxBottomTime;

	ncPlayer targetActor = (ncPlayer)targetE;

	/* no valid transfer target */
	if (!targetE) {
		return;
	}

	/* no valid model on target */
	if (!targetE.modelindex) {
		return;
	}

	if (!m_targetEntity) {
		return;
	}

	if (anim_top_delay <= 0.0f) {
		anim_top = m_actAim;
	}

	if (vlen(targetActor.velocity) < 1) {
		if (targetActor.IsCrouching()) {
			anim_bottom = m_actIdleCrouch;
		} else if (targetActor.IsProne()) {
			anim_bottom = m_actIdleProne;
		} else {
			anim_bottom = m_actIdle;
		}
	} else if (vlen(targetActor.velocity) < 150) {
		if (targetActor.IsCrouching()) {
			anim_bottom = m_actWalkCrouch;
		} else if (targetActor.IsProne()) {
			anim_bottom = m_actWalkProne;
		} else {
			anim_bottom = m_actWalk;
		}
	} else if (vlen(targetActor.velocity) > 200) {
		if (targetActor.IsCrouching()) {
			anim_bottom = m_actWalkCrouch;
		} else if (targetActor.IsProne()) {
			anim_bottom = m_actWalkProne;
		} else {
			anim_bottom = m_actRun;
		}
	}

	if (anim_top == ACTIVITY_NOTFOUND) {
		if (m_actAim == ACTIVITY_NOTFOUND) {
			anim_top = anim_bottom;
		}
	}

	if (targetActor.HasVFlags(VFL_INVEHICLE) && targetActor.vehicle._isVehicle) {
		float rq = -1;
		ncVehicle veh = (ncVehicle)targetActor.vehicle;

		if (veh && veh._isVehicle) {
			rq = veh.DriverAnimation();
		}

		if (rq == -1) {
			//anim_top = ANIMATION_CAR_SIT_IDLE;
			//anim_bottom = ANIMATION_CAR_SIT_IDLE;
			targetActor.angles = targetActor.vehicle.angles;
		} else {
			anim_top = rq;
			anim_bottom = rq;
			targetActor.angles = veh.angles;
		}
	}

	maxTopTime = frameduration(targetActor.modelindex, anim_top);
	maxBottomTime = frameduration(targetActor.modelindex, anim_bottom);

	if (anim_bottom_time > maxBottomTime) {
		anim_bottom_time = (anim_bottom_time - maxBottomTime);
	} else if (anim_bottom_time < 0.0f) {
		anim_bottom_time = (maxBottomTime - anim_bottom_time);
	}

	if (anim_top_time > maxTopTime) {
		anim_top_time = (anim_top_time - maxTopTime);
	} else if (anim_bottom_time < 0.0f) {
		anim_top_time = (maxTopTime - anim_top_time);
	}

	switch (m_animBackend) {
	case ANIMATIONMODEL_HLMDL_VALVE:
		UpdatePlayerAnimation_Valve(0);
		break;
	case ANIMATIONMODEL_HLMDL_GOOSE:
		UpdatePlayerAnimation_Goose(0);
		break;
	case ANIMATIONMODEL_SKELETAL:
		UpdatePlayerAnimation_Skeletal(0);
		break;
	}

}


void
ncAnimationManager::UpdatePlayerAnimation_Skeletal(float timelength)
{
	ncPlayer targetActor = (ncPlayer)m_targetEntity;

	float skeletonIndex = ncAnimationSkeleton::SkeletonindexForEntity(targetActor);
	m_targetEntity.skeletonindex = skeletonIndex;

	targetActor.angles[0] = 0.0f;
	targetActor.angles[1] = targetActor.v_angle[1];
	targetActor.angles[2] = 0.0f;

	float fCorrect = dotproduct(targetActor.velocity, anglesToRight([0, targetActor.v_angle[1], 0])) * 0.25f;

	/* Correct the legs */
	targetActor.angles[1] -= fCorrect;


	/* TODO: Needs interpolation */
	/* lower body */
	targetActor.frame = anim_bottom;
	targetActor.frame1time = anim_bottom_time;
	skel_build(skeletonIndex, targetActor, targetActor.modelindex, 0, 0, 0, 1);

	// Build the top body
	targetActor.frame = anim_top;
	targetActor.frame1time = anim_top_time;
//  	lerpfrac = 1.0f;
	skel_build(skeletonIndex, targetActor, targetActor.modelindex, 0.001, m_torsoFirst, m_torsoLast ); // The 0.0001 comes from a stupid bug?

	skel_postmul_bone( skeletonIndex, m_torsoTwistYaw, [0,0,0], anglesToForward([ 0, fCorrect, 0 ]) );

}

void
ncAnimationManager::UpdatePlayerAnimation_Valve(float timelength)
{
	ncPlayer targetActor = (ncPlayer)m_targetEntity;
	targetActor.basebone = m_boneSpine;
	targetActor.frame = anim_top;
	targetActor.frame1time = anim_top_time;
	targetActor.baseframe = anim_bottom;
	targetActor.baseframe1time = anim_bottom_time;

	float fCorrect = dotproduct(targetActor.velocity, anglesToRight([0, targetActor.v_angle[1], 0])) * 0.25f;
	targetActor.bonecontrol1 = -fCorrect;
	targetActor.bonecontrol2 = targetActor.bonecontrol1 * 0.5f;
	targetActor.bonecontrol3 = targetActor.bonecontrol2 * 0.5f;
	targetActor.bonecontrol4 = targetActor.bonecontrol3 * 0.5f;

	targetActor.angles[1] = targetActor.v_angle[1] - fCorrect;
	targetActor.angles[0] = targetActor.angles[2] = 0;

	targetActor.subblendfrac =
	targetActor.subblend2frac = targetActor.v_angle[0] / 90;
}

void
ncAnimationManager::PredictPreFrame(void)
{
	SAVE_STATE(m_targetEntity)
	SAVE_STATE(m_animBackend)
	SAVE_STATE(m_boneSpine)
	SAVE_STATE(m_torsoFirst)
	SAVE_STATE(m_torsoLast)
	SAVE_STATE(m_torsoTwistYaw)

	SAVE_STATE(m_actIdle)
	SAVE_STATE(m_actIdleCrouch)
	SAVE_STATE(m_actIdleProne)
	SAVE_STATE(m_actWalk)
	SAVE_STATE(m_actWalkCrouch)
	SAVE_STATE(m_actWalkProne)
	SAVE_STATE(m_actRun)
	SAVE_STATE(m_actJump)

	SAVE_STATE(m_actAim)
	SAVE_STATE(m_actDraw)
	SAVE_STATE(m_actAttack)
	SAVE_STATE(m_actReload)
	SAVE_STATE(m_actReloadStart)
	SAVE_STATE(m_actReloadEnd)

	SAVE_STATE(anim_top)
	SAVE_STATE(anim_top_delay)
	SAVE_STATE(anim_bottom)
	SAVE_STATE(anim_top_time)
	SAVE_STATE(anim_bottom_time)
}

void
ncAnimationManager::PredictPostFrame(void)
{
	ROLL_BACK(m_targetEntity)
	ROLL_BACK(m_animBackend)
	ROLL_BACK(m_boneSpine)
	ROLL_BACK(m_torsoFirst)
	ROLL_BACK(m_torsoLast)
	ROLL_BACK(m_torsoTwistYaw)

	ROLL_BACK(m_actIdle)
	ROLL_BACK(m_actIdleCrouch)
	ROLL_BACK(m_actIdleProne)
	ROLL_BACK(m_actWalk)
	ROLL_BACK(m_actWalkCrouch)
	ROLL_BACK(m_actWalkProne)
	ROLL_BACK(m_actRun)
	ROLL_BACK(m_actJump)

	ROLL_BACK(m_actAim)
	ROLL_BACK(m_actDraw)
	ROLL_BACK(m_actAttack)
	ROLL_BACK(m_actReload)
	ROLL_BACK(m_actReloadStart)
	ROLL_BACK(m_actReloadEnd)

	ROLL_BACK(anim_top)
	ROLL_BACK(anim_top_delay)
	ROLL_BACK(anim_bottom)
	ROLL_BACK(anim_top_time)
	ROLL_BACK(anim_bottom_time)
}

void
ncAnimationManager::UpdatePlayerAnimation_Goose(float timelength)
{
	ncPlayer targetActor = (ncPlayer)m_targetEntity;
	targetActor.basebone = m_boneSpine;
	targetActor.baseframe = anim_top;
	targetActor.baseframe1time = anim_top_time;
	targetActor.frame = anim_bottom;
	targetActor.frame1time = anim_bottom_time;

	float fCorrect = dotproduct(targetActor.velocity, anglesToRight([0, targetActor.v_angle[1], 0])) * 0.25f;

	targetActor.subblendfrac = -fCorrect * 0.05f;
	targetActor.angles[1] = targetActor.v_angle[1] - fCorrect;
	targetActor.subblend2frac = targetActor.v_angle[0] / 90;
	targetActor.angles[0] = targetActor.angles[2] = 0;
}

void
ncAnimationManager::PlayGesture(float gestureAnim, float overrideTime)
{
	ncPlayer targetActor = (ncPlayer)m_targetEntity;

	if (gestureAnim == ACTIVITY_NOTFOUND) {
		return;
	}

	if (overrideTime == -1) {
		overrideTime = frameduration(targetActor.modelindex, gestureAnim);
	}

	anim_top = gestureAnim;
	anim_top_time = 0.0f;
	anim_top_delay = overrideTime;
}


#ifdef SERVER
void
ncAnimationManager::EvaluateEntity(void)
{
    pvsflags = PVSF_NOREMOVE | PVSF_IGNOREPVS;

	EVALUATE_FIELD(m_targetEntity, ANIMENT_CHANGED_BONESETUP)
	EVALUATE_FIELD(m_animBackend, ANIMENT_CHANGED_BONESETUP)
	EVALUATE_FIELD(m_boneSpine, ANIMENT_CHANGED_BONESETUP)
	EVALUATE_FIELD(m_torsoFirst, ANIMENT_CHANGED_BONESETUP)
	EVALUATE_FIELD(m_torsoLast, ANIMENT_CHANGED_BONESETUP)
	EVALUATE_FIELD(m_torsoTwistYaw, ANIMENT_CHANGED_BONESETUP)

	EVALUATE_FIELD(m_actIdle, ANIMENT_CHANGED_ACTS_BOTTOM)
	EVALUATE_FIELD(m_actIdleCrouch, ANIMENT_CHANGED_ACTS_BOTTOM)
	EVALUATE_FIELD(m_actIdleProne, ANIMENT_CHANGED_ACTS_BOTTOM)
	EVALUATE_FIELD(m_actWalk, ANIMENT_CHANGED_ACTS_BOTTOM)
	EVALUATE_FIELD(m_actWalkCrouch, ANIMENT_CHANGED_ACTS_BOTTOM)
	EVALUATE_FIELD(m_actWalkProne, ANIMENT_CHANGED_ACTS_BOTTOM)
	EVALUATE_FIELD(m_actRun, ANIMENT_CHANGED_ACTS_BOTTOM)
	EVALUATE_FIELD(m_actJump, ANIMENT_CHANGED_ACTS_BOTTOM)

	EVALUATE_FIELD(m_actAim, ANIMENT_CHANGED_ACTS_TOP)
	EVALUATE_FIELD(m_actDraw, ANIMENT_CHANGED_ACTS_TOP)
	EVALUATE_FIELD(m_actAttack, ANIMENT_CHANGED_ACTS_TOP)
	EVALUATE_FIELD(m_actReload, ANIMENT_CHANGED_ACTS_TOP)
	EVALUATE_FIELD(m_actReloadStart, ANIMENT_CHANGED_ACTS_TOP)
	EVALUATE_FIELD(m_actReloadEnd, ANIMENT_CHANGED_ACTS_TOP)

	EVALUATE_FIELD(anim_top, ANIMENT_CHANGED_SET)
	EVALUATE_FIELD(anim_top_delay, ANIMENT_CHANGED_TIMERS)
	EVALUATE_FIELD(anim_bottom, ANIMENT_CHANGED_SET)
	EVALUATE_FIELD(anim_top_time, ANIMENT_CHANGED_TIMERS)
	EVALUATE_FIELD(anim_bottom_time, ANIMENT_CHANGED_TIMERS)
	//SendFlags = -1;
}

float
ncAnimationManager::SendEntity(entity ePEnt, float flChanged)
{
	if (clienttype(ePEnt) != CLIENTTYPE_REAL)
		return (0);

	WriteByte(MSG_ENTITY, ENT_ANIMATIONMANAGER);
	WriteFloat(MSG_ENTITY, flChanged);

	SENDENTITY_ENTITY(m_targetEntity, ANIMENT_CHANGED_BONESETUP)
	SENDENTITY_FLOAT(m_animBackend, ANIMENT_CHANGED_BONESETUP)
	SENDENTITY_FLOAT(m_boneSpine, ANIMENT_CHANGED_BONESETUP)
	SENDENTITY_FLOAT(m_torsoFirst, ANIMENT_CHANGED_BONESETUP)
	SENDENTITY_FLOAT(m_torsoLast, ANIMENT_CHANGED_BONESETUP)
	SENDENTITY_FLOAT(m_torsoTwistYaw, ANIMENT_CHANGED_BONESETUP)

	SENDENTITY_FLOAT(m_actIdle, ANIMENT_CHANGED_ACTS_BOTTOM)
	SENDENTITY_FLOAT(m_actIdleCrouch, ANIMENT_CHANGED_ACTS_BOTTOM)
	SENDENTITY_FLOAT(m_actIdleProne, ANIMENT_CHANGED_ACTS_BOTTOM)
	SENDENTITY_FLOAT(m_actWalk, ANIMENT_CHANGED_ACTS_BOTTOM)
	SENDENTITY_FLOAT(m_actWalkCrouch, ANIMENT_CHANGED_ACTS_BOTTOM)
	SENDENTITY_FLOAT(m_actWalkProne, ANIMENT_CHANGED_ACTS_BOTTOM)
	SENDENTITY_FLOAT(m_actRun, ANIMENT_CHANGED_ACTS_BOTTOM)
	SENDENTITY_FLOAT(m_actJump, ANIMENT_CHANGED_ACTS_BOTTOM)

	SENDENTITY_FLOAT(m_actAim, ANIMENT_CHANGED_ACTS_TOP)
	SENDENTITY_FLOAT(m_actDraw, ANIMENT_CHANGED_ACTS_TOP)
	SENDENTITY_FLOAT(m_actAttack, ANIMENT_CHANGED_ACTS_TOP)
	SENDENTITY_FLOAT(m_actReload, ANIMENT_CHANGED_ACTS_TOP)
	SENDENTITY_FLOAT(m_actReloadStart, ANIMENT_CHANGED_ACTS_TOP)
	SENDENTITY_FLOAT(m_actReloadEnd, ANIMENT_CHANGED_ACTS_TOP)

	SENDENTITY_BYTE(anim_top, ANIMENT_CHANGED_SET)
	SENDENTITY_FLOAT(anim_top_time, ANIMENT_CHANGED_TIMERS)
	SENDENTITY_FLOAT(anim_top_delay, ANIMENT_CHANGED_TIMERS)
	SENDENTITY_BYTE(anim_bottom, ANIMENT_CHANGED_SET)
	SENDENTITY_FLOAT(anim_bottom_time, ANIMENT_CHANGED_TIMERS)

	return (1);
}
#endif

#ifdef CLIENT
void
ncAnimationManager::ReceiveEntity(float flNew, float flChanged)
{
	READENTITY_ENTNUM(m_targetEntityEntityNum, ANIMENT_CHANGED_BONESETUP)
	READENTITY_FLOAT(m_animBackend, ANIMENT_CHANGED_BONESETUP)
	READENTITY_FLOAT(m_boneSpine, ANIMENT_CHANGED_BONESETUP)
	READENTITY_FLOAT(m_torsoFirst, ANIMENT_CHANGED_BONESETUP)
	READENTITY_FLOAT(m_torsoLast, ANIMENT_CHANGED_BONESETUP)
	READENTITY_FLOAT(m_torsoTwistYaw, ANIMENT_CHANGED_BONESETUP)

	READENTITY_FLOAT(m_actIdle, ANIMENT_CHANGED_ACTS_BOTTOM)
	READENTITY_FLOAT(m_actIdleCrouch, ANIMENT_CHANGED_ACTS_BOTTOM)
	READENTITY_FLOAT(m_actIdleProne, ANIMENT_CHANGED_ACTS_BOTTOM)
	READENTITY_FLOAT(m_actWalk, ANIMENT_CHANGED_ACTS_BOTTOM)
	READENTITY_FLOAT(m_actWalkCrouch, ANIMENT_CHANGED_ACTS_BOTTOM)
	READENTITY_FLOAT(m_actWalkProne, ANIMENT_CHANGED_ACTS_BOTTOM)
	READENTITY_FLOAT(m_actRun, ANIMENT_CHANGED_ACTS_BOTTOM)
	READENTITY_FLOAT(m_actJump, ANIMENT_CHANGED_ACTS_BOTTOM)

	READENTITY_FLOAT(m_actAim, ANIMENT_CHANGED_ACTS_TOP)
	READENTITY_FLOAT(m_actDraw, ANIMENT_CHANGED_ACTS_TOP)
	READENTITY_FLOAT(m_actAttack, ANIMENT_CHANGED_ACTS_TOP)
	READENTITY_FLOAT(m_actReload, ANIMENT_CHANGED_ACTS_TOP)
	READENTITY_FLOAT(m_actReloadStart, ANIMENT_CHANGED_ACTS_TOP)
	READENTITY_FLOAT(m_actReloadEnd, ANIMENT_CHANGED_ACTS_TOP)

	READENTITY_BYTE(anim_top, ANIMENT_CHANGED_SET)
	READENTITY_FLOAT(anim_top_time, ANIMENT_CHANGED_TIMERS)
	READENTITY_FLOAT(anim_top_delay, ANIMENT_CHANGED_TIMERS)
	READENTITY_BYTE(anim_bottom, ANIMENT_CHANGED_SET)
	READENTITY_FLOAT(anim_bottom_time, ANIMENT_CHANGED_TIMERS)
}
#endif
