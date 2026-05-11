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

/*!QUAKED ncAVReceiver (1 0 0) (-8 -8 -8) (8 8 8)
Receives a video signal from an receiver and displays it.

# KEYS
- "angles" : Sets the pitch, yaw and roll angles of the surface.
- "channel" : Default channel to receive
- "volume" : Default receiver volume.
- "enabled" : Whether this entity is enabled by default.

# INPUTS
- "SwitchChannel" : Zap to a different channel, broadcasted from a different ncAVTransmitter that's active.

# SPAWNFLAGSS
None yet

# TRIVIA
This entity was introduced in Nuclide (2025).
*/
class
ncAVReceiver:ncMediaSource
{
public:
    void ncAVReceiver(void);

#ifdef SERVER
    virtual void Input(entity,string,string);
    virtual void SpawnKey(string,string);

    virtual void EvaluateEntity(void);
    virtual float SendEntity(entity,float);
#endif

#ifdef CLIENT
    virtual void Draw(void);
    virtual void ReceiveEntity(float,float);
    virtual void UpdateSpeakers(void);
    virtual void UpdateVideoOutputs(void);
    virtual void RefreshVideoDisplay(entity);
    virtual void OnRemoveEntity(void);
    virtual void KillVideoOutputs(void);

    nonvirtual int GlobalBroadcasters(void);
    nonvirtual ncAVTransmitter GetTransmitterForChannel(int channelNum);
    nonvirtual string GetMaterialForChannel(int channelNum);
#endif

private:
    NETWORKED_INT(m_avReceiverChannel)
    NETWORKED_FLOAT(m_avReceiverVolume)
    NETWORKED_FLOAT(m_avReceiverMuted)
    bool m_triggerEnabled_net;

#ifdef CLIENT
    bool m_triggerEnabled;
#endif
};

typedef enumflags
{
    AVRECEIVERFL_ORIGIN,
    AVRECEIVERFL_CHAN,
    AVRECEIVERFL_VOLUME,
    AVRECEIVERFL_ENABLED,
    AVRECEIVERFL_MUTED,
};
