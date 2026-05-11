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

static bool
TraceAgainsTarget(ncMonster monster, ncEntity targetEntity)
{
    vector hitLocation = monster.GetOrigin();
    vector testCenter = targetEntity.GetOrigin();

    traceline(hitLocation, testCenter, MOVE_NORMAL, monster);

    if (trace_fraction == 1.0f || trace_ent == targetEntity) {
        return (true);
    }

    traceline(hitLocation, testCenter + [15.0f, 15.0f, 0.0f], MOVE_NORMAL, monster);

    if (trace_fraction == 1.0f || trace_ent == targetEntity) {
        return (true);
    }

    traceline(hitLocation, testCenter + [-15.0f, -15.0f, 0.0f], MOVE_NORMAL, monster);

    if (trace_fraction == 1.0f || trace_ent == targetEntity) {
        return (true);
    }

    traceline(hitLocation, testCenter + [-15.0f, 15.0f, 0.0f], MOVE_NORMAL, monster);

    if (trace_fraction == 1.0f || trace_ent == targetEntity) {
        return (true);
    }

    traceline(hitLocation, testCenter + [15.0f, -15.0f, 0.0f], MOVE_NORMAL, monster);

    if (trace_fraction == 1.0f || trace_ent == targetEntity) {
        return (true);
    }

    return (false);
}

void
ncSecurityCamera::ncSecurityCamera(void)
{
    m_securiCamScanDist = g_float_null;
    m_securiCamScanFOV = g_float_null;
    m_securiCamSightResume = g_float_null;
    m_securiCamSightTime = g_float_null;
    m_securiCamSweepAngle = g_float_null;
    m_securiCamSweepSpeed = g_float_null;
    m_securiCamSweepWait = g_float_null;
    m_securiCamAlertResumeTime = g_float_null;
    m_outputOnFoundPlayer = g_string_null;
}

#ifdef CLIENT

