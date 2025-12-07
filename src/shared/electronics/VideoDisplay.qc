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
ncVideoDisplay::ncVideoDisplay(void)
{
}

#ifdef SERVER
entity
ncVideoDisplay::FindInputByName(string inputName)
{
	for (ncAVReceiver videoReceiver = 0; (videoReceiver = (ncAVReceiver)find(videoReceiver, ::spawnclass, "ncAVReceiver"));) {
		if (videoReceiver.targetname == inputName) {
			return (videoReceiver);
		}
	}

	return (__NULL__);
}

void
ncVideoDisplay::SpawnKey(string strKey, string strValue)
{
	switch (strKey) {
	case "ui_menu":
		m_strUIClass = strValue;
		break;
	default:
		super::SpawnKey(strKey, strValue);
		break;
	}
}

/* once all spawn parms have been initialized */
void
ncVideoDisplay::Spawned(void)
{
	m_flUseDistance = 64;
	m_vecScreenLight = [1,1,1];

	super::Spawned();
	pvsflags = PVSF_NOREMOVE;

	m_strUIClass = GetSpawnString("ui_menu");

	if (STRING_SET(!m_strUIClass)) {
		m_strUIClass = "ui/tv.menu";
	}
}

void
ncVideoDisplay::OnMapFinishedLoading(void)
{
	super::OnMapFinishedLoading();

	string spawnInput = GetSpawnString("input");

	if (STRING_SET(spawnInput)) {
		m_videoDisplayInput = FindInputByName(spawnInput);
	} else {
		m_videoDisplayInput = world;
	}

	EntError("spawnInput: %S; %s (%d)", spawnInput, m_videoDisplayInput.classname, num_for_edict(m_videoDisplayInput));
	SendFlags |= VIDEODISPLAYFL_INPUT;
}


void
ncVideoDisplay::Input( entity entityActivator, string inputName, string dataField )
{
	switch (inputName) {
	default:
		super::Input(entityActivator, inputName, dataField);
	}
}

void
ncVideoDisplay::EvaluateEntity(void)
{
	EVALUATE_VECTOR(origin, 0, VIDEODISPLAYFL_ORIGIN)
	EVALUATE_VECTOR(origin, 1, VIDEODISPLAYFL_ORIGIN)
	EVALUATE_VECTOR(origin, 2, VIDEODISPLAYFL_ORIGIN)
	EVALUATE_VECTOR(angles, 0, VIDEODISPLAYFL_ANGLES)
	EVALUATE_VECTOR(angles, 1, VIDEODISPLAYFL_ANGLES)
	EVALUATE_VECTOR(angles, 2, VIDEODISPLAYFL_ANGLES)
	EVALUATE_FIELD(m_strUIClass, VIDEODISPLAYFL_INTERFACE)
	EVALUATE_FIELD(m_flScale, VIDEODISPLAYFL_SCALE)
	EVALUATE_FIELD(m_flUseDistance, VIDEODISPLAYFL_DISTANCE)
	EVALUATE_VECTOR(m_vecUIRes, 0, VIDEODISPLAYFL_RESOLUTION)
	EVALUATE_VECTOR(m_vecUIRes, 1, VIDEODISPLAYFL_RESOLUTION)
	EVALUATE_VECTOR(m_vecScreenLight, 0, VIDEODISPLAYFL_LIGHT)
	EVALUATE_VECTOR(m_vecScreenLight, 1, VIDEODISPLAYFL_LIGHT)
	EVALUATE_VECTOR(m_vecScreenLight, 2, VIDEODISPLAYFL_LIGHT)
	EVALUATE_FIELD(m_uiSurfaceEnabled, VIDEODISPLAYFL_ENABLED)
	EVALUATE_FIELD(m_videoDisplayInput, VIDEODISPLAYFL_INPUT)
}

float
ncVideoDisplay::SendEntity(entity ePEnt, float flChanged)
{
	WriteByte(MSG_ENTITY, ENT_VIDEODISPLAY);
	WriteFloat(MSG_ENTITY, flChanged);
	SENDENTITY_COORD(origin[0], VIDEODISPLAYFL_ORIGIN)
	SENDENTITY_COORD(origin[1], VIDEODISPLAYFL_ORIGIN)
	SENDENTITY_COORD(origin[2], VIDEODISPLAYFL_ORIGIN)
	SENDENTITY_ANGLE(angles[0], VIDEODISPLAYFL_ANGLES)
	SENDENTITY_ANGLE(angles[1], VIDEODISPLAYFL_ANGLES)
	SENDENTITY_ANGLE(angles[2], VIDEODISPLAYFL_ANGLES)
	SENDENTITY_INT(num_for_edict(this), VIDEODISPLAYFL_INTERFACE)
	SENDENTITY_STRING(m_strUIClass, VIDEODISPLAYFL_INTERFACE)
	SENDENTITY_FLOAT(m_flScale, VIDEODISPLAYFL_SCALE)
	SENDENTITY_FLOAT(m_flUseDistance, VIDEODISPLAYFL_DISTANCE)
	SENDENTITY_FLOAT(m_vecUIRes[0], VIDEODISPLAYFL_RESOLUTION)
	SENDENTITY_FLOAT(m_vecUIRes[1], VIDEODISPLAYFL_RESOLUTION)
	SENDENTITY_FLOAT(m_vecScreenLight[0], VIDEODISPLAYFL_LIGHT)
	SENDENTITY_FLOAT(m_vecScreenLight[1], VIDEODISPLAYFL_LIGHT)
	SENDENTITY_FLOAT(m_vecScreenLight[2], VIDEODISPLAYFL_LIGHT)
	SENDENTITY_BYTE(m_uiSurfaceEnabled, VIDEODISPLAYFL_ENABLED)
	SENDENTITY_ENTITY(m_videoDisplayInput, VIDEODISPLAYFL_INPUT)

	return (1);
}
#endif

