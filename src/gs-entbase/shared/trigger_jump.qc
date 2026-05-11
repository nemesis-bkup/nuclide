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


typedef enumflags
{
    PUSH_CHANGED_ORIGIN_X,
    PUSH_CHANGED_ORIGIN_Y,
    PUSH_CHANGED_ORIGIN_Z,
    PUSH_CHANGED_ANGLES_X,
    PUSH_CHANGED_ANGLES_Y,
    PUSH_CHANGED_ANGLES_Z,
    PUSH_CHANGED_MODELINDEX,
    PUSH_CHANGED_SIZE,
    PUSH_CHANGED_FRAME,
    PUSH_CHANGED_SPAWNFLAGS,
    PUSH_CHANGED_SOLIDMOVETYPE,
    PUSH_CHANGED_VELOCITY,
    PUSH_CHANGED_ANGULARVELOCITY,
    PUSH_CHANGED_RENDERCOLOR,
    PUSH_CHANGED_RENDERAMT,
    PUSH_CHANGED_RENDERMODE,
    PUSH_CHANGED_SPEED,
    PUSH_CHANGED_MOVEDIR
} trigger_jump_changed_t;

enumflags
{
    TP_ONCE,
    TP_STARTOFF
};

/*! \brief Shared-Entity: Push Force Volume */
/*!QUAKED trigger_jump (.5 .5 .5) ?
# OVERVIEW

# KEYS
- "targetname" : Name
- "target" : Position of where you should jump to.


# TRIVIA
This entity was introduced in Ricochet (2000).

@ingroup sharedentity
@ingroup brushentity
*/
class
trigger_jump:ncBrushTrigger
{
public:
    void trigger_jump(void);

    virtual void Touch(entity);
    virtual vector GetJumpVelocity(vector vecFrom, vector vecTo, float flGravMod);
    virtual float GetJumpHeight(vector vecFrom, vector vecTo, float flGravMod);
    
#ifdef SERVER
    virtual void Save(float);
    virtual void Restore(string,string);
    virtual void SpawnKey(string,string);
    virtual void Respawn(void);
    virtual void Trigger(entity,triggermode_t);
    virtual void SetMovementDirection(void);
    virtual float SendEntity(entity,float);
    virtual void EvaluateEntity(void);
#endif

#ifdef CLIENT
    virtual void ReceiveEntity(float, float);
#endif

private:
    NETWORKED_FLOAT(m_flSpeed)
    NETWORKED_VECTOR(m_vecMoveDir)
    NETWORKED_VECTOR(m_pushAngle)
    NETWORKED_BOOL(m_bHasTarget)
};

float
trigger_jump::GetJumpHeight(vector vecFrom, vector vecTo, float flGravMod)
{
    float flHeight, flGravity, flTime, flDistance, flDir;
    vector vecJump = [0,0,0];

    if (flGravMod <= 0.0)
        flGravMod = 1.0f;

    flGravity = 800 * flGravMod;
    flHeight = vecTo[2] - vecFrom[2];

    /* this may not be a much verticality to this jump, use distance instead */
    if (flHeight <= 0) {
        flHeight = vlen(vecTo - vecFrom);
        flTime = flHeight / flGravity;
    } else {
        flTime = sqrt(flHeight / (flGravity * 0.5f));
        if (flTime <= 0) {
            return 0;
        }
    }

    vecJump = vecTo - vecFrom;
    vecJump[2] = 0;
    flDistance = vlen(normalize(vecJump));

    flDir = flDistance / flTime;
    vecJump *= flDir;
    vecJump[2] = flTime * flGravity;
    return vecJump[2] * 1.25f;
}

vector
trigger_jump::GetJumpVelocity(vector vecFrom, vector vecTo, float flGravMod)
{
    vector vecJump = [0,0,0];
    float flDist = vlen(vecTo - vecFrom);
    makevectors(vectoangles(vecTo - vecFrom));
    vecJump = v_forward * flDist;
    vecJump[2] = 380;
    return vecJump;
}

void
trigger_jump::trigger_jump(void)
{
    m_vecMoveDir = [0,0,0];
    m_flSpeed = 100;
    m_bHasTarget = false;
}

#ifdef SERVER
void
trigger_jump::Save(float handle)
{
    super::Save(handle);
    SaveVector(handle, "m_vecMoveDir", m_vecMoveDir);
    SaveFloat(handle, "m_flSpeed", m_flSpeed);
    SaveBool(handle, "m_bHasTarget", m_bHasTarget);
}

