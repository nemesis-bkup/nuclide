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

class
ncAnimationManager:ncEntity
{
    void ncAnimationManager(void);

    nonvirtual ncAnimationManager ManagerForEntity(entity playerEntity);

    nonvirtual void UpdateLerpAnimations(entity targetE, entity physVars);
    nonvirtual void UpdatePlayerAnimation_Basic(entity targetE);
    nonvirtual void UpdatePlayerAnimation_Skeletal(entity targetE);
    nonvirtual void UpdatePlayerAnimation_Valve(entity targetE);
    nonvirtual void UpdatePlayerAnimation_Goose(entity targetE);
    nonvirtual void TransferAnimationData(entity targetE);

    nonvirtual void SetAnimationPrefix(string animPrefix);
    nonvirtual void AdvanceAnimation(entity sourceVelocity, float timelength);
    nonvirtual void PlayGesture(float gestureAnim, float overrideTime);
    virtual void PredictPreFrame(void);
    virtual void PredictPostFrame(void);

#ifdef SERVER
    virtual void EvaluateEntity(void);
    virtual float SendEntity(entity ePEnt, float flChanged);
#endif

#ifdef CLIENT
    virtual void ReceiveEntity(float flNew, float flChanged);
#endif

private:

    nonvirtual float __ActForPrefix(string actName, string animPrefix, string emotionString);

    /* animation */
    NETWORKED_FLOAT(anim_top)
    NETWORKED_FLOAT(anim_top_time)
    NETWORKED_FLOAT(anim_top_delay)
    NETWORKED_FLOAT(anim_bottom)
    NETWORKED_FLOAT(anim_bottom_time)

    NETWORKED_ENTITY(m_targetEntity)
    NETWORKED_FLOAT(m_animBackend)
    NETWORKED_FLOAT(m_actIdle)
    NETWORKED_FLOAT(m_actIdleCrouch)
    NETWORKED_FLOAT(m_actIdleProne)
    NETWORKED_FLOAT(m_actWalk)
    NETWORKED_FLOAT(m_actWalkCrouch)
    NETWORKED_FLOAT(m_actWalkProne)
    NETWORKED_FLOAT(m_actRun)
    NETWORKED_FLOAT(m_actJump)
    NETWORKED_FLOAT(m_actAim)
    NETWORKED_FLOAT(m_actDraw)
    NETWORKED_FLOAT(m_actAttack)
    NETWORKED_FLOAT(m_actReloadStart)
    NETWORKED_FLOAT(m_actReload)
    NETWORKED_FLOAT(m_actReloadEnd)
    NETWORKED_FLOAT(m_actHolster)
    NETWORKED_FLOAT(m_boneSpine)
    NETWORKED_FLOAT(m_torsoFirst)
    NETWORKED_FLOAT(m_torsoLast)
    NETWORKED_FLOAT(m_torsoTwistYaw)
    NETWORKED_FLOAT(m_targetEntityEntityNum)
    NETWORKED_VECTOR(m_twistVec)
    NETWORKED_VECTOR(m_pitchVec)

    // generated for lerping purposes
    float m_slowAnim;
    float m_fastAnim;
    float m_playerSpeed;
    float m_lerpFrac;

};

void
ncAnimationManager::ncAnimationManager(void)
{
    m_targetEntity = __NULL__;
    m_targetEntityEntityNum = 0;

    anim_top = 0.0;
    anim_top_time = 0.0;
    anim_top_delay = 0.0;
    anim_bottom = 0.0;
    anim_bottom_time = 0.0;
    m_animBackend = 0.0;
    m_actIdle = 0.0;
    m_actIdleCrouch = 0.0;
    m_actIdleProne = 0.0;
    m_actWalk = 0.0;
    m_actWalkCrouch = 0.0;
    m_actWalkProne = 0.0;
    m_actRun = 0.0;
    m_actJump = 0.0;
    m_actAim = 0.0;
    m_actDraw = 0.0;
    m_actAttack = 0.0;
    m_actReloadStart = 0.0;
    m_actReload = 0.0;
    m_actReloadEnd = 0.0;
    m_actHolster = 0.0;
    m_boneSpine = 0.0;
    m_torsoFirst = 0.0;
    m_torsoLast = 0.0;
    m_torsoTwistYaw = 0.0;
}

typedef enumflags
{
    ANTMENT_CHANGED_NOTHING,
    ANIMENT_CHANGED_ACTS_TOP,
    ANIMENT_CHANGED_ACTS_BOTTOM,
    ANIMENT_CHANGED_BONESETUP,
    ANIMENT_CHANGED_ANIMATION,
    ANIMENT_CHANGED_SET,
    ANIMENT_CHANGED_TIMERS,
};

enum
{
    ANIMATIONMODEL_BASIC,
    ANIMATIONMODEL_SKELETAL,
    ANIMATIONMODEL_HLMDL_VALVE,
    ANIMATIONMODEL_HLMDL_GOOSE,
};
