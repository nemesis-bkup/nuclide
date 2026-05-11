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
    m_mediaSize = [320,240];
}

#ifdef SERVER
void
ncAVTransmitter::TransmitSingleAudio(string audioFile, bool advancesSchedule)
{
    /* FIXME: easy network speedup: turn this into an event after, and set those _new fields to prevent networking them */
    ncDict videoDict = ncDict::LoadDeclFromFile(audioFile, sprintf("audio/%s.audio", audioFile));
    m_tvChannelVideo = videoDict.GetString("video");
    m_tvChannelAudio = videoDict.GetString("audio");
    m_tvChannelDOG = videoDict.GetString("dog");
    m_tvChannelTopText = videoDict.GetString("top_text");
    m_tvChannelBottomText = videoDict.GetString("bottom_text");
    m_tvChannelLight = videoDict.GetVector("light_color");
    m_tvChannelLightStyle = videoDict.GetFloat("light_style");

    float durationInterval = videoDict.GetFloat("duration");

    remove(videoDict);

    Input(this, "settitle", sprintf("channel %S", m_tvChannelVideo));
    Input(this, "settitle", sprintf("dog %S", m_tvChannelDOG));
    Input(this, "settitle", sprintf("toptext %S", m_tvChannelTopText));
    Input(this, "settitle", sprintf("bottomtext %S", m_tvChannelBottomText));

    if (advancesSchedule && m_activeSchedule && durationInterval > 0.0f) {
        m_activeSchedule.AdvanceLater(durationInterval);
    }
}
void
ncAVTransmitter::TransmitSingleVideo(string videoFile, bool advancesSchedule)
{
    /* FIXME: easy network speedup: turn this into an event after, and set those _new fields to prevent networking them */
    ncDict videoDict = ncDict::LoadDeclFromFile(videoFile, sprintf("videos/%s.video", videoFile));
    m_tvChannelVideo = videoDict.GetString("video");
    m_tvChannelAudio = videoDict.GetString("audio");
    m_tvChannelDOG = videoDict.GetString("dog");
    m_tvChannelTopText = videoDict.GetString("top_text");
    m_tvChannelBottomText = videoDict.GetString("bottom_text");
    m_tvChannelLight = videoDict.GetVector("light_color");
    m_tvChannelLightStyle = videoDict.GetFloat("light_style");

    float durationInterval = videoDict.GetFloat("duration");

    remove(videoDict);

    Input(this, "settitle", sprintf("channel %S", m_tvChannelVideo));
    Input(this, "settitle", sprintf("dog %S", m_tvChannelDOG));
    Input(this, "settitle", sprintf("toptext %S", m_tvChannelTopText));
    Input(this, "settitle", sprintf("bottomtext %S", m_tvChannelBottomText));

    if (advancesSchedule && m_activeSchedule && durationInterval > 0.0f) {
        m_activeSchedule.AdvanceLater(durationInterval);
    }
}

void
ncAVTransmitter::Input(entity entityActivator, string inputName, string dataField)
{
    switch (inputName) {
    case "switchcontainer":
        m_tvChannelVideo = sprintf("video/%s.roq", dataField);
        m_tvChannelAudio = sprintf("video/%s.ogg", dataField);
        m_tvChannelTime = time;
        EntLog("Channel %i is now playing video track %S", m_tvChannelNum, m_tvChannelVideo);
        EntLog("Channel %i is now playing audio track %S", m_tvChannelNum, m_tvChannelAudio);
        break;
    case "switchvideotrack":
        m_tvChannelVideo = dataField;
        m_tvChannelTime = time;
        EntLog("Channel %i is now playing video track %S", m_tvChannelNum, m_tvChannelVideo);
        Input(this, "settitle", sprintf("channel %S", m_tvChannelVideo));
        health = 1;
        break;
    case "switchaudiotrack":
        m_tvChannelAudio = dataField;
        m_tvChannelTime = time;
        EntLog("Channel %i is now playing audio track %S", m_tvChannelNum, m_tvChannelAudio);
        health = 1;
        break;
    case "randomvideo":
        float videoEnum = tokenize(dataField);
        float randomVideo = floor(random(0, videoEnum));
        TransmitSingleVideo(argv(randomVideo), true);
        break;
    case "asyncvideo":
        TransmitSingleVideo(dataField, false);
        break;
    case "singleaudio":
    case "loadaudio":
        TransmitSingleAudio(dataField, true);
        break;
    case "singlevideo":
    case "loadvideo":
        TransmitSingleVideo(dataField, true);
        break;
    case "setdog":
        m_tvChannelDOG = dataField;
        Input(this, "settitle", sprintf("dog %S", m_tvChannelDOG));
        break;
    case "settoptext":
        m_tvChannelTopText = dataField;
        Input(this, "settitle", sprintf("toptext %S", m_tvChannelTopText));
        break;
    case "setbottomtext":
        m_tvChannelBottomText = dataField;
        Input(this, "settitle", sprintf("bottomtext %S", m_tvChannelBottomText));
        break;
    case "setlight":
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
    case "gui64":
        m_gui64 = ReadString(setValue);
        break;
    default:
        super::SpawnKey(keyName, setValue);
        break;
    }
}

