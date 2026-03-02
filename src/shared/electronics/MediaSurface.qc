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

#ifdef SERVER
class
ncMediaSurfaceDataEvent:ncEntity
{
    ncPlayer m_targetClient;
    string m_dataCommand;
    ncMediaSurface m_targetSurface;

    nonvirtual void Send(void);
    nonvirtual void Set(ncClient, ncMediaSurface, string);
};

void
ncMediaSurfaceDataEvent::ncMediaSurfaceDataEvent(void)
{
    m_targetSurface = __NULL__;
    m_targetClient = __NULL__;
    m_dataCommand = __NULL__;
}

void
ncMediaSurfaceDataEvent::Send(void)
{
    WriteEntityEvent(MSG_MULTICAST, m_targetSurface, MEDIASURFACE_EVENT_OPENURL);
    WriteString(MSG_MULTICAST, m_dataCommand);
    msg_entity = m_targetClient;
    multicast(g_vec_null, MULTICAST_ONE_R);
    Destroy();
}

void
ncMediaSurfaceDataEvent::Set(ncClient targetClient, ncMediaSurface targetSurface, string lastData)
{
    m_targetSurface = targetSurface;
    m_targetClient = targetClient;
    m_dataCommand = lastData;
    ScheduleThink(Send, 0.0f);
}
#endif


void
ncMediaSurface::ncMediaSurface(void)
{
	m_vecUIRes = [320, 240];
	m_flScale = 0.25f;
	m_flUseDistance = 64;
	m_vecScreenLight = g_vec_null;

#ifdef CLIENT
	m_uiRootWindow = __NULL__;
    m_uiInteractive = __NULL__;
	m_strSurfaceMat = sprintf("UISurface%d", m_serverSideNum);
	EntLog("UI surface material: %S\n", m_strSurfaceMat);
	m_bCached = false;
    m_refreshRate = 50.0f;
#endif

#ifdef SERVER
    m_lastDataCommand = g_string_null;
	m_outputOnActivate = g_string_null;
	m_outputOnActivateFailed = g_string_null;
	m_outputOnOutput1 = g_string_null;
	m_outputOnOutput2 = g_string_null;
	m_outputOnOutput3 = g_string_null;
	m_outputOnOutput4 = g_string_null;
	m_outputOnOutput5 = g_string_null;
	m_outputOnOutput6 = g_string_null;
	m_outputOnOutput7 = g_string_null;
	m_outputOnOutput8 = g_string_null;
	m_outputOnOutput9 = g_string_null;
	m_outputOnOutput10 = g_string_null;
	m_outputOnOutput11 = g_string_null;
	m_outputOnOutput12 = g_string_null;
	m_outputOnOutput13 = g_string_null;
	m_outputOnOutput14 = g_string_null;
	m_outputOnOutput15 = g_string_null;
	m_outputOnOutput16 = g_string_null;
#endif
}


#ifdef SERVER
void
ncMediaSurface::SpawnKey(string keyName, string setValue)
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
    case "accepts":
        m_acceptsData = ReadString(setValue);
        break;
    case "gui_base64":
        m_gui64 = ReadString(setValue);
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
	case "OnOutput5":
		m_outputOnOutput5 = PrepareOutput(m_outputOnOutput5, setValue);
		break;
	case "OnOutput6":
		m_outputOnOutput6 = PrepareOutput(m_outputOnOutput6, setValue);
		break;
	case "OnOutput7":
		m_outputOnOutput7 = PrepareOutput(m_outputOnOutput7, setValue);
		break;
	case "OnOutput8":
		m_outputOnOutput8 = PrepareOutput(m_outputOnOutput8, setValue);
		break;
	case "OnOutput9":
		m_outputOnOutput9 = PrepareOutput(m_outputOnOutput9, setValue);
		break;
	case "OnOutput10":
		m_outputOnOutput10 = PrepareOutput(m_outputOnOutput10, setValue);
		break;
	case "OnOutput11":
		m_outputOnOutput11 = PrepareOutput(m_outputOnOutput11, setValue);
		break;
	case "OnOutput12":
		m_outputOnOutput12 = PrepareOutput(m_outputOnOutput12, setValue);
		break;
	case "OnOutput13":
		m_outputOnOutput13 = PrepareOutput(m_outputOnOutput13, setValue);
		break;
	case "OnOutput14":
		m_outputOnOutput14 = PrepareOutput(m_outputOnOutput14, setValue);
		break;
	case "OnOutput15":
		m_outputOnOutput15 = PrepareOutput(m_outputOnOutput15, setValue);
		break;
	case "OnOutput16":
		m_outputOnOutput16 = PrepareOutput(m_outputOnOutput16, setValue);
		break;
	default:
		super::SpawnKey(keyName, setValue);
		break;
	}
}

