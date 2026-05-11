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


class
ncSelectionProxy:ncRenderableEntity
{
    virtual float predraw(void);
    nonvirtual void MoveToMouseCoordinates(vector mousePos);
    nonvirtual void ClearSelection(void);
    nonvirtual void SelectNearPointer(void);
    nonvirtual void SetHeightOffset(float);
    nonvirtual void SetBrushSize(vector,vector);
    nonvirtual void SetSpawnMode(selectionSpawnMode_t);
    nonvirtual void SetDict(ncDict targetDict);
    nonvirtual ncEntity NearestMediaEntity(float searchRadius);
    nonvirtual void SetSelectionURLItem(string itemName, string itemType, string groupName);
    nonvirtual void SetSelectionProfileItem(string itemName, profileItem_t itemType);
    nonvirtual void SetSelectionDict(ncDict targetDict, string iconPath, selectionSpawnMode_t spawnMode);

private:
    string m_itemName;
    string m_imagePath;
    string m_itemDataFormat;
    vector m_aspect;
    ncEntity m_mediaSelection;
    string m_itemDataGroup;
    float m_heightOffset;
    selectionSpawnMode_t m_spawnMode;
    ncDict m_targetDict;
    vector m_previewSize;
    string m_iconPath;
    vector m_brushMins;
    vector m_brushMaxs;
    string m_brushMaterial;
};

void
ncSelectionProxy::ncSelectionProxy(void)
{
    m_itemName = __NULL__;
    m_imagePath = __NULL__;
    m_iconPath = __NULL__;
    m_brushMins = [-30,-30,-30];
    m_brushMaxs = [30,30,30];
    m_brushMaterial = "detail_pbr/default";
}

void
ncSelectionProxy::ClearSelection(void)
{
    m_itemName = __NULL__;
}

void
ncSelectionProxy::SetSpawnMode(selectionSpawnMode_t spawnMode)
{
    m_spawnMode = spawnMode;
}

void
ncSelectionProxy::SetDict(ncDict spawnMode)
{
    m_targetDict = spawnMode;
}

void
ncSelectionProxy::SetHeightOffset(float heightOffset)
{
    m_heightOffset = heightOffset;
}

void
ncSelectionProxy::SetBrushSize(vector newMins, vector newMaxs)
{
    m_brushMins = newMins;
    m_brushMaxs = newMaxs;
}

void
ncSelectionProxy::SelectNearPointer(void)
{
    m_mediaSelection = NearestMediaEntity(128.0f);

    if (!m_mediaSelection) {
        EntError("Could not find anything to select at point %v", origin);
        return;
    }

    m_iconPath = "gfx/icon16/transmit";
    precache_pic(m_iconPath);
    m_aspect[0] = 1.0f;
    m_aspect[1] = 1.0f;
}

