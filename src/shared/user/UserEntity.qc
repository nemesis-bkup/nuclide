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
ncUserEntity::ncUserEntity(void)
{
#ifdef CLIENT
    m_uiControlView = __NULL__;
#endif

    m_ownerClientID = -1;
    m_ownerGroupID = -1;
}

void
ncUserEntity::Spawned(void)
{
    super::Spawned();

    spawnclass = "ncUserEntity";
}

#ifdef CLIENT
void
ncUserEntity::_ReceiveComplete(float u1, float u2)
{
    super::_ReceiveComplete(u1, u2);
    drawmask = MASK_CLIENTENTITY;
}

void
ncUserEntity::RequestRemoval(void)
{
    localcmd(sprintf("cmd ui_input %d kill\n", m_serverSideNum));
}

void
ncUserEntity::OnGainedFocus(void)
{
    if (m_uiControlView) {
        vguiView controlView = (vguiView)m_uiControlView;
        controlView.Show();
    }
}

void
ncUserEntity::OnLostFocus(void)
{
    if (m_uiControlView) {
        vguiView controlView = (vguiView)m_uiControlView;
        controlView.Hide();
    }
}

#endif

#ifdef SERVER

ncUserEntity
ncUserEntity::AllocateNewType(ncPlayer queryingPlayer, string entClass)
{
    ncUserEntity userURL = 0;
    vector src;
    vector co;
    vector forwardDir;
    vector planeNormal;
    vector endPos;
    const float maxDist = 512.0f;
    float bestDist;

    src = queryingPlayer.GetEyePos();

    makevectors(queryingPlayer.v_angle);
    forwardDir = v_forward;
    traceline(src, src + (forwardDir * maxDist), MOVE_NORMAL, queryingPlayer);
    planeNormal = trace_plane_normal;
    endPos = trace_endpos;

    if (trace_fraction >= 1.0f) {
        return (__NULL__);
    }

    bestDist = maxDist;

    for (ncUserEntity e = __NULL__; (e = (ncUserEntity)nextent(e));) {
        if (e.classname != entClass) {
            continue;
        }

        float dist = distance(e.origin, src);

        if (dist > maxDist) {
            continue;
        }

        if (dist <= bestDist) {
            bestDist = dist;
            userURL = e;
        }
    }

    /* spawn the new one */
    if (!userURL) {
        /* limit */
        if (ncUserEntityManager::NumUserObjectsForClient(queryingPlayer, entClass) >= 1) {
            return (__NULL__);
        }

        userURL = spawn(ncUserEntity);
        CallSpawnfuncByName(userURL, entClass);
        userURL.Spawn();

        /* calculate the rotation by taking our current view and mapping it
         * against the surface we're looking at */
        makevectors([queryingPlayer.v_angle[0] * -1, queryingPlayer.v_angle[1], queryingPlayer.v_angle[2]]);
        co = forwardDir -(forwardDir * planeNormal) * planeNormal;

        /* quick fix */
        if (planeNormal[2] == 0) {
            co = [0,0,1];
        }

        /* apply the angles and apply networking */
        userURL.angles = vectoangles(co, planeNormal);

        setorigin(userURL, endPos + (forwardDir * -(userURL.m_flScale * 5)));
    }

    return (userURL);
}
#endif
