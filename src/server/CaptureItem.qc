/*
 * Copyright (c) 2023-2025 Vera Visions LLC.
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
ncCaptureItem::Precache(void)
{
    if (STRING_SET(m_outputOnCapture))
        m_outputOnCapture = CreateOutput(m_outputOnCapture);
    if (STRING_SET(m_outputOnTake))
        m_outputOnTake = CreateOutput(m_outputOnTake);
    if (STRING_SET(m_outputOnReturn))
        m_outputOnReturn = CreateOutput(m_outputOnReturn);
    if (STRING_SET(m_outputOnDrop))
        m_outputOnDrop = CreateOutput(m_outputOnDrop);
}

void
ncCaptureItem::SpawnKey(string strKey, string strValue)
{
    switch (strKey) {
    case "OnCapture":
        m_outputOnCapture = PrepareOutput(m_outputOnCapture, strValue);
        break;
    case "OnTake":
        m_outputOnTake = PrepareOutput(m_outputOnTake, strValue);
        break;
    case "OnReturn":
        m_outputOnReturn = PrepareOutput(m_outputOnReturn, strValue);
        break;
    case "OnDrop":
        m_outputOnDrop = PrepareOutput(m_outputOnDrop, strValue);
        break;
    default:
        super::SpawnKey(strKey, strValue);
    }
}

void
ncCaptureItem::Respawn(void)
{
    super::Respawn();

    m_desiredItem = GetSpawnString("needs");
    m_goalItem = GetSpawnString("goalItem");
    m_requiresItem = GetSpawnString("needs");
    m_playerScore = GetSpawnInt("playerScore");
    m_teamScore = GetSpawnInt("teamScore");
    m_goalNo = GetSpawnFloat("goal_no");

    SetSolid(SOLID_TRIGGER);
    SetMovetype(MOVETYPE_NONE);
    SetSize(GetSpawnVector("goal_min"), GetSpawnVector("goal_max"));
    m_hintType = "GOALITEM";
    owner = this;

    if (GetSpawnBool("dropToFloor") == true) {
        DropToFloor();
    }
}

void
ncCaptureItem::Captured(float teamNum)
{
    for (ncCaptureItem e = __NULL__; ((e = (ncCaptureItem)find(e, ::spawnclass, spawnclass)));) {
        if (e.m_goalNo == teamNum) {
            e.Respawn();
            e.Show();
        }
    }
}

void
ncCaptureItem::Return(void)
{
    Respawn();
    UseOutput(this, m_outputOnReturn);
}

void
ncCaptureItem::Spawned(void)
{
    super::Spawned();
    m_hintType = "GOALITEM";
}

void
ncCaptureItem::WatchPlayer(void)
{
    if (m_watchPlayer.health <= 0) {
        ncItem dropFlag = (ncItem)spawnClass(m_goalItem, m_watchPlayer.GetOrigin());
        m_watchPlayer = __NULL__;
        dropFlag.ScheduleThink(Destroy, 30.0f);
        dropFlag.SetMovetype(MOVETYPE_TOSS);
        dropFlag.AddVelocity([0,0, 200]);
        dropFlag.target = classname;
        dropFlag.team = m_goalNo;
        dropFlag.m_goalNo = m_goalNo;
        dropFlag.m_touchingOnlyTeam = -m_goalNo;
        dropFlag.m_hintType = "GOALITEM";
        dropFlag.skin = skin;
        dropFlag.m_renderMode = m_renderMode;
        dropFlag.m_renderFX = m_renderFX;
        dropFlag.m_renderAmount = m_renderAmount;
        dropFlag.m_renderColor = m_renderColor;
        ScheduleThink(Return, 30.0f);
        UseOutput(this, m_outputOnDrop);
    }

    /* continue */
    if (m_watchPlayer) {
        ScheduleThink(WatchPlayer, 0.0f);
    }
}

void
ncCaptureItem::Touch(entity touchingEntity)
{
    ncActor ourToucher = (ncActor)touchingEntity;
    ncItem theItem = __NULL__;

    if (!touchingEntity) {
        return;
    }

    if (is.Player(touchingEntity) == false) {
        return;
    }

    if (ourToucher.team != m_goalNo) {
        ourToucher.GiveNamedItem(m_goalItem);
        theItem = ourToucher.GetItem(m_goalItem);

        if (!theItem) {
            EntError("Couldn't get item %s we'd just attempted to give to %s (%d)", m_goalItem, ourToucher.classname, num_for_edict(ourToucher));
            return;
        }

        theItem.team = m_goalNo;
        theItem.target = classname;
        Disappear();
        UseOutput(touchingEntity, m_outputOnTake);

        m_watchPlayer = (ncPlayer)ourToucher;
        ScheduleThink(WatchPlayer, 0.0f);
    } else if (STRING_SET(m_desiredItem)) {
        theItem = ourToucher.GetItem(m_desiredItem);

        if (theItem) {
            if (m_teamScore >= 1i) {
                teams.AddScore(touchingEntity.team, m_teamScore);
            }

            if (m_playerScore >= 1i) {
                ourToucher.frags += (float)m_playerScore;
            }

            Captured(theItem.team);
            UseOutput(touchingEntity, m_outputOnCapture);
            ourToucher.RemoveItem(theItem);
        }
    }
}
