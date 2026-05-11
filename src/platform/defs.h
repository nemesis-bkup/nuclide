/*
 * Copyright (c) 2016-2024 Vera Visions LLC.
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

#include "Platform.h"
#include "Locale.h"
#include "AchievementManager.h"
#include "ActivityPubClient.h"
#include "ArchiveItemManager.h"
#include "CustomGameLibrary.h"
#include "ControlBindingsManager.h"
#include "RenderingManager.h"
#include "FingerClient.h"
#include "GopherClient.h"
#include "HTTPReceiver.h"
#include "MPDClient.h"
#include "MapLibrary.h"
#include "MatrixClient.h"
#include "MenuBackground.h"
#include "MenuDataFeed.h"
#include "MusicController.h"
#include "OnlineServices.h"
#include "PackageManager.h"
#include "PlatformCommands.h"
#include "ProfileManager.h"
#include "RichPresence.h"
#include "SaveGameLibrary.h"
#include "ServerErrorHandler.h"
#include "PlayerModelLibrary.h"
#include "GametypeLibrary.h"
#include "TCPHandler.h"
#include "WorldFinder.h"
#include "WorldSetup.h"

/** Definitions for FTE's internal package manager. We don't want you to talk to this one directly within Nuclide. */
typedef enum
{
    GPMI_NAME,          /**< name of the package, for use with the pkg command. */
    GPMI_CATEGORY,      /**< category text */
    GPMI_TITLE,         /**< name of the package, for showing the user. */
    GPMI_VERSION,       /**< version info (may have multiple with the same name but different versions) */
    GPMI_DESCRIPTION,   /**< some blurb */
    GPMI_LICENSE,       /**< what license its distributed under */
    GPMI_AUTHOR,        /**< name of the person(s) who created it */
    GPMI_WEBSITE,       /**< where to contribute/find out more info/etc */
    GPMI_INSTALLED,     /**< current state */
    GPMI_ACTION,        /**< desired state */
    GPMI_AVAILABLE,     /**< whether it may be downloaded or not. */
    GPMI_FILESIZE,      /**< size to download. */
} packageType_t;

.float movetype;
.float solid;;
.vector avelocity;
float clframetime;
.entity owner;

#include "../shared/system/ConstantManager.h"
#include "../shared/system/ConstantManager.qc"

int stoi(string inputString)
{
    return (int)stof(inputString);
}

#define MOVETYPE_FLY 0
#define SOLID_NOT 0

__variant(float prnum, string varname) externvalue = #203;

__variant
linkToMenuProgs(string funcName)
{
    static void empty(void)
    {
        print("Called unimplemented menu-side API call.\n");
    }

    void *func = externvalue(0, funcName);

    if (func) {
        return ((__variant)func);
    } else {
        return (empty);
    }
}


/** Draws a non-filled rectangle with a specified outline. */
void drawrect(vector pos, vector sz, float thickness, vector rgb, float al, optional float dfl)
{
    /* top */
    drawfill(pos, [sz[0], thickness], rgb, al, dfl);
    /* bottom */
    drawfill(pos + [0, sz[1] - thickness], [sz[0], thickness], rgb, al, dfl);
    /* left */
    drawfill(pos + [0, thickness], [thickness, sz[1] - (thickness * 2)], rgb, al, dfl);
    /* right */
    drawfill(pos + [sz[0] - thickness, thickness], [thickness, sz[1] - (thickness * 2)], rgb, al, dfl);
}

void
UIPF_draw_Rect(vector pos, vector size, vector rgb, float a)
{
    drawfill(pos, size, rgb, a);
}

void
UIPF_draw_RectOutline(vector pos, vector size, float thickness, vector rgb, float a)
{
    drawrect(pos, size, thickness, rgb, a);
}

