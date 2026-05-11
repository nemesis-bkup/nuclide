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

#define BROWSER_HOVER 8
#define BROWSER_MOUSEDOWN 4

/** VGUI Widget: WWW View

@ingroup vgui
*/
class
vguiXView:vguiPic
{
public:
    void vguiXView(void);

    virtual void Draw(void);
    virtual bool Input(float, float, float, float);
    virtual void SizeChanged(vector, vector);
    virtual void OnRemove(void);

    nonvirtual void LoadRequest(string requestString);
    nonvirtual void PageStop(void);
    nonvirtual void PageReload(void);
    nonvirtual void NavigateForward(void);
    nonvirtual void NavigateBack(void);
    nonvirtual bool CanGoBack(void);
    nonvirtual bool CanGoForward(void);

    nonvirtual string GetURL(void);

private:
    string m_webViewURL;
    string m_webViewName;
    float m_webViewRef;

    /* status cache */
    string m_pageTitle;
    string m_pageURL;
    string m_pageStatus;

    /* our options */
    bool m_focusLocked;

    nonvirtual void _InitializeWebContext(void);
    nonvirtual void _RefreshPageInfo(void);
};

void
vguiXView::vguiXView(void)
{
    m_webViewURL = "about:blank";
    m_webViewRef = 0;
    m_webViewName = __NULL__;
}

void
vguiXView::Draw(void)
{
    if (!STRING_SET(m_webViewName)) {
        Font_DrawText([8,8], "No X server plugin loaded.", g_fntDefault);
        Font_DrawText([8,32], "Run host applications on DISPLAY=:1", g_fntDefault);
        return;
    }

    super::Draw();
}

string
vguiXView::GetURL(void)
{
    return (m_pageURL);
}

void
vguiXView::LoadRequest(string requestString)
{
    if (!STRING_SET(m_webViewName)) {
        _InitializeWebContext();
    }

    if (!STRING_SET(m_webViewName)) {
        return;
    }

    m_webViewURL = requestString;
    gecko_navigate(m_webViewName, m_webViewURL);
    ncLog("loading request for %S", m_webViewURL);
    _RefreshPageInfo();
}

void
vguiXView::OnRemove(void)
{
    gecko_destroy(m_webViewName);
}

void
vguiXView::SizeChanged(vector vecOld, vector vecNew)
{
    if (!STRING_SET(m_webViewName)) {
        _InitializeWebContext();
    }

    if (!STRING_SET(m_webViewName)) {
        return;
    }

    gecko_resize(m_webViewName, vecNew[0], vecNew[1]);
}


bool
vguiXView::Input(float flEVType, float flKey, float flChar, float flDevID)
{
    bool ret = false;
    bool mouseHover = false;

    if (IsEnabled() == false) {
        return (false);
    }

    if (!STRING_SET(m_webViewName)) {
        return;
    }

    if (Util_MouseAbove(g_vecMousePos, m_parent.m_vecOrigin + m_vecOrigin, m_vecSize)) {
        vector relativeMousePos;
        relativeMousePos[0] = (g_vecMousePos[0] - (m_parent.m_vecOrigin[0] + m_vecOrigin[0])) / m_vecSize[0];
        relativeMousePos[1] = (g_vecMousePos[1] - (m_parent.m_vecOrigin[1] + m_vecOrigin[1])) / m_vecSize[1];
        mouseHover = true;
        ret = true;

        if (relativeMousePos[0] > 1.0f) {
            relativeMousePos[0] = 1.0f;
        }
        if (relativeMousePos[1] > 1.0f) {
            relativeMousePos[1] = 1.0f;
        }
        if (relativeMousePos[0] < 0.0f) {
            relativeMousePos[0] = 0.0f;
        }
        if (relativeMousePos[1] < 0.0f) {
            relativeMousePos[1] = 1.0f;
        }

        gecko_mousemove(m_webViewName, relativeMousePos[0], relativeMousePos[1]);
    }

    if (mouseHover == true && HasFlag(BROWSER_HOVER) == false) {
        FlagAdd(BROWSER_HOVER);
        gecko_navigate(m_webViewName, "cmd:focus");
        _RefreshPageInfo();
    } else if (HasFlag(BROWSER_HOVER) && mouseHover == false) {
        FlagRemove(BROWSER_HOVER);
        gecko_navigate(m_webViewName, "cmd:unfocus");
    }

    if (m_focusLocked) {
        ret = mouseHover;
    }

    if (flEVType == IE_KEYDOWN || flEVType == IE_KEYUP) {
        gecko_keyevent(m_webViewName, flKey, flEVType, flChar);
    }

    return (ret);
}


void
vguiXView::PageStop(void)
{
}

void
vguiXView::PageReload(void)
{
}

void
vguiXView::NavigateForward(void)
{
}

void
vguiXView::NavigateBack(void)
{
}

bool
vguiXView::CanGoBack(void)
{
}

bool
vguiXView::CanGoForward(void)
{
}

void
vguiXView::_InitializeWebContext(void)
{
    if (checkcommand("startx") == 0) {
        SetImage("");
        return;
    }

    m_webViewName = sprintf("vguiXView%d", num_for_edict(this));
    m_webViewRef = gecko_create(m_webViewName, "x11");

    ncLog("Context %d named %S created", m_webViewRef, m_webViewName);
    SetImage(m_webViewName);
    _RefreshPageInfo();
}

void
vguiXView::_RefreshPageInfo(void)
{
    if (!STRING_SET(m_webViewName)) {
        return;
    }

    m_pageTitle = gecko_getproperty(m_webViewName, "title");
    m_pageURL = gecko_getproperty(m_webViewName, "url");
    m_pageStatus = gecko_getproperty(m_webViewName, "status");

    ncLog("Title: %S\n\tURL: %S\n\tStatus: %S", m_pageTitle, m_pageURL, m_pageStatus);
}