void
ncSecurityCamera::Draw(void)
{
    if (iscachedpic(m_strSurfaceMat))
        drawpic([0,0], m_strSurfaceMat, m_mediaSize, [1,1,1], 1.0f);

    Font_DrawText([8,8], "Security Camera", g_fntDefault);
    Font_DrawText([8,32], "Feed Here", g_fntDefault);
}
/*
============
ncSurfacePropEntity::ReceiveEntity
============
*/
void
ncSecurityCamera::ReceiveEntity(float flNew, float flChanged)
{
    READENTITY_INT(m_serverSideNum, SRFENT_CHANGED_MODELINDEX)
    READENTITY_COORD(origin[0], SRFENT_CHANGED_ORIGIN_X)
    READENTITY_COORD(origin[1], SRFENT_CHANGED_ORIGIN_Y)
    READENTITY_COORD(origin[2], SRFENT_CHANGED_ORIGIN_Z)
    READENTITY_ANGLE(angles[0], SRFENT_CHANGED_ANGLES_X)
    READENTITY_ANGLE(angles[1], SRFENT_CHANGED_ANGLES_Y)
    READENTITY_ANGLE(angles[2], SRFENT_CHANGED_ANGLES_Z)
    READENTITY_SHORT(modelindex, SRFENT_CHANGED_MODELINDEX)
    READENTITY_BYTE(solid, SRFENT_CHANGED_SOLIDMOVETYPE)
    READENTITY_BYTE(movetype, SRFENT_CHANGED_SOLIDMOVETYPE)
    READENTITY_INT(flags, SRFENT_CHANGED_FLAGS)
    READENTITY_COORD(mins[0], SRFENT_CHANGED_SIZE)
    READENTITY_COORD(mins[1], SRFENT_CHANGED_SIZE)
    READENTITY_COORD(mins[2], SRFENT_CHANGED_SIZE)
    READENTITY_COORD(maxs[0], SRFENT_CHANGED_SIZE)
    READENTITY_COORD(maxs[1], SRFENT_CHANGED_SIZE)
    READENTITY_COORD(maxs[2], SRFENT_CHANGED_SIZE)
    READENTITY_BYTE(frame, SRFENT_CHANGED_FRAME)
    READENTITY_FLOAT(skin, SRFENT_CHANGED_SKIN)
    READENTITY_FLOAT(effects, SRFENT_CHANGED_EFFECTS)
    READENTITY_SHORT(m_geomsetField, SRFENT_CHANGED_BODY)
    READENTITY_FLOAT(scale, SRFENT_CHANGED_SCALE)
    READENTITY_FLOAT(m_axialScale[0], SRFENT_CHANGED_SCALE)
    READENTITY_FLOAT(m_axialScale[1], SRFENT_CHANGED_SCALE)
    READENTITY_FLOAT(m_axialScale[2], SRFENT_CHANGED_SCALE)
    READENTITY_COORD(velocity[0], SRFENT_CHANGED_VELOCITY)
    READENTITY_COORD(velocity[1], SRFENT_CHANGED_VELOCITY)
    READENTITY_COORD(velocity[2], SRFENT_CHANGED_VELOCITY)
    READENTITY_COORD(avelocity[0], SRFENT_CHANGED_ANGULARVELOCITY)
    READENTITY_COORD(avelocity[1], SRFENT_CHANGED_ANGULARVELOCITY)
    READENTITY_COORD(avelocity[2], SRFENT_CHANGED_ANGULARVELOCITY)
    READENTITY_BYTE(m_renderMode, SRFENT_CHANGED_RENDERMODE)
    READENTITY_BYTE(m_renderFX, SRFENT_CHANGED_RENDERMODE)
    READENTITY_BYTE(m_renderColor[0], SRFENT_CHANGED_RENDERCOLOR)
    READENTITY_BYTE(m_renderColor[1], SRFENT_CHANGED_RENDERCOLOR)
    READENTITY_BYTE(m_renderColor[2], SRFENT_CHANGED_RENDERCOLOR)
    READENTITY_BYTE(m_renderAmount, SRFENT_CHANGED_RENDERAMT)
    READENTITY_ANGLE(m_studioBoneController1, SRFENT_CHANGED_CONTROLLER)
    READENTITY_ANGLE(m_studioBoneController2, SRFENT_CHANGED_CONTROLLER)
    READENTITY_ANGLE(m_studioBoneController3, SRFENT_CHANGED_CONTROLLER)
    READENTITY_ANGLE(m_studioBoneController4, SRFENT_CHANGED_CONTROLLER)
    READENTITY_ANGLE(m_studioBoneController5, SRFENT_CHANGED_CONTROLLER)

    if (flNew) {
        ReloadVideoResources();
    }

    /* this shall never be valid. use Hide() */
    if (scale == 0.0f) {
        scale = 1.0f;
    }

    if (flChanged & SRFENT_CHANGED_FRAME) {
        frame1time = 0.0f;
    }

    /* other post-eval operations happen here */
    if (flChanged & SRFENT_CHANGED_SIZE) {
        setsize(this, mins * scale, maxs * scale);
    }

    if (flChanged & SRFENT_CHANGED_BODY) {
        setcustomskin(this, "", sprintf("geomset 0 %i\ngeomset 1 %i\n", m_geomsetField, m_geomsetField));
    }

    if (flChanged & SRFENT_CHANGED_MODELINDEX) {
        _ModelChanged();
        _UpdateBoneCount();
    }
}
#endif

