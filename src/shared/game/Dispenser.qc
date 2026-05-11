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
ncDispenser::ncDispenser(void)
{
#ifdef SERVER
    m_nextDispenseTime = 0.0f;
#endif
}

#ifdef CLIENT
void
ncDispenser::ReceiveEntity(float flNew, float flChanged)
{
    ncRenderableEntity::ReceiveEntity(flNew, flChanged);
}
#endif

#ifdef SERVER
float
ncDispenser::SendEntity(entity pvsEnt, float flChanged)
{
    return ncRenderableEntity:: SendEntity(pvsEnt, flChanged);
}
void
ncDispenser::EvaluateEntity(void)
{
    ncRenderableEntity::EvaluateEntity();
}

void
ncDispenser::Touch(entity touchingEntity)
{
    if (m_nextDispenseTime > time) {
        return;
    }

    if (ItemBonusCheck(touchingEntity) == true) {
        GiveBonusItems(touchingEntity, true);
        UseTargets(touchingEntity, TRIG_TOGGLE, GetTriggerDelay());
    } 

    if (m_dispenseDelay > 0.0f) {
        m_nextDispenseTime = GetTime() + m_dispenseDelay;
    } else {
        m_nextDispenseTime = GetTime() + 1.0f;
    }
}

void
ncDispenser::Respawn(void)
{
    SetSolid(SOLID_TRIGGER);
    SetMovetype(MOVETYPE_NONE);
    SetModel(GetSpawnString("model"));
    SetOrigin(GetSpawnVector("origin"));
    SetAngles(GetSpawnVector("angles"));
    SetSize(GetSpawnVector("mins"), GetSpawnVector("maxs"));
    m_dispenseDelay = GetSpawnFloat("delay");
}
#endif
