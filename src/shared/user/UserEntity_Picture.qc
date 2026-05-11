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
ncUserEntity_Picture::ncUserEntity_Picture(void)
{
}

#ifdef SERVER
void
ncUserEntity_Picture::Save(float handle)
{
    SaveVector(handle, "origin", origin);
    SaveVector(handle, "angles", angles);
    SaveVector(handle, "size", size);
    SaveString(handle, "m_userPictureURL", m_userPictureURL);
    SaveString(handle, "m_userPosterName", m_userPosterName);
    SaveFloat(handle, "m_flScale", m_flScale);
    SaveFloat(handle, "m_flUseDistance", m_flUseDistance);
    SaveVector(handle, "m_vecUIRes", m_vecUIRes);
    SaveVector(handle, "m_vecScreenLight", m_vecScreenLight);
    SaveBool(handle, "m_uiSurfaceEnabled", m_uiSurfaceEnabled);
}

void
ncUserEntity_Picture::Restore(string keyName, string setValue)
{
    switch (keyName) {
    case "origin":
        origin = ReadVector(setValue);
        setorigin(this, origin);
        break;
    case "angles":
        angles = ReadVector(setValue);
        break;
    case "size":
        size = ReadVector(setValue);
        break;
    case "m_userPictureURL":
        m_userPictureURL = ReadString(setValue);
        break;
    case "m_userPosterName":
        m_userPosterName = ReadString(setValue);
        break;
    case "m_flScale":
        m_flScale = ReadFloat(setValue);
        break;
    case "m_flUseDistance":
        m_flUseDistance = ReadFloat(setValue);
        break;
    case "m_vecUIRes":
        m_vecUIRes = ReadVector(setValue);
        break;
    case "m_vecScreenLight":
        m_vecScreenLight = ReadVector(setValue);
        break;
    case "m_uiSurfaceEnabled":
        m_uiSurfaceEnabled = ReadBool(setValue);
        break;
    }
}


void
ncUserEntity_Picture::EvaluateEntity(void)
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
ncUserEntity_Picture::SendEntity(entity ePEnt, float flChanged)
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
ncUserEntity_Picture::ReloadVideoResources(void)
{
    super::ReloadVideoResources();
    precache_pic(m_userPictureURL);
}

float
ncUserEntity_Picture::predraw(void)
{
    if (m_bInFocus) {
        super::predraw();
        return;
    }

    classname = "ncMediaSurface";
    vector fsize = size / 2;
    vector vertexLight = getlight(origin) * (1/255);

    if (m_bCached == false)
        return (PREDRAW_NEXT);

    makevectors(angles);
    R_BeginPolygon(m_userPictureURL, 0, 0);
    R_PolygonVertex(origin - v_right * fsize[0] - v_up * fsize[1],
        [1,1], vertexLight, 1.0f);
    R_PolygonVertex(origin + v_right * fsize[0] - v_up * fsize[1],
        [0,1], vertexLight, 1.0f);
    R_PolygonVertex(origin + v_right * fsize[0] + v_up * fsize[1],
        [0,0], vertexLight, 1.0f);
    R_PolygonVertex(origin - v_right * fsize[0] + v_up * fsize[1],
        [1,0], vertexLight, 1.0f);
    R_EndPolygon();
    return (PREDRAW_NEXT);
}

/* called whenever we are in the proximity of a surface */
void
ncUserEntity_Picture::RenderScene(void)
{
    if (m_bInFocus == false)
        return;
    if (m_bCached == false)
        return;

    clearscene();

    setviewprop(VF_RT_DESTCOLOUR, m_strSurfaceMat, (float)1, m_vecUIRes);
    setviewprop(VF_SIZE, m_vecUIRes);
    setviewprop(VF_DRAWENGINESBAR, (float)0);
    setviewprop(VF_ORIGIN, [0,0,0]);
    setviewprop(VF_ANGLES, [0,0,0]);
    setviewprop(VF_AFOV, 90.0f);

    /* draw the chain */
    if (m_uiRootWindow) {
        vguiWidget uiChain = (vguiWidget)m_uiRootWindow;
        uiChain.Draw();
    }

    /* render cursor */
    if (m_bInFocus)
        drawpic(m_vecCursorPos, "gfx/icon16/cursor", [16,16], [1,1,1], 1.0f);

    /* reset */
    setviewprop(VF_RT_DESTCOLOUR, "");
}

void
ncUserEntity_Picture::VideoSave_Clicked(vguiWidget sender)
{
    localcmd(sprintf("saveImage %S %S %S %S %S\n", m_userPosterName, m_userPosterTitle, m_userPictureURL, m_userPictureURL, ""));
}

void
ncUserEntity_Picture::ReceiveEntity(float flNew, float flChanged)
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

    if (flNew) {
        vguiWidget uiChain = (vguiWidget)m_uiRootWindow;

        m_vecWorldSize = m_vecUIRes * m_flScale;
        ReloadVideoResources();

        /* initialize UI panel here */
        m_uiRootWindow = spawn(vguiRootWindow);
        vguiWidget uiChain = (vguiWidget)m_uiRootWindow;
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
        if (m_uiPic) {
            vguiPic ourVideo = (vguiPic)m_uiPic;
            ourVideo.SetImage(m_userPictureURL);
        }
    }
}
#endif

#ifdef SERVER
void
ncUserEntity_Picture::PlaceAtPositionWithSize(ncPlayer pictureSharer, string pictureName, string pictureURL, vector worldPos, vector eulerAngle, vector realSize)
{
    ncUserEntity_Picture userPicture;
    userPicture = spawn(ncUserEntity_Picture);
    userPicture.Spawn();
    userPicture.real_owner = pictureSharer;
    userPicture.m_userPictureURL = pictureURL;
    userPicture.SetAngles(eulerAngle);
    userPicture.SendFlags = 1;
    userPicture.m_vecUIRes = realSize * (1/0.25);
    userPicture.size = realSize;
    userPicture.m_flScale = 0.25f;
    userPicture.m_userPosterName = pictureName;

    if (userPicture.m_flScale < 0) {
        userPicture.m_flScale = 0.25f;
    }

    userPicture.SetOrigin(worldPos);

    printf("N: %S; URL: %S @ %v; ang: %v; size: %v\n", pictureName, pictureURL, worldPos, eulerAngle, realSize);
}

void
ncUserEntity_Picture::Place(ncPlayer pictureSharer, string pictureName, string pictureURL, vector realSize, string pictureTitle)
{
    ncUserEntity_Picture userPicture;
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
    /*if (ncUserEntityManager::NumUserObjectsForClient(pictureSharer, "ncUserEntity_Picture") >= 1) {
        return;
    }*/

    /* we only allow one active userPicture */
    //Spray_RemoveAll(pictureSharer);

    /* spawn the new one */
    userPicture = spawn(ncUserEntity_Picture);
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
    userPicture.m_userPosterTitle = pictureTitle;

    if (userPicture.m_flScale < 0) {
        userPicture.m_flScale = 0.25f;
    }

    setorigin(userPicture, endPos + (forwardDir * -(userPicture.m_flScale * 5)));
}
#endif