/* once all spawn parms have been initialized */
void
ncMediaSurface::Spawned(void)
{
	super::Spawned();
	m_uiSurfaceEnabled = true;

	OUTPUT_ALLOC(m_outputOnActivate)
	OUTPUT_ALLOC(m_outputOnActivateFailed)
	OUTPUT_ALLOC(m_outputOnOutput1)
	OUTPUT_ALLOC(m_outputOnOutput2)
	OUTPUT_ALLOC(m_outputOnOutput3)
	OUTPUT_ALLOC(m_outputOnOutput4)
	OUTPUT_ALLOC(m_outputOnOutput5)
	OUTPUT_ALLOC(m_outputOnOutput6)
	OUTPUT_ALLOC(m_outputOnOutput7)
	OUTPUT_ALLOC(m_outputOnOutput8)
	OUTPUT_ALLOC(m_outputOnOutput9)
	OUTPUT_ALLOC(m_outputOnOutput10)
	OUTPUT_ALLOC(m_outputOnOutput11)
	OUTPUT_ALLOC(m_outputOnOutput12)
	OUTPUT_ALLOC(m_outputOnOutput13)
	OUTPUT_ALLOC(m_outputOnOutput14)
	OUTPUT_ALLOC(m_outputOnOutput15)
	OUTPUT_ALLOC(m_outputOnOutput16)
}

entity
ncMediaSurface::FindInputByName(string inputName)
{
	for (ncAVReceiver videoReceiver = 0; (videoReceiver = (ncAVReceiver)find(videoReceiver, ::targetname, inputName));) {
		if (videoReceiver.targetname == inputName) {
			return (videoReceiver);
		}
	}

	return (__NULL__);
}

void
ncMediaSurface::OnMapFinishedLoading(void)
{
	super::OnMapFinishedLoading();

	string spawnInput = GetSpawnString("input");

	if (STRING_SET(spawnInput)) {
		m_mediaSource = FindInputByName(spawnInput);
	} else {
		m_mediaSource = world;
	}

	SendFlags |= UISURFACEFL_SOURCE;
}