#ifdef SERVER
void
ncSecurityCamera::EvaluateEntity(void)
{
    if (modelindex == 0) {
        return;
    }

    SecurityCameraMovement();
    SecurityCameraVisionTick();

    EVALUATE_VECTOR(origin, 0, SRFENT_CHANGED_ORIGIN_X)
    EVALUATE_VECTOR(origin, 1, SRFENT_CHANGED_ORIGIN_Y)
    EVALUATE_VECTOR(origin, 2, SRFENT_CHANGED_ORIGIN_Z)
    EVALUATE_VECTOR(angles, 0, SRFENT_CHANGED_ANGLES_X)
    EVALUATE_VECTOR(angles, 1, SRFENT_CHANGED_ANGLES_Y)
    EVALUATE_VECTOR(angles, 2, SRFENT_CHANGED_ANGLES_Z)
    EVALUATE_FIELD(modelindex, SRFENT_CHANGED_MODELINDEX)
    EVALUATE_FIELD(solid, SRFENT_CHANGED_SOLIDMOVETYPE)
    EVALUATE_FIELD(movetype, SRFENT_CHANGED_SOLIDMOVETYPE)
    EVALUATE_FIELD(flags, SRFENT_CHANGED_FLAGS)
    EVALUATE_VECTOR(mins, 0, SRFENT_CHANGED_SIZE)
    EVALUATE_VECTOR(mins, 1, SRFENT_CHANGED_SIZE)
    EVALUATE_VECTOR(mins, 2, SRFENT_CHANGED_SIZE)
    EVALUATE_VECTOR(maxs, 0, SRFENT_CHANGED_SIZE)
    EVALUATE_VECTOR(maxs, 1, SRFENT_CHANGED_SIZE)
    EVALUATE_VECTOR(maxs, 2, SRFENT_CHANGED_SIZE)
    EVALUATE_FIELD(frame, SRFENT_CHANGED_FRAME)
    EVALUATE_FIELD(skin, SRFENT_CHANGED_SKIN)
    EVALUATE_FIELD(effects, SRFENT_CHANGED_EFFECTS)
    EVALUATE_FIELD(m_geomsetField, SRFENT_CHANGED_BODY)
    EVALUATE_FIELD(scale, SRFENT_CHANGED_SCALE)
    EVALUATE_VECTOR(m_axialScale, 0, SRFENT_CHANGED_SCALE)
    EVALUATE_VECTOR(m_axialScale, 1, SRFENT_CHANGED_SCALE)
    EVALUATE_VECTOR(m_axialScale, 2, SRFENT_CHANGED_SCALE)
    EVALUATE_VECTOR(velocity, 0, SRFENT_CHANGED_VELOCITY)
    EVALUATE_VECTOR(velocity, 1, SRFENT_CHANGED_VELOCITY)
    EVALUATE_VECTOR(velocity, 2, SRFENT_CHANGED_VELOCITY)
    EVALUATE_VECTOR(avelocity, 0, SRFENT_CHANGED_ANGULARVELOCITY)
    EVALUATE_VECTOR(avelocity, 1, SRFENT_CHANGED_ANGULARVELOCITY)
    EVALUATE_VECTOR(avelocity, 2, SRFENT_CHANGED_ANGULARVELOCITY)
    EVALUATE_FIELD(m_renderMode, SRFENT_CHANGED_RENDERMODE)
    EVALUATE_FIELD(m_renderFX, SRFENT_CHANGED_RENDERMODE)
    EVALUATE_VECTOR(m_renderColor, 0, SRFENT_CHANGED_RENDERCOLOR)
    EVALUATE_VECTOR(m_renderColor, 1, SRFENT_CHANGED_RENDERCOLOR)
    EVALUATE_VECTOR(m_renderColor, 2, SRFENT_CHANGED_RENDERCOLOR)
    EVALUATE_FIELD(m_renderAmount, SRFENT_CHANGED_RENDERAMT)
    EVALUATE_FIELD(m_studioBoneController1, SRFENT_CHANGED_CONTROLLER)
    EVALUATE_FIELD(m_studioBoneController2, SRFENT_CHANGED_CONTROLLER)
    EVALUATE_FIELD(m_studioBoneController3, SRFENT_CHANGED_CONTROLLER)
    EVALUATE_FIELD(m_studioBoneController4, SRFENT_CHANGED_CONTROLLER)
    EVALUATE_FIELD(m_studioBoneController5, SRFENT_CHANGED_CONTROLLER)
}

