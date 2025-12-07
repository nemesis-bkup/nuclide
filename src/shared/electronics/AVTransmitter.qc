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

const string g_tvChannelMat = "{\n" \
				"\t{\n" \
				"\t\tvideomap %s\n" \
				"\t}\n" \
				"}\n";

const string g_tvChannelMatFFMPEG = "{\n" \
				"\t{\n" \
				"\t\tvideomap av:%s\n" \
				"\t}\n" \
				"}\n";

var bool autocvar_tv_useFFMPEG = false;

void
ncAVTransmitter::ncAVTransmitter(void)
{
	m_tvChannelNum = g_int_null;
	m_tvChannelVideo = g_string_null;
	m_tvChannelAudio = g_string_null;
	m_tvChannelTime = g_float_null;
	m_tvChannelDOG = g_string_null;
	m_tvChannelTopText = g_string_null;
	m_tvChannelBottomText = g_string_null;
	m_tvChannelLight = g_vec_null;
	m_tvChannelLightStyle = g_float_null;
}

#ifdef SERVER
void
ncAVTransmitter::TransmitSingleVideo(string videoFile, bool advancesSchedule)
{
	/* FIXME: easy network speedup: turn this into an event after, and set those _new fields to prevent networking them */
	ncDict videoDict = ncDict::LoadDeclFromFile("video", sprintf("videos/%s.decl", videoFile));
	m_tvChannelVideo = videoDict.GetString("video");
	m_tvChannelAudio = videoDict.GetString("audio");
	m_tvChannelDOG = videoDict.GetString("dog");
	m_tvChannelTopText = videoDict.GetString("top_text");
	m_tvChannelBottomText = videoDict.GetString("bottom_text");
	m_tvChannelLight = videoDict.GetVector("light_color");
	m_tvChannelLightStyle = videoDict.GetFloat("light_style");

	float durationInterval = videoDict.GetFloat("duration");

	remove(videoDict);

	if (advancesSchedule && m_activeSchedule && durationInterval > 0.0f) {
		m_activeSchedule.AdvanceLater(durationInterval);
	}
}

void
ncAVTransmitter::Input(entity entityActivator, string inputName, string dataField)
{
	switch (inputName) {
	case "SwitchContainer":
		m_tvChannelVideo = sprintf("video/%s.roq", dataField);
		m_tvChannelAudio = sprintf("video/%s.ogg", dataField);
		m_tvChannelTime = time;
		EntLog("Channel %i is now playing video track %S", m_tvChannelNum, m_tvChannelVideo);
		EntLog("Channel %i is now playing audio track %S", m_tvChannelNum, m_tvChannelAudio);
		break;
	case "SwitchVideoTrack":
		m_tvChannelVideo = dataField;
		m_tvChannelTime = time;
		EntLog("Channel %i is now playing video track %S", m_tvChannelNum, m_tvChannelVideo);
		health = 1;
		break;
	case "SwitchAudioTrack":
		m_tvChannelAudio = dataField;
		m_tvChannelTime = time;
		EntLog("Channel %i is now playing audio track %S", m_tvChannelNum, m_tvChannelAudio);
		health = 1;
		break;
	case "RandomVideo":
		float videoEnum = tokenize(dataField);
		float randomVideo = floor(random(0, videoEnum));
		TransmitSingleVideo(argv(randomVideo), true);
		break;
	case "AsyncVideo":
		TransmitSingleVideo(dataField, false);
		break;
	case "SingleVideo":
	case "LoadVideo":
		TransmitSingleVideo(dataField, true);
		break;
	case "SetDOG":
		m_tvChannelDOG = dataField;
		break;
	case "SetTopText":
		m_tvChannelTopText = dataField;
		break;
	case "SetBottomText":
		m_tvChannelBottomText = dataField;
		break;
	case "SetLight":
		tokenize_console(dataField);
		m_tvChannelLight[0] = stof(argv(0));
		m_tvChannelLight[1] = stof(argv(1));
		m_tvChannelLight[2] = stof(argv(2));
		m_tvChannelLightStyle = stof(argv(3));
		break;
	default:
		super::Input(entityActivator, inputName, dataField);
	}
}

bool
ncAVTransmitter::IsAlive(void)
{
	return (true);
}

void
ncAVTransmitter::SpawnKey(string keyName, string setValue)
{
	switch (keyName) {
	case "channel":
		m_tvChannelNum = ReadInt(setValue);
		break;
	case "video":
		m_tvChannelVideo = ReadString(setValue);
		break;
	case "audio":
		m_tvChannelAudio = ReadString(setValue);
		break;
	case "dog":
		m_tvChannelDOG = ReadString(setValue);
		break;
	case "toptext":
		m_tvChannelTopText = ReadString(setValue);
		break;
	case "bottomtext":
		m_tvChannelBottomText = ReadString(setValue);
		break;
	default:
		super::SpawnKey(keyName, setValue);
		break;
	}
}

