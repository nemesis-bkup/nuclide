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

/** Trinity Menu File "menuDef"

This class represents objects that are parsed from "menuDef" entries
defined in the Quake III: Team Arena (2000) menu scripting language.

They are mainly used as a container for smaller items, which you
may want to move together without having to adjust
absolute screen values. As [items](@ref vguiScriptedItem) are placed relative to their parent
menuDef.

# SEE ALSO

[itemDef](@ref vguiScriptedItem)

*/
class
vguiScriptedMenu:vguiView
{
public:
    void vguiScriptedMenu(void);
    virtual void Draw(void);
    virtual bool Input(float, float, float, float);
    virtual void Reposition(void);

    nonvirtual void OnClose(void);
    nonvirtual void OnOpen(void);
    nonvirtual void OnESC(void);

private:
    vguiScriptedView m_trGlobal;
    int m_trSubBorder;
    int m_trSubStyle;
    string m_trSubSoundLoop;
    vector m_vecSize;
    vector m_vecOrigin;
    bool m_trSubFullScreen;
    string m_trSubName;
    vector m_trSubBorderColor;
    float m_trSubBorderAlpha;
    vector m_trSubFocusColor;
    float m_trSubFocusAlpha;
    vector m_trSubBackColor;
    float m_trSubBackAlpha;
    string m_trSubBackground;
    string m_trSubOnESC;
    string m_trSubOnOpen;
    string m_trSubOnClose;
};

void
vguiScriptedMenu::vguiScriptedMenu(void)
{
    m_trSubName = __NULL__;
    m_trSubFullScreen = false;
    m_vecOrigin = g_vec_null;
    m_vecSize = g_vec_null;
    m_trGlobal = __NULL__;
    m_trSubOnESC = __NULL__;
    m_trSubOnOpen = __NULL__;
    m_trSubOnClose = __NULL__;
    classname = "vguiScriptedMenu";
}

void
vguiScriptedMenu::Reposition(void)
{
}

void
vguiScriptedMenu::OnOpen(void)
{
    Show();

    int commandCount;

    for (int i = 0; i < (commandCount = tokenizebyseparator(m_trSubOnOpen, ";", "\n")); i++) {
        string commandString = argv(i);

        if (STRING_SET(commandString)) {
            m_trGlobal.InterpretCommand(this, commandString);
        }
    }
}

void
vguiScriptedMenu::OnClose(void)
{
    Hide();

    int commandCount;

    for (int i = 0; i < (commandCount = tokenizebyseparator(m_trSubOnClose, ";", "\n")); i++) {
        string commandString = argv(i);

        if (STRING_SET(commandString)) {
            m_trGlobal.InterpretCommand(this, commandString);
        }
    }
}

void
vguiScriptedMenu::OnESC(void)
{
    int commandCount;

    for (int i = 0; i < (commandCount = tokenizebyseparator(m_trSubOnESC, ";", "\n")); i++) {
        string commandString = argv(i);

        if (STRING_SET(commandString)) {
            m_trGlobal.InterpretCommand(this, commandString);
        }
    }
}


bool
vguiScriptedMenu::Input(float flEVType, float flKey, float flChar, float flDevID)
{

    bool mouseHover = false;

    if (Util_MouseAbove(g_vecMousePos, m_parent.m_vecOrigin + m_vecOrigin, m_vecSize)) {
        mouseHover = true;
    }

    if (mouseHover)
    if (flEVType == IE_KEYDOWN) {
        if (flKey == K_ESCAPE) {
            OnESC();
        }
    }

    return super::Input(flEVType, flKey, flChar, flDevID);
}

void
vguiScriptedMenu::Draw(void)
{
    vector pos;
    vector size;

    if (m_trSubFullScreen == true) {
        pos = GetAbsPos() + [0,0];
        size = [640,480];
        m_vecOrigin = pos;
        m_vecSize = size;
        SetPos(pos);
        SetSize(size);
    } else {
        pos = GetAbsPos();
        size = m_vecSize;
    }

    if (STRING_SET(m_trSubBackground)) {
        draw.Pic(pos, m_trSubBackground, size, [1,1,1], 1.0, 0);
    } else {
        draw.Rect(pos, size, m_trSubBackColor, m_trSubBackAlpha);
    }

    if (m_trSubBorder > 0) {
        draw.RectOutline(pos, size, 1.0f, m_trSubBorderColor, m_trSubBorderAlpha);
    }

    super::Draw();
}