void
ncMediaSurface::Input(entity entityActivator, string inputName, string dataField)
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
			break;
		case 2:
			UseOutput(entityActivator, m_outputOnOutput2);
			break;
		case 3:
			UseOutput(entityActivator, m_outputOnOutput3);
			break;
		case 4:
			UseOutput(entityActivator, m_outputOnOutput4);
			break;
		case 5:
			UseOutput(entityActivator, m_outputOnOutput5);
			break;
		case 6:
			UseOutput(entityActivator, m_outputOnOutput6);
			break;
		case 7:
			UseOutput(entityActivator, m_outputOnOutput7);
			break;
		case 8:
			UseOutput(entityActivator, m_outputOnOutput8);
			break;
		case 9:
			UseOutput(entityActivator, m_outputOnOutput9);
			break;
		case 10:
			UseOutput(entityActivator, m_outputOnOutput10);
			break;
		case 11:
			UseOutput(entityActivator, m_outputOnOutput11);
			break;
		case 12:
			UseOutput(entityActivator, m_outputOnOutput12);
			break;
		case 13:
			UseOutput(entityActivator, m_outputOnOutput13);
			break;
		case 14:
			UseOutput(entityActivator, m_outputOnOutput14);
			break;
		case 15:
			UseOutput(entityActivator, m_outputOnOutput15);
			break;
		case 16:
			UseOutput(entityActivator, m_outputOnOutput16);
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
	case "SetSourceID":
		m_mediaSource = edict_num(stof(dataField));

        /* sanity check */
        if (m_mediaSource) {
            if (m_mediaSource.classname != "ncMediaSource") {
                m_mediaSource = __NULL__;
            }
        }
		SendFlags |= UISURFACEFL_SOURCE;
		break;
	case "SetSource":
		m_mediaSource = find(world, ::targetname, dataField);
		SendFlags |= UISURFACEFL_SOURCE;
		break;
    case "SendUICommand":
        /* this could be very exploitable indeed. */
        if (cvars.GetBool("sv_cheats") == false) {
            return;
        }

        WriteEntityEvent(MSG_MULTICAST, this, MEDIASURFACE_EVENT_COMMAND);
        WriteString(MSG_MULTICAST, dataField);
        msg_entity = entityActivator;
        multicast(GetOrigin(), MULTICAST_PVS_R);
        break;
    case "openurl":
        WriteEntityEvent(MSG_MULTICAST, this, MEDIASURFACE_EVENT_OPENURL);
        WriteString(MSG_MULTICAST, dataField);
        msg_entity = entityActivator;
        multicast(GetOrigin(), MULTICAST_PVS_R);
        m_lastDataCommand = dataField;
        break;
	default:
		super::Input(entityActivator, inputName, dataField);
	}
}

void
ncMediaSurface::EvaluateEntity(void)
{
	EVALUATE_VECTOR(origin, 0, UISURFACEFL_ORIGIN)
	EVALUATE_VECTOR(origin, 1, UISURFACEFL_ORIGIN)
	EVALUATE_VECTOR(origin, 2, UISURFACEFL_ORIGIN)
	EVALUATE_VECTOR(angles, 0, UISURFACEFL_ANGLES)
	EVALUATE_VECTOR(angles, 1, UISURFACEFL_ANGLES)
	EVALUATE_VECTOR(angles, 2, UISURFACEFL_ANGLES)
	EVALUATE_FIELD(m_strUIClass, UISURFACEFL_INTERFACE)
	EVALUATE_FIELD(m_mediaSource, UISURFACEFL_SOURCE)
	EVALUATE_FIELD(m_flScale, UISURFACEFL_SCALE)
	EVALUATE_FIELD(m_flUseDistance, UISURFACEFL_DISTANCE)
	EVALUATE_VECTOR(m_vecUIRes, 0, UISURFACEFL_RESOLUTION)
	EVALUATE_VECTOR(m_vecUIRes, 1, UISURFACEFL_RESOLUTION)
	EVALUATE_VECTOR(m_vecScreenLight, 0, UISURFACEFL_LIGHT)
	EVALUATE_VECTOR(m_vecScreenLight, 1, UISURFACEFL_LIGHT)
	EVALUATE_VECTOR(m_vecScreenLight, 2, UISURFACEFL_LIGHT)
	EVALUATE_FIELD(m_uiSurfaceEnabled, UISURFACEFL_ENABLED)
    EVALUATE_FIELD(m_acceptsData, UISURFACEFL_INTERFACE)
}

void
ncMediaSurface::DispatchLastDataToClient(ncPlayer clientEntity)
{
    ncMediaSurfaceDataEvent newEvent = spawn(ncMediaSurfaceDataEvent);
    newEvent.Set(clientEntity, this, m_lastDataCommand);
}