float
ncSelectionProxy::predraw(void)
{
    bool drawEntity = true;
    vector fakeOrigin = GetOrigin() + [0, 0, m_heightOffset];

    /* only show it when in editor mode... */
    if (pSeat->m_ePlayer.movetype != MOVETYPE_NOCLIP) {
        //drawEntity = false;
    }
    if (pSeat->m_showInterface == false) {
        drawEntity = false;
    }

    if (!m_mediaSelection)
    if (!drawEntity || !STRING_SET(m_itemName)) {
        return (PREDRAW_NEXT);
    }

    if (m_mediaSelection || m_spawnMode == INPUT_DATA) {
        vector fsize = [4 * m_aspect[0],4 * m_aspect[1]];
        vector vertexLight = [1,1,1];
        vector newAngle = vectoangles(g_view.GetCameraOrigin() - fakeOrigin);
        vector rightVector = anglesToRight(newAngle);
        vector upVector = anglesToUp(newAngle);
        vector newOrg = fakeOrigin + (anglesToForward(newAngle) * 16);

        newAngle = vectoangles(g_view.GetCameraOrigin() - newOrg);
        rightVector = anglesToRight(newAngle);
        upVector = anglesToUp(newAngle);

        R_BeginPolygon(m_iconPath, 0, 0);
        R_PolygonVertex(newOrg - rightVector * fsize[0] - upVector * fsize[1],
            [1,1], vertexLight, 1.0f);
        R_PolygonVertex(newOrg + rightVector * fsize[0] - upVector * fsize[1],
            [0,1], vertexLight, 1.0f);
        R_PolygonVertex(newOrg + rightVector * fsize[0] + upVector * fsize[1],
            [0,0], vertexLight, 1.0f);
        R_PolygonVertex(newOrg - rightVector * fsize[0] + upVector * fsize[1],
            [1,0], vertexLight, 1.0f);
        R_EndPolygon();
        return (PREDRAW_NEXT);
    } else if (STRING_SET(m_imagePath)) {
        vector fsize = m_previewSize / 2;
        vector vertexLight = getlight(fakeOrigin) * (1/255);
        vector rightVector = anglesToRight(GetAngles());
        vector upVector = anglesToUp(GetAngles());

        drawcone(WorldSpaceCenter(), GetAngles(), 16, 48, 15, [1,1,1], 0.25f);
        R_BeginPolygon(m_imagePath, 0, 0);
        R_PolygonVertex(fakeOrigin - rightVector * fsize[0] - upVector * fsize[1],
            [1,1], vertexLight, 1.0f);
        R_PolygonVertex(fakeOrigin + rightVector * fsize[0] - upVector * fsize[1],
            [0,1], vertexLight, 1.0f);
        R_PolygonVertex(fakeOrigin + rightVector * fsize[0] + upVector * fsize[1],
            [0,0], vertexLight, 1.0f);
        R_PolygonVertex(fakeOrigin - rightVector * fsize[0] + upVector * fsize[1],
            [1,0], vertexLight, 1.0f);
        R_EndPolygon();
        return (PREDRAW_NEXT);
    }

    if (m_itemDataFormat == "createbrush") {
        DebugBox(fakeOrigin, m_brushMins, m_brushMaxs, [1.0,0.5,0.5], 0.5f);
        return (PREDRAW_NEXT);
    }

    if (m_itemDataFormat == "carvebrush") {
        DebugBox(fakeOrigin, m_brushMins, m_brushMaxs, [1.0,0.5,0.5], 0.5f);
        return (PREDRAW_NEXT);
    }

    drawcone(WorldSpaceCenter(), GetAngles(), 16, 48, 15, [1,1,1], 0.25f);

    vector oldOrigin = origin;
    origin = fakeOrigin;
    addentity(this);
    origin = oldOrigin;
    return (PREDRAW_NEXT);
}

vector snapVector(vector aVal, float aInterval, float aOffset)
{
    vector output;
    output[0] = rint((aVal[0] - aOffset)/aInterval) * aInterval + aOffset;
    output[1] = rint((aVal[1] - aOffset)/aInterval) * aInterval + aOffset;
    output[2] = rint((aVal[2] - aOffset)/aInterval) * aInterval + aOffset;
    return (output);
}

void
ncSelectionProxy::MoveToMouseCoordinates(vector mousePos)
{
    g_view.SetupView();
    makevectors(g_view.GetCameraAngle());
    vector traceStart = unproject([mousePos[0], mousePos[1], 0]);
    vector traceEnd = unproject([mousePos[0], mousePos[1], 1024]);
    other = world;
    traceline(traceStart, traceEnd, MOVE_OTHERONLY, g_view.m_viewTarget);

    trace_endpos = snapVector(trace_endpos, autocvar(snap_interval, 1), autocvar(snap_offset, 0));

    if (m_itemName == "brush") {
        SetOrigin(trace_endpos);
    } else {
        SetOrigin(trace_endpos - [0,0,mins[2]]);
    }
}

ncEntity
ncSelectionProxy::NearestMediaEntity(float searchRadius)
{
    float bestSourceDist = searchRadius;
    float bestSurfaceDist = searchRadius;
    ncMediaSurface bestSurface = 0;
    ncMediaSurface bestSource = 0;
    float dist;

    for (ncMediaSurface mediaSurf = 0; (mediaSurf = find(mediaSurf, ::classname, "ncMediaSurface"));) {
        dist = distance(mediaSurf.origin, origin);

        if (dist < bestSurfaceDist) {
            bestSurfaceDist = dist;
            bestSurface = mediaSurf;
        }
    }

    for (ncMediaSource mediaSource = 0; (mediaSource = find(mediaSource, ::classname, "ncMediaSource"));) {
        dist = distance(mediaSource.origin, origin);

        if (dist < bestSourceDist) {
            bestSourceDist = dist;
            bestSource = mediaSource;
        }
    }

    if (bestSource && bestSurface) {
        if (bestSourceDist < bestSurfaceDist) {
            return bestSource;
        } else {
            return bestSurface;
        }
    }

    if (bestSource)
        return bestSource;

    if (bestSurface)
        return bestSurface;

    return __NULL__;
}

