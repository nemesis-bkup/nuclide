/*
 * Copyright (c) 2022-2025 Vera Visions LLC.
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
ncUserEntity_Video::ncUserEntity_Video(void)
{
}

#ifdef SERVER
void
ncUserEntity_Video::Spawned(void)
{
    m_userVideoURL = "video/static.roq";
    super::Spawned();
}

void
ncUserEntity_Video::Stop(void)
{
    m_userVideoURL = "video/static.roq";
    m_userVideoAudio = "common/null.wav";
    m_userVideoName = "";
    m_userVideoTitle = "";
    m_userVideoPreview = "";
}

void
ncUserEntity_Video::EvaluateEntity(void)
{
    EVALUATE_VECTOR(origin, 0, UISURFACEFL_ORIGIN)
    EVALUATE_VECTOR(origin, 1, UISURFACEFL_ORIGIN)
    EVALUATE_VECTOR(origin, 2, UISURFACEFL_ORIGIN)
    EVALUATE_VECTOR(angles, 0, UISURFACEFL_ANGLES)
    EVALUATE_VECTOR(angles, 1, UISURFACEFL_ANGLES)
    EVALUATE_VECTOR(angles, 2, UISURFACEFL_ANGLES)
    EVALUATE_FIELD(m_strUIClass, UISURFACEFL_INTERFACE)
    EVALUATE_FIELD(m_flScale, UISURFACEFL_SCALE)
    EVALUATE_FIELD(m_flUseDistance, UISURFACEFL_DISTANCE)
    EVALUATE_VECTOR(m_vecUIRes, 0, UISURFACEFL_RESOLUTION)
    EVALUATE_VECTOR(m_vecUIRes, 1, UISURFACEFL_RESOLUTION)
    EVALUATE_VECTOR(m_vecScreenLight, 0, UISURFACEFL_LIGHT)
    EVALUATE_VECTOR(m_vecScreenLight, 1, UISURFACEFL_LIGHT)
    EVALUATE_VECTOR(m_vecScreenLight, 2, UISURFACEFL_LIGHT)
    EVALUATE_FIELD(m_uiSurfaceEnabled, UISURFACEFL_ENABLED)
}

float
ncUserEntity_Video::SendEntity(entity ePEnt, float flChanged)
{
    WriteByte(MSG_ENTITY, ENT_SPRAYVIDEO);
    WriteFloat(MSG_ENTITY, flChanged);
    SENDENTITY_COORD(origin[0], UISURFACEFL_ORIGIN)
    SENDENTITY_COORD(origin[1], UISURFACEFL_ORIGIN)
    SENDENTITY_COORD(origin[2], UISURFACEFL_ORIGIN)
    SENDENTITY_ANGLE(angles[0], UISURFACEFL_ANGLES)
    SENDENTITY_ANGLE(angles[1], UISURFACEFL_ANGLES)
    SENDENTITY_ANGLE(angles[2], UISURFACEFL_ANGLES)
    SENDENTITY_INT(num_for_edict(this), UISURFACEFL_INTERFACE)
    SENDENTITY_STRING(m_userVideoName, UISURFACEFL_INTERFACE)
    SENDENTITY_STRING(m_userVideoTitle, UISURFACEFL_INTERFACE)
    SENDENTITY_STRING(m_userVideoPreview, UISURFACEFL_INTERFACE)
    SENDENTITY_STRING(m_userVideoURL, UISURFACEFL_INTERFACE)
    SENDENTITY_STRING(m_userVideoAudio, UISURFACEFL_INTERFACE)
    SENDENTITY_FLOAT(m_flScale, UISURFACEFL_SCALE)
    SENDENTITY_FLOAT(m_flUseDistance, UISURFACEFL_DISTANCE)
    SENDENTITY_FLOAT(m_vecUIRes[0], UISURFACEFL_RESOLUTION)
    SENDENTITY_FLOAT(m_vecUIRes[1], UISURFACEFL_RESOLUTION)
    SENDENTITY_FLOAT(m_vecScreenLight[0], UISURFACEFL_LIGHT)
    SENDENTITY_FLOAT(m_vecScreenLight[1], UISURFACEFL_LIGHT)
    SENDENTITY_FLOAT(m_vecScreenLight[2], UISURFACEFL_LIGHT)
    SENDENTITY_BYTE(m_uiSurfaceEnabled, UISURFACEFL_ENABLED)
    return (1);
}
#endif

#ifdef CLIENT
void
ncUserEntity_Video::VideoSave_Clicked(vguiWidget sender)
{
    if (!STRING_SET(m_userVideoName)) {
        return;
    }

    localcmd(sprintf("saveVideo %S %S %S %S %S\n", m_userVideoName, m_userVideoTitle, m_userVideoPreview, m_userVideoURL, m_userVideoAudio));
}

void
ncUserEntity_Video::ReceiveEntity(float flNew, float flChanged)
{
    READENTITY_COORD(origin[0], UISURFACEFL_ORIGIN)
    READENTITY_COORD(origin[1], UISURFACEFL_ORIGIN)
    READENTITY_COORD(origin[2], UISURFACEFL_ORIGIN)
    READENTITY_ANGLE(angles[0], UISURFACEFL_ANGLES)
    READENTITY_ANGLE(angles[1], UISURFACEFL_ANGLES)
    READENTITY_ANGLE(angles[2], UISURFACEFL_ANGLES)
    READENTITY_INT(m_serverSideNum, UISURFACEFL_INTERFACE)
    READENTITY_STRING(m_userVideoName, UISURFACEFL_INTERFACE)
    READENTITY_STRING(m_userVideoTitle, UISURFACEFL_INTERFACE)
    READENTITY_STRING(m_userVideoPreview, UISURFACEFL_INTERFACE)
    READENTITY_STRING(m_userVideoURL, UISURFACEFL_INTERFACE)
    READENTITY_STRING(m_userVideoAudio, UISURFACEFL_INTERFACE)

    READENTITY_FLOAT(m_flScale, UISURFACEFL_SCALE)
    READENTITY_FLOAT(m_flUseDistance, UISURFACEFL_DISTANCE)
    READENTITY_FLOAT(m_vecUIRes[0], UISURFACEFL_RESOLUTION)
    READENTITY_FLOAT(m_vecUIRes[1], UISURFACEFL_RESOLUTION)
    READENTITY_FLOAT(m_vecScreenLight[0], UISURFACEFL_LIGHT)
    READENTITY_FLOAT(m_vecScreenLight[1], UISURFACEFL_LIGHT)
    READENTITY_FLOAT(m_vecScreenLight[2], UISURFACEFL_LIGHT)
    READENTITY_BYTE(m_uiSurfaceEnabled, UISURFACEFL_ENABLED)

    if (flNew) {
        vguiWidget uiChain = (vguiWidget)m_uiRootWindow;

        m_vecWorldSize = m_vecUIRes * m_flScale;
        ReloadVideoResources();

        /* initialize UI panel here */
        m_uiRootWindow = spawn(vguiRootWindow);
        vguiWidget uiChain = (vguiWidget)m_uiRootWindow;
        uiChain.m_iFlags = 1;

        m_videoPic = spawn(vguiVideo);
        vguiVideo ourVideo = (vguiVideo)m_videoPic;
        ourVideo.SetSize(m_vecUIRes);
        uiChain.Add(ourVideo);

        m_uiControlView = spawn(vguiView);
        vguiView controlView = (vguiView)m_uiControlView;
        uiChain.Add(controlView);

        vguiButton btnSave = spawn(vguiButton);
        controlView.Add(btnSave);
        btnSave.SetPos([8, m_vecUIRes[1] - 22-8]);
        btnSave.SetIcon("gfx/icon16/disk");
        btnSave.SetSize([22,22]);
        btnSave.SetFuncWithDelegate(VideoSave_Clicked, this);

        m_videoLabel = spawn(vguiLabel);
        vguiLabel ourTitle = (vguiLabel)m_videoLabel;
        controlView.Add(ourTitle);
        ourTitle.SetPos([8, 8]);
        ourTitle.SetSize(m_vecUIRes - [48,16]);

        vguiButton btnRemove = spawn(vguiButton);
        controlView.Add(btnRemove);
        btnRemove.SetPos([m_vecUIRes[0] - 22-8, 8]);
        btnRemove.SetIcon("gfx/icon16/cross");
        btnRemove.SetSize([22,22]);
        btnRemove.SetFuncWithDelegate(RequestRemoval, this);
    }

    if (flChanged & UISURFACEFL_INTERFACE) {
        if (m_videoPic) {
            vguiVideo ourVideo = (vguiVideo)m_videoPic;
            vguiLabel ourTitle = (vguiLabel)m_videoLabel;
            ourVideo.SetVideo(m_userVideoURL);
            ourTitle.SetTitle(m_userVideoTitle);
        }
    }
}
#endif