/* Make sure StartFrame calls this */
float
ncSecurityCamera::SendEntity(entity ePEnt, float flChanged)
{
    if (!modelindex) {
        return (0);
    }

    if (clienttype(ePEnt) != CLIENTTYPE_REAL) {
        return (0);
    }

    WriteByte(MSG_ENTITY, ENT_SECURITYCAMERA);

    /* broadcast how much data is expected to be read */
    WriteFloat(MSG_ENTITY, flChanged);
    SENDENTITY_INT(num_for_edict(this), SRFENT_CHANGED_MODELINDEX)
    SENDENTITY_COORD(origin[0], SRFENT_CHANGED_ORIGIN_X)
    SENDENTITY_COORD(origin[1], SRFENT_CHANGED_ORIGIN_Y)
    SENDENTITY_COORD(origin[2], SRFENT_CHANGED_ORIGIN_Z)
    SENDENTITY_ANGLE(angles[0], SRFENT_CHANGED_ANGLES_X)
    SENDENTITY_ANGLE(angles[1], SRFENT_CHANGED_ANGLES_Y)
    SENDENTITY_ANGLE(angles[2], SRFENT_CHANGED_ANGLES_Z)
    SENDENTITY_SHORT(modelindex, SRFENT_CHANGED_MODELINDEX)
    SENDENTITY_BYTE(solid, SRFENT_CHANGED_SOLIDMOVETYPE)
    SENDENTITY_BYTE(movetype, SRFENT_CHANGED_SOLIDMOVETYPE)
    SENDENTITY_INT(flags, SRFENT_CHANGED_FLAGS)
    SENDENTITY_COORD(mins[0], SRFENT_CHANGED_SIZE)
    SENDENTITY_COORD(mins[1], SRFENT_CHANGED_SIZE)
    SENDENTITY_COORD(mins[2], SRFENT_CHANGED_SIZE)
    SENDENTITY_COORD(maxs[0], SRFENT_CHANGED_SIZE)
    SENDENTITY_COORD(maxs[1], SRFENT_CHANGED_SIZE)
    SENDENTITY_COORD(maxs[2], SRFENT_CHANGED_SIZE)
    SENDENTITY_BYTE(frame, SRFENT_CHANGED_FRAME)
    SENDENTITY_FLOAT(skin, SRFENT_CHANGED_SKIN)
    SENDENTITY_FLOAT(effects, SRFENT_CHANGED_EFFECTS)
    SENDENTITY_SHORT(m_geomsetField, SRFENT_CHANGED_BODY)
    SENDENTITY_FLOAT(scale, SRFENT_CHANGED_SCALE)
    SENDENTITY_FLOAT(m_axialScale[0], SRFENT_CHANGED_SCALE)
    SENDENTITY_FLOAT(m_axialScale[1], SRFENT_CHANGED_SCALE)
    SENDENTITY_FLOAT(m_axialScale[2], SRFENT_CHANGED_SCALE)
    SENDENTITY_COORD(velocity[0], SRFENT_CHANGED_VELOCITY)
    SENDENTITY_COORD(velocity[1], SRFENT_CHANGED_VELOCITY)
    SENDENTITY_COORD(velocity[2], SRFENT_CHANGED_VELOCITY)
    SENDENTITY_COORD(avelocity[0], SRFENT_CHANGED_ANGULARVELOCITY)
    SENDENTITY_COORD(avelocity[1], SRFENT_CHANGED_ANGULARVELOCITY)
    SENDENTITY_COORD(avelocity[2], SRFENT_CHANGED_ANGULARVELOCITY)
    SENDENTITY_BYTE(m_renderMode, SRFENT_CHANGED_RENDERMODE)
    SENDENTITY_BYTE(m_renderFX, SRFENT_CHANGED_RENDERMODE)
    SENDENTITY_BYTE(m_renderColor[0], SRFENT_CHANGED_RENDERCOLOR)
    SENDENTITY_BYTE(m_renderColor[1], SRFENT_CHANGED_RENDERCOLOR)
    SENDENTITY_BYTE(m_renderColor[2], SRFENT_CHANGED_RENDERCOLOR)
    SENDENTITY_BYTE(m_renderAmount, SRFENT_CHANGED_RENDERAMT)
    SENDENTITY_ANGLE(m_studioBoneController1, SRFENT_CHANGED_CONTROLLER)
    SENDENTITY_ANGLE(m_studioBoneController2, SRFENT_CHANGED_CONTROLLER)
    SENDENTITY_ANGLE(m_studioBoneController3, SRFENT_CHANGED_CONTROLLER)
    SENDENTITY_ANGLE(m_studioBoneController4, SRFENT_CHANGED_CONTROLLER)
    SENDENTITY_ANGLE(m_studioBoneController5, SRFENT_CHANGED_CONTROLLER)

    return (1);
}