void
ncAVTransmitter::EvaluateEntity(void)
{
    pvsflags = PVSF_IGNOREPVS;

    ThinkSchedules();
    EVALUATE_VECTOR(origin, 0, SRFENT_CHANGED_ORIGIN_X)
    EVALUATE_VECTOR(origin, 1, SRFENT_CHANGED_ORIGIN_Y)
    EVALUATE_VECTOR(origin, 2, SRFENT_CHANGED_ORIGIN_Z)
    EVALUATE_VECTOR(angles, 0, SRFENT_CHANGED_ANGLES_X)
    EVALUATE_VECTOR(angles, 1, SRFENT_CHANGED_ANGLES_Y)
    EVALUATE_VECTOR(angles, 2, SRFENT_CHANGED_ANGLES_Z)
    EVALUATE_FIELD(modelindex, SRFENT_CHANGED_MODELINDEX)
    EVALUATE_FIELD(solid, SRFENT_CHANGED_SOLIDMOVETYPE)
    EVALUATE_FIELD(movetype, SRFENT_CHANGED_SOLIDMOVETYPE)
    EVALUATE_FIELD(flags, SRFENT_CHANGED_FLAGS)
    EVALUATE_VECTOR(mins, 0, SRFENT_CHANGED_SIZE)
    EVALUATE_VECTOR(mins, 1, SRFENT_CHANGED_SIZE)
    EVALUATE_VECTOR(mins, 2, SRFENT_CHANGED_SIZE)
    EVALUATE_VECTOR(maxs, 0, SRFENT_CHANGED_SIZE)
    EVALUATE_VECTOR(maxs, 1, SRFENT_CHANGED_SIZE)
    EVALUATE_VECTOR(maxs, 2, SRFENT_CHANGED_SIZE)
    EVALUATE_FIELD(frame, SRFENT_CHANGED_FRAME)
    EVALUATE_FIELD(skin, SRFENT_CHANGED_SKIN)
    EVALUATE_FIELD(effects, SRFENT_CHANGED_EFFECTS)
    EVALUATE_FIELD(m_geomsetField, SRFENT_CHANGED_BODY)
    EVALUATE_FIELD(scale, SRFENT_CHANGED_SCALE)
    EVALUATE_VECTOR(m_axialScale, 0, SRFENT_CHANGED_SCALE)
    EVALUATE_VECTOR(m_axialScale, 1, SRFENT_CHANGED_SCALE)
    EVALUATE_VECTOR(m_axialScale, 2, SRFENT_CHANGED_SCALE)
    EVALUATE_VECTOR(velocity, 0, SRFENT_CHANGED_VELOCITY)
    EVALUATE_VECTOR(velocity, 1, SRFENT_CHANGED_VELOCITY)
    EVALUATE_VECTOR(velocity, 2, SRFENT_CHANGED_VELOCITY)
    EVALUATE_VECTOR(avelocity, 0, SRFENT_CHANGED_ANGULARVELOCITY)
    EVALUATE_VECTOR(avelocity, 1, SRFENT_CHANGED_ANGULARVELOCITY)
    EVALUATE_VECTOR(avelocity, 2, SRFENT_CHANGED_ANGULARVELOCITY)
    EVALUATE_FIELD(m_renderMode, SRFENT_CHANGED_RENDERMODE)
    EVALUATE_FIELD(m_renderFX, SRFENT_CHANGED_RENDERMODE)
    EVALUATE_VECTOR(m_renderColor, 0, SRFENT_CHANGED_RENDERCOLOR)
    EVALUATE_VECTOR(m_renderColor, 1, SRFENT_CHANGED_RENDERCOLOR)
    EVALUATE_VECTOR(m_renderColor, 2, SRFENT_CHANGED_RENDERCOLOR)
    EVALUATE_FIELD(m_renderAmount, SRFENT_CHANGED_RENDERAMT)
    EVALUATE_FIELD(m_studioBoneController1, SRFENT_CHANGED_CONTROLLER)
    EVALUATE_FIELD(m_studioBoneController2, SRFENT_CHANGED_CONTROLLER)
    EVALUATE_FIELD(m_studioBoneController3, SRFENT_CHANGED_CONTROLLER)
    EVALUATE_FIELD(m_studioBoneController4, SRFENT_CHANGED_CONTROLLER)
    EVALUATE_FIELD(m_studioBoneController5, SRFENT_CHANGED_CONTROLLER)
    EVALUATE_VECTOR(m_mediaSize, 0, SRFENT_CHANGED_BODY)
    EVALUATE_VECTOR(m_mediaSize, 1, SRFENT_CHANGED_BODY)
    EVALUATE_FIELD(m_dataFormat, SRFENT_CHANGED_RENDERMODE)
    EVALUATE_FIELD(m_dataURL, SRFENT_CHANGED_RENDERMODE)
    EVALUATE_FIELD(m_acceptsData, SRFENT_CHANGED_RENDERMODE)
    EVALUATE_FIELD(m_gui64, SRFENT_CHANGED_RENDERMODE)
}