float
ncMediaSurface::SendEntity(entity ePEnt, float flChanged)
{
	WriteByte(MSG_ENTITY, ENT_MEDIASURFACE);
	WriteFloat(MSG_ENTITY, flChanged);
	SENDENTITY_COORD(origin[0], UISURFACEFL_ORIGIN)
	SENDENTITY_COORD(origin[1], UISURFACEFL_ORIGIN)
	SENDENTITY_COORD(origin[2], UISURFACEFL_ORIGIN)
	SENDENTITY_ANGLE(angles[0], UISURFACEFL_ANGLES)
	SENDENTITY_ANGLE(angles[1], UISURFACEFL_ANGLES)
	SENDENTITY_ANGLE(angles[2], UISURFACEFL_ANGLES)
	SENDENTITY_FLOAT(num_for_edict(this), UISURFACEFL_INTERFACE)
	SENDENTITY_STRING(m_strUIClass, UISURFACEFL_INTERFACE)
	SENDENTITY_FLOAT(num_for_edict(m_mediaSource), UISURFACEFL_SOURCE)
	SENDENTITY_FLOAT(m_flScale, UISURFACEFL_SCALE)
	SENDENTITY_FLOAT(m_flUseDistance, UISURFACEFL_DISTANCE)
	SENDENTITY_FLOAT(m_vecUIRes[0], UISURFACEFL_RESOLUTION)
	SENDENTITY_FLOAT(m_vecUIRes[1], UISURFACEFL_RESOLUTION)
	SENDENTITY_FLOAT(m_vecScreenLight[0], UISURFACEFL_LIGHT)
	SENDENTITY_FLOAT(m_vecScreenLight[1], UISURFACEFL_LIGHT)
	SENDENTITY_FLOAT(m_vecScreenLight[2], UISURFACEFL_LIGHT)
	SENDENTITY_BYTE(m_uiSurfaceEnabled, UISURFACEFL_ENABLED)
    SENDENTITY_STRING(m_acceptsData, UISURFACEFL_INTERFACE)
	SENDENTITY_STRING(m_gui64, UISURFACEFL_INTERFACE)

    if (flChanged & UISURFACEFL_ENABLED && STRING_SET(m_lastDataCommand)) {
        DispatchLastDataToClient(ePEnt);
    }

	return (1);
}
#endif

#ifdef CLIENT

void
ncMediaSurface::ReceiveEvent(float eventID)
{
	switch (eventID) {
	case MEDIASURFACE_EVENT_COMMAND:
        vguiScriptedView scriptedView = (vguiScriptedView)m_uiInteractive;
        string commandString = readstring();
		scriptedView.InterpretCommand(m_uiInteractive, commandString);
		break;
	case MEDIASURFACE_EVENT_OPENURL:
        vguiScriptedView scriptedView = (vguiScriptedView)m_uiInteractive;
        string dataField = readstring();
        tokenizebyseparator(dataField, " ");
        string dataFormat = argv(0);
        string dataURL = argv(1);
        string mediaCommand;

        //printf("Received data of type %s %s\n", dataFormat, dataURL);
        mediaCommand = sprintf("openurl shared_%s \"%s\"", dataFormat, dataURL);
        //printf("%s %s\n", dataFormat, mediaCommand);
        scriptedView.InterpretCommand(m_uiInteractive, mediaCommand);

		break;
    default:
        super::ReceiveEvent(eventID);
        break;
	}
}

void
ncMediaSurface::OnRemoveEntity(void)
{
    super::OnRemoveEntity();

    if (m_uiRootWindow) {
        vguiWidget ourUI = (vguiWidget)m_uiRootWindow;
        ourUI.Remove();
    }
}

void
ncMediaSurface::_ReceiveComplete(float u1, float u2)
{
	super::_ReceiveComplete(u1, u2);
	drawmask = MASK_MEDIASURFACE;
}

