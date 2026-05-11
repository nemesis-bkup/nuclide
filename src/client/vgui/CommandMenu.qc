/*
 * Copyright (c) 2024 Vera Visions LLC.
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

vguiWidget g_uiCommandMenu;

void
Commandmenu_Init(void)
{

}

void
Commandmenu_Draw(void)
{
    if (pSeat->m_bCommandMenu == false)
        return;

    if (g_uiCommandMenu)
        g_uiCommandMenu.Draw();
}

bool
Commandmenu_Input(float flEvType, float flScanX, float flCharY, float flDevID)
{
    if (pSeat->m_bCommandMenu == false)
        return (false);

    if (!g_uiCommandMenu)
        return (false);

    return g_uiCommandMenu.Input(flEvType, flScanX, flCharY, flDevID);
}

void
Commandmenu_Open(void)
{
    pSeat->m_bCommandMenu = true;
}

void
Commandmenu_Close(void)
{
    pSeat->m_bCommandMenu = false;
}
