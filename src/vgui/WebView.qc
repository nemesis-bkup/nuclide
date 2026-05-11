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

.void(vguiControl sender) tmpvguiWebView1;
.vguiWidget tmpvguiWebView1Delegate;

static void
vguiWebView_CallFunctionWithDelegateSender(void(vguiControl sender) targetFunc, vguiWidget delegateWidget, vguiControl sender)
{
    entity oldSelf = self;

    if (delegateWidget) {
        self = delegateWidget;
    }

    if (targetFunc) {
        targetFunc(sender);
    }

    self = oldSelf;
}

/** VGUI Widget: WWW View

@ingroup vgui
*/
class
vguiWebView:vguiPic
{
public:
    void vguiWebView(void);

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

    nonvirtual void CallOnPageUpdateWithDelegate(void(void) func, vguiControl delegateWidget);

    nonvirtual string GetURL(void);
    nonvirtual string GetTitle(void);

    virtual void ReloadVideoResources(void);

private:
    string m_webViewURL;
    string m_webViewName;
    float m_webViewRef;
    int m_pageCounter;
    int m_pageMax;

    /* status cache */
    string m_pageTitle;
    string m_pageURL;
    string m_pageStatus;
    string m_pageIcon;

    /* our options */
    bool m_focusLocked;

    nonvirtual void _InitializeWebContext(void);
    nonvirtual void _RefreshPageInfo(void);
};

void
vguiWebView::CallOnPageUpdateWithDelegate(void(void) func, vguiControl delegateWidget)
{
    //#warning "SetFunc in vguiButton is DEPRECATED. Compiler IS generating JUNK in the old way. Please override vguiButton and define a OnMouseDown/Up method instead"
    //m_vFunc = vFunc;
    tmpvguiWebView1 = func;
    tmpvguiWebView1Delegate = delegateWidget;
}

void
vguiWebView::vguiWebView(void)
{
    m_webViewURL = "about:blank";
    m_webViewRef = 0;
    m_webViewName = __NULL__;
    m_pageIcon = "gfx/icon16/empty";
    m_pageCounter = 0;
    m_pageMax = 0;
}

void
vguiWebView::ReloadVideoResources(void)
{
    OnRemove();
    LoadRequest(m_webViewURL);
}

void
vguiWebView::Draw(void)
{
    if (!STRING_SET(m_webViewName)) {
        Font_DrawText([8,8], "No CEF plugin loaded.", g_fntDefault);
        return;
    }

    super::Draw();
}

string
vguiWebView::GetURL(void)
{
    return (m_pageURL);
}

string
vguiWebView::GetTitle(void)
{
    return (m_pageTitle);
}

void
vguiWebView::LoadRequest(string requestString)
{
    if (checkcommand("cef") == 0) {
        SetImage("");
        return;
    }

    _InitializeWebContext();

    m_webViewURL = requestString;
    gecko_navigate(m_webViewName, m_webViewURL);
    ncLog("loading request for %S", m_webViewURL);
    _RefreshPageInfo();

    /* new page request > forget future pages. */
    m_pageCounter++;
    m_pageMax = m_pageCounter;
}

void
vguiWebView::OnRemove(void)
{
    gecko_destroy(m_webViewName);
}

void
vguiWebView::SizeChanged(vector vecOld, vector vecNew)
{
    gecko_resize(m_webViewName, vecNew[0], vecNew[1]);
}


bool
vguiWebView::Input(float flEVType, float flKey, float flChar, float flDevID)
{
    bool ret = false;
    bool mouseHover = false;
    vguiRootWindow rootWin = (vguiRootWindow)GetRootWindow();
    vector mousePos = rootWin.GetMousePos();
    vector absPos = GetAbsPos();

    if (IsEnabled() == false) {
        return (false);
    }

    if (MouseAbove()) {
        vector relativeMousePos;
        relativeMousePos[0] = (mousePos[0] - (absPos[0])) / GetWidth();
        relativeMousePos[1] = (mousePos[1] - (absPos[1])) / GetHeight();
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
        _RefreshPageInfo();
    }

    if (m_focusLocked) {
        ret = mouseHover;
    }

#if 0
    if (HasFlag(BROWSER_HOVER)) {
        if (flEVType == IE_KEYDOWN) {
            ncError("IE_KEYDOWN %s %d %d %d", m_webViewName, flKey, flEVType, flChar);
            ret = gecko_keyevent(m_webViewName, flKey, flEVType, flChar);
        } else if (flEVType == IE_KEYUP) {
            ncError("IE_KEYUP %s %d %d %d", m_webViewName, flKey, flEVType, flChar);
            ret = gecko_keyevent(m_webViewName, flKey, flEVType, flChar);
            _RefreshPageInfo();
        }
    }
#else

    if (mouseHover)
    switch (flEVType) {
    case IE_KEYDOWN:
        if (flKey == K_MOUSE1) {
            if (mouseHover) {
                gecko_keyevent(m_webViewName, flKey, flEVType, flChar);
                ret = true;
                FlagAdd(BROWSER_MOUSEDOWN);
            }
        } else {
            gecko_keyevent(m_webViewName, flKey, flEVType, flChar);
        }
        break;
    case IE_KEYUP:
        if (flKey == K_MOUSE1) {
            if (HasFlag(BROWSER_MOUSEDOWN) && mouseHover) {
                gecko_keyevent(m_webViewName, flKey, flEVType, flChar);
                ret = true;
            }
            FlagRemove(BROWSER_MOUSEDOWN);
        } else {
            gecko_keyevent(m_webViewName, flKey, flEVType, flChar);
        }
        break;
    default:
        return (ret);
    }
#endif

    return (ret);
}

