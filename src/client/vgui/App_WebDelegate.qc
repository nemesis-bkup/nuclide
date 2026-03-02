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

class
vguiApp_WebDelegate:vguiWindow
{
	void vguiApp_WebDelegate(void);
	virtual void Spawned(void);

	nonvirtual vguiWindow NewWebAppWindow(string appName, string appIcon, string webURL, vector initialResolution, bool capturesMouse, bool isResizable);
	nonvirtual void WebApp_Resized(void);

private:

	vguiWebView webView;
};

void
vguiApp_WebDelegate::vguiApp_WebDelegate(void)
{
}

void
vguiApp_WebDelegate::WebApp_Resized(void)
{
	vector windowSize = GetSize();
	webView.SetSize( [windowSize[0]-16, windowSize[1]-40] );
}


vguiWindow
vguiApp_WebDelegate::NewWebAppWindow(string appName, string appIcon, string webURL, vector initialResolution, bool capturesMouse, bool isResizable)
{
	vguiApp_WebDelegate newWindow = spawn(vguiApp_WebDelegate);

    if (STRING_SET(appName)) {
        newWindow.SetTitle( appName );
    }

    if (STRING_SET(appIcon)) {
        newWindow.SetIcon( appIcon );
    }

	newWindow.webView.LoadRequest(webURL);
	newWindow.SetSize( initialResolution + [16,40] );
	newWindow.webView.SetSize( initialResolution );

	if (isResizable) {
		newWindow.SetStyleMask( vguiWindowStyleDefault | vguiWindowResizeable );
		newWindow.CallOnResize(WebApp_Resized);
	}

	if (capturesMouse) {
		newWindow.webView.m_focusLocked = true;
	} else {
		newWindow.webView.m_focusLocked = true;
	}

	ncLogAlways("Created WebApp %S with dimensions %d x %d", appName, initialResolution[0], initialResolution[1]);
	return (newWindow);
}

void
vguiApp_WebDelegate::Spawned(void)
{
	super::Spawned();

	classname = "vguiWindow";
	SetTitle( "WebApp" );
	SetSize( [640,480] );
	SetIcon( "gfx/icon16/world" );
	SetMaxSize( [9999,9999] );

	webView = spawn( vguiWebView );
	webView.SetSize( [640-16, 480-40] );
	webView.SetPos( [8, 32] );

	Add( webView );
}