void
UIPF_draw_RoundedRectOutline(vector pos, vector size, vector rgb, float a)
{
    float tileScale = 1.0f;

    if (size[1] < 32) {
        tileScale = size[1] / 32;
    }

    vector tileSize = g_vec_null;
    tileSize[0] = tileSize[1] =  (16 * tileScale);

    drawpic(pos, "gfx/ui/m_linetopleft.tga", [16,16], rgb, a, 0);
    drawpic(pos + [size[0] - 16, 0], "gfx/ui/m_linetopright.tga", [16,16], rgb, a, 0);
    drawpic(pos + [0, size[1] - 16], "gfx/ui/m_linebottomleft.tga", [16,16], rgb, a, 0);
    drawpic(pos + [size[0] - 16, size[1] - 16], "gfx/ui/m_linebottomright.tga", [16,16], rgb, a, 0);

    if (size_x > 32) {
        drawpic(pos + [16, 0], "gfx/ui/m_linetop.tga", [size[0] - 32, 16], rgb, a, 0);
        drawpic(pos + [16, size[1] - 16], "gfx/ui/m_linebottom.tga", [size[0] - 32, 16], rgb, a, 0);
    }

    if (size_y > 32) {
        drawpic(pos + [0, 16], "gfx/ui/m_lineleft.tga", [16, size[1] - 32], rgb, a, 0);
        drawpic(pos + [size[0] - 16, 16], "gfx/ui/m_lineright.tga", [16, size[1] - 32], rgb, a, 0);
        drawpic(pos + [16, 16], "gfx/ui/m_linemid.tga", [size[0] - 32, size[1] - 32], rgb, a, 0);
    }
}

void
UIPF_draw_RoundedBox(vector pos, vector size, vector rgb, float a)
{
    float tileScale = 1.0f;

    if (size[1] < 32) {
        tileScale = size[1] / 32;
    }

    vector tileSize = g_vec_null;
    tileSize[0] = tileSize[1] =  (16 * tileScale);

    drawpic(pos, "gfx/ui/m_topleft.tga", tileSize, rgb, a, 0);
    drawpic(pos + [size[0] - tileSize[0], 0], "gfx/ui/m_topright.tga", tileSize, rgb, a, 0);
    drawpic(pos + [0, size[1] - tileSize[1]], "gfx/ui/m_bottomleft.tga", tileSize, rgb, a, 0);
    drawpic(pos + [size[0] - tileSize[0], size[1] - tileSize[1]], "gfx/ui/m_bottomright.tga", tileSize, rgb, a, 0);

    if (size_x > 32) {
        drawpic(pos + [tileSize[0], 0], "gfx/ui/m_top.tga", [size[0] - (tileSize[0] * 2), tileSize[1]], rgb, a, 0);
        drawpic(pos + [tileSize[0], size[1] - tileSize[1]], "gfx/ui/m_bottom.tga", [size[0] - (tileSize[0] * 2), tileSize[1]], rgb, a, 0);
    }

    if (size_y > 32) {
        drawpic(pos + [0, tileSize[1]], "gfx/ui/m_left.tga", [tileSize[0], size[1] - (tileSize[0] * 2)], rgb, a, 0);
        drawpic(pos + [size[0] - tileSize[0], tileSize[1]], "gfx/ui/m_right.tga", [tileSize[0], size[1] - (tileSize[0] * 2)], rgb, a, 0);
        drawpic(pos + [tileSize[0], tileSize[1]], "gfx/ui/m_mid.tga", [size[0] - (tileSize[0] * 2), size[1] - (tileSize[0] * 2)], rgb, a, 0);
    }
}

void
UIPF_draw_Line(float thickness, vector pos1, vector pos2, vector rgb, float a)
{
    drawline(thickness, pos1, pos2, rgb, a);
}

void
UIPF_draw_Pic(vector pos, string material, vector size, vector rgb, float a, float imageFlags)
{
    drawpic(pos, material, size, rgb, a, imageFlags);
}

void
UIPF_draw_SubPic(vector pos, vector displaySize, string material, vector sourcePos, vector sourceSize, vector rgb, float a, float imageFlags)
{
    drawsubpic(pos, displaySize, material, sourcePos, sourceSize, rgb, a, imageFlags);
}


int
Util_CheckMouse(int x, int y, int sx, int sy)
{
    int mins[2];
    int maxs[2];

    x += g_menuofs[0];
    y += g_menuofs[1];

    mins[0] = x;
    mins[1] = y;
    maxs[0] = x + sx;
    maxs[1] = y + sy;

    if (g_vecMousePos[0] >= mins[0] && g_vecMousePos[0] <= maxs[0]) {
        if (g_vecMousePos[1] >= mins[1] && g_vecMousePos[1] <= maxs[1]) {
            return (1);
        }
    }

    return (0);
}

string
Util_CmdToKey(string cmd)
{
    float fBindKey = tokenize(findkeysforcommand(cmd));
    string sBindTx = "";
    float j, k;

    for(j = 0; j < fBindKey; ++j) {
        k = stof(argv(j));
        if(k != -1) {
            if(sBindTx != "") {
                sBindTx = strcat(sBindTx, ", ");
            }
            sBindTx = strcat(sBindTx, keynumtostring(k));
        }
    }

    return sBindTx;
}