void
ncSelectionProxy::SpawnSelection(void)
{
    ncEntity closestSurface = 0;
    vector fakeOrigin = GetOrigin() + [0, 0, m_heightOffset];
    vector newAngle = vectoangles(g_view.GetCameraOrigin() - fakeOrigin);
    vector newOrg = fakeOrigin + (anglesToForward(newAngle) * 16);

    if (m_mediaSelection) {
        closestSurface = NearestMediaEntity(1024);

        if (closestSurface) {
            trailparticles(particleeffectnum("test.zap"), this, newOrg, closestSurface.WorldSpaceCenter());
            ncCommand("cmd input %d setsourceid %d", closestSurface.entnum, m_mediaSelection.entnum);
            m_mediaSelection = __NULL__;
        }
        return;
    }

    if (m_itemDataFormat == "createbrush") {
        vector fakeMins = fakeOrigin + m_brushMins;
        vector fakeMaxs = fakeOrigin + m_brushMaxs;
        ncCommand("cmd createBrush \"%v\" \"%v\" %S", fakeMins, fakeMaxs, m_brushMaterial);
        m_itemName = __NULL__;
        return;
    }

    if (m_itemDataFormat == "carvebrush") {
        vector fakeMins = fakeOrigin + m_brushMins;
        vector fakeMaxs = fakeOrigin + m_brushMaxs;
        ncCommand("cmd carveBrush \"%v\" \"%v\" %S", fakeMins, fakeMaxs, m_brushMaterial);
        m_itemName = __NULL__;
        return;
    }

    if (m_spawnMode == INPUT_DATA) {
        closestSurface = NearestMediaEntity(1024);
        trailparticles(particleeffectnum("test.zap"), this, newOrg, closestSurface.WorldSpaceCenter());

        if (m_targetDict) {
            m_targetDict.TransmitToEntity(closestSurface.entnum);
        } else {
            m_targetDict = spawn(ncDict);
            m_targetDict.m_dictType = m_itemDataFormat;
            m_targetDict.AddKey(m_itemDataFormat, m_itemName);
            m_targetDict.TransmitToEntity(closestSurface.entnum);
            remove(m_targetDict);
        }

        m_itemName = __NULL__;
        m_targetDict = __NULL__;
        return;
    }

    if (m_itemDataFormat == "object") {
        ncCommand("objectSpawn %S \"%v\" \"%v\"", m_itemName, fakeOrigin, GetAngles());
        m_itemName = __NULL__;
        return;
    }
    if (STRING_SET(m_imagePath)) {
        ncCommand("cmd spawnPicture %S %S \"%v\" \"%v\" \"%v\"", m_itemName, m_imagePath, fakeOrigin, GetAngles(), m_previewSize);
        m_itemName = __NULL__;
        return;
    }


    if (m_itemDataFormat == "entityDef") {
        ncCommand("cmd shareEntity %S %S \"%v\" \"%v\"", m_itemName, GetModel(), fakeOrigin, GetAngles());
        m_itemName = __NULL__;
    } else {
        if (m_spawnMode == SPAWN_OBJECT) {

        } else if (m_spawnMode == INPUT_DATA) {

        }
    }
}

void
ncSelectionProxy::SetSelectionBrush(string brushTexture, bool willCarve)
{
    SetSpawnMode(SPAWN_OBJECT);
    SetModel("models/prims/cube.glb");
    m_itemName = "brush";
    m_itemDataGroup = "";
    m_itemDataFormat = willCarve ? "carvebrush" : "createbrush";
    m_brushMaterial = brushTexture;
}

