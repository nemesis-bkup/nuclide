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
    nonvirtual ncEntity NearestMediaEntity(float searchRadius);
    nonvirtual void SetSelectionURLItem(string itemName, string itemType, string groupName);
    nonvirtual void SetSelectionProfileItem(string itemName, profileItem_t itemType);

private:
    string m_itemName;
    string m_imagePath;
    bool m_isFlat;
    bool m_isIcon;
    string m_itemDataFormat;
    vector m_aspect;
    ncEntity m_mediaSelection;
    string m_itemDataGroup;
};

void
ncSelectionProxy::ncSelectionProxy(void)
{
    m_itemName = __NULL__;
    m_isFlat = false;
    m_imagePath = __NULL__;
}

void
ncSelectionProxy::ClearSelection(void)
{
    m_itemName = __NULL__;
}

void
ncSelectionProxy::SelectNearPointer(void)
{
    m_mediaSelection = NearestMediaEntity(128.0f);

    if (!m_mediaSelection) {
        EntError("Could not find anything to select at point %v", origin);
        return;
    }

    m_isIcon = true;
    m_imagePath = "gfx/icon16/transmit";
    precache_pic(m_imagePath);
    m_aspect[0] = 1.0f;
    m_aspect[1] = 1.0f;
}

float
ncSelectionProxy::predraw(void)
{
	bool drawEntity = true;

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

	if (m_isIcon) {
        vector fsize = [4 * m_aspect[0],4 * m_aspect[1]];
        vector vertexLight = [1,1,1];
        vector newAngle = vectoangles(g_view.GetCameraOrigin() - GetOrigin());
        vector rightVector = anglesToRight(newAngle);
        vector upVector = anglesToUp(newAngle);
        vector newOrg = GetOrigin() + (anglesToForward(newAngle) * 16);

        newAngle = vectoangles(g_view.GetCameraOrigin() - newOrg);
        rightVector = anglesToRight(newAngle);
        upVector = anglesToUp(newAngle);

        R_BeginPolygon(m_imagePath, 0, 0);
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
	} else if (m_isFlat) {
        vector fsize = GetSize() / 2;
        vector vertexLight = getlight(GetOrigin()) * (1/255);
        vector rightVector = anglesToRight(GetAngles());
        vector upVector = anglesToUp(GetAngles());

        drawcone(WorldSpaceCenter(), GetAngles(), 16, 48, 15, [1,1,1], 0.25f);
        R_BeginPolygon(m_imagePath, 0, 0);
        R_PolygonVertex(origin - rightVector * fsize[0] - upVector * fsize[1],
            [1,1], vertexLight, 1.0f);
        R_PolygonVertex(origin + rightVector * fsize[0] - upVector * fsize[1],
            [0,1], vertexLight, 1.0f);
        R_PolygonVertex(origin + rightVector * fsize[0] + upVector * fsize[1],
            [0,0], vertexLight, 1.0f);
        R_PolygonVertex(origin - rightVector * fsize[0] + upVector * fsize[1],
            [1,0], vertexLight, 1.0f);
        R_EndPolygon();
        return (PREDRAW_NEXT);
	}

    drawcone(WorldSpaceCenter(), GetAngles(), 16, 48, 15, [1,1,1], 0.25f);
	addentity(this);

	return (PREDRAW_NEXT);
}

void
ncSelectionProxy::MoveToMouseCoordinates(vector mousePos)
{
	g_view.SetupView();
	vector traceStart = unproject([mousePos[0], mousePos[1], 0]);
	vector traceEnd = unproject([mousePos[0], mousePos[1], 1024]);
	other = world;
	traceline(traceStart, traceEnd, MOVE_OTHERONLY, g_view.m_viewTarget);
	SetOrigin(trace_endpos - [0,0,mins[2]]);
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
    vector newAngle = vectoangles(g_view.GetCameraOrigin() - GetOrigin());
    vector newOrg = GetOrigin() + (anglesToForward(newAngle) * 16);

	if (m_mediaSelection) {
        closestSurface = NearestMediaEntity(1024);

        if (closestSurface) {
            trailparticles(particleeffectnum("test.zap"), this, newOrg, closestSurface.WorldSpaceCenter());
            localcmd(sprintf("cmd input %d SetSourceID %d\n", closestSurface.entnum, m_mediaSelection.entnum));
            m_mediaSelection = __NULL__;
        }
        return;
	}

	if (!STRING_SET(m_itemName)) {
		return (PREDRAW_NEXT);
	}

    if (m_itemDataFormat == "video") {
        closestSurface = NearestMediaEntity(1024);

        if (closestSurface) {
            trailparticles(particleeffectnum("test.zap"), this, newOrg, closestSurface.WorldSpaceCenter());

            if (STRING_SET(m_itemDataGroup)) {
                localcmd(sprintf("cmd input %d openurl \"video_%s %s\"\n", closestSurface.entnum, m_itemDataGroup, m_itemName));
            } else {
                localcmd(sprintf("cmd input %d openurl \"video %s\"\n", closestSurface.entnum, m_itemName));
            }

            m_itemName = __NULL__;
        }
        return;
    }

    if (m_itemDataFormat == "audio") {
        closestSurface = NearestMediaEntity(1024);

        if (closestSurface) {
            trailparticles(particleeffectnum("test.zap"), this, newOrg, closestSurface.WorldSpaceCenter());
            localcmd(sprintf("cmd input %d openurl \"audio %s\"\n", closestSurface.entnum, m_itemName));
            m_itemName = __NULL__;
        }
        return;
    }

    if (m_itemDataFormat == "app") {
        closestSurface = NearestMediaEntity(1024);

        if (closestSurface) {
            trailparticles(particleeffectnum("test.zap"), this, newOrg, closestSurface.WorldSpaceCenter());

            if (STRING_SET(m_itemDataGroup)) {
                localcmd(sprintf("cmd input %d openurl \"app_%s %s\"\n", closestSurface.entnum, m_itemDataGroup, m_itemName));
            } else {
                localcmd(sprintf("cmd input %d openurl \"app %s\"\n", closestSurface.entnum, m_itemName));
            }

            m_itemName = __NULL__;
        }
        return;
    }

    if (m_itemDataFormat == "picture") {
        closestSurface = NearestMediaEntity(1024);

        if (closestSurface) {
            trailparticles(particleeffectnum("test.zap"), this, newOrg, closestSurface.WorldSpaceCenter());
            localcmd(sprintf("cmd input %d openurl \"picture %s\"\n", closestSurface.entnum, m_itemName));
            m_itemName = __NULL__;
        }
        return;
    }


    if (m_itemDataFormat == "object") {
        localcmd(sprintf("objectSpawn %S \"%v\" \"%v\"\n", m_itemName, origin, angles));
        m_itemName = __NULL__;
        return;
    }

    if (m_itemDataFormat == "entityDef") {
        localcmd(sprintf("cmd shareEntity %S %S \"%v\" \"%v\"\n", m_itemName, model, origin, angles));
        m_itemName = __NULL__;
        return;
	}
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


	SetModel(entModel);
	SetSize(stov(entMins), stov(entMaxs));
	m_itemName = entityClass;
    m_isFlat = false;
    m_itemDataGroup = "";
	m_itemDataFormat = "entityDef";
}

