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
ncUserEntity_Audio::ncUserEntity_Audio(void)
{
}

#ifdef SERVER
void
ncUserEntity_Audio::EvaluateEntity(void)
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
ncUserEntity_Audio::SendEntity(entity ePEnt, float flChanged)
{
	WriteByte(MSG_ENTITY, ENT_SPRAYAUDIO);
	WriteFloat(MSG_ENTITY, flChanged);
	SENDENTITY_COORD(origin[0], UISURFACEFL_ORIGIN)
	SENDENTITY_COORD(origin[1], UISURFACEFL_ORIGIN)
	SENDENTITY_COORD(origin[2], UISURFACEFL_ORIGIN)
	SENDENTITY_ANGLE(angles[0], UISURFACEFL_ANGLES)
	SENDENTITY_ANGLE(angles[1], UISURFACEFL_ANGLES)
	SENDENTITY_ANGLE(angles[2], UISURFACEFL_ANGLES)
	SENDENTITY_INT(num_for_edict(this), UISURFACEFL_INTERFACE)
	SENDENTITY_STRING(m_userAudioURL, UISURFACEFL_INTERFACE)
	SENDENTITY_STRING(m_userAudioPic, UISURFACEFL_INTERFACE)
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
ncUserEntity_Audio::VideoSave_Clicked(vguiWidget sender)
{
	printf("Saved %S\n", m_userAudioURL);
}

void
ncUserEntity_Audio::ReceiveEntity(float flNew, float flChanged)
{
	READENTITY_COORD(origin[0], UISURFACEFL_ORIGIN)
	READENTITY_COORD(origin[1], UISURFACEFL_ORIGIN)
	READENTITY_COORD(origin[2], UISURFACEFL_ORIGIN)
	READENTITY_ANGLE(angles[0], UISURFACEFL_ANGLES)
	READENTITY_ANGLE(angles[1], UISURFACEFL_ANGLES)
	READENTITY_ANGLE(angles[2], UISURFACEFL_ANGLES)
	READENTITY_INT(m_serverSideNum, UISURFACEFL_INTERFACE)
	READENTITY_STRING(m_userAudioURL, UISURFACEFL_INTERFACE)
	READENTITY_STRING(m_userAudioPic, UISURFACEFL_INTERFACE)
	READENTITY_FLOAT(m_flScale, UISURFACEFL_SCALE)
	READENTITY_FLOAT(m_flUseDistance, UISURFACEFL_DISTANCE)
	READENTITY_FLOAT(m_vecUIRes[0], UISURFACEFL_RESOLUTION)
	READENTITY_FLOAT(m_vecUIRes[1], UISURFACEFL_RESOLUTION)
	READENTITY_FLOAT(m_vecScreenLight[0], UISURFACEFL_LIGHT)
	READENTITY_FLOAT(m_vecScreenLight[1], UISURFACEFL_LIGHT)
	READENTITY_FLOAT(m_vecScreenLight[2], UISURFACEFL_LIGHT)
	READENTITY_BYTE(m_uiSurfaceEnabled, UISURFACEFL_ENABLED)


	if (flNew) {
		m_vecWorldSize = m_vecUIRes * m_flScale;
		ReloadVideoResources();

		/* initialize UI panel here */
		m_uiRootWindow = spawn(vguiRootWindow);
		vguiWidget uiChain = (vguiWidget)m_uiRootWindow;
		vguiView controlView = (vguiView)m_uiRootWindow;
		uiChain.m_iFlags = 1;

		m_audioPic = spawn(vguiAudioStream);
		vguiAudioStream ourVideo = (vguiAudioStream)m_audioPic;
		ourVideo.SetSize(m_vecUIRes);
		uiChain.Add(ourVideo);

		vguiButton btnStart = spawn(vguiButton);
		controlView.Add(btnStart);
		btnStart.SetPos([8, m_vecUIRes[1] - 22-8]);
		btnStart.SetIcon("gfx/icon16/control_start");
		btnStart.SetSize([22,22]);
		btnStart.SetFuncWithDelegate(vguiAudioStream::RestartStream, m_audioPic);

		vguiButton btnRewind = spawn(vguiButton);
		controlView.Add(btnRewind);
		btnRewind.SetPos(btnStart.GetPos() + [btnStart.GetWidth(), 0]);
		btnRewind.SetIcon("gfx/icon16/control_rewind");
		btnRewind.SetSize([22,22]);
		btnRewind.SetFuncWithDelegate(vguiAudioStream::SeekBackward, m_audioPic);

		vguiButton btnPlay = spawn(vguiButton);
		controlView.Add(btnPlay);
		btnPlay.SetPos(btnRewind.GetPos() + [btnRewind.GetWidth(), 0]);
		btnPlay.SetIcon("gfx/icon16/control_play");
		btnPlay.SetSize([22,22]);
		btnPlay.SetFuncWithDelegate(vguiAudioStream::PlayStream, m_audioPic);

		vguiButton btnFastForward = spawn(vguiButton);
		controlView.Add(btnFastForward);
		btnFastForward.SetPos(btnPlay.GetPos() + [btnPlay.GetWidth(), 0]);
		btnFastForward.SetIcon("gfx/icon16/control_fastforward");
		btnFastForward.SetSize([22,22]);
		btnFastForward.SetFuncWithDelegate(vguiAudioStream::SeekForward, m_audioPic);

		vguiButton btnEnd = spawn(vguiButton);
		controlView.Add(btnEnd);
		btnEnd.SetPos(btnFastForward.GetPos() + [btnFastForward.GetWidth(), 0]);
		btnEnd.SetIcon("gfx/icon16/control_end");
		btnEnd.SetSize([22,22]);
		btnEnd.SetFuncWithDelegate(vguiAudioStream::StopStream, m_audioPic);

		vguiButton btnSave = spawn(vguiButton);
		controlView.Add(btnSave);
		btnSave.SetPos(btnEnd.GetPos() + [btnEnd.GetWidth(), 0]);
		btnSave.SetIcon("gfx/icon16/disk");
		btnSave.SetSize([22,22]);
		btnSave.SetFuncWithDelegate(VideoSave_Clicked, this);

		vguiButton btnRemove = spawn(vguiButton);
		controlView.Add(btnRemove);
		btnRemove.SetPos([m_vecUIRes[0] - 22-8, 8]);
		btnRemove.SetIcon("gfx/icon16/cross");
		btnRemove.SetSize([22,22]);
		btnRemove.SetFuncWithDelegate(RequestRemoval, this);
	}

	if (flChanged & UISURFACEFL_INTERFACE) {
		if (m_audioPic) {
			vguiAudioStream ourVideo = (vguiAudioStream)m_audioPic;
			ourVideo.LoadRequest(m_userAudioURL);
			ourVideo.SetImage(m_userAudioPic);
		}
	}
}
#endif

#ifdef SERVER
void
ncUserEntity_Audio::Place(ncPlayer pageSharer, string videoName, string videoURL, string videoPreview)
{
	ncUserEntity_Audio userURL = AllocateNewType(pageSharer, "ncUserEntity_Audio");

	if (!userURL) {
		return;
	}

	userURL.real_owner = pageSharer;
	userURL.m_userAudioURL = videoURL;
	userURL.m_userAudioPic = videoPreview;
	userURL.m_vecScreenLight = [255,255,255];
	userURL.m_flScale = 0.2f;
	userURL.m_vecUIRes[0] = (22 * 6) + 16;
	userURL.m_vecUIRes[1] = userURL.m_vecUIRes[0];
	userURL.SendFlags = -1;

}
#endif