void
ncSecurityCamera::SpawnKey(string keyName, string setValue)
{
    switch (keyName) {
    case "scanDist":
        m_securiCamScanDist = ReadFloat(setValue);
        break;
    case "scanFov":
        m_securiCamScanFOV = ReadFloat(setValue);
        break;
    case "sightResume":
        m_securiCamSightResume = ReadFloat(setValue);
        break;
    case "sightTime":
        m_securiCamSightTime = ReadFloat(setValue);
        break;
    case "sweepAngle":
        m_securiCamSweepAngle = ReadFloat(setValue);
        break;
    case "sweepSpeed":
        m_securiCamSweepSpeed = ReadFloat(setValue);
        break;
    case "sweepWait":
        m_securiCamSweepWait = ReadFloat(setValue);
        break;
    case "wait":
        m_securiCamAlertResumeTime = ReadFloat(setValue);
        break;
    case "OnFoundPlayer":
        m_outputOnFoundPlayer = PrepareOutput(m_outputOnFoundPlayer, setValue);
        break;
    default:
        super::SpawnKey(keyName, setValue);
    }
}

void
ncSecurityCamera::Spawned(void)
{
    super::Spawned();

    if (STRING_SET(m_outputOnFoundPlayer)) {
        m_outputOnFoundPlayer = CreateOutput(m_outputOnFoundPlayer);
    }

    m_securiCamSpawnYaw = angles[1];
}


bool
ncSecurityCamera::SecurityCameraIsEnemy(entity enny)
{
    if (enny == __NULL__)
        return false;

    /* dead enny should not be considered valid */
    if ((enny.solid == SOLID_CORPSE) || (enny.health <= 0))
        return false;

    /* monsters ignore enny who uses notarget cheat, useful for development */
    if (enny.flags & FL_NOTARGET)
        return false;

    /* prevent from shooting non-sentient stuff */
    if (!(enny.flags & (FL_MONSTER | FL_CLIENT)))
        return false;

    return true;
}

bool
ncSecurityCamera::SecurityCameraCheck(ncActor toCheck)
{
    /* cheapest check */
    if (toCheck.IsVulnerable() == false) {
        return (false);
    }

    /* slightly more expensive check */
    float distanceToEnemy = distance(GetOrigin(), toCheck.GetOrigin());
    if (distanceToEnemy > m_securiCamScanDist) {
        return (false);
    }

    /* much more expensive checks */
    vector v = normalize(toCheck.origin - GetOrigin());
    float flDot = v * anglesToForward(GetAngles());

    if (flDot < (m_securiCamScanFOV / 180)) {
        return (false);
    }

    if (TraceAgainsTarget(this, toCheck) == true) {
        if (SecurityCameraIsEnemy(toCheck) == true) {
            return (true);
        }
    }

    return (false);
}