void
trigger_jump::Restore(string strKey, string setValue)
{
    switch (strKey) {
    case "m_vecMoveDir":
        m_vecMoveDir = ReadVector(setValue);
        break;
    case "m_flSpeed":
        m_flSpeed = ReadFloat(setValue);
        break;
    case "m_bHasTarget":
        m_bHasTarget = ReadFloat(setValue);
        break;
    default:
        super::Restore(strKey, setValue);
    }
}

void
trigger_jump::SpawnKey(string strKey, string setValue)
{
    switch (strKey) {
    case "speed":
        m_flSpeed = stof(setValue);
        break;
    default:
        super::SpawnKey(strKey, setValue);
    }
}

void
trigger_jump::Respawn(void)
{
    static void JumpDestCheck(void) {
        /* this ent has a destination target */
        m_bHasTarget = false;
        if (HasTriggerTarget()) {
            entity targetPos = find(world, ::targetname, GetTriggerTarget());

            if (targetPos) {
                m_bHasTarget = true;
                m_vecMoveDir = targetPos.origin;
            }
        }
    }

    InitBrushTrigger();
    RestoreAngles();
    m_pushAngle = GetAngles();
    SetMovementDirection();
    ClearAngles();

    if (HasSpawnFlags(TP_STARTOFF)) {
        SetSolid(SOLID_NOT);
    }

    if (HasTriggerTarget()) {
        ScheduleThink(JumpDestCheck, 0.5f);
    }
}

void
trigger_jump::Trigger(entity act, triggermode_t state)
{
    switch (state) {
    case TRIG_OFF:
        SetSolid(SOLID_NOT);
        break;
    case TRIG_ON:
        SetSolid(SOLID_TRIGGER);
        break;
    default:
        SetSolid(solid == SOLID_NOT ? SOLID_TRIGGER : SOLID_NOT);
    }
}

void
trigger_jump::SetMovementDirection(void)
{
    if (GetAngles() == [0,-1,0]) {
        m_vecMoveDir = [0,0,1];
    } else if (GetAngles() == [0,-2,0]) {
        m_vecMoveDir = [0,0,-1];
    } else {
        makevectors(GetAngles());
        m_vecMoveDir = v_forward;
    }
}

void
trigger_jump::EvaluateEntity(void)
{
    EVALUATE_VECTOR(origin, 0, PUSH_CHANGED_ORIGIN_X)
    EVALUATE_VECTOR(origin, 1, PUSH_CHANGED_ORIGIN_Y)
    EVALUATE_VECTOR(origin, 2, PUSH_CHANGED_ORIGIN_Z)
    EVALUATE_VECTOR(angles, 0, PUSH_CHANGED_ANGLES_X)
    EVALUATE_VECTOR(angles, 1, PUSH_CHANGED_ANGLES_Y)
    EVALUATE_VECTOR(angles, 2, PUSH_CHANGED_ANGLES_Z)
    EVALUATE_FIELD(modelindex, PUSH_CHANGED_MODELINDEX)
    EVALUATE_FIELD(solid, PUSH_CHANGED_SOLIDMOVETYPE)
    EVALUATE_FIELD(movetype, PUSH_CHANGED_SOLIDMOVETYPE)
    EVALUATE_VECTOR(mins, 0, PUSH_CHANGED_SIZE)
    EVALUATE_VECTOR(mins, 1, PUSH_CHANGED_SIZE)
    EVALUATE_VECTOR(mins, 2, PUSH_CHANGED_SIZE)
    EVALUATE_VECTOR(maxs, 0, PUSH_CHANGED_SIZE)
    EVALUATE_VECTOR(maxs, 1, PUSH_CHANGED_SIZE)
    EVALUATE_VECTOR(maxs, 2, PUSH_CHANGED_SIZE)
    EVALUATE_FIELD(frame, PUSH_CHANGED_FRAME)
    EVALUATE_VECTOR(velocity, 0, PUSH_CHANGED_VELOCITY)
    EVALUATE_VECTOR(velocity, 1, PUSH_CHANGED_VELOCITY)
    EVALUATE_VECTOR(velocity, 2, PUSH_CHANGED_VELOCITY)
    EVALUATE_VECTOR(avelocity, 0, PUSH_CHANGED_ANGULARVELOCITY)
    EVALUATE_VECTOR(avelocity, 1, PUSH_CHANGED_ANGULARVELOCITY)
    EVALUATE_VECTOR(avelocity, 2, PUSH_CHANGED_ANGULARVELOCITY)
    EVALUATE_FIELD(m_flSpeed, PUSH_CHANGED_SPEED)
    EVALUATE_VECTOR(m_vecMoveDir, 0, PUSH_CHANGED_MOVEDIR)
    EVALUATE_VECTOR(m_vecMoveDir, 1, PUSH_CHANGED_MOVEDIR)
    EVALUATE_VECTOR(m_vecMoveDir, 2, PUSH_CHANGED_MOVEDIR)
    EVALUATE_VECTOR(m_pushAngle, 0, PUSH_CHANGED_MOVEDIR)
    EVALUATE_VECTOR(m_pushAngle, 1, PUSH_CHANGED_MOVEDIR)
    EVALUATE_VECTOR(m_pushAngle, 2, PUSH_CHANGED_MOVEDIR)
    EVALUATE_FIELD(m_bHasTarget, PUSH_CHANGED_MOVEDIR)
}

