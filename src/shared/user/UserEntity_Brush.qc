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
ncUserEntity_Brush::ncUserEntity_Brush(void)
{
}

#ifdef SERVER
void
ncUserEntity_Brush::EvaluateEntity(void)
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
ncUserEntity_Brush::SendEntity(entity ePEnt, float flChanged)
{
	WriteByte(MSG_ENTITY, ENT_SPRAYIMAGE);
	WriteFloat(MSG_ENTITY, flChanged);
	SENDENTITY_COORD(origin[0], UISURFACEFL_ORIGIN)
	SENDENTITY_COORD(origin[1], UISURFACEFL_ORIGIN)
	SENDENTITY_COORD(origin[2], UISURFACEFL_ORIGIN)
	SENDENTITY_ANGLE(angles[0], UISURFACEFL_ANGLES)
	SENDENTITY_ANGLE(angles[1], UISURFACEFL_ANGLES)
	SENDENTITY_ANGLE(angles[2], UISURFACEFL_ANGLES)
	SENDENTITY_FLOAT(size[0], UISURFACEFL_ANGLES)
	SENDENTITY_FLOAT(size[1], UISURFACEFL_ANGLES)
	SENDENTITY_INT(num_for_edict(this), UISURFACEFL_INTERFACE)
	SENDENTITY_STRING(m_userPictureURL, UISURFACEFL_INTERFACE)
	SENDENTITY_STRING(m_userPosterName, UISURFACEFL_INTERFACE)
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
ncUserEntity_Brush::VideoSave_Clicked(vguiWidget sender)
{
	printf("Saved %S %S\n", m_userPosterName, m_userPictureURL);
}

void
ncUserEntity_Brush::ReceiveEntity(float flNew, float flChanged)
{
	READENTITY_COORD(origin[0], UISURFACEFL_ORIGIN)
	READENTITY_COORD(origin[1], UISURFACEFL_ORIGIN)
	READENTITY_COORD(origin[2], UISURFACEFL_ORIGIN)
	READENTITY_ANGLE(angles[0], UISURFACEFL_ANGLES)
	READENTITY_ANGLE(angles[1], UISURFACEFL_ANGLES)
	READENTITY_ANGLE(angles[2], UISURFACEFL_ANGLES)
	READENTITY_FLOAT(size[0], UISURFACEFL_ANGLES)
	READENTITY_FLOAT(size[1], UISURFACEFL_ANGLES)
	READENTITY_INT(m_serverSideNum, UISURFACEFL_INTERFACE)
	READENTITY_STRING(m_userPictureURL, UISURFACEFL_INTERFACE)
	READENTITY_STRING(m_userPosterName, UISURFACEFL_INTERFACE)
	READENTITY_FLOAT(m_flScale, UISURFACEFL_SCALE)
	READENTITY_FLOAT(m_flUseDistance, UISURFACEFL_DISTANCE)
	READENTITY_FLOAT(m_vecUIRes[0], UISURFACEFL_RESOLUTION)
	READENTITY_FLOAT(m_vecUIRes[1], UISURFACEFL_RESOLUTION)
	READENTITY_FLOAT(m_vecScreenLight[0], UISURFACEFL_LIGHT)
	READENTITY_FLOAT(m_vecScreenLight[1], UISURFACEFL_LIGHT)
	READENTITY_FLOAT(m_vecScreenLight[2], UISURFACEFL_LIGHT)
	READENTITY_BYTE(m_uiSurfaceEnabled, UISURFACEFL_ENABLED)

	if (flChanged & UISURFACEFL_ANGLES) {
		angles[0] += 90;
	}

	if (flNew) {
		vguiWidget uiChain = (vguiWidget)m_UIChain;

		m_vecWorldSize = m_vecUIRes * m_flScale;
		ReloadVideoResources();

		/* initialize UI panel here */
		m_UIChain = spawn(vguiWidget);
		vguiWidget uiChain = (vguiWidget)m_UIChain;
		uiChain.m_iFlags = 1;

		m_uiPic = spawn(vguiPic);
		vguiPic ourVideo = (vguiPic)m_uiPic;
		ourVideo.SetSize(m_vecUIRes);
		uiChain.Add(ourVideo);

		m_uiLabel = spawn(vguiLabel);
		vguiLabel ourLabel = (vguiLabel)m_uiLabel;
		ourLabel.SetSize(m_vecUIRes);
		ourLabel.m_strTitle = (m_userPosterName);
		ourLabel.SetPos([8,8]);
		ourLabel.SetShadow(true);
		uiChain.Add(ourLabel);

		vguiButton btnSave = spawn(vguiButton);
		uiChain.Add(btnSave);
		btnSave.SetSize([22,22]);
		btnSave.SetPos([8, m_vecUIRes[1] - 22 - 8]);
		btnSave.SetIcon("gfx/icon16/disk");
		btnSave.SetFuncWithDelegate(VideoSave_Clicked, this);

		vguiButton btnRemove = spawn(vguiButton);
		uiChain.Add(btnRemove);
		btnRemove.SetPos([m_vecUIRes[0] - 22-8, 8]);
		btnRemove.SetIcon("gfx/icon16/cross");
		btnRemove.SetSize([22,22]);
		btnRemove.SetFuncWithDelegate(RequestRemoval, this);
	}

	if (flChanged & UISURFACEFL_INTERFACE) {
		precache_pic(m_userPictureURL);

		if (m_uiPic) {
			vguiPic ourVideo = (vguiPic)m_uiPic;
			ourVideo.SetImage(m_userPictureURL);
		}
	}
}
#endif

#ifdef SERVER
void
ncUserEntity_Brush::Place(ncPlayer pictureSharer, string pictureName, string pictureURL, vector realSize)
{
	ncUserEntity_Brush userPicture;
	vector src;
	vector co;
	vector forwardDir;
	vector planeNormal;
	vector endPos;

	src = pictureSharer.GetEyePos();

	makevectors(pictureSharer.v_angle);
	forwardDir = v_forward;
	traceline(src, src + forwardDir * 512, FALSE, pictureSharer);
	planeNormal = trace_plane_normal;
	endPos = trace_endpos;

	if (trace_fraction >= 1.0f) {
		return;
	}

	/* limit */
	/*if (ncUserEntityManager::NumUserObjectsForClient(pictureSharer, "ncUserEntity_Brush") >= 1) {
		return;
	}*/

	/* we only allow one active userPicture */
	//Spray_RemoveAll(pictureSharer);

	/* spawn the new one */
	userPicture = spawn(ncUserEntity_Brush);
	userPicture.Spawn();

	userPicture.real_owner = pictureSharer;
	userPicture.m_userPictureURL = pictureURL;

	/* calculate the rotation by taking our current view and mapping it
	 * against the surface we're looking at */
	makevectors([pictureSharer.v_angle[0] * -1, pictureSharer.v_angle[1], pictureSharer.v_angle[2]]);
	co = forwardDir -(forwardDir * planeNormal) * planeNormal;

	/* quick fix */
	if (planeNormal[2] == 0) {
		co = '0 0 1';
	}

	/* apply the angles and apply networking */
	userPicture.angles = vectoangles(co, planeNormal);
	userPicture.SendFlags = 1;
	userPicture.m_vecUIRes = realSize * (1/0.25);
	userPicture.size = realSize;
	userPicture.m_flScale = 0.25f;
	userPicture.m_userPosterName = pictureName;

	if (userPicture.m_flScale < 0) {
		userPicture.m_flScale = 0.25f;
	}

	setorigin(userPicture, endPos + (forwardDir * -(userPicture.m_flScale * 5)));
}
#endif