/* Make sure StartFrame calls this */
float
ncAVTransmitter::SendEntity(entity ePEnt, float flChanged)
{
    WriteByte(MSG_ENTITY, ENT_TVCHANNEL);

    /* broadcast how much data is expected to be read */
    WriteFloat(MSG_ENTITY, flChanged);
    SENDENTITY_INT(num_for_edict(this), SRFENT_CHANGED_MODELINDEX)
    SENDENTITY_INT(m_tvChannelNum, SRFENT_CHANGED_MODELINDEX)
    SENDENTITY_COORD(origin[0], SRFENT_CHANGED_ORIGIN_X)
    SENDENTITY_COORD(origin[1], SRFENT_CHANGED_ORIGIN_Y)
    SENDENTITY_COORD(origin[2], SRFENT_CHANGED_ORIGIN_Z)
    SENDENTITY_ANGLE(angles[0], SRFENT_CHANGED_ANGLES_X)
    SENDENTITY_ANGLE(angles[1], SRFENT_CHANGED_ANGLES_Y)
    SENDENTITY_ANGLE(angles[2], SRFENT_CHANGED_ANGLES_Z)
    SENDENTITY_SHORT(modelindex, SRFENT_CHANGED_MODELINDEX)
    SENDENTITY_BYTE(solid, SRFENT_CHANGED_SOLIDMOVETYPE)
    SENDENTITY_BYTE(movetype, SRFENT_CHANGED_SOLIDMOVETYPE)
    SENDENTITY_INT(flags, SRFENT_CHANGED_FLAGS)
    SENDENTITY_COORD(mins[0], SRFENT_CHANGED_SIZE)
    SENDENTITY_COORD(mins[1], SRFENT_CHANGED_SIZE)
    SENDENTITY_COORD(mins[2], SRFENT_CHANGED_SIZE)
    SENDENTITY_COORD(maxs[0], SRFENT_CHANGED_SIZE)
    SENDENTITY_COORD(maxs[1], SRFENT_CHANGED_SIZE)
    SENDENTITY_COORD(maxs[2], SRFENT_CHANGED_SIZE)
    SENDENTITY_BYTE(frame, SRFENT_CHANGED_FRAME)
    SENDENTITY_FLOAT(skin, SRFENT_CHANGED_SKIN)
    SENDENTITY_FLOAT(effects, SRFENT_CHANGED_EFFECTS)
    SENDENTITY_SHORT(m_geomsetField, SRFENT_CHANGED_BODY)
    SENDENTITY_FLOAT(scale, SRFENT_CHANGED_SCALE)
    SENDENTITY_FLOAT(m_axialScale[0], SRFENT_CHANGED_SCALE)
    SENDENTITY_FLOAT(m_axialScale[1], SRFENT_CHANGED_SCALE)
    SENDENTITY_FLOAT(m_axialScale[2], SRFENT_CHANGED_SCALE)
    SENDENTITY_COORD(velocity[0], SRFENT_CHANGED_VELOCITY)
    SENDENTITY_COORD(velocity[1], SRFENT_CHANGED_VELOCITY)
    SENDENTITY_COORD(velocity[2], SRFENT_CHANGED_VELOCITY)
    SENDENTITY_COORD(avelocity[0], SRFENT_CHANGED_ANGULARVELOCITY)
    SENDENTITY_COORD(avelocity[1], SRFENT_CHANGED_ANGULARVELOCITY)
    SENDENTITY_COORD(avelocity[2], SRFENT_CHANGED_ANGULARVELOCITY)
    SENDENTITY_BYTE(m_renderMode, SRFENT_CHANGED_RENDERMODE)
    SENDENTITY_BYTE(m_renderFX, SRFENT_CHANGED_RENDERMODE)
    SENDENTITY_BYTE(m_renderColor[0], SRFENT_CHANGED_RENDERCOLOR)
    SENDENTITY_BYTE(m_renderColor[1], SRFENT_CHANGED_RENDERCOLOR)
    SENDENTITY_BYTE(m_renderColor[2], SRFENT_CHANGED_RENDERCOLOR)
    SENDENTITY_BYTE(m_renderAmount, SRFENT_CHANGED_RENDERAMT)
    SENDENTITY_ANGLE(m_studioBoneController1, SRFENT_CHANGED_CONTROLLER)
    SENDENTITY_ANGLE(m_studioBoneController2, SRFENT_CHANGED_CONTROLLER)
    SENDENTITY_ANGLE(m_studioBoneController3, SRFENT_CHANGED_CONTROLLER)
    SENDENTITY_ANGLE(m_studioBoneController4, SRFENT_CHANGED_CONTROLLER)
    SENDENTITY_ANGLE(m_studioBoneController5, SRFENT_CHANGED_CONTROLLER)
    SENDENTITY_SHORT(m_mediaSize[0], SRFENT_CHANGED_BODY)
    SENDENTITY_SHORT(m_mediaSize[1], SRFENT_CHANGED_BODY)
    SENDENTITY_STRING(m_dataFormat, SRFENT_CHANGED_RENDERMODE)
    SENDENTITY_STRING(m_dataURL, SRFENT_CHANGED_RENDERMODE)
    SENDENTITY_STRING(m_acceptsData, SRFENT_CHANGED_RENDERMODE)
    SENDENTITY_STRING(m_gui64, SRFENT_CHANGED_RENDERMODE)

    return (1);
}
#endif

