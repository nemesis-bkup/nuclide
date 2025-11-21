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
ncTVChannel::ncTVChannel(void)
{
	m_tvChannelNum = g_int_null;
	m_tvChannelVideo = g_string_null;
	m_tvChannelTime = g_float_null;
}

#ifdef SERVER
void
ncTVChannel::Input(entity entityActivator, string inputName, string dataField)
{
	switch (inputName) {
	case "SwitchVideo":
		m_tvChannelVideo = dataField;
		m_tvChannelTime = time;
		health = 1;
		break;
	default:
		super::Input(entityActivator, inputName, dataField);
	}
}

bool
ncTVChannel::IsAlive(void)
{
	return (true);
}

void
ncTVChannel::SpawnKey(string keyName, string setValue)
{
	switch (keyName) {
	case "channel":
		m_tvChannelNum = ReadInt(setValue);
		break;
	default:
		super::SpawnKey(keyName, setValue);
		break;
	}
}

void
ncTVChannel::EvaluateEntity(void)
{
	ThinkSchedules();
	EVALUATE_FIELD(m_tvChannelNum, TVCHANNELFL_CHAN)
	EVALUATE_FIELD(m_tvChannelVideo, TVCHANNELFL_VIDEO)
	EVALUATE_FIELD(m_tvChannelTime, TVCHANNELFL_SEEKTIME)
}

/* Make sure StartFrame calls this */
float
ncTVChannel::SendEntity(entity ePEnt, float flChanged)
{
	WriteByte(MSG_ENTITY, ENT_TVCHANNEL);
	WriteFloat(MSG_ENTITY, flChanged);
	SENDENTITY_INT(m_tvChannelNum, TVCHANNELFL_CHAN)
	SENDENTITY_STRING(m_tvChannelVideo, TVCHANNELFL_VIDEO)
	SENDENTITY_FLOAT(m_tvChannelTime, TVCHANNELFL_SEEKTIME)
	pvsflags = PVSF_NOREMOVE;
	return (1);
}
#endif

#ifdef CLIENT
void
ncTVChannel::ReceiveEntity(float flNew, float flChanged)
{
	READENTITY_INT(m_tvChannelNum, TVCHANNELFL_CHAN)
	READENTITY_STRING(m_tvChannelVideo, TVCHANNELFL_VIDEO)
	READENTITY_FLOAT(m_tvChannelTime, TVCHANNELFL_SEEKTIME)

	if (m_bCached == false || flNew || flChanged & TVCHANNELFL_CHAN) {
		m_tvChannelMat = sprintf("tvchannel_%i", m_tvChannelNum);
		ReloadVideoResources();
	}

	if (flChanged & TVCHANNELFL_VIDEO) {

		/* video changed, so the destination for remapshader call should be different as well */
		m_tvChannelVideoMat = sprintf("tvchannel_%i_%s", m_tvChannelNum, m_tvChannelVideo);
		ReloadVideoResources();
	}
}

void
ncTVChannel::ReloadVideoResources(void)
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
#endif