#ifdef CLIENT
void
ncVideoDisplay::ReceiveEntity(float flNew, float flChanged)
{
	READENTITY_COORD(origin[0], VIDEODISPLAYFL_ORIGIN)
	READENTITY_COORD(origin[1], VIDEODISPLAYFL_ORIGIN)
	READENTITY_COORD(origin[2], VIDEODISPLAYFL_ORIGIN)
	READENTITY_ANGLE(angles[0], VIDEODISPLAYFL_ANGLES)
	READENTITY_ANGLE(angles[1], VIDEODISPLAYFL_ANGLES)
	READENTITY_ANGLE(angles[2], VIDEODISPLAYFL_ANGLES)
	READENTITY_INT(m_serverSideNum, VIDEODISPLAYFL_INTERFACE)
	READENTITY_STRING(m_strUIClass, VIDEODISPLAYFL_INTERFACE)
	READENTITY_FLOAT(m_flScale, VIDEODISPLAYFL_SCALE)
	READENTITY_FLOAT(m_flUseDistance, VIDEODISPLAYFL_DISTANCE)
	READENTITY_FLOAT(m_vecUIRes[0], VIDEODISPLAYFL_RESOLUTION)
	READENTITY_FLOAT(m_vecUIRes[1], VIDEODISPLAYFL_RESOLUTION)
	READENTITY_FLOAT(m_vecScreenLight[0], VIDEODISPLAYFL_LIGHT)
	READENTITY_FLOAT(m_vecScreenLight[1], VIDEODISPLAYFL_LIGHT)
	READENTITY_FLOAT(m_vecScreenLight[2], VIDEODISPLAYFL_LIGHT)
	READENTITY_BYTE(m_uiSurfaceEnabled, VIDEODISPLAYFL_ENABLED)
	READENTITY_ENTNUM(m_videoDisplayInputNum, VIDEODISPLAYFL_INPUT)

	if (flChanged & VIDEODISPLAYFL_INTERFACE) {
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

void
ncVideoDisplay::ReloadVideoResources(void)
{
	m_strSurfaceMat = sprintf("UISurface%d", num_for_edict(this));
	m_flSurfaceMat = shaderforname(m_strSurfaceMat, sprintf("{\nsurfaceParm nolightmap\n{\nmap $rt:%s\n}\n}", m_strSurfaceMat));
	m_bCached = true;
}

void
ncVideoDisplay::postdraw(void)
{
	ncAVReceiver oldInput = m_videoDisplayInput;

	if (m_videoDisplayInputNum == 0) {
		super::postdraw();
		return;
	}

	m_videoDisplayInput = (ncAVReceiver)findfloat(world, ::entnum, m_videoDisplayInputNum);

	if (oldInput != m_videoDisplayInput) {
		if (m_videoDisplayInput) {
			ncAVReceiver newInput = (ncAVReceiver)m_videoDisplayInput;
			newInput.RefreshVideoDisplay(this);
		}
	}

	RenderScene();
}

float
ncVideoDisplay::predraw(void)
{
	vector fsize = m_vecWorldSize / 2;
	vector finalOrg = GetOrigin();

	if (m_uiSurfaceEnabled == false || m_bCached == false)
		return (PREDRAW_NEXT);

	makevectors(angles);
	R_BeginPolygon(m_strSurfaceMat, 0, 0);
	finalOrg += (v_forward * -0.25);
	R_PolygonVertex(finalOrg + v_right * fsize[0] - v_up * fsize[1],
		[1,1], [1,1,1], 1.0f);
	R_PolygonVertex(finalOrg - v_right * fsize[0] - v_up * fsize[1],
		[0,1], [1,1,1], 1.0f);
	R_PolygonVertex(finalOrg - v_right * fsize[0] + v_up * fsize[1],
		[0,0], [1,1,1], 1.0f);
	R_PolygonVertex(finalOrg + v_right * fsize[0] + v_up * fsize[1],
		[1,0], [1,1,1], 1.0f);
	R_EndPolygon();

	if (m_vecScreenLight != g_vec_null) {
		float p = dynamiclight_add(origin + (v_forward * -1), 256, m_vecScreenLight / 255, 0, "lights/tube");
		vector lightAngles = vectoangles(v_forward * -1);
		dynamiclight_set(p, LFIELD_ANGLES, lightAngles);
		dynamiclight_set(p, LFIELD_FLAGS, 3);
		dynamiclight_set(p, LFIELD_OWNER, this);
		dynamiclight_set(p, LFIELD_STYLE, m_vecScreenLightStyle);
	}

	addentity(this);
	return (PREDRAW_NEXT);
}

/* called whenever we are in the proximity of a surface */
void
ncVideoDisplay::RenderScene(void)
{
	if (m_videoDisplayInputNum == 0) {
		super::RenderScene();
		return;
	}

	if (m_bCached == false)
		return;

	clearscene();

	setviewprop(VF_RT_DESTCOLOUR, m_strSurfaceMat, (float)1, [320,240]);
	setviewprop(VF_SIZE, [320,240]);
	setviewprop(VF_DRAWENGINESBAR, (float)0);
	setviewprop(VF_ORIGIN, [0,0,0]);
	setviewprop(VF_ANGLES, [0,0,0]);
	setviewprop(VF_AFOV, 90.0f);

	drawfill([0,0], [320,240], [0,0,1], 1.0f);

	/* draw the chain */
	if (m_UIChain) {
		vguiWidget uiChain = (vguiWidget)m_UIChain;
		uiChain.Draw();
	}

	/* reset */
	setviewprop(VF_RT_DESTCOLOUR, "");
}
#endif
