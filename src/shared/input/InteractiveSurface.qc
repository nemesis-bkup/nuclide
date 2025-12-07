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
ncInteractiveSurface::ncInteractiveSurface(void)
{
	m_strUIClass = "ui/tv.menu";
	m_vecUIRes = [320, 240];
	m_flScale = 0.25f;
	m_flUseDistance = 64;
	m_vecScreenLight = g_vec_null;

#ifdef CLIENT
	m_UIChain = __NULL__;
	m_strSurfaceMat = sprintf("UISurface%d", num_for_edict(this));
	EntLog("UI surface material: %S\n", m_strSurfaceMat);
	m_bCached = false;
#endif

#ifdef SERVER
	m_outputOnActivate = g_string_null;
	m_outputOnActivateFailed = g_string_null;
	m_outputOnOutput1 = g_string_null;
	m_outputOnOutput2 = g_string_null;
	m_outputOnOutput3 = g_string_null;
	m_outputOnOutput4 = g_string_null;
#endif
}


#ifdef SERVER
void
ncInteractiveSurface::SpawnKey(string keyName, string setValue)
{
	switch (keyName) {
	case "ui_menu":
		m_strUIClass = setValue;
		break;
	case "ui_res":
		m_vecUIRes = stov(setValue);
		break;
	case "ui_scale":
		m_flScale = stof(setValue);
		break;
	case "ui_dist":
		m_flUseDistance = stof(setValue);
		break;
	case "light":
		m_vecScreenLight = stov(setValue);
		break;
	case "OnActivate":
		m_outputOnActivate = PrepareOutput(m_outputOnActivate, setValue);
		break;
	case "OnActivateFailed":
		m_outputOnActivateFailed = PrepareOutput(m_outputOnActivateFailed, setValue);
		break;
	case "OnOutput1":
		m_outputOnOutput1 = PrepareOutput(m_outputOnOutput1, setValue);
		break;
	case "OnOutput2":
		m_outputOnOutput2 = PrepareOutput(m_outputOnOutput2, setValue);
		break;
	case "OnOutput3":
		m_outputOnOutput3 = PrepareOutput(m_outputOnOutput3, setValue);
		break;
	case "OnOutput4":
		m_outputOnOutput4 = PrepareOutput(m_outputOnOutput4, setValue);
		break;
	default:
		super::SpawnKey(keyName, setValue);
		break;
	}
}

/* once all spawn parms have been initialized */
void
ncInteractiveSurface::Spawned(void)
{
	super::Spawned();
	pvsflags = PVSF_NOREMOVE;
	m_uiSurfaceEnabled = true;

	if (STRING_SET(m_outputOnActivate)) {
		m_outputOnActivate = CreateOutput(m_outputOnActivate);
	}
	if (STRING_SET(m_outputOnActivateFailed)) {
		m_outputOnActivateFailed = CreateOutput(m_outputOnActivateFailed);
	}
	if (STRING_SET(m_outputOnOutput1)) {
		m_outputOnOutput1 = CreateOutput(m_outputOnOutput1);
	}
	if (STRING_SET(m_outputOnOutput2)) {
		m_outputOnOutput2 = CreateOutput(m_outputOnOutput2);
	}
	if (STRING_SET(m_outputOnOutput3)) {
		m_outputOnOutput3 = CreateOutput(m_outputOnOutput3);
	}
	if (STRING_SET(m_outputOnOutput4)) {
		m_outputOnOutput4 = CreateOutput(m_outputOnOutput4);
	}
}


void
ncInteractiveSurface::Input(entity entityActivator, string inputName, string dataField)
{
	switch (inputName) {
	case "Enable":
		m_uiSurfaceEnabled = true;
		UseOutput(entityActivator, m_outputOnEnable);
		break;
	case "Disable":
		m_uiSurfaceEnabled = false;
		UseOutput(entityActivator, m_outputOnDisable);
		break;
	case "Toggle":
		m_uiSurfaceEnabled = (m_uiSurfaceEnabled == true) ? (false) : (true);
		break;
	case "FireOutput":
		float outputNum = stof(dataField);

		printf("FireOutput: %d\n", outputNum);

		/* prevent cheating... */
		if (distance(entityActivator.origin, origin) > (m_flUseDistance * 2)) {
			return;
		}

		switch (outputNum) {
		case 1:
			UseOutput(entityActivator, m_outputOnOutput1);
			printf("%d %S", outputNum, m_outputOnOutput1);
			break;
		case 2:
			UseOutput(entityActivator, m_outputOnOutput2);
			printf("%d %S", outputNum, m_outputOnOutput2);
			break;
		case 3:
			UseOutput(entityActivator, m_outputOnOutput3);
			printf("%d %S", outputNum, m_outputOnOutput3);
			break;
		case 4:
			UseOutput(entityActivator, m_outputOnOutput4);
			printf("%d %S", outputNum, m_outputOnOutput4);
			break;
		}
		break;
	case "ActivateOnTextMatch":
		string wantedText = GetSpawnString("gui_parm1");

		/* prevent cheating... */
		if (distance(entityActivator.origin, origin) > (m_flUseDistance * 2)) {
			return;
		}

		if (dataField == wantedText) {
			UseTargets(this, TRIG_TOGGLE, 0.0f);
			UseOutput(entityActivator, m_outputOnActivate);
		} else {
			UseOutput(entityActivator, m_outputOnActivateFailed);
		}
		break;
	default:
		super::Input(entityActivator, inputName, dataField);
	}
}