void
ncMediaSurface::ReceiveEntity(float flNew, float flChanged)
{
	READENTITY_COORD(origin[0], UISURFACEFL_ORIGIN)
	READENTITY_COORD(origin[1], UISURFACEFL_ORIGIN)
	READENTITY_COORD(origin[2], UISURFACEFL_ORIGIN)
	READENTITY_ANGLE(angles[0], UISURFACEFL_ANGLES)
	READENTITY_ANGLE(angles[1], UISURFACEFL_ANGLES)
	READENTITY_ANGLE(angles[2], UISURFACEFL_ANGLES)
	READENTITY_FLOAT(m_serverSideNum, UISURFACEFL_INTERFACE)
	READENTITY_STRING(m_strUIClass, UISURFACEFL_INTERFACE)
	READENTITY_FLOAT(m_mediaSourceEntityNum, UISURFACEFL_SOURCE)
	READENTITY_FLOAT(m_flScale, UISURFACEFL_SCALE)
	READENTITY_FLOAT(m_flUseDistance, UISURFACEFL_DISTANCE)
	READENTITY_FLOAT(m_vecUIRes[0], UISURFACEFL_RESOLUTION)
	READENTITY_FLOAT(m_vecUIRes[1], UISURFACEFL_RESOLUTION)
	READENTITY_FLOAT(m_vecScreenLight[0], UISURFACEFL_LIGHT)
	READENTITY_FLOAT(m_vecScreenLight[1], UISURFACEFL_LIGHT)
	READENTITY_FLOAT(m_vecScreenLight[2], UISURFACEFL_LIGHT)
	READENTITY_BYTE(m_uiSurfaceEnabled, UISURFACEFL_ENABLED)
    READENTITY_STRING(m_acceptsData, UISURFACEFL_INTERFACE)
	READENTITY_STRING(m_gui64, UISURFACEFL_INTERFACE)

	if ((flChanged & UISURFACEFL_RESOLUTION) || (flChanged & UISURFACEFL_SCALE)) {
		m_vecWorldSize = m_vecUIRes * fabs(m_flScale);
	}

	if (flNew) {
        m_strSurfaceMat = sprintf("UISurface%d", m_serverSideNum);
		ReloadVideoResources();

		if (STRING_SET(m_strUIClass)) {
			vguiRootWindow rootWindow;
            m_uiRootWindow = spawn(vguiRootWindow);
			m_uiInteractive = vguiScriptedView::CreateFromMenuFile(m_uiInteractive, m_strUIClass);
            rootWindow = (vguiRootWindow)m_uiRootWindow;
            rootWindow.Add(m_uiInteractive);
		}

		if (STRING_SET(m_gui64)) {
			vguiRootWindow rootWindow;
            m_uiRootWindow = spawn(vguiRootWindow);
			m_uiInteractive = vguiScriptedView::CreateFromBase64(m_uiInteractive, m_gui64);
            rootWindow = (vguiRootWindow)m_uiRootWindow;
            rootWindow.Add(m_uiInteractive);
		}
	}
}

bool
ncMediaSurface::FocusCheck(vector vecViewPos, vector vecViewAng)
{
	vector vecPlayerForward;
	vector vecNormal, vecTangent, vecBitTangent;
	vector vecNear, vecFar, vecImpact;
	vector vecTestOrg;
	float fs, fe, f, s, t;
	vguiRootWindow rootWindow = (vguiRootWindow)m_uiRootWindow;

	m_bInFocus = false;

	m_mediaSource = findfloat(world, ::m_serverSideNum, m_mediaSourceEntityNum);

	/* no media source */
	if (!m_mediaSource && !m_uiRootWindow) {
		m_bInFocus = false;
		return (m_bInFocus);
	}

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

    if (m_flScale <= 0.0) {
        vecPlayerForward = -v_forward;
    } else {
        vecPlayerForward = v_forward;
    }

	/* get surface normals etc. */
	makevectors(angles);
	vecNormal = v_forward;

    if (m_flScale <= 0.0) {
        vecTangent = v_right;
    } else {
        vecTangent = -v_right;
    }

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
			m_vecCursorPos = [s, -t, 0] / fabs(m_flScale);

			/* widgets query this instead of getmousepos() */
			rootWindow.m_vecMousePos = m_vecCursorPos;
			return true;
		}
	}

	m_bInFocus = false;
	return m_bInFocus;
}