float
trigger_jump::SendEntity(entity ePEnt, float flChanged)
{
    if (!modelindex)
        return (0);

    if (clienttype(ePEnt) != CLIENTTYPE_REAL)
        return (0);

    WriteByte(MSG_ENTITY, ENT_PUSH);

    /* optimisation */
    {
        /* we'll never network these if we aren't moving. */
        if (movetype == MOVETYPE_NONE) {
            flChanged &= ~PUSH_CHANGED_VELOCITY;
            flChanged &= ~PUSH_CHANGED_ANGULARVELOCITY;
        }
    }

    /* broadcast how much data is expected to be read */
    WriteFloat(MSG_ENTITY, flChanged);

    SENDENTITY_COORD(origin[0], PUSH_CHANGED_ORIGIN_X)
    SENDENTITY_COORD(origin[1], PUSH_CHANGED_ORIGIN_Y)
    SENDENTITY_COORD(origin[2], PUSH_CHANGED_ORIGIN_Z)
    SENDENTITY_ANGLE(angles[0], PUSH_CHANGED_ANGLES_X)
    SENDENTITY_ANGLE(angles[1], PUSH_CHANGED_ANGLES_Y)
    SENDENTITY_ANGLE(angles[2], PUSH_CHANGED_ANGLES_Z)
    SENDENTITY_SHORT(modelindex, PUSH_CHANGED_MODELINDEX)
    SENDENTITY_BYTE(solid, PUSH_CHANGED_SOLIDMOVETYPE)
    SENDENTITY_BYTE(movetype, PUSH_CHANGED_SOLIDMOVETYPE)
    SENDENTITY_COORD(mins[0], PUSH_CHANGED_SIZE)
    SENDENTITY_COORD(mins[1], PUSH_CHANGED_SIZE)
    SENDENTITY_COORD(mins[2], PUSH_CHANGED_SIZE)
    SENDENTITY_COORD(maxs[0], PUSH_CHANGED_SIZE)
    SENDENTITY_COORD(maxs[1], PUSH_CHANGED_SIZE)
    SENDENTITY_COORD(maxs[2], PUSH_CHANGED_SIZE)
    SENDENTITY_BYTE(frame, PUSH_CHANGED_FRAME)
    SENDENTITY_COORD(velocity[0], PUSH_CHANGED_VELOCITY)
    SENDENTITY_COORD(velocity[1], PUSH_CHANGED_VELOCITY)
    SENDENTITY_COORD(velocity[2], PUSH_CHANGED_VELOCITY)
    SENDENTITY_COORD(avelocity[0], PUSH_CHANGED_ANGULARVELOCITY)
    SENDENTITY_COORD(avelocity[1], PUSH_CHANGED_ANGULARVELOCITY)
    SENDENTITY_COORD(avelocity[2], PUSH_CHANGED_ANGULARVELOCITY)
    SENDENTITY_FLOAT(m_flSpeed, PUSH_CHANGED_SPEED)
    SENDENTITY_FLOAT(m_vecMoveDir[0], PUSH_CHANGED_MOVEDIR)
    SENDENTITY_FLOAT(m_vecMoveDir[1], PUSH_CHANGED_MOVEDIR)
    SENDENTITY_FLOAT(m_vecMoveDir[2], PUSH_CHANGED_MOVEDIR)
    SENDENTITY_FLOAT(m_pushAngle[0], PUSH_CHANGED_MOVEDIR)
    SENDENTITY_FLOAT(m_pushAngle[1], PUSH_CHANGED_MOVEDIR)
    SENDENTITY_FLOAT(m_pushAngle[2], PUSH_CHANGED_MOVEDIR)
    SENDENTITY_BYTE(m_bHasTarget, PUSH_CHANGED_MOVEDIR)

    return true;
}
#endif

