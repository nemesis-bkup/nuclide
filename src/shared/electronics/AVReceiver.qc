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
ncAVReceiver::ncAVReceiver(void)
{
	m_avReceiverChannel = g_int_null;
	m_avReceiverVolume = 1.0f;
}

#ifdef SERVER
void
ncAVReceiver::Input(entity entityActivator, string inputName, string dataField)
{
	switch (inputName) {
	case "SwitchChannel":
		m_avReceiverChannel = ReadInt(dataField);
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
}

float
ncAVReceiver::SendEntity(entity ePEnt, float flChanged)
{
	WriteByte(MSG_ENTITY, ENT_AVRECEIVER);
	WriteFloat(MSG_ENTITY, flChanged);
	SENDENTITY_COORD(origin[0], AVRECEIVERFL_ORIGIN)
	SENDENTITY_COORD(origin[1], AVRECEIVERFL_ORIGIN)
	SENDENTITY_COORD(origin[2], AVRECEIVERFL_ORIGIN)
	SENDENTITY_INT(m_avReceiverChannel, AVRECEIVERFL_CHAN)
	SENDENTITY_BYTE(m_triggerEnabled, AVRECEIVERFL_ENABLED)
	SENDENTITY_FLOAT(m_avReceiverVolume, AVRECEIVERFL_VOLUME)
	return (1);
}
#endif

#ifdef CLIENT
void
ncAVReceiver::ReceiveEntity(float flNew, float flChanged)
{
	READENTITY_COORD(origin[0], AVRECEIVERFL_ORIGIN)
	READENTITY_COORD(origin[1], AVRECEIVERFL_ORIGIN)
	READENTITY_COORD(origin[2], AVRECEIVERFL_ORIGIN)
	READENTITY_INT(m_avReceiverChannel, AVRECEIVERFL_CHAN)
	READENTITY_BYTE(m_triggerEnabled, AVRECEIVERFL_ENABLED)
	READENTITY_FLOAT(m_avReceiverVolume, AVRECEIVERFL_VOLUME)
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

/* FIXME: the engine needs to fix sound offset in sound() calls before this gets set to false */
var bool autocvar_avReceiver_ignoreSoundOffset = true;

void
ncAVReceiver::KillVideoOutputs(void)
{
	for (ncVideoDisplay videoDisplay = 0; (videoDisplay = (ncVideoDisplay)find(videoDisplay, ::classname, "ncVideoDisplay"));) {
		vguiTrUIMenu targetMenu = (vguiTrUIMenu)videoDisplay.m_videoDisplayUI;
		targetMenu.InterpretCommand(sprintf("setbackground channel %S", ""));
		targetMenu.InterpretCommand(sprintf("setbackground dog %S", ""));
		targetMenu.InterpretCommand(sprintf("setbackground toptext %S", ""));
		targetMenu.InterpretCommand(sprintf("setbackground bottomtext %S", ""));
		EntLog("disconnecting video display on entity %d", num_for_edict(videoDisplay));
	}
}

void
ncAVReceiver::UpdateVideoOutputs(void)
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
		KillVideoOutputs();
		return;
	}

	for (ncVideoDisplay videoDisplay = 0; (videoDisplay = (ncVideoDisplay)find(videoDisplay, ::classname, "ncVideoDisplay"));) {
		vguiTrUIMenu targetMenu = (vguiTrUIMenu)videoDisplay.m_videoDisplayUI;
		targetMenu.InterpretCommand(sprintf("setbackground channel tvchannel_%i", m_avReceiverChannel));
		targetMenu.InterpretCommand(sprintf("setbackground dog %s", findTransmitter.m_tvChannelDOG));
		targetMenu.InterpretCommand(sprintf("settext toptext %S", findTransmitter.m_tvChannelTopText));
		targetMenu.InterpretCommand(sprintf("settext bottomtext %S", findTransmitter.m_tvChannelBottomText));
		EntLog("connecting video display on entity %d to channel %i\n\tdog: %s\n\ttop text: %s\n\tbottom text: %s\n\tcolor: %v", num_for_edict(videoDisplay), m_avReceiverChannel, findTransmitter.m_tvChannelDOG, findTransmitter.m_tvChannelTopText, findTransmitter.m_tvChannelBottomText, findTransmitter.m_tvChannelLight);
		videoDisplay.m_vecScreenLight = findTransmitter.m_tvChannelLight;
		videoDisplay.m_vecScreenLightStyle = findTransmitter.m_tvChannelLightStyle;
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
		
	if (soundOffset < 1 || autocvar_avReceiver_ignoreSoundOffset) {
		sound(this, CHAN_BODY, findTransmitter.m_tvChannelAudio, m_avReceiverVolume, ATTN_IDLE, 0, 0, 0);
	} else {
		soundupdate(this, CHAN_BODY, findTransmitter.m_tvChannelAudio, m_avReceiverVolume, ATTN_IDLE, 0, 0, soundOffset);
	}
	
	EntLog("Playing audio %s at offset %f with volume %f", findTransmitter.m_tvChannelAudio, soundOffset, m_avReceiverVolume);
}
#endif