void
ncInteractiveSurface::EvaluateEntity(void)
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
ncInteractiveSurface::SendEntity(entity ePEnt, float flChanged)
{
	WriteByte(MSG_ENTITY, ENT_UISURFACE);
	WriteFloat(MSG_ENTITY, flChanged);
	SENDENTITY_COORD(origin[0], UISURFACEFL_ORIGIN)
	SENDENTITY_COORD(origin[1], UISURFACEFL_ORIGIN)
	SENDENTITY_COORD(origin[2], UISURFACEFL_ORIGIN)
	SENDENTITY_ANGLE(angles[0], UISURFACEFL_ANGLES)
	SENDENTITY_ANGLE(angles[1], UISURFACEFL_ANGLES)
	SENDENTITY_ANGLE(angles[2], UISURFACEFL_ANGLES)
	SENDENTITY_INT(num_for_edict(this), UISURFACEFL_INTERFACE)
	SENDENTITY_STRING(m_strUIClass, UISURFACEFL_INTERFACE)
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
ncInteractiveSurface::ReceiveEntity(float flNew, float flChanged)
{
	READENTITY_COORD(origin[0], UISURFACEFL_ORIGIN)
	READENTITY_COORD(origin[1], UISURFACEFL_ORIGIN)
	READENTITY_COORD(origin[2], UISURFACEFL_ORIGIN)
	READENTITY_ANGLE(angles[0], UISURFACEFL_ANGLES)
	READENTITY_ANGLE(angles[1], UISURFACEFL_ANGLES)
	READENTITY_ANGLE(angles[2], UISURFACEFL_ANGLES)
	READENTITY_INT(m_serverSideNum, UISURFACEFL_INTERFACE)
	READENTITY_STRING(m_strUIClass, UISURFACEFL_INTERFACE)
	READENTITY_FLOAT(m_flScale, UISURFACEFL_SCALE)
	READENTITY_FLOAT(m_flUseDistance, UISURFACEFL_DISTANCE)
	READENTITY_FLOAT(m_vecUIRes[0], UISURFACEFL_RESOLUTION)
	READENTITY_FLOAT(m_vecUIRes[1], UISURFACEFL_RESOLUTION)
	READENTITY_FLOAT(m_vecScreenLight[0], UISURFACEFL_LIGHT)
	READENTITY_FLOAT(m_vecScreenLight[1], UISURFACEFL_LIGHT)
	READENTITY_FLOAT(m_vecScreenLight[2], UISURFACEFL_LIGHT)
	READENTITY_BYTE(m_uiSurfaceEnabled, UISURFACEFL_ENABLED)

	if (flNew) {
		vguiWidget uiChain = (vguiWidget)m_UIChain;

		m_vecWorldSize = m_vecUIRes * m_flScale;
		ReloadVideoResources();

		/* initialize UI panel here */
		m_UIChain = spawn(vguiWidget);
		vguiWidget uiChain = (vguiWidget)m_UIChain;
		uiChain.m_iFlags = 1;

		m_videoDisplayUI = vguiTrUIMenu::CreateFromMenuFile(m_UIChain, m_strUIClass);
		m_videoDisplayUI.owner = this;

		if (m_videoDisplayUI) {
			uiChain.Add(m_videoDisplayUI);
		} else {
			error("Unable to allocate ncVideoDisplay");
		}
	}

	drawmask = MASK_ENGINE;
}

bool
ncInteractiveSurface::FocusCheck(vector vecViewPos, vector vecViewAng)
{
	vector vecPlayerForward;
	vector vecNormal, vecTangent, vecBitTangent;
	vector vecNear, vecFar, vecImpact;
	vector vecTestOrg;
	float fs, fe, f, s, t;

	if (m_uiSurfaceEnabled == false) {
		/* cancel out early */
		m_bInFocus = false;
		return (m_bInFocus);
	}

	/* are we within the use-distance of our UI even? */
	if (vlen(origin - vecViewPos) > m_flUseDistance) {
		/* cancel out early */
		m_bInFocus = false;
		return (m_bInFocus);
	}

	/* get client forward vector */
	makevectors(vecViewAng);
	vecPlayerForward = v_forward;

	/* get surface normals etc. */
	makevectors(angles);
	vecNormal = v_forward;
	vecTangent = v_right;
	vecBitTangent = v_up;

	/* get our reference points, near being the corner */
	vecNear = vecViewPos - (origin - (vecTangent * (m_vecWorldSize[0]/2)) + vecBitTangent * (m_vecWorldSize[1]/2));
	vecFar = vecNear + vecPlayerForward * 512;

	/* calculate our impact, which in turns gives us surface/texture coordinates */
	fs = dotproduct(vecNear, vecNormal);
	fe = dotproduct(vecFar, vecNormal);
	f = fs / (fs - fe);
	vecImpact = vecNear + (vecFar - vecNear) * f;
	s = dotproduct(vecImpact, vecTangent);
	t = dotproduct(vecImpact, vecBitTangent);

	/* our aim-pos in world units */
	vecTestOrg = [s,-t,0];

	/* bounds check for our in-world aim-pos */
	if (vecTestOrg[0] >= 0 && vecTestOrg[0] <= m_vecWorldSize[0]) {
		if (vecTestOrg[1] >= 0 && vecTestOrg[1] <= m_vecWorldSize[1]) {
			m_bInFocus = true;

			/* cursors need to be scaled according to the UI */
			m_vecCursorPos = [s, -t, 0] / m_flScale;

			/* widgets query this instead of getmousepos() */
			g_vecMousePos = m_vecCursorPos;
			return true;
		}
	}

	m_bInFocus = false;
	return m_bInFocus;
}

void
ncInteractiveSurface::ReloadVideoResources(void)
{
	m_flSurfaceMat = shaderforname(m_strSurfaceMat, sprintf("{\nsurfaceParm nolightmap\n{\nmap $rt:%s\n}\n}", m_strSurfaceMat));
	m_bCached = true;
}

void
ncInteractiveSurface::postdraw(void)
{
	RenderScene();
}

float
ncInteractiveSurface::predraw(void)
{
	vector fsize = m_vecWorldSize / 2;

	if (m_uiSurfaceEnabled == false || m_bCached == false)
		return (PREDRAW_NEXT);

	makevectors(angles);
	R_BeginPolygon(m_strSurfaceMat, 0, 0);
	R_PolygonVertex(origin + v_right * fsize[0] - v_up * fsize[1],
		[1,1], [1,1,1], 1.0f);
	R_PolygonVertex(origin - v_right * fsize[0] - v_up * fsize[1],
		[0,1], [1,1,1], 1.0f);
	R_PolygonVertex(origin - v_right * fsize[0] + v_up * fsize[1],
		[0,0], [1,1,1], 1.0f);
	R_PolygonVertex(origin + v_right * fsize[0] + v_up * fsize[1],
		[1,0], [1,1,1], 1.0f);
	R_EndPolygon();

	if (m_vecScreenLight != g_vec_null) {
		float p = dynamiclight_add(origin + (v_forward * -1), 256, m_vecScreenLight / 255, 0, "lights/tube");
		vector lightAngles = vectoangles(v_forward * -1);
		dynamiclight_set(p, LFIELD_ANGLES, lightAngles);
		dynamiclight_set(p, LFIELD_FLAGS, 3);
		dynamiclight_set(p, LFIELD_OWNER, this);
		dynamiclight_set(p, LFIELD_STYLE, 64);
	}

	addentity(this);
	return (PREDRAW_NEXT);
}

/* we just forward input events to our UI chain */
bool
ncInteractiveSurface::Input(float flEVType, float flKey, float flChar, float flDevID)
{
	if (m_UIChain) {
		vguiWidget uiChain = (vguiWidget)m_UIChain;
		uiChain.Input(flEVType, flKey, flChar, flDevID);
	}

	return true;
}

/* called whenever we are in the proximity of a surface */
void
ncInteractiveSurface::RenderScene(void)
{
	if (m_bCached == false)
		return;

	clearscene();

	setviewprop(VF_RT_DESTCOLOUR, m_strSurfaceMat, (float)1, m_vecUIRes);
	setviewprop(VF_SIZE, m_vecUIRes);
	setviewprop(VF_DRAWENGINESBAR, (float)0);
	setviewprop(VF_ORIGIN, [0,0,0]);
	setviewprop(VF_ANGLES, [0,0,0]);
	setviewprop(VF_AFOV, 90.0f);

	drawfill([0,0], m_vecUIRes, [sin(cltime),sin(cltime*2),sin(cltime*0.5f)], 1.0f);

	/* draw the chain */
	if (m_UIChain) {
		vguiWidget uiChain = (vguiWidget)m_UIChain;
		uiChain.Draw();
	}

	/* render cursor */
	if (m_bInFocus)
		drawpic(m_vecCursorPos, "gfx/icon16/cursor", [16,16], [1,1,1], 1.0f);

	/* reset */
	setviewprop(VF_RT_DESTCOLOUR, "");
}
#endif