#ifdef CLIENT
void
trigger_jump::ReceiveEntity(float flNew, float flChanged)
{
    READENTITY_COORD(origin[0], PUSH_CHANGED_ORIGIN_X)
    READENTITY_COORD(origin[1], PUSH_CHANGED_ORIGIN_Y)
    READENTITY_COORD(origin[2], PUSH_CHANGED_ORIGIN_Z)
    READENTITY_ANGLE(angles[0], PUSH_CHANGED_ANGLES_X)
    READENTITY_ANGLE(angles[1], PUSH_CHANGED_ANGLES_Y)
    READENTITY_ANGLE(angles[2], PUSH_CHANGED_ANGLES_Z)
    READENTITY_SHORT(modelindex, PUSH_CHANGED_MODELINDEX)
    READENTITY_BYTE(solid, PUSH_CHANGED_SOLIDMOVETYPE)
    READENTITY_BYTE(movetype, PUSH_CHANGED_SOLIDMOVETYPE)
    READENTITY_COORD(mins[0], PUSH_CHANGED_SIZE)
    READENTITY_COORD(mins[1], PUSH_CHANGED_SIZE)
    READENTITY_COORD(mins[2], PUSH_CHANGED_SIZE)
    READENTITY_COORD(maxs[0], PUSH_CHANGED_SIZE)
    READENTITY_COORD(maxs[1], PUSH_CHANGED_SIZE)
    READENTITY_COORD(maxs[2], PUSH_CHANGED_SIZE)
    READENTITY_BYTE(frame, PUSH_CHANGED_FRAME)
    READENTITY_COORD(velocity[0], PUSH_CHANGED_VELOCITY)
    READENTITY_COORD(velocity[1], PUSH_CHANGED_VELOCITY)
    READENTITY_COORD(velocity[2], PUSH_CHANGED_VELOCITY)
    READENTITY_COORD(avelocity[0], PUSH_CHANGED_ANGULARVELOCITY)
    READENTITY_COORD(avelocity[1], PUSH_CHANGED_ANGULARVELOCITY)
    READENTITY_COORD(avelocity[2], PUSH_CHANGED_ANGULARVELOCITY)
    READENTITY_FLOAT(m_flSpeed, PUSH_CHANGED_SPEED)
    READENTITY_FLOAT(m_vecMoveDir[0], PUSH_CHANGED_MOVEDIR)
    READENTITY_FLOAT(m_vecMoveDir[1], PUSH_CHANGED_MOVEDIR)
    READENTITY_FLOAT(m_vecMoveDir[2], PUSH_CHANGED_MOVEDIR)
    READENTITY_FLOAT(m_pushAngle[0], PUSH_CHANGED_MOVEDIR)
    READENTITY_FLOAT(m_pushAngle[1], PUSH_CHANGED_MOVEDIR)
    READENTITY_FLOAT(m_pushAngle[2], PUSH_CHANGED_MOVEDIR)
    READENTITY_BYTE(m_bHasTarget, PUSH_CHANGED_MOVEDIR)

    if (flChanged & PUSH_CHANGED_SIZE)
        setsize(this, mins, maxs);

    setorigin(this, origin);
}

void
trigger_jump_ReadEntity(bool new)
{
    float fl;

    trigger_jump rend = (trigger_jump)self;
    if (new) {
        spawnfunc_trigger_jump();
    }

    fl = readfloat();
    rend.ReceiveEntity(new, fl);
}
#endif

.float jump_touched;
void
trigger_jump::Touch(entity eToucher)
{
    ncPlayer ourPlayer = (ncPlayer)eToucher;

#ifdef SERVER
    eActivator = (ncEntity)eToucher;
#endif

    switch(ourPlayer.movetype) {
    case MOVETYPE_NONE:
    case MOVETYPE_PUSH:
    case MOVETYPE_NOCLIP:
    case MOVETYPE_FOLLOW:
        return;
    }

    if (m_bHasTarget) {
        if (ourPlayer.jump_touched < time) {
            ourPlayer.velocity = GetJumpVelocity(WorldSpaceCenter(), m_vecMoveDir, 1.0);
            ourPlayer.velocity[2] = GetJumpHeight(WorldSpaceCenter(), m_vecMoveDir, 1.0);
            ourPlayer.StartSound("triggerjump.wav", CHAN_VOICE, 0, true);
            
            if (ourPlayer.velocity[2] < 380)
                ourPlayer.velocity[2] = 380;

            ourPlayer.jump_touched = time + 1.0f;

        }

        return;
    }
}