#ifdef SERVER
var float autocvar_videopanel_scale=0.2f;
void
ncUserEntity_Video::Place(ncPlayer videoSharer, string videoName, string videoTitle, string videoPreview, string videoURL, string audioURL)
{
    ncUserEntity_Video userVideo = AllocateNewType(videoSharer, "ncUserEntity_Video");

    if (!userVideo) {
        return;
    }

    if (!STRING_SET(audioURL)) {
        audioURL = "common/null.wav";
        sound(userVideo, CHAN_VOICE, "common/null.wav", 1.0, ATTN_NORM, 100, SOUNDFLAG_FORCELOOP, 0);
    } else {
        sound(userVideo, CHAN_VOICE, audioURL, 1.0, ATTN_NORM, 100, SOUNDFLAG_FORCELOOP, 0);
    }

    userVideo.m_userVideoName = videoName;
    userVideo.m_userVideoTitle = videoTitle;
    userVideo.m_userVideoPreview = videoPreview;
    userVideo.m_userVideoURL = videoURL;
    userVideo.m_userVideoAudio = audioURL;
    userVideo.StartSound(audioURL, CHAN_BODY, 0, true);

    printf("Playing audio %S\n", audioURL);
    userVideo.real_owner = videoSharer;
    userVideo.SendFlags = -1;
}
#endif