void
ncSelectionProxy::SetSelectionProfileItem(string itemName, profileItem_t itemType)
{
    ncDict itemDict = ncUserInventory::GetItemDict(itemName, itemType);

    if (!itemDict) {
        ncError("Invalid item %S for type %d", itemName, itemType);
        return;
    }


	m_itemName = itemName;
	m_itemDataFormat = g_profileItems[itemType];
    m_aspect[0] = 1.0f;
    m_aspect[1] = 1.0f;

	string entModel = itemDict.GetString("model");
	string entColor = itemDict.GetString("color");

	if (!STRING_SET(entModel)) {
        m_isFlat = true;
        m_imagePath = itemDict.GetString("preview");
        precache_pic(m_imagePath);

        vector imageAspect = itemDict.GetVector("resolution");

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
        vector realSize = [standardLength * imageAspect[0], standardLength * imageAspect[1]];

        /* to game units */
        realSize[0] *= (1/2.54);
        realSize[1] *= (1/2.54);

        SetScale(1.0f);
        SetSize(realSize * -0.5, realSize * 0.5);
    } else {
        m_isFlat = false;
        SetModel(entModel);
        string entMins = itemDict.GetString("mins");
        string entMaxs = itemDict.GetString("maxs");
        string entScale = itemDict.GetString("scale");
        float entSkin = itemDict.GetFloat("skin");
        SetScale(stof(entScale));
        SetSize(stov(entMins), stov(entMaxs));
        SetSkin(entSkin);
    }

    if (m_itemDataFormat == "video") {
        m_isIcon = true;
        m_imagePath = "gfx/icon16/film";
    } else if (m_itemDataFormat == "app") {
        m_isIcon = true;
        m_imagePath = itemDict.GetString("preview");

        if (!STRING_SET(m_imagePath)) {
            m_imagePath = "gfx/icon16/application_view_gallery";
            SetSize([-4,-4,-4], [-4,-4,-4]);
        } else {
            precache_pic(m_imagePath);
            vector imageAspect = drawgetimagesize(m_imagePath);

            /* 2d normalize */
            if (imageAspect[0] > imageAspect[1]) {
                m_aspect[1] = imageAspect[1] / imageAspect[0];
                m_aspect[0] = 1.0f;
            } else if (imageAspect[0] < imageAspect[1]) {
                m_aspect[0] = imageAspect[0] / imageAspect[1];
                m_aspect[1] = 1.0f;
            } else {
                m_aspect[0] = 1.0f;
                m_aspect[1] = 1.0f;
            }
        }
    } else if (m_itemDataFormat == "audio") {
        m_isIcon = true;
        m_imagePath = "gfx/icon16/music";
    } else {
        m_isIcon = false;
    }
}

void
ncSelectionProxy::SetSelectionURLItem(string itemName, string itemType, string groupName)
{
	m_itemName = itemName;
	m_itemDataFormat = itemType;
    m_itemDataGroup = groupName;
    m_isIcon = true;

    m_aspect[0] = 1.0f;
    m_aspect[1] = 1.0f;

    switch (m_itemDataFormat) {
    case "web":
        m_imagePath = "gfx/icon16/html";
        break;
    case "text":
        m_imagePath = "gfx/icon16/page";
        break;
    case "video":
        m_imagePath = "gfx/icon16/film";
        break;
    case "audio":
        m_imagePath = "gfx/icon16/music";
        break;
    case "app":
        m_imagePath = "gfx/icon16/application_view_gallery";
        break;
    case "picture":
        m_imagePath = "gfx/icon16/picture";
        break;
    }
}
