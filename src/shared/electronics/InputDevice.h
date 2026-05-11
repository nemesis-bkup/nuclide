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

/*! \brief Shared-Entity: Electronics Input Device */
/*!QUAKED ncInputDevice (1 0 0) (-50 -50 0) (50 50 70)
# OVERVIEW
An input device, that can interact with ncMediaSource entities, such
as ncAVReceiver, ncXTerminal etc.

# KEYS
- "targetname" : Name

# SPAWNFLAGS

None currently.

# NOTES

None currently.

# TRIVIA
This entity was introduced in Nuclide (2025).

@ingroup sharedentity
@ingroup pointentity
*/
class ncInputDevice:ncVehicle
{
public:
    void ncInputDevice(void);

    virtual void Spawned(void);
    virtual void WeaponInput(void);
    virtual void PlayerInput(void);

#ifdef CLIENT
    virtual bool HideViewWeapon(void);
    virtual void UpdateView(void);
    virtual void PredictPreFrame(void);
    virtual void PredictPostFrame(void);
    virtual void ReceiveEntity(float flNew, float flSendFlags);
#endif

#ifdef SERVER
    virtual void Respawn(void);
    virtual void OnPlayerUse(void);
    virtual void EvaluateEntity(void);
    virtual float SendEntity(entity,float);
    virtual void SpawnKey(string keyName, string setValue);
#endif

private:
    NETWORKED_VECTOR(m_vecSeatOffest)
    NETWORKED_FLOAT(m_flUseTime)
};