void
ncMediaSurface::ReloadVideoResources(void)
{
	m_flSurfaceMat = shaderforname(m_strSurfaceMat, sprintf("{\nsurfaceParm nolightmap\n{\nmap $rt:%s\n}\n}", m_strSurfaceMat));
	m_bCached = true;
}

void
ncMediaSurface::postdraw(void)
{
}

void
ncMediaSurface::postframe(void)
{
	RenderScene();
}

float
ncMediaSurface::predraw(void)
{
	classname = "ncMediaSurface";
	vector fsize = m_vecWorldSize / 2;

	if (m_bCached == false) {
		return (PREDRAW_NEXT);
	}

	if (m_bInFocus != m_bWasInFocus) {
		if (m_bInFocus) {
			OnGainedFocus();
		} else {
			OnLostFocus();
		}
		m_bWasInFocus = m_bInFocus;
	}

	makevectors(angles);
	R_BeginPolygon(m_strSurfaceMat, 0, 0);

    if (m_flScale <= 0.0) {
        R_PolygonVertex(origin + v_right * fsize[0] - v_up * fsize[1],
            [1,1], [1,1,1], 1.0f);
        R_PolygonVertex(origin - v_right * fsize[0] - v_up * fsize[1],
            [0,1], [1,1,1], 1.0f);
        R_PolygonVertex(origin - v_right * fsize[0] + v_up * fsize[1],
            [0,0], [1,1,1], 1.0f);
        R_PolygonVertex(origin + v_right * fsize[0] + v_up * fsize[1],
            [1,0], [1,1,1], 1.0f);
        R_EndPolygon();
    } else {
        R_PolygonVertex(origin - v_right * fsize[0] - v_up * fsize[1],
            [1,1], [1,1,1], 1.0f);
        R_PolygonVertex(origin + v_right * fsize[0] - v_up * fsize[1],
            [0,1], [1,1,1], 1.0f);
        R_PolygonVertex(origin + v_right * fsize[0] + v_up * fsize[1],
            [0,0], [1,1,1], 1.0f);
        R_PolygonVertex(origin - v_right * fsize[0] + v_up * fsize[1],
            [1,0], [1,1,1], 1.0f);
        R_EndPolygon();
    }

	if (m_vecScreenLight != g_vec_null) {
		float lightScale = (((m_vecWorldSize[0] > m_vecWorldSize[1]) ? (m_vecWorldSize[0]) : (m_vecWorldSize[1])));
		float p = dynamiclight_add(origin + (v_forward * m_flScale), lightScale * autocvar(r_displayLightScale, 5.0), m_vecScreenLight / 255, 0, "lights/tube");
		dynamiclight_set(p, LFIELD_ANGLES, vectoangles(v_forward * m_flScale));
		dynamiclight_set(p, LFIELD_FLAGS, 3);
		dynamiclight_set(p, LFIELD_OWNER, this);
		dynamiclight_set(p, LFIELD_STYLE, 70);
	}

	addentity(this);
	return (PREDRAW_NEXT);
}

/* we just forward input events to our UI chain */
bool
ncMediaSurface::Input(float flEVType, float flKey, float flChar, float flDevID)
{
	if (m_mediaSourceEntityNum != 0 && m_mediaSource) {
		ncMediaSource mediaSource = (ncMediaSource)m_mediaSource;
        vguiRootWindow rootWindow = (vguiRootWindow)mediaSource.m_UIChain;

		ncMediaSource mediaSource = (ncMediaSource)m_mediaSource;
		mediaSource._InputInternal(flEVType, flKey, flChar, flDevID);
	} else if (m_uiRootWindow) {
		vguiRootWindow uiChain = (vguiRootWindow)m_uiRootWindow;

        if (flEVType == IE_KEYDOWN && flKey == K_MOUSE1) {
            pSeat->m_inputFocus = uiChain;
        }

		uiChain.Input(flEVType, flKey, flChar, flDevID);

	}

	return true;
}

