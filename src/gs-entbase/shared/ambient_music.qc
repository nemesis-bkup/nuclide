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

typedef enumflags
{
    AMBIENTMUSIC_TRACK,
    AMBIENTMUSIC_VOLUME,
    AMBIENTMUSIC_STATE,
};

typedef enum
{
    AMBIENTMUSICEVENT_PLAY,
    AMBIENTMUSICEVENT_STOP,
};

/*! \brief Shared-Entity: Level Music */
/*!QUAKED ambient_music (0.3 0.1 0.6) (-8 -8 -8) (8 8 8) SILENT LOOP ACTIVATORONLY
# OVERVIEW
Used to play a global music track within a level.

# KEYS
- "targetname" : Name
- "message" : Music track to play.
- "volume" : Playback volume from 0 to 10 (needs engine support, TBA)

# SPAWNFLAGS
- SILENT (1) : Starts silent. Needs to be triggered for music to play.
- LOOP (2) : Music track will loop.
- ONACTIVATOR (4) : Only the activator receives the music update.

# TRIVIA
This entity was introduced in Sven Coop (1999).

@ingroup sharedentity
@ingroup pointentity
*/
class
ambient_music:ncPointTrigger
{
    void ambient_music(void);

#ifdef SERVER
    virtual void Respawn(void);
    virtual void EvaluateEntity(void);
    virtual bool SendEntity(entity pvsEnt, float flChanged);
    virtual void Trigger(entity, triggermode_t);
#endif

#ifdef CLIENT
    virtual void ReceiveEvent(float eventID);
    virtual void ReceiveEntity(float flNew, float flChanged);
    nonvirtual void Event_PlayMusicTrack(void);
    nonvirtual void Event_StopMusicTrack(void);
#endif

    NETWORKED_STRING(m_musicTrack)
    NETWORKED_FLOAT(m_musicVolume)
    NETWORKED_BOOL(m_musicPlaying)
    NETWORKED_BOOL(m_musicLoops)
};

void
ambient_music::ambient_music(void)
{
    m_musicTrack = "";
    m_musicVolume = 0.0f;
    m_musicPlaying = false;
    m_musicLoops = false;
}

#ifdef SERVER
void
ambient_music::Respawn(void)
{
    m_musicTrack = GetSpawnString("message");
    m_musicVolume = GetSpawnFloat("volume") / 10;
    m_musicPlaying = HasSpawnFlags(1) ? (false) : (true);
    m_musicLoops = HasSpawnFlags(2);
}

void
ambient_music::Trigger(entity entityActivator, triggermode_t state)
{
    if (state == TRIG_OFF) {
        WriteEntityEvent(MSG_MULTICAST, this, AMBIENTMUSICEVENT_STOP);
    } else {
        WriteEntityEvent(MSG_MULTICAST, this, AMBIENTMUSICEVENT_PLAY);
    }

    msg_entity = entityActivator;
    multicast(GetOrigin(), MULTICAST_ONE_R);
}

void
ambient_music::EvaluateEntity(void)
{
    pvsflags = PVSF_NOREMOVE | PVSF_IGNOREPVS;
    EVALUATE_FIELD(m_musicTrack, AMBIENTMUSIC_TRACK)
    EVALUATE_FIELD(m_musicVolume, AMBIENTMUSIC_VOLUME)
    EVALUATE_FIELD(m_musicPlaying, AMBIENTMUSIC_STATE)
    EVALUATE_FIELD(m_musicLoops, AMBIENTMUSIC_STATE)
}

bool
ambient_music::SendEntity(entity pvsEnt, float flChanged)
{
    if (HasSpawnFlags(4)) {
        return (false);
    }

    WriteByte(MSG_ENTITY, ENT_AMBIENTMUSIC);
    WriteFloat(MSG_ENTITY, flChanged);
    SENDENTITY_STRING(m_musicTrack, AMBIENTMUSIC_TRACK)
    SENDENTITY_FLOAT(m_musicVolume, AMBIENTMUSIC_VOLUME)
    SENDENTITY_BYTE(m_musicPlaying, AMBIENTMUSIC_STATE)
    SENDENTITY_BYTE(m_musicLoops, AMBIENTMUSIC_STATE)
    return (true);
}
#endif

#ifdef CLIENT

void
ambient_music::Event_PlayMusicTrack(void)
{
    /* call me when I can play this with bgmvolume * m_musicVolume */
    if (m_musicLoops) {
        ncCommand("music %S", m_musicTrack);
    } else {
        ncCommand("music %S -", m_musicTrack);
    }
}

void
ambient_music::Event_StopMusicTrack(void)
{
    ncCommand("stopmusic");
}

void
ambient_music::ReceiveEvent(float eventID)
{
    switch (eventID) {
    case AMBIENTMUSICEVENT_PLAY:
        Event_PlayMusicTrack();
        break;
    case AMBIENTMUSICEVENT_STOP:
        Event_StopMusicTrack();
        break;
    }
}

void
ambient_music::ReceiveEntity(float flNew, float flChanged)
{
    READENTITY_STRING(m_musicTrack, AMBIENTMUSIC_TRACK)
    READENTITY_FLOAT(m_musicVolume, AMBIENTMUSIC_VOLUME)
    READENTITY_BYTE(m_musicPlaying, AMBIENTMUSIC_STATE)
    READENTITY_BYTE(m_musicLoops, AMBIENTMUSIC_STATE)

    if (!flChanged & AMBIENTMUSIC_STATE) {
        return;
    }

    if (m_musicPlaying) {
        Event_PlayMusicTrack();
    } else {
        Event_StopMusicTrack();
    }
}
#endif
