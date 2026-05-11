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


/** VGUI: Root Window

@ingroup vgui
*/
class vguiRootWindow:vguiWidget
{
public:
    void vguiRootWindow(void);

    nonvirtual void SetFocus(vguiWidget);
    nonvirtual vguiWidget GetFocusedWidget(void);
    nonvirtual bool MouseActive(void);
    nonvirtual vector GetMousePos(void);
    nonvirtual void SetFocusToNextWindow(void);

    /* overrides */
    virtual void Add(vguiWidget);
    virtual void Reposition(void);
    virtual void Draw(void);
    virtual bool Input(float, float, float, float);

private:
    vguiWidget m_focusedWidget;
    int m_activeWidgetCount;
    vector m_vecMousePos;
};




void
vguiWidget::vguiWidget(void)
{

    m_vecOrigin = [0.0f, 0.0f];
    m_vecSize = [0.0f, 0.0f];
    m_vecMinSize = [0.0f, 0.0f];
    m_vecMaxSize = [9999.0f, 9999.0f];
    m_next = __NULL__;
    m_parent = __NULL__;
    m_iFlags = 0i;
    m_bVisible = true;
    m_bEnabled = true;
    isVGUI = true;
    m_theme = __NULL__;


    m_children = __NULL__;
    m_windowNext = __NULL__;
    m_windowPrev = __NULL__;
    m_rootNext = __NULL__;
    m_rootPrev = __NULL__;

    Spawned();
}

void
vguiWidget::ReloadVideoResources(void)
{

}

void
vguiWidget::SetTheme(vguiTheme theme)
{
    m_theme = theme;
}

bool
vguiWidget::IsEnabled(void)
{
    return (m_bEnabled);
}

void
vguiWidget::Enable(void)
{
    m_bEnabled = true;
}

vguiWidget
vguiWidget::GetParent(void)
{
    return (m_parent);
}

void
vguiWidget::OnRemove(void)
{
   for (vguiWidget widgets = 0; (widgets = findfloat(widgets, ::isVGUI, true));) {
        if (widgets.GetParent() == this) {
            widgets.Remove();
        }
    }

    m_bVisible = false;
    m_bEnabled = false;
    m_next = __NULL__;
    m_parent = __NULL__;
    isVGUI = false;
    m_vecOrigin = [0.0f, 0.0f];
    m_vecSize = [0.0f, 0.0f];
    m_vecMinSize = [0.0f, 0.0f];
}

bool
vguiWidget::MouseAbove(void)
{
    vguiRootWindow rootWin = (vguiRootWindow)GetRootWindow();
    return Util_MouseAbove(rootWin.GetMousePos(), GetAbsPos(), GetSize());
}

vector
vguiWidget::GetMousePos(void)
{
    vguiRootWindow rootWin = (vguiRootWindow)GetRootWindow();
    return rootWin.GetMousePos();
}


void
vguiWidget::Remove(void)
{
    OnRemove();

    if (wasfreed(this) == false)
        remove(this);
}

bool
vguiWidget::HasFocus(void)
{
    vguiRootWindow rootWin = (vguiRootWindow)GetRootWindow();

    return (rootWin.GetFocusedWidget() == this) ? (true) : (false);
}

vguiWidget
vguiWidget::GetRootWindow(void)
{
    if (m_parent) {
        return m_parent.GetRootWindow();
    }

    return (this);
}

void
vguiWidget::Disable(void)
{
    m_bEnabled = false;
}

void
vguiWidget::NowEnabled(void)
{
}

void
vguiWidget::NowDisabled(void)
{
}

vguiTheme
vguiWidget::GetTheme(void)
{
    /* if no theme set, but we have a parent... inherit the parents' theme recursively */
    if (!m_theme && m_parent) {
        return m_parent.GetTheme();
    }

    /* we have nothing, use the default one. */
    if (!m_theme) {
        m_theme = spawn(vguiTheme);
    }

    return (m_theme);
}

bool
vguiWidget::Visible(void)
{
    return (m_bVisible);
}

void
vguiWidget::Hide(void)
{
    m_bVisible = false;
    NowHidden();
}

void
vguiWidget::NowHidden(void)
{
}


void
vguiWidget::NowVisible(void)
{
}


void
vguiWidget::Show(void)
{
    m_bVisible = true;
    NowVisible();
}

void
vguiWidget::PositionChanged(vector vecOld, vector vecNew)
{

}

void
vguiWidget::SizeChanged(vector vecOld, vector vecNew)
{

}

void
vguiWidget::SetPos(vector vecNewPos)
{
    vector vecOld = m_vecOrigin;
    m_vecOrigin[0] = bound(0, vecNewPos[0], 9999.0);
    m_vecOrigin[1] = bound(0, vecNewPos[1], 9999.0);
    PositionChanged(vecOld, m_vecOrigin);
}

vector
vguiWidget::GetAbsPos(void)
{
    if (m_parent) {
        vector parentPos2 = (m_parent.m_parent) ? (m_parent.m_parent.m_vecOrigin) : g_vec_null;
        vector parentPos = m_parent.m_vecOrigin;
        return (parentPos2 + parentPos + m_vecOrigin);
    }

    return m_vecOrigin;
}

vector
vguiWidget::GetPos(void)
{
    return (m_vecOrigin);
}

int
vguiWidget::GetPosWidth(void)
{
    return (m_vecOrigin[0]);
}

int
vguiWidget::GetPosHeight(void)
{
    return (m_vecOrigin[1]);
}

void
vguiWidget::SetSize(vector vecNewSize)
{
    vector vecOld = m_vecSize;
    m_vecSize[0] = bound(m_vecMinSize[0], vecNewSize[0], m_vecMaxSize[0]);
    m_vecSize[1] = bound(m_vecMinSize[1], vecNewSize[1], m_vecMaxSize[1]);
    SizeChanged(vecOld, m_vecSize);
}

vector
vguiWidget::GetSize(void)
{
    return (m_vecSize);
}

int
vguiWidget::GetWidth(void)
{
    return (m_vecSize[0]);
}

int
vguiWidget::GetHeight(void)
{
    return (m_vecSize[1]);
}

void
vguiWidget::SetMinSize (vector vecNewSize)
{
    m_vecMinSize = vecNewSize;
}

vector
vguiWidget::GetMinSize(void)
{
    return (m_vecMinSize);
}

void
vguiWidget::SetMaxSize(vector vecNewSize)
{
    m_vecMaxSize = vecNewSize;
}

vector
vguiWidget::GetMaxSize(void)
{
    return (m_vecMaxSize);
}

void
vguiWidget::FlagAdd(int iFlag)
{
    m_iFlags |= iFlag;
}

void
vguiWidget::FlagRemove(int iFlag)
{
    m_iFlags -= (m_iFlags & iFlag);
}

bool
vguiWidget::HasFlag(int flag)
{
    return (m_iFlags & flag) ? (true) : (false);
}

void
vguiWidget::Reposition(void)
{

}

void
vguiWidget::Add(vguiWidget wNew)
{

}

void
vguiWidget::Draw(void)
{

}

bool
vguiWidget::Input(float flEVType, float flKey, float flChar, float flDevID)
{
    return (false);
}

void
vguiWidget::Spawned(void)
{
}