void
vguiWebView::PageStop(void)
{
    gecko_navigate(m_webViewName, "cmd:stop");
}

void
vguiWebView::PageReload(void)
{
    gecko_navigate(m_webViewName, "cmd:reload");
}

void
vguiWebView::NavigateForward(void)
{
    if (!CanGoForward()) {
        return;
    }

    gecko_navigate(m_webViewName, "cmd:forward");
    m_pageCounter++;
}

void
vguiWebView::NavigateBack(void)
{
    if (!CanGoBack()) {
        return;
    }

    gecko_navigate(m_webViewName, "cmd:back");
    m_pageCounter--;
}

bool
vguiWebView::CanGoBack(void)
{
    if (m_pageCounter == 0) {
        return (false);
    } else {
        return (true);
    }
}

bool
vguiWebView::CanGoForward(void)
{
    if (m_pageMax == m_pageCounter) {
        return (false);
    } else {
        return (true);
    }
}

void
vguiWebView::_InitializeWebContext(void)
{
    if (STRING_SET(m_webViewName)) {
        return;
    }

    m_webViewName = sprintf("vguiWebView%d", num_for_edict(this));
    m_webViewRef = gecko_create(m_webViewName, "http:");

    ncLog("Context %d named %S created", m_webViewRef, m_webViewName);
    SetImage(m_webViewName);
    _RefreshPageInfo();
}

void
vguiWebView::_RefreshPageInfo(void)
{
    m_pageTitle = gecko_getproperty(m_webViewName, "title");
    m_pageURL = gecko_getproperty(m_webViewName, "url");
    m_pageStatus = gecko_getproperty(m_webViewName, "status");
    m_pageIcon = gecko_getproperty(m_webViewName, "icon");

    ncLog("Title: %S\n\tURL: %S\n\tStatus: %S\ntIcon: %S", m_pageTitle, m_pageURL, m_pageStatus, m_pageIcon);

    vguiWebView_CallFunctionWithDelegateSender(tmpvguiWebView1, tmpvguiWebView1Delegate ? tmpvguiWebView1Delegate : m_parent, this);
}


#if 0
float(string name, optional string initialURI) gecko_create = #487; /* Part of DP_GECKO_SUPPORT
        Create a new 'browser tab' shader with the specified name that can then be drawn via drawpic (shader should not already exist - including from map/model textures or disk). In order to function correctly, this builtin depends upon external plugins being available. Use gecko_navigate to navigate it to a page of your choosing. */

void(string name) gecko_destroy = #488; /* Part of DP_GECKO_SUPPORT
        Destroy a shader. */

void(string name, string URI) gecko_navigate = #489; /* Part of DP_GECKO_SUPPORT
        Sends a command to the media decoder attached to the specified shader. In the case of a browser decoder, this changes the url that the browser displays. 'cmd:[un]focus' will tell the decoder that it has focus. */

float(string name, float key, float eventtype, optional float charcode) gecko_keyevent = #490; /* Part of DP_GECKO_SUPPORT
        Send a key event to a media decoder. This applies only to interactive decoders like browsers. */

void(string name, float x, float y) gecko_mousemove = #491; /* Part of DP_GECKO_SUPPORT
        Sets a media decoder shader's mouse position. Values should be 0-1. */

void(string name, float w, float h) gecko_resize = #492; /* Part of DP_GECKO_SUPPORT
        Request to resize a media decoder. */

vector(string name) gecko_get_texture_extent = #493; /* Part of DP_GECKO_SUPPORT
        Retrieves a media decoder current image pixel sizes. */

string(string shadname, string propname) gecko_getproperty = #0:gecko_getproperty; /*
        Queries the media decoder (especially browser ones) for decoder-specific properties. The cef plugin recognises url, title, status. */
#endif
