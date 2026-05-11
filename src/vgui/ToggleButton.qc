/*
 * Copyright (c) 2016-2022 Vera Visions LLC.
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

enumflags
{
    TOGGLEBUTTON_HOVER,
    TOGGLEBUTTON_DOWN,
    TOGGLEBUTTON_CHECKED
};

/** VGUI Widget: Toggle Button

@ingroup vgui
*/
class vguiToggleButton:vguiControl
{
public:
    void vguiToggleButton(void);

    nonvirtual void SetIcon(string);
    nonvirtual void SetTitle(string);
    nonvirtual int GetValue(void);
    nonvirtual void SetValue(int);

    virtual void Draw(void);
    virtual bool Input(float, float, float, float);
    virtual void Spawned(void);

private:
    vector m_vecIMGSize;
    vector m_vecColor;
    vector m_vecIconColor;
    float m_flAlpha;
    string m_strTitle;
    string m_strTitleActive;
    string m_strIcon;
    string m_strExec;
    int m_keyEquivalent;
};

void vguiToggleButton::vguiToggleButton(void)
{
    m_flAlpha = 1.0f;
    m_vecIconColor = [1,1,1];
    m_strIcon = __NULL__;
}

void
vguiToggleButton::Spawned(void)
{
    SetSize([96,18]);
}

void vguiToggleButton::SetIcon (string iconPath)
{
    m_strIcon = iconPath;
    m_vecIMGSize = [16,16];

    if (length(GetSize()) < length(m_vecIMGSize)) {
        SetSize(m_vecIMGSize + [4,4]);
    }
}

void vguiToggleButton::SetTitle (string strName)
{
    m_strTitle = strName;
}
int vguiToggleButton::GetValue(void)
{
    if (m_iFlags & TOGGLEBUTTON_CHECKED) {
        return (1);
    } else {
        return (0);
    }
}
void vguiToggleButton::SetValue (int iValue)
{
    _PreModificationCallback();

    if (iValue == TRUE) {
        m_iFlags |= TOGGLEBUTTON_CHECKED;
    } else {
        m_iFlags -= (m_iFlags & TOGGLEBUTTON_CHECKED);
    }

    _PostModificationCallback();
}

void vguiToggleButton::Draw(void)
{
    vguiTheme theme = GetTheme();

    if (IsEnabled() == false) {
        theme.DrawButton(m_parent.m_vecOrigin + m_vecOrigin, m_vecSize, VGUI_STATE_DISABLED);
    } else if (m_iFlags & TOGGLEBUTTON_CHECKED) {
        theme.DrawButton(m_parent.m_vecOrigin + m_vecOrigin, m_vecSize, VGUI_STATE_ACTIVE);
    } else if (m_iFlags & TOGGLEBUTTON_HOVER) {
        theme.DrawButton(m_parent.m_vecOrigin + m_vecOrigin, m_vecSize, VGUI_STATE_HOVER);
    } else {
        theme.DrawButton(m_parent.m_vecOrigin + m_vecOrigin, m_vecSize, VGUI_STATE_NORMAL);
    }

    float textPadding = 8;

    /* size check is a quick hack for small buttons */
    if (m_keyEquivalent >= 0 && (m_vecSize[1] > 128)) {
        float length;
        string keyText = GetKeyEquivalent();

        length = Font_StringWidth(keyText, FALSE, g_fntDefault);
        textPadding += length + 8;
        theme.DrawText(m_parent.m_vecOrigin + m_vecOrigin + [8, 6], keyText, m_vecSize, g_fntDefault);
    }

    if ((STRING_SET(m_strIcon) && theme.IconsEnabled()) || (!STRING_SET(m_strTitle) && STRING_SET(m_strIcon))) {
        if (m_iFlags & TOGGLEBUTTON_CHECKED)
            drawpic(m_parent.m_vecOrigin + m_vecOrigin + [3,3], m_strIcon, m_vecIMGSize, m_vecIconColor * 0.25, 1.0f, 0);
        else
            drawpic(m_parent.m_vecOrigin + m_vecOrigin + [3,3], m_strIcon, m_vecIMGSize, m_vecIconColor, 1.0f, 0);

        textPadding += m_vecIMGSize[0] + 3;
    }

    if (STRING_SET(m_strTitle)) {
        if (m_iFlags & TOGGLEBUTTON_HOVER) {
            theme.DrawText(m_parent.m_vecOrigin + m_vecOrigin + [textPadding, 6], m_strTitle, m_vecSize, g_fntDefault);
        } else {
            theme.DrawText(m_parent.m_vecOrigin + m_vecOrigin + [textPadding, 6], m_strTitle, m_vecSize, g_fntDefault);
        }
    }
}

bool
vguiToggleButton::Input(float flEVType, float flKey, float flChar, float flDevID)
{
    bool ret = false;

    if (flEVType == IE_KEYDOWN) {
        if (flKey == K_MOUSE1) {
            if (Util_MouseAbove(g_vecMousePos, m_parent.m_vecOrigin + m_vecOrigin, m_vecSize)) {
                m_iFlags |= TOGGLEBUTTON_DOWN;
                ret = true;
            }
        }
    } else if (flEVType == IE_KEYUP) {
        if (flKey == K_MOUSE1) {
            if (m_iFlags & TOGGLEBUTTON_DOWN && Util_MouseAbove(g_vecMousePos, m_parent.m_vecOrigin + m_vecOrigin, m_vecSize)) {
                _PreInteractionCallback();
                SetValue(!GetValue());
                _PostInteractionCallback();
                ret = true;
            }
            m_iFlags -= (m_iFlags & TOGGLEBUTTON_DOWN);
        }
    }

    return (ret);
}