void
ncMediaSurface::OnGainedFocus(void)
{
}

void
ncMediaSurface::OnLostFocus(void)
{
}

var float autocvar_r_displayMaxRefreshRate = 120.0f;
var float autocvar_r_displayMinRefreshRate = 1.0f;

/* called whenever we are in the proximity of a surface */
void
ncMediaSurface::RenderScene(void)
{
    bool isFacing = false;

	if (m_bCached == false) {
		return;
	}

	vector playerViewOrg = g_view.GetCameraOrigin();
    isFacing = IsFacingPosition(playerViewOrg);

    if (m_flScale < 0.0 && isFacing == true) {
        return;
    } else if (m_flScale >= 0.0 && isFacing == false) {
        return;
    }

    float distanceToCamera = distance(playerViewOrg, GetOrigin());
    float scaleMultiplier = bound(0.001f, ((4096 - distanceToCamera) / 4096), 1.0f);
    float minRefresh = (autocvar_r_displayMinRefreshRate > 1) ? autocvar_r_displayMinRefreshRate : 1;
    float refreshRate = bound(minRefresh, (scaleMultiplier * m_refreshRate), autocvar_r_displayMaxRefreshRate);

	if (m_lastRefresh + (1.0/refreshRate) > cltime) {
        return;
    }

	clearscene();

    vector renderRes = m_vecUIRes;
	m_mediaSource = findfloat(world, ::m_serverSideNum, m_mediaSourceEntityNum);

    if (m_mediaSourceEntityNum != 0 && m_mediaSource) {
		ncMediaSource mediaSource = (ncMediaSource)m_mediaSource;
        renderRes = mediaSource.m_mediaSize;
    }

	setviewprop(VF_RT_DESTCOLOUR, m_strSurfaceMat, (float)1, renderRes);
	setviewprop(VF_SIZE, renderRes);
	setviewprop(VF_DRAWENGINESBAR, (float)0);
	setviewprop(VF_ORIGIN, [0,0,0]);
	setviewprop(VF_ANGLES, [0,0,0]);
	setviewprop(VF_AFOV, 90.0f);

    if (time & 1)
        draw.Rect([0,0], renderRes, [0.0,0.0,0.25], 1.0f, DRAWFLAG_NORMAL);
    else
        draw.Rect([0,0], renderRes, [0.0,0.0,0.0], 1.0f, DRAWFLAG_NORMAL);

	/* draw the source, otherwise the interface chain */
	if (m_mediaSourceEntityNum != 0 && m_mediaSource) {
		ncMediaSource mediaSource = (ncMediaSource)m_mediaSource;

		mediaSource._DrawInternal();

        vguiRootWindow rootWindow = (vguiRootWindow)mediaSource.m_UIChain;

        if (m_lastCursorPos != rootWindow.m_vecMousePos) {
            m_lastMouseInputTime = time;
        }

        if not (m_lastMouseInputTime + 5.0 < time) {
            draw.Pic(rootWindow.m_vecMousePos, "gfx/icon16/cursor", [16,16], [1,1,1], 1.0f, DRAWFLAG_NORMAL);
        }
        m_lastCursorPos = rootWindow.m_vecMousePos;

	} else if (m_uiRootWindow) {
		vguiWidget uiChain = (vguiWidget)m_uiRootWindow;
		uiChain.Draw();

        /* render cursor */
        if (m_bInFocus) {
            vguiRootWindow rootWindow = (vguiRootWindow)m_uiRootWindow;
            vguiScriptedView uiMenu = (vguiScriptedView)m_uiInteractive;

            if (STRING_SET(uiMenu.m_trGlobalCursor)) {
                draw.Pic(rootWindow.m_vecMousePos, uiMenu.m_trGlobalCursor, [16,16], [1,1,1], 1.0f, DRAWFLAG_NORMAL);
            }
        }
	}


	/* reset */
	setviewprop(VF_RT_DESTCOLOUR, "");
    m_lastRefresh = cltime;
}
#endif