void
ncSecurityCamera::SecurityCameraMovement(void)
{
    ncEntity targetEntity = GetTargetEntity();

    if ((m_securiCamSweepState == CAMSWEEP_ALERTED) && m_securiCamTrackingRef) {
        vector oldAngles = GetAngles();
        vector oldForward = anglesToForward(oldAngles);
        TurnToPos(m_securiCamTrackingRef.origin);
        angles = vectorLerp(oldForward, anglesToForward(GetAngles()), frametime);
        angles = vectoangles(angles);
        return;
    } else if (m_securiCamSweepState == CAMSWEEP_RETURN) {
        vector oldAngles = GetAngles();
        vector oldForward = anglesToForward(oldAngles);
        vector wishAngle = oldAngles;
        wishAngle[1] = m_securiCamSpawnYaw;
        wishAngle[1] += m_securiCamSweepTime;
        vector wishForward = anglesToForward(wishAngle);

        angles = vectoangles(vectorLerp(oldForward, wishForward, frametime));

        if (vlen(oldForward - wishForward) < 0.025) {
            m_securiCamSweepState = CAMSWEEP_IDLE;
        }

        return;
    } else if (targetEntity) {
        TurnToPos(targetEntity.GetOrigin());
    } else {
        angles[1] = m_securiCamSpawnYaw;
    }

    /* pick a direction if we lack any */
    if (m_securiCamSweepState == CAMSWEEP_IDLE) {
        if (random() < 0.5) {
            m_securiCamSweepState = CAMSWEEP_LEFT;
        } else {
            m_securiCamSweepState = CAMSWEEP_RIGHT;
        }
    }

    if (m_securiCamSweepState == CAMSWEEP_LEFT) {
        m_securiCamSweepTime -= (frametime * m_securiCamSweepSpeed);

        if (m_securiCamSweepTime < -m_securiCamSweepAngle) {
            m_securiCamSweepWaitTime = m_securiCamSweepWait;
            m_securiCamSweepTime = -m_securiCamSweepAngle;
            m_securiCamSweepState = CAMSWEEP_LEFT_WAIT;
        }
    } else if (m_securiCamSweepState == CAMSWEEP_RIGHT) {
        m_securiCamSweepTime += (frametime * m_securiCamSweepSpeed);

        if (m_securiCamSweepTime > m_securiCamSweepAngle) {
            m_securiCamSweepWaitTime = m_securiCamSweepWait;
            m_securiCamSweepTime = m_securiCamSweepAngle;
            m_securiCamSweepState = CAMSWEEP_RIGHT_WAIT;
        }
    } else if (m_securiCamSweepState == CAMSWEEP_LEFT_WAIT) {
        m_securiCamSweepWaitTime -= (frametime);

        if (m_securiCamSweepWaitTime < 0.0f) {
            m_securiCamSweepState = CAMSWEEP_RIGHT;
        }
    } else if (m_securiCamSweepState == CAMSWEEP_RIGHT_WAIT) {
        m_securiCamSweepWaitTime -= (frametime);

        if (m_securiCamSweepWaitTime < 0.0f) {
            m_securiCamSweepState = CAMSWEEP_LEFT;
        }

    }

    angles[1] += m_securiCamSweepTime;
}

void
ncSecurityCamera::SecurityCameraVisionTick(void)
{
    /* we're already tracking somebody in vision */
    if (m_securiCamTrackingRef) {
        /* has this camera been staring long enough? */
        if (m_securiCamTrackingTime < time) {
            m_securiCamTrackingTime = time + m_securiCamAlertResumeTime;

            /* still valid? */
            if (SecurityCameraCheck(m_securiCamTrackingRef) == true) {
                UseOutput(m_securiCamTrackingRef, m_outputOnFoundPlayer);
                //printf("Can see you.\n");
                m_securiCamSweepState = CAMSWEEP_ALERTED;
            } else {
                m_securiCamTrackingRef = g_entity_null;
                //printf("Can't see.\n");

                if (m_securiCamSweepState == CAMSWEEP_ALERTED) {
                    m_securiCamSweepState = CAMSWEEP_RETURN;
                }
            }
        }
        return;
    }

    for (ncEntity w = world; (w = (ncEntity)findfloat(w, ::_isActor, 1));) {
        if (SecurityCameraCheck(w)) {
            if (!m_securiCamTrackingRef) {
                m_securiCamTrackingRef = w;
                m_securiCamTrackingTime = time + m_securiCamSightTime;
            }
        }
    }
}
#endif
