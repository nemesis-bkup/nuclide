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
ncUserEntity_URL::ncUserEntity_URL(void)
{
}

#ifdef SERVER
void
ncUserEntity_URL::EvaluateEntity(void)
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
ncUserEntity_URL::SendEntity(entity ePEnt, float flChanged)
{
	WriteByte(MSG_ENTITY, ENT_SPRAYWWW);
	WriteFloat(MSG_ENTITY, flChanged);
	SENDENTITY_COORD(origin[0], UISURFACEFL_ORIGIN)
	SENDENTITY_COORD(origin[1], UISURFACEFL_ORIGIN)
	SENDENTITY_COORD(origin[2], UISURFACEFL_ORIGIN)
	SENDENTITY_ANGLE(angles[0], UISURFACEFL_ANGLES)
	SENDENTITY_ANGLE(angles[1], UISURFACEFL_ANGLES)
	SENDENTITY_ANGLE(angles[2], UISURFACEFL_ANGLES)
	SENDENTITY_INT(num_for_edict(this), UISURFACEFL_INTERFACE)
	SENDENTITY_STRING(m_userPageURL, UISURFACEFL_INTERFACE)
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
ncUserEntity_URL::VideoSave_Clicked(vguiWidget sender)
{
	printf("Saved %S\n", m_userPageURL);
}

void
ncUserEntity_URL::ReceiveEntity(float flNew, float flChanged)
{
	READENTITY_COORD(origin[0], UISURFACEFL_ORIGIN)
	READENTITY_COORD(origin[1], UISURFACEFL_ORIGIN)
	READENTITY_COORD(origin[2], UISURFACEFL_ORIGIN)
	READENTITY_ANGLE(angles[0], UISURFACEFL_ANGLES)
	READENTITY_ANGLE(angles[1], UISURFACEFL_ANGLES)
	READENTITY_ANGLE(angles[2], UISURFACEFL_ANGLES)
	READENTITY_INT(m_serverSideNum, UISURFACEFL_INTERFACE)
	READENTITY_STRING(m_userPageURL, UISURFACEFL_INTERFACE)
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
		m_uiRootWindow = vguiScriptedView::CreateFromMenuFile(m_uiRootWindow, "ui/browser.menu");
	}

	if (flChanged & UISURFACEFL_INTERFACE) {
		if (m_videoPic) {
			vguiWebView ourVideo = (vguiWebView)m_videoPic;
			ourVideo.LoadRequest(m_userPageURL);
		}
	}
}
#endif

#ifdef SERVER
void
ncUserEntity_URL::Place(ncPlayer pageSharer, string videoName, string videoURL, string videoPreview)
{
	ncUserEntity_URL userURL;
	vector src;
	vector co;
	vector forwardDir;
	vector planeNormal;
	vector endPos;

	src = pageSharer.GetEyePos();

	makevectors(pageSharer.v_angle);
	forwardDir = v_forward;
	traceline(src, src + forwardDir * 512, FALSE, pageSharer);
	planeNormal = trace_plane_normal;
	endPos = trace_endpos;

	if (trace_fraction >= 1.0f) {
		return;
	}

	/* limit */
	if (ncUserEntityManager::NumUserObjectsForClient(pageSharer, "ncUserEntity_URL") >= 1) {
		return;
	}

	/* spawn the new one */
	userURL = spawn(ncUserEntity_URL);
	userURL.Spawn();

	userURL.real_owner = pageSharer;
	userURL.m_userPageURL = videoURL;

	/* calculate the rotation by taking our current view and mapping it
	 * against the surface we're looking at */
	makevectors([pageSharer.v_angle[0] * -1, pageSharer.v_angle[1], pageSharer.v_angle[2]]);
	co = forwardDir -(forwardDir * planeNormal) * planeNormal;

	/* quick fix */
	if (planeNormal[2] == 0) {
		co = '0 0 1';
	}

	/* apply the angles and apply networking */
	userURL.angles = vectoangles(co, planeNormal);
	userURL.SendFlags = 1;
	userURL.m_vecScreenLight = [255,255,255];
	userURL.m_vecUIRes = [1024,768];
	userURL.m_flScale =  0.05f;

	setorigin(userURL, endPos + (forwardDir * -(userURL.m_flScale * 5)));
}
#endif
