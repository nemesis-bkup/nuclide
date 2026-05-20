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

/* FIXME: the engine needs to fix sound offset in sound() calls before this gets set to false */
var bool autocvar_avReceiver_ignoreSoundOffset = true;

#ifdef CLIENT
const string g_videoStaticMat = "{\n" \
                "\t{\n" \
                "\t\tvideomap video/static.roq\n" \
                "\t}\n" \
                "}\n";
#endif

void
ncAVReceiver::ncAVReceiver(void)
{
    m_avReceiverChannel = g_int_null;
    m_avReceiverVolume = 1.0f;
    m_avReceiverMuted = false;
    m_mediaSize = [320,240];
}

#ifdef SERVER
void
ncAVReceiver::Input(entity entityActivator, string inputName, string dataField)
{
    switch (inputName) {
    case "nextchannel":
        m_avReceiverChannel++;
        break;
    case "previouschannel":
        m_avReceiverChannel--;

        if (m_avReceiverChannel < 0) {
            m_avReceiverChannel = 0;
        }
        break;
    case "switchchannel":
        m_avReceiverChannel = ReadInt(dataField);

        if (m_avReceiverChannel < 0) {
            m_avReceiverChannel = 0;
        }
        break;
    case "mute":
        m_avReceiverMuted = true;
        break;
    case "unmute":
        m_avReceiverMuted = false;
        break;
    case "togglemute":
        m_avReceiverChannel = m_avReceiverMuted ? (false) : (true);
        break;
    default:
        super::Input(entityActivator, inputName, dataField);
    }
}

void
ncAVReceiver::SpawnKey(string keyName, string setValue)
{
    switch (keyName) {
    case "channel":
        m_avReceiverChannel = ReadInt(setValue);
        break;
    case "enabled":
        m_triggerEnabled = ReadBool(setValue);
        break;
    case "volume":
        m_avReceiverVolume = ReadFloat(setValue);
        break;
    case "muted":
        m_avReceiverMuted = ReadBool(setValue);
        break;
    default:
        super::SpawnKey(keyName, setValue);
        break;
    }
}

void
ncAVReceiver::EvaluateEntity(void)
{
    EVALUATE_VECTOR(origin, 0, AVRECEIVERFL_ORIGIN)
    EVALUATE_VECTOR(origin, 1, AVRECEIVERFL_ORIGIN)
    EVALUATE_VECTOR(origin, 2, AVRECEIVERFL_ORIGIN)
    EVALUATE_FIELD(m_avReceiverChannel, AVRECEIVERFL_CHAN)
    EVALUATE_FIELD(m_triggerEnabled, AVRECEIVERFL_ENABLED)
    EVALUATE_FIELD(m_avReceiverVolume, AVRECEIVERFL_VOLUME)
    EVALUATE_FIELD(m_avReceiverMuted, AVRECEIVERFL_MUTED)
}

float
ncAVReceiver::SendEntity(entity ePEnt, float flChanged)
{
    WriteByte(MSG_ENTITY, ENT_AVRECEIVER);
    WriteFloat(MSG_ENTITY, flChanged);
    SENDENTITY_INT(num_for_edict(this), AVRECEIVERFL_ENABLED)
    SENDENTITY_COORD(origin[0], AVRECEIVERFL_ORIGIN)
    SENDENTITY_COORD(origin[1], AVRECEIVERFL_ORIGIN)
    SENDENTITY_COORD(origin[2], AVRECEIVERFL_ORIGIN)
    SENDENTITY_INT(m_avReceiverChannel, AVRECEIVERFL_CHAN)
    SENDENTITY_BYTE(m_triggerEnabled, AVRECEIVERFL_ENABLED)
    SENDENTITY_FLOAT(m_avReceiverVolume, AVRECEIVERFL_VOLUME)
    SENDENTITY_BYTE(m_avReceiverMuted, AVRECEIVERFL_MUTED)
    return (1);
}
#endif

#ifdef CLIENT

int
ncAVReceiver::GlobalBroadcasters(void)
{
    int transmitterEnum = 0i;

    for (ncAVTransmitter receiverEnum = 0; (receiverEnum = (ncAVTransmitter)find(receiverEnum, ::classname, "ncAVTransmitter"));) {
        transmitterEnum++;
    }
}

ncAVTransmitter
ncAVReceiver::GetTransmitterForChannel(int channelNum)
{
    for (ncAVTransmitter receiverEnum = 0; (receiverEnum = (ncAVTransmitter)find(receiverEnum, ::classname, "ncAVTransmitter"));) {
        if (receiverEnum.m_tvChannelNum == channelNum) {
            return receiverEnum;
        }
    }

    return (__NULL__);
}

