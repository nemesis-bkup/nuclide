/*
 * Copyright (c) 2026 Vera Visions LLC.
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
vguiRootWindow::vguiRootWindow(void)
{
    m_focusedWidget = 0;
}

vguiWidget
vguiRootWindow::GetFocusedWidget(void)
{
    return (m_focusedWidget);
}

void
vguiRootWindow::SetFocus(vguiWidget focusedWidget)
{
    m_focusedWidget = focusedWidget;
}

void
vguiRootWindow::SetFocusToNextWindow(void)
{
    vguiWidget prevWidget = m_focusedWidget.m_rootPrev;
    m_focusedWidget = m_focusedWidget.m_rootNext;

    if (!m_focusedWidget || wasfreed(m_focusedWidget)) {
        m_focusedWidget = prevWidget;
    }

    if (!m_focusedWidget || wasfreed(m_focusedWidget)) {
        m_focusedWidget = __NULL__;
    }
}

void
vguiRootWindow::Add(vguiWidget wNew)
{
    wNew.m_parent = this;
}

void
vguiRootWindow::Reposition(void)
{
    vguiWidget wNext = this;

    for (vguiWidget widgets = 0; (widgets = findfloat(widgets, ::isVGUI, true));) {
        if (widgets.GetParent() == this) {
            widgets.Reposition();
        }
    }
}

vector
vguiRootWindow::GetMousePos(void)
{
    return (m_vecMousePos);
}

bool
vguiRootWindow::MouseActive(void)
{
    return (m_activeWidgetCount != 0) ? (true) : (false);
}

void
vguiRootWindow::Draw(void)
{
    m_activeWidgetCount = 0;
    m_bVisible = true;

    for (vguiWidget widgets = 0; (widgets = findfloat(widgets, ::isVGUI, true));) {
        if (widgets.GetParent() == this && widgets.Visible()) {
            m_activeWidgetCount++;

            if not (m_focusedWidget && widgets == m_focusedWidget) {
                widgets.Draw();
            }
        }
    }

    /* avoid recursion. */
    if (m_focusedWidget == this) {
        m_focusedWidget = __NULL__;
    }

    if (m_focusedWidget) {
        m_focusedWidget.Draw();
    }
}

bool
vguiRootWindow::Input (float flEVType, float flKey, float flChar, float flDevID)
{
    float ret = false;

    vguiWidget wNext = this;

    switch (flEVType) {
    case IE_KEYDOWN:
        break;
    case IE_KEYUP:
        break;
    case IE_MOUSEABS:
        m_vecMousePos[0] = flKey;
        m_vecMousePos[1] = flChar;
        break;
    case IE_MOUSEDELTA:
        m_vecMousePos[0] += flKey;
        m_vecMousePos[1] += flChar;
        break;
    default:
        return (true);
    }


    if (m_focusedWidget) {
        ret = m_focusedWidget.Input(flEVType, flKey, flChar, flDevID);
    }

    if (ret == false) {
        for (vguiWidget widgets = 0; (widgets = findfloat(widgets, ::isVGUI, true));) {
            if (widgets != m_focusedWidget)
            if (widgets.GetParent() == this && widgets.Visible()) {
                ret = widgets.Input(flEVType, flKey, flChar, flDevID);

                if (ret) {
                    return (true);
                }
            }
        }

    }

    return (false);
}
