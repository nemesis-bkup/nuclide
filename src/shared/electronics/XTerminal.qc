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
ncXTerminal::ncXTerminal(void)
{
    m_mediaSize = [1024,768];
}

#ifdef CLIENT
void
ncXTerminal::Draw(void)
{
    vguiWidget uiChain = (vguiWidget)m_UIChain;

    if (!uiChain) {
        return;
    }

    uiChain.Draw();
}

bool
ncXTerminal::Input(float a,float b,float c,float d)
{
    vguiWidget uiChain = (vguiWidget)m_UIChain;

    if (!uiChain) {
        return (false);
    }

    return uiChain.Input(a,b,c,d);
}

/*
============
ncSurfacePropEntity::ReceiveEntity
============
*/
void
ncXTerminal::ReceiveEntity(float flNew, float flChanged)
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

        /* initialize UI panel here */
        m_UIChain = spawn(vguiWidget);
        vguiWidget uiChain = (vguiWidget)m_UIChain;
        uiChain.m_iFlags = 1;

        m_xTermView = spawn(vguiXView);
        vguiXView ourVideo = (vguiXView)m_xTermView;
        ourVideo.SetSize([1024,768]);
        uiChain.Add(ourVideo);
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
ncXTerminal::EvaluateEntity(void)
{
    if (modelindex == 0) {
        return;
    }

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
ncXTerminal::SendEntity(entity ePEnt, float flChanged)
{
    if (!modelindex) {
        return (0);
    }

    if (clienttype(ePEnt) != CLIENTTYPE_REAL) {
        return (0);
    }

    WriteByte(MSG_ENTITY, ENT_XTERMINAL);

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
ncXTerminal::SpawnKey(string keyName, string setValue)
{
    switch (keyName) {
    default:
        super::SpawnKey(keyName, setValue);
    }
}

void
ncXTerminal::Spawned(void)
{
    super::Spawned();
}

void
ncXTerminal::Respawn(void)
{
    super::Respawn();
    SetHealth(GetSpawnFloat("health"));
    MakeVulnerable();
    SetSolid(SOLID_BBOX);
    SetMovetype(MOVETYPE_NONE);
}

void
ncXTerminal::Death(entity inflictor, entity attacker, int damagePoints, vector dir, vector absImpactPos, int hitBody)
{
    modelindex = 0;
}

#endif