string
ncAVReceiver::GetMaterialForChannel(int channelNum)
{
    for (ncAVTransmitter receiverEnum = 0; (receiverEnum = (ncAVTransmitter)find(receiverEnum, ::classname, "ncAVTransmitter"));) {
        if (receiverEnum.m_tvChannelNum == channelNum) {
            return sprintf("tvchannel_%i", channelNum);
        }
    }

    shaderforname("video_static", g_videoStaticMat);
    return ("video_static");
}

void
ncAVReceiver::ReceiveEntity(float flNew, float flChanged)
{
    READENTITY_INT(m_serverSideNum, AVRECEIVERFL_ENABLED)
    READENTITY_COORD(origin[0], AVRECEIVERFL_ORIGIN)
    READENTITY_COORD(origin[1], AVRECEIVERFL_ORIGIN)
    READENTITY_COORD(origin[2], AVRECEIVERFL_ORIGIN)
    READENTITY_INT(m_avReceiverChannel, AVRECEIVERFL_CHAN)
    READENTITY_BYTE(m_triggerEnabled, AVRECEIVERFL_ENABLED)
    READENTITY_FLOAT(m_avReceiverVolume, AVRECEIVERFL_VOLUME)
    READENTITY_BYTE(m_avReceiverMuted, AVRECEIVERFL_MUTED)
    setorigin(this, origin);

    UpdateSpeakers();
    UpdateVideoOutputs();
}

void
ncAVReceiver::OnRemoveEntity(void)
{
    super::OnRemoveEntity();
    sound(this, CHAN_BODY, "common/null.wav", 0.5f, ATTN_IDLE);
    KillVideoOutputs();
}

void
ncAVReceiver::Draw(void)
{
    for (ncAVTransmitter receiverEnum = 0; (receiverEnum = (ncAVTransmitter)find(receiverEnum, ::classname, "ncAVTransmitter"));) {
        if (receiverEnum.m_tvChannelNum == m_avReceiverChannel) {
            receiverEnum.Draw();
        }
    }
}

void
ncAVReceiver::KillVideoOutputs(void)
{

}

void
ncAVReceiver::RefreshVideoDisplay(entity targetEntity)
{

}

void
ncAVReceiver::UpdateVideoOutputs(void)
{
    ncAVTransmitter findTransmitter = world;
    float bestDist = MAX_DISTANCE;

    /* find the closest transmitter source */
    for (ncAVTransmitter receiverEnum = 0; (receiverEnum = (ncAVTransmitter)find(receiverEnum, ::classname, "ncAVTransmitter"));) {
        float distanceToTransmitter = distance(receiverEnum.GetOrigin(), GetOrigin());

        if (receiverEnum.m_tvChannelNum == m_avReceiverChannel && distanceToTransmitter < bestDist) {
            findTransmitter = receiverEnum;
            bestDist = distanceToTransmitter;
        }
    }

    /* kill the sound if it's invalid */
    if (m_triggerEnabled == false || !findTransmitter) {
        KillVideoOutputs();
        return;
    }

}

void
ncAVReceiver::UpdateSpeakers(void)
{
    ncAVTransmitter findTransmitter = world;
    float bestDist = 99999;

    /* find the closest transmitter source */
    for (ncAVTransmitter receiverEnum = 0; (receiverEnum = (ncAVTransmitter)find(receiverEnum, ::classname, "ncAVTransmitter"));) {
        float distanceToTransmitter = distance(receiverEnum.GetOrigin(), GetOrigin());

        if (receiverEnum.m_tvChannelNum == m_avReceiverChannel && distanceToTransmitter < bestDist) {
            findTransmitter = receiverEnum;
            bestDist = distanceToTransmitter;
        }
    }

    /* kill the sound if it's invalid */
    if (m_triggerEnabled == false || !findTransmitter) {
        sound(this, CHAN_BODY, "common/null.wav", 0.5f, ATTN_IDLE);
        EntLog("Nulled audio stream");
        return;
    }

    float soundOffset = (time - findTransmitter.m_tvChannelTime);
    float finalVolume = (m_avReceiverMuted) ? (0.001) : m_avReceiverVolume;

    if (soundOffset < 1 || autocvar_avReceiver_ignoreSoundOffset) {
        sound(this, CHAN_BODY, findTransmitter.m_tvChannelAudio, finalVolume, ATTN_IDLE, 0, 0, 0);
    } else {
        soundupdate(this, CHAN_BODY, findTransmitter.m_tvChannelAudio, finalVolume, ATTN_IDLE, 0, 0, soundOffset);
    }

    if (m_avReceiverMuted)
        EntLog("Playing audio %s at offset %f with muted volume", findTransmitter.m_tvChannelAudio, soundOffset);
    else
        EntLog("Playing audio %s at offset %f with volume %f", findTransmitter.m_tvChannelAudio, soundOffset, finalVolume);
}
#endif
