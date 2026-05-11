/*
 * Copyright (c) 2016-2025 Vera Visions LLC.
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

vguiRootWindow g_uiDesktop;
vguiRootWindow g_uiInterface;

void
VGUI_Init(void)
{
    UISystem_Init();
    g_uiDesktop = spawn(vguiRootWindow);
    g_uiDesktop.FlagAdd(1);
}

void
UI_DesktopInit(void)
{
    if (serverinfo.GetString("mode") == "editor") {
        g_uiInterface = spawn(vguiDesktop_Editor);
    } else if (serverinfo.GetString("mode") == "home") {
        g_uiInterface = spawn(vguiDesktop_Home);
    } else {
        g_uiInterface = spawn(vguiDesktop);
    }
}

int
VGUI_Draw(void)
{
    if (pSeat->m_showInterface) {
        if (!g_uiInterface) {
            UI_DesktopInit();
        }
        g_uiInterface.Draw();
    } else {
        g_uiDesktop.Draw();
    }

    return (1);
}

bool
VGUI_Input(float flEvType, float flScanX, float flCharY, float flDevID)
{
    bool returnValue = false;

    if (pSeat->m_showInterface) {
        if (!g_uiInterface) {
            UI_DesktopInit();
        }

        returnValue = g_uiInterface.Input(flEvType, flScanX, flCharY, flDevID);
    } else {
        returnValue = g_uiDesktop.Input(flEvType, flScanX, flCharY, flDevID);
    }

    if (returnValue == true) {
        pSeat->m_flInputBlockTime = time + 0.1;
        return (true);
    }

    return (false);
}

void
VGUI_Reposition(void)
{
    if (g_uiDesktop) {
        g_uiDesktop.Reposition();
    }

    if (g_uiInterface) {
        g_uiInterface.Reposition();
    }
}

bool
VGUI_MouseActive(void)
{
    if (g_uiInterface) {
        if (pSeat->m_showInterface) {
            pSeat->m_flInputBlockTime = time + 0.1;
            return (true);
        }
    }

    if (g_uiDesktop) {
        if (g_uiDesktop.m_activeWidgetCount > 0i) {
            pSeat->m_flInputBlockTime = time + 0.1;
            return (true);
        }
    }

    return (false);
}

void
Editor_SetSelectionEntity(string entityClass)
{
    vguiDesktop_Editor editorIF = (vguiDesktop_Editor)g_uiInterface;
    thread(editorIF.SetSelectionEntity(entityClass));
}

void
Editor_SetSelectionProfileItem(string itemName, profileItem_t itemType)
{
    vguiDesktop_Editor editorIF = (vguiDesktop_Editor)g_uiInterface;
    editorIF.SetSelectionProfileItem(itemName, itemType);
}

void
Editor_SetSelectionURLItem(string itemURL, string itemType, string groupName)
{
    vguiDesktop_Editor editorIF = (vguiDesktop_Editor)g_uiInterface;
    editorIF.SetSelectionURLItem(itemURL, itemType, groupName);
}

void
Editor_SetSpawnMode(selectionSpawnMode_t spawnMode)
{
    vguiDesktop_Editor editorIF = (vguiDesktop_Editor)g_uiInterface;
    editorIF.SetSpawnMode(spawnMode);
}

void
Editor_SetSelectionBrush(string textureName, bool willCarve)
{
    vguiDesktop_Editor editorIF = (vguiDesktop_Editor)g_uiInterface;
    editorIF.SetSelectionBrush(textureName, willCarve);
}

void
Editor_SpawnSelection(void)
{

    vguiDesktop_Editor editorIF = (vguiDesktop_Editor)g_uiInterface;
    thread(editorIF.SpawnSelection());
}

void
Editor_SetHeightOffset(float heightOffset)
{
    vguiDesktop_Editor editorIF = (vguiDesktop_Editor)g_uiInterface;
    editorIF.SetHeightOffset(heightOffset);
}

void
Editor_SetBrushSize(vector newMins, vector newMaxs)
{
    vguiDesktop_Editor editorIF = (vguiDesktop_Editor)g_uiInterface;
    editorIF.SetBrushSize(newMins, newMaxs);
}

void
Editor_SetSelectionDict(ncDict targetDict, string iconPath, selectionSpawnMode_t spawnMode)
{
    vguiDesktop_Editor editorIF = (vguiDesktop_Editor)g_uiInterface;
    thread(editorIF.SetSelectionDict(targetDict, iconPath, spawnMode));
}