void
ncSelectionProxy::SetSelectionEntity(string entityClass)
{
    string entModel = EntityDef_GetKeyValue(entityClass, "editor_model");
    string entColor = EntityDef_GetKeyValue(entityClass, "editor_color");
    string entMins = EntityDef_GetKeyValue(entityClass, "editor_mins");
    string entMaxs = EntityDef_GetKeyValue(entityClass, "editor_maxs");

    /* various fallbacks */
    if (!STRING_SET(entModel)) {
        entModel = EntityDef_GetKeyValue(entityClass, "model");
    }

    if (!STRING_SET(entMins)) {
        entMins = EntityDef_GetKeyValue(entityClass, "mins");
    }

    if (!STRING_SET(entMaxs)) {
        entMaxs = EntityDef_GetKeyValue(entityClass, "maxs");
    }

    SetSpawnMode(SPAWN_OBJECT);
    SetModel(entModel);
    SetSize(stov(entMins), stov(entMaxs));
    m_itemName = entityClass;
    m_itemDataGroup = "";
    m_itemDataFormat = "entityDef";
}

void
ncSelectionProxy::SetSelectionDict(ncDict targetDict, string iconPath, selectionSpawnMode_t spawnMode)
{
    m_itemName = targetDict.Name();
    m_targetDict = targetDict;
    m_aspect[0] = 1.0f;
    m_aspect[1] = 1.0f;
    m_itemDataFormat = m_targetDict.Type();

    /* to avoid truncation crash */
    m_imagePath = substring(m_targetDict.GetString("picture"), 0, 122);

    switch (m_itemDataFormat) {
        case "object":
            m_iconPath = "gfx/icon16/brick";
            break;
        case "web":
            m_iconPath = "gfx/icon16/html";
            break;
        case "text":
            m_iconPath = "gfx/icon16/page";
            break;
        case "video":
            m_iconPath = "gfx/icon16/film";
            break;
        case "audio":
            m_iconPath = "gfx/icon16/music";
            break;
        case "app":
            m_iconPath = "gfx/icon16/application_view_gallery";
            break;
        case "picture":
            m_iconPath = "gfx/icon16/picture";
            break;
    }

    string modelPath = m_targetDict.GetString("model");

    if (STRING_SET(modelPath)) {
        SetModel(m_targetDict.GetString("model"));
        string entScale = m_targetDict.GetString("scale");

        if (STRING_SET(entScale)) {
            SetScale(stof(entScale));
        } else {
            SetScale(1.0);
        }
    } else {
        SetScale(1.0);
        model = "";
        modelindex = 0;
    }

    if (STRING_SET(model)) {
        float entSkin = m_targetDict.GetFloat("skin");
        SetSkin(entSkin);
        string entMins = m_targetDict.GetString("mins");
        string entMaxs = m_targetDict.GetString("maxs");

        if (STRING_SET(entMins) && STRING_SET(entMaxs)) {
            SetSize(stov(entMins), stov(entMaxs));
        }
        printf("Definitely a model\n");
    }

    if (STRING_SET(m_imagePath)) {
        precache_pic(m_imagePath);
        vector imageAspect = drawgetimagesize(m_imagePath);

        /* 2d normalize */
        if (imageAspect[0] > imageAspect[1]) {
            imageAspect[1] = imageAspect[1] / imageAspect[0];
         imageAspect[0] = 1.0f;
        } else if (imageAspect[0] < imageAspect[1]) {
            imageAspect[0] = imageAspect[0] / imageAspect[1];
            imageAspect[1] = 1.0f;
        } else {
            imageAspect[0] = 1.0f;
            imageAspect[1] = 1.0f;
        }

        float standardLength = 118.9f;

        /* length * aspect = decent approximation for our image turned poster */
        m_previewSize = [standardLength * imageAspect[0], standardLength * imageAspect[1]];

        /* to game units */
        m_previewSize[0] *= (1/2.54);
        m_previewSize[1] *= (1/2.54);
        printf("Definitely an image\n");
    }
}

void
ncSelectionProxy::SetSelectionProfileItem(string itemName, profileItem_t itemType)
{
    ncDict itemDict = ncUserInventory::GetItemDict(itemName, itemType);

    if (!itemDict) {
        ncError("Invalid item %S for type %d", itemName, itemType);
        return;
    }

    m_itemDataFormat = itemDict.Type();

    SetSelectionDict(itemDict, m_imagePath, m_spawnMode);
}

void
ncSelectionProxy::SetSelectionURLItem(string itemName, string itemType, string groupName)
{
    m_itemName = itemName;
    m_itemDataFormat = itemType;
    m_itemDataGroup = groupName;
    SetSpawnMode(INPUT_DATA);
    m_targetDict = __NULL__;

    m_aspect[0] = 1.0f;
    m_aspect[1] = 1.0f;

}