#ifdef CLIENT
void
ncAVTransmitter::postdraw(void)
{
    RenderSource(sprintf("tvchannel_%i", m_tvChannelNum));
}

void
ncAVTransmitter::DrawDebug(void)
{
    for (ncAVTransmitter receiverEnum = 0; (receiverEnum = (ncAVTransmitter)find(receiverEnum, ::classname, "ncAVTransmitter"));) {
        receiverEnum.Draw();
    }
}

void
ncAVTransmitter::ReceiveEntity(float flNew, float flChanged)
{
    READENTITY_INT(m_serverSideNum, SRFENT_CHANGED_MODELINDEX)
    READENTITY_INT(m_tvChannelNum, SRFENT_CHANGED_MODELINDEX)
    READENTITY_COORD(origin[0], SRFENT_CHANGED_ORIGIN_X)
    READENTITY_COORD(origin[1], SRFENT_CHANGED_ORIGIN_Y)
    READENTITY_COORD(origin[2], SRFENT_CHANGED_ORIGIN_Z)
    READENTITY_ANGLE(angles[0], SRFENT_CHANGED_ANGLES_X)
    READENTITY_ANGLE(angles[1], SRFENT_CHANGED_ANGLES_Y)
    READENTITY_ANGLE(angles[2], SRFENT_CHANGED_ANGLES_Z)
    READENTITY_SHORT(modelindex, SRFENT_CHANGED_MODELINDEX)
    READENTITY_BYTE(solid, SRFENT_CHANGED_SOLIDMOVETYPE)
    READENTITY_BYTE(movetype, SRFENT_CHANGED_SOLIDMOVETYPE)
    READENTITY_INT(flags, SRFENT_CHANGED_FLAGS)
    READENTITY_COORD(mins[0], SRFENT_CHANGED_SIZE)
    READENTITY_COORD(mins[1], SRFENT_CHANGED_SIZE)
    READENTITY_COORD(mins[2], SRFENT_CHANGED_SIZE)
    READENTITY_COORD(maxs[0], SRFENT_CHANGED_SIZE)
    READENTITY_COORD(maxs[1], SRFENT_CHANGED_SIZE)
    READENTITY_COORD(maxs[2], SRFENT_CHANGED_SIZE)
    READENTITY_BYTE(frame, SRFENT_CHANGED_FRAME)
    READENTITY_FLOAT(skin, SRFENT_CHANGED_SKIN)
    READENTITY_FLOAT(effects, SRFENT_CHANGED_EFFECTS)
    READENTITY_SHORT(m_geomsetField, SRFENT_CHANGED_BODY)
    READENTITY_FLOAT(scale, SRFENT_CHANGED_SCALE)
    READENTITY_FLOAT(m_axialScale[0], SRFENT_CHANGED_SCALE)
    READENTITY_FLOAT(m_axialScale[1], SRFENT_CHANGED_SCALE)
    READENTITY_FLOAT(m_axialScale[2], SRFENT_CHANGED_SCALE)
    READENTITY_COORD(velocity[0], SRFENT_CHANGED_VELOCITY)
    READENTITY_COORD(velocity[1], SRFENT_CHANGED_VELOCITY)
    READENTITY_COORD(velocity[2], SRFENT_CHANGED_VELOCITY)
    READENTITY_COORD(avelocity[0], SRFENT_CHANGED_ANGULARVELOCITY)
    READENTITY_COORD(avelocity[1], SRFENT_CHANGED_ANGULARVELOCITY)
    READENTITY_COORD(avelocity[2], SRFENT_CHANGED_ANGULARVELOCITY)
    READENTITY_BYTE(m_renderMode, SRFENT_CHANGED_RENDERMODE)
    READENTITY_BYTE(m_renderFX, SRFENT_CHANGED_RENDERMODE)
    READENTITY_BYTE(m_renderColor[0], SRFENT_CHANGED_RENDERCOLOR)
    READENTITY_BYTE(m_renderColor[1], SRFENT_CHANGED_RENDERCOLOR)
    READENTITY_BYTE(m_renderColor[2], SRFENT_CHANGED_RENDERCOLOR)
    READENTITY_BYTE(m_renderAmount, SRFENT_CHANGED_RENDERAMT)
    READENTITY_ANGLE(m_studioBoneController1, SRFENT_CHANGED_CONTROLLER)
    READENTITY_ANGLE(m_studioBoneController2, SRFENT_CHANGED_CONTROLLER)
    READENTITY_ANGLE(m_studioBoneController3, SRFENT_CHANGED_CONTROLLER)
    READENTITY_ANGLE(m_studioBoneController4, SRFENT_CHANGED_CONTROLLER)
    READENTITY_ANGLE(m_studioBoneController5, SRFENT_CHANGED_CONTROLLER)
    READENTITY_SHORT(m_mediaSize[0], SRFENT_CHANGED_BODY)
    READENTITY_SHORT(m_mediaSize[1], SRFENT_CHANGED_BODY)
    READENTITY_STRING(m_dataFormat, SRFENT_CHANGED_RENDERMODE)
    READENTITY_STRING(m_dataURL, SRFENT_CHANGED_RENDERMODE)
    READENTITY_STRING(m_acceptsData, SRFENT_CHANGED_RENDERMODE)
    READENTITY_STRING(m_gui64, SRFENT_CHANGED_RENDERMODE)

    /* hack, this should never be the world model! so therefore we abuse it to make it nothing. */
    if (modelindex == 1) {
        modelindex = 0;
    }

    if (flNew) {
        ReloadVideoResources();

        /* initialize UI panel here */
        m_UIChain = spawn(vguiRootWindow);
    }

    /* this shall never be valid. use Hide() */
    if (scale == 0.0f) {
        scale = 1.0f;
    }

    if (flChanged & SRFENT_CHANGED_FRAME) {
        frame1time = 0.0f;
    }

    /* other post-eval operations happen here */
    if (flChanged & SRFENT_CHANGED_SIZE) {
        setsize(this, mins * scale, maxs * scale);
    }

    if (flChanged & SRFENT_CHANGED_BODY) {
        setcustomskin(this, "", sprintf("geomset 0 %i\ngeomset 1 %i\n", m_geomsetField, m_geomsetField));
    }

    if (flNew) {
        if (STRING_SET(m_gui64)) {
            vguiRootWindow rootWindow = (vguiRootWindow)m_UIChain;
            m_uiInteractive = vguiScriptedView::CreateFromBase64(m_uiInteractive, m_gui64);
            rootWindow.Add(m_uiInteractive);
        }
    }

    if (flChanged & SRFENT_CHANGED_MODELINDEX) {
        if (m_tvChannelNum > 0) {
            ncError("TV channel %i now known", m_tvChannelNum);
        } else if (m_tvChannelNum < 0) {
            ncError("Radio channel %i now known", -m_tvChannelNum);
        }

        _ModelChanged();
        _UpdateBoneCount();
    }
}
#endif