void
ncAVTransmitter::EvaluateEntity(void)
{
	ThinkSchedules();
	EVALUATE_VECTOR(origin, 0, TVCHANNELFL_ORIGIN)
	EVALUATE_VECTOR(origin, 1, TVCHANNELFL_ORIGIN)
	EVALUATE_VECTOR(origin, 2, TVCHANNELFL_ORIGIN)
	EVALUATE_FIELD(m_tvChannelNum, TVCHANNELFL_CHAN)
	EVALUATE_FIELD(m_tvChannelVideo, TVCHANNELFL_VIDEO)
	EVALUATE_FIELD(m_tvChannelAudio, TVCHANNELFL_AUDIO)
	EVALUATE_FIELD(m_tvChannelTime, TVCHANNELFL_SEEKTIME)
	EVALUATE_FIELD(m_tvChannelDOG, TVCHANNELFL_DOG)
	EVALUATE_FIELD(m_tvChannelTopText, TVCHANNELFL_TOPTEXT)
	EVALUATE_FIELD(m_tvChannelBottomText, TVCHANNELFL_BOTTOMTEXT)
	EVALUATE_VECTOR(m_tvChannelLight, 0, TVCHANNELFL_LIGHT)
	EVALUATE_VECTOR(m_tvChannelLight, 1, TVCHANNELFL_LIGHT)
	EVALUATE_VECTOR(m_tvChannelLight, 2, TVCHANNELFL_LIGHT)
	EVALUATE_FIELD(m_tvChannelLightStyle, TVCHANNELFL_LIGHT)
}

/* Make sure StartFrame calls this */
float
ncAVTransmitter::SendEntity(entity ePEnt, float flChanged)
{
	WriteByte(MSG_ENTITY, ENT_TVCHANNEL);
	WriteFloat(MSG_ENTITY, flChanged);
	SENDENTITY_COORD(origin[0], TVCHANNELFL_ORIGIN)
	SENDENTITY_COORD(origin[1], TVCHANNELFL_ORIGIN)
	SENDENTITY_COORD(origin[2], TVCHANNELFL_ORIGIN)
	SENDENTITY_INT(m_tvChannelNum, TVCHANNELFL_CHAN)
	SENDENTITY_STRING(m_tvChannelVideo, TVCHANNELFL_VIDEO)
	SENDENTITY_STRING(m_tvChannelAudio, TVCHANNELFL_AUDIO)
	SENDENTITY_FLOAT(m_tvChannelTime, TVCHANNELFL_SEEKTIME)
	SENDENTITY_STRING(m_tvChannelDOG, TVCHANNELFL_DOG)
	SENDENTITY_STRING(m_tvChannelTopText, TVCHANNELFL_TOPTEXT)
	SENDENTITY_STRING(m_tvChannelBottomText, TVCHANNELFL_BOTTOMTEXT)
	SENDENTITY_FLOAT(m_tvChannelLight[0], TVCHANNELFL_LIGHT)
	SENDENTITY_FLOAT(m_tvChannelLight[1], TVCHANNELFL_LIGHT)
	SENDENTITY_FLOAT(m_tvChannelLight[2], TVCHANNELFL_LIGHT)
	SENDENTITY_FLOAT(m_tvChannelLightStyle, TVCHANNELFL_LIGHT)
	pvsflags = PVSF_IGNOREPVS;
	return (1);
}
#endif

