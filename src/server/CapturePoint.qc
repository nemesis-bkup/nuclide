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

void
ncCapturePoint::ncCapturePoint(void)
{

}

void
ncCapturePoint::Captured(string classTarget, float teamNum)
{
    for (ncCaptureItem e = __NULL__; ((e = (ncCaptureItem)find(e, ::classname, classTarget)));) {
        if (e.m_goalNo == teamNum) {
            e.Respawn();
            e.Show();
        }
    }
}

void
ncCapturePoint::Respawn(void)
{
    super::Respawn();

    m_desiredItem = GetSpawnString("needs");
    m_playerScore = GetSpawnInt("playerScore");
    m_teamScore = GetSpawnInt("teamScore");
    m_goalNo = GetSpawnFloat("goal_no");

    SetSolid(SOLID_TRIGGER);
    SetMovetype(MOVETYPE_NONE);
    SetSize(GetSpawnVector("goal_min"), GetSpawnVector("goal_max"));
    m_hintType = "GOALCAP";

    if (GetSpawnBool("dropToFloor") == true) {
        DropToFloor();
    }
}

void
ncCapturePoint::Touch(entity touchingEntity)
{
    ncActor ourToucher = (ncActor)touchingEntity;

    if (is.Player(touchingEntity) == false) {
        return;
    }

    if (ourToucher.team != m_goalNo) {
        return;
    }

    ncItem theItem = ourToucher.GetItem(m_desiredItem);

    if (theItem) {
        if (m_teamScore >= 1i) {
            teams.AddScore(touchingEntity.team, m_teamScore);
        }

        if (m_playerScore >= 1i) {
            ourToucher.frags += (float)m_playerScore;
        }

        Captured(theItem.target, theItem.team);
        ourToucher.RemoveItem(theItem);
    }
}