#ifdef CLIENT
void
ncAVTransmitter::ReceiveEntity(float flNew, float flChanged)
{
	READENTITY_COORD(origin[0], TVCHANNELFL_ORIGIN)
	READENTITY_COORD(origin[1], TVCHANNELFL_ORIGIN)
	READENTITY_COORD(origin[2], TVCHANNELFL_ORIGIN)
	READENTITY_INT(m_tvChannelNum, TVCHANNELFL_CHAN)
	READENTITY_STRING(m_tvChannelVideo, TVCHANNELFL_VIDEO)
	READENTITY_STRING(m_tvChannelAudio, TVCHANNELFL_AUDIO)
	READENTITY_FLOAT(m_tvChannelTime, TVCHANNELFL_SEEKTIME)
	READENTITY_STRING(m_tvChannelDOG, TVCHANNELFL_DOG)
	READENTITY_STRING(m_tvChannelTopText, TVCHANNELFL_TOPTEXT)
	READENTITY_STRING(m_tvChannelBottomText, TVCHANNELFL_BOTTOMTEXT)
	READENTITY_FLOAT(m_tvChannelLight[0], TVCHANNELFL_LIGHT)
	READENTITY_FLOAT(m_tvChannelLight[1], TVCHANNELFL_LIGHT)
	READENTITY_FLOAT(m_tvChannelLight[2], TVCHANNELFL_LIGHT)
	READENTITY_FLOAT(m_tvChannelLightStyle, TVCHANNELFL_LIGHT)

	if (m_bCached == false || flNew || flChanged & TVCHANNELFL_CHAN) {
		if (m_tvChannelNum < 0) {
			m_tvChannelMat = sprintf("videochannel_%i", -m_tvChannelNum);
		} else {
			m_tvChannelMat = sprintf("tvchannel_%i", m_tvChannelNum);
		}
	}

	if (flChanged & TVCHANNELFL_VIDEO || flChanged & TVCHANNELFL_CHAN) {
		/* video changed, so the destination for remapshader call should be different as well */

		if (m_tvChannelNum < 0) {
			m_tvChannelVideoMat = sprintf("videochannel_%i_%s", -m_tvChannelNum, m_tvChannelVideo);
		} else {
			m_tvChannelVideoMat = sprintf("tvchannel_%i_%s", m_tvChannelNum, m_tvChannelVideo);
		}

		ReloadVideoResources();
	}

	UpdateReceivers();
}

void
ncAVTransmitter::UpdateReceivers(void)
{
	for (ncAVReceiver receiverEnum = 0; (receiverEnum = (ncAVReceiver)find(receiverEnum, ::classname, "ncAVReceiver"));) {
		if (receiverEnum.m_avReceiverChannel == m_tvChannelNum) {
			receiverEnum.UpdateVideoOutputs();
			receiverEnum.UpdateSpeakers();
		}
	}

	/* now update all the 'static' displays... */
	for (ncInteractiveSurface videoDisplay = 0; (videoDisplay = (ncInteractiveSurface)find(videoDisplay, ::classname, "ncInteractiveSurface"));) {
		vguiTrUIMenu targetMenu = (vguiTrUIMenu)videoDisplay.m_videoDisplayUI;

		string videoName = sprintf("videochannel_%i", -m_tvChannelNum);
		printf("%s\n", sprintf("setbackground videochannel_%i_video %S", -m_tvChannelNum, videoName));
		targetMenu.InterpretCommand(targetMenu, sprintf("setbackground videochannel_%i_video %S", -m_tvChannelNum, videoName));
		targetMenu.InterpretCommand(targetMenu, sprintf("setbackground videochannel_%i_dog %S", -m_tvChannelNum, m_tvChannelDOG));
		targetMenu.InterpretCommand(targetMenu, sprintf("settext videochannel_%i_toptext %S", -m_tvChannelNum, m_tvChannelTopText));
		targetMenu.InterpretCommand(targetMenu, sprintf("settext videochannel_%i_bottomtext %S", -m_tvChannelNum, m_tvChannelBottomText));
		printf("%s\n", sprintf("settext videochannel_%i_toptext %S", -m_tvChannelNum, m_tvChannelTopText));
		printf("%s\n", sprintf("settext videochannel_%i_bottomtext %S", -m_tvChannelNum, m_tvChannelBottomText));
	}
}

void
ncAVTransmitter::ReloadVideoResources(void)
{
	shaderforname(m_tvChannelMat, "{\n{\nmap $whiteimage\n}\n}");
	m_bCached = true;

	if (STRING_SET(m_tvChannelVideo)) {
		/* compose the new material body text */
		string newMaterial;

		if (autocvar_tv_useFFMPEG) {
			newMaterial = sprintf(g_tvChannelMatFFMPEG, m_tvChannelVideo);
		} else {
			newMaterial = sprintf(g_tvChannelMat, m_tvChannelVideo);
		}

		/* register the videomaterial with the newly generated body text */
		shaderforname(m_tvChannelVideoMat, newMaterial);

		/* rewind the destination video material, to resync */
		gecko_navigate(m_tvChannelVideoMat, "cmd:rewind");
		gecko_navigate(m_tvChannelMat, "cmd:rewind");

		/* ensure the material is registered */
		shaderforname(m_tvChannelMat, "{\n{\nmap $whiteimage\n}\n}");

		/* remap it as soon as possible */
		remapshader(m_tvChannelMat, m_tvChannelVideoMat, time - m_tvChannelTime);
	}
}

void
ncAVTransmitter::FlipImages(void)
{
	for (ncAVTransmitter receiverEnum = 0; (receiverEnum = (ncAVTransmitter)find(receiverEnum, ::classname, "ncAVTransmitter"));) {
		drawpic([0,0], receiverEnum.m_tvChannelMat, [1,1], [1,1,1], 1.0f, DRAWFLAG_NORMAL);
	}
}
#endif
