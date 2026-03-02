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


void Editor_SetSelectionEntity(string className);
void Editor_SpawnSelection();
void Editor_SetSelectionURLItem(string itemURL, string itemType, string groupName);
void Editor_SetSelectionProfileItem(string itemName, profileItem_t itemType);

class
vguiApp_WebSurf:vguiWindow
{
	void vguiApp_WebSurf(void);

	virtual void Spawned(void);

	nonvirtual void WebSurf_Navigate(void);
	nonvirtual void WebSurf_Resized(void);

private:

	vguiWebView webView;
	vguiButton btnGo;
	vguiButton btnFwd;
	vguiButton btnBack;
	vguiButton btnReload;
	vguiTextBox addressField;
	vguiButton btnSave;
	vguiButton btnShare;

	vguiButton btnBookmark1;
	vguiButton btnBookmark2;
	vguiButton btnBookmark3;
	vguiButton btnBookmark4;

	/* save panel */
	vguiPanel m_savePanel;
	vguiPanel m_sharePanel;
	vguiRadio m_saveType0;
	vguiRadio m_saveType1;
	vguiRadio m_saveType2;
	vguiRadio m_saveType3;
	vguiRadio m_saveType4;
	vguiRadio m_saveType5;
	vguiRadio m_shareType0;
	vguiRadio m_shareType1;
	vguiRadio m_shareType2;
	vguiRadio m_shareType3;
	vguiRadio m_shareType4;
	vguiRadio m_shareType5;
	vguiButton m_saveItem;
	vguiButton m_shareItem;
};

void
vguiApp_WebSurf::vguiApp_WebSurf(void)
{
}

void
vguiApp_WebSurf::WebSurf_Navigate(void)
{
	webView.LoadRequest(addressField.GetText());
	webView.SetSize(webView.GetSize());
}


void
vguiApp_WebSurf::WebSurf_Bookmark1(void)
{
	addressField.SetText("https://archive.org/");
	WebSurf_Navigate();
}

void
vguiApp_WebSurf::WebSurf_Bookmark2(void)
{
	addressField.SetText("https://www.gutenberg.org/");
	WebSurf_Navigate();
}

void
vguiApp_WebSurf::WebSurf_Bookmark3(void)
{
	addressField.SetText("https://commons.wikimedia.org/wiki/Main_Page");
	WebSurf_Navigate();
}

void
vguiApp_WebSurf::WebSurf_Bookmark4(void)
{
	addressField.SetText("https://www.worldhistory.org/");
	WebSurf_Navigate();
}

void
vguiApp_WebSurf::WebSurf_Forward(void)
{
	webView.NavigateForward();
}

void
vguiApp_WebSurf::WebSurf_Back(void)
{
	webView.NavigateBack();
}

void
vguiApp_WebSurf::WebSurf_Reload(void)
{
	webView.PageReload();
}

void
vguiApp_WebSurf::WebSurf_Resized(void)
{
	vector windowSize = GetSize();
	webView.SetSize( [windowSize[0]-16, windowSize[1]-64-26] );
	addressField.SetSize([webView.GetWidth() - (26 * 6), 24]);
	btnBack.SetPos( [8,32] );
	btnFwd.SetPos( btnBack.GetPos() + [btnBack.GetWidth() + 2, 0] );
	btnReload.SetPos( btnFwd.GetPos() + [btnFwd.GetWidth() + 2, 0] );
	addressField.SetPos( btnReload.GetPos() + [btnReload.GetWidth() + 2, 0] );
	btnGo.SetPos( addressField.GetPos() + [addressField.GetWidth() + 2, 0] );
	btnSave.SetPos( btnGo.GetPos() + [btnGo.GetWidth() + 2, 0] );
	btnShare.SetPos( btnSave.GetPos() + [btnSave.GetWidth() + 2, 0] );

	btnBookmark1.SetPos( btnBack.GetPos() + [0, btnBack.GetHeight()] );
	btnBookmark2.SetPos( btnBookmark1.GetPos() + [btnBookmark1.GetWidth(), 0] );
	btnBookmark3.SetPos( btnBookmark2.GetPos() + [btnBookmark2.GetWidth(), 0] );
	btnBookmark4.SetPos( btnBookmark3.GetPos() + [btnBookmark3.GetWidth(), 0] );
}

void
vguiApp_WebSurf::WebSurf_PageUpdated(void)
{
	SetTitle( sprintf("%s - WebSurf", webView.GetTitle()) );
	addressField.SetText(webView.GetURL());
}


void
vguiApp_WebSurf::WebSurf_SaveItem(void)
{
	int itemType = -1i;
	string fullURL = webView.GetURL();

	tokenizebyseparator(fullURL, "/");
	string webSiteUrl = argv(4);
	string webSiteItem = argv(5);

	if (m_saveType0.GetValue()) {
		itemType = 0i;
	} else if (m_saveType1.GetValue()) {
		itemType = 1i;
	} else if (m_saveType2.GetValue()) {
		itemType = 2i;
	} else if (m_saveType3.GetValue()) {
		itemType = 3i;
	} else if (m_saveType4.GetValue()) {
		itemType = 4i;
	} else if (m_saveType5.GetValue()) {
		itemType = 5i;
	}

	switch (itemType) {
	case 0i:
		localcmd(sprintf("archiveSaveWeb %S %S\n", webSiteUrl, webSiteItem));
		break;
	case 1i:
		localcmd(sprintf("archiveSaveText %S %S\n", webSiteUrl, webSiteItem));
		break;
	case 2i:
		localcmd(sprintf("archiveSaveVideo %S %S\n", webSiteUrl, webSiteItem));
		break;
	case 3i:
		localcmd(sprintf("archiveSaveAudio %S %S\n", webSiteUrl, webSiteItem));
		break;
	case 4i:
		localcmd(sprintf("archiveSaveSoftware %S %S\n", webSiteUrl, webSiteItem));
		break;
	case 5i:
		localcmd(sprintf("archiveSaveImage %S %S\n", webSiteUrl, webSiteItem));
		break;
	}
}


void
vguiApp_WebSurf::WebSurf_OpenSavePanel(void)
{
	vector windowSize = GetSize();

	if (!m_savePanel.m_parent) {
		m_parent.Add(m_savePanel);
	}

	m_savePanel.Show();
	m_savePanel.SetPos(GetPos() + [windowSize[0], 0]);
}

void
vguiApp_WebSurf::WebSurf_OpenSharePanel(void)
{
	vector windowSize = GetSize();

	if (!m_sharePanel.m_parent) {
		m_parent.Add(m_sharePanel);
	}

	m_sharePanel.Show();
	m_sharePanel.SetPos(GetPos() + [windowSize[0], 0]);
}


void
vguiApp_WebSurf::WebSurf_SaveValueChanged(void)
{
	m_saveType0.SetValue( false );
	m_saveType1.SetValue( false );
	m_saveType2.SetValue( false );
	m_saveType3.SetValue( false );
	m_saveType4.SetValue( false );
	m_saveType5.SetValue( false );
}

void
vguiApp_WebSurf::WebSurf_ShareValueChanged(void)
{
	m_shareType0.SetValue( false );
	m_shareType1.SetValue( false );
	m_shareType2.SetValue( false );
	m_shareType3.SetValue( false );
	m_shareType4.SetValue( false );
	m_shareType5.SetValue( false );
}

void
vguiApp_WebSurf::WebSurf_ShareValue(void)
{

    string itemType;
	string fullURL = webView.GetURL();
	tokenizebyseparator(fullURL, "/");
	string webSiteDomain = argv(2);
	string webSiteDetail = argv(3);
	string webSiteUrl = argv(4);
	string webSiteItem = argv(5);

	if (m_shareType0.GetValue()) {
		itemType = "web";
	} else if (m_shareType1.GetValue()) {
		itemType = "text";
	} else if (m_shareType2.GetValue()) {
		itemType = "video";
	} else if (m_shareType3.GetValue()) {
		itemType = "audio";
	} else if (m_shareType4.GetValue()) {
		itemType = "app";
	} else if (m_shareType5.GetValue()) {
		itemType = "picture";
	}

	/* detect archive.org API ability, either on archive.org/details/foo/* or archive.org/download/foo/ (empty item string) */
	if ((webSiteDomain == "archive.org" || webSiteDomain == "www.archive.org") && (webSiteDetail == "details" || (webSiteDetail == "download" && webSiteItem == ""))) {
		switch (itemType) {
		case "web":
			localcmd(sprintf("shareWeb %S\n", fullURL));
			break;
		case "text":
			localcmd(sprintf("archiveShareText %S %S\n", webSiteUrl, webSiteItem));
			break;
		case "video":
			localcmd(sprintf("archiveShareVideo %S %S\n", webSiteUrl, webSiteItem));
			break;
		case "audio":
			localcmd(sprintf("archiveShareAudio %S %S\n", webSiteUrl, webSiteItem));
			break;
		case "app":
			localcmd(sprintf("archiveShareSoftware %S %S\n", webSiteUrl, webSiteItem));
			break;
		case "picture":
			localcmd(sprintf("archiveShareImage %S %S\n", webSiteUrl, webSiteItem));
			break;
		}

		return;
	}

	Editor_SetSelectionURLItem(fullURL, itemType, "");

	printf("%S %d\n", fullURL, itemType);
}

void
vguiApp_WebSurf::InitSavePanel(void)
{
	/* set up the poster size/sharing window */

	m_savePanel = spawn(vguiPanel);
	m_savePanel.SetTitle( "Save Item" );
	m_savePanel.SetSize( [128,200] );
	m_savePanel.SetIcon( "gfx/icon16/disk" );
	m_savePanel.SetPos(GetPos() + GetSize());

	m_saveItem = spawn(vguiButton);
	m_saveItem.SetTitle( "Save" );
	m_saveItem.SetSize( '64 24' );
	m_saveItem.SetPos( m_savePanel.GetSize() - '152 32' );
	m_saveItem.SetFuncWithDelegate( WebSurf_SaveItem, this );

	m_saveType0 = spawn(vguiRadio);
	m_saveType0.SetTitle( "Web" );
	m_saveType0.SetSize( '96 16' );
	m_saveType0.SetPos( [8,32] );

	m_saveType1 = spawn(vguiRadio);
	m_saveType1.SetTitle( "Texts" );
	m_saveType1.SetSize( '96 16' );
	m_saveType1.SetPos( [8,32 + 20] );
	m_saveType1.SetValue( TRUE );

	m_saveType2 = spawn(vguiRadio);
	m_saveType2.SetTitle( "Video" );
	m_saveType2.SetSize( '96 16' );
	m_saveType2.SetPos( [8,32 + 20+20] );

	m_saveType3 = spawn(vguiRadio);
	m_saveType3.SetTitle( "Audio" );
	m_saveType3.SetSize( '96 16' );
	m_saveType3.SetPos( [8,32 + 20+20+20] );

	m_saveType4 = spawn(vguiRadio);
	m_saveType4.SetTitle( "Software" );
	m_saveType4.SetSize( '96 16' );
	m_saveType4.SetPos( [8,32 + 20+20+20+20]);

	m_saveType5 = spawn(vguiRadio);
	m_saveType5.SetTitle( "Images" );
	m_saveType5.SetSize( '96 16' );
	m_saveType5.SetPos( [8,32 + 20+20+20+20+20] );

	m_saveType0.CallOnChangeWithDelegate( WebSurf_SaveValueChanged, this );
	m_saveType1.CallOnChangeWithDelegate( WebSurf_SaveValueChanged, this );
	m_saveType2.CallOnChangeWithDelegate( WebSurf_SaveValueChanged, this );
	m_saveType3.CallOnChangeWithDelegate( WebSurf_SaveValueChanged, this );
	m_saveType4.CallOnChangeWithDelegate( WebSurf_SaveValueChanged, this );
	m_saveType5.CallOnChangeWithDelegate( WebSurf_SaveValueChanged, this );

	m_savePanel.Add(m_saveType0);
	m_savePanel.Add(m_saveType1);
	m_savePanel.Add(m_saveType2);
	m_savePanel.Add(m_saveType3);
	m_savePanel.Add(m_saveType4);
	m_savePanel.Add(m_saveType5);
	m_savePanel.Add(m_saveItem);
}



void
vguiApp_WebSurf::InitSharePanel(void)
{
	/* set up the poster size/sharing window */

	m_sharePanel = spawn(vguiPanel);
	m_sharePanel.SetTitle( "Share Item" );
	m_sharePanel.SetSize( [128,200] );
	m_sharePanel.SetIcon( "gfx/icon16/transmit" );
	m_sharePanel.SetPos(GetPos() + GetSize());

	m_shareType0 = spawn(vguiRadio);
	m_shareType0.SetTitle( "Web" );
	m_shareType0.SetSize( '96 16' );
	m_shareType0.SetPos( [8,32] );

	m_shareType1 = spawn(vguiRadio);
	m_shareType1.SetTitle( "Texts" );
	m_shareType1.SetSize( '96 16' );
	m_shareType1.SetPos( [8,32 + 20] );
	m_shareType1.SetValue( TRUE );

	m_shareType2 = spawn(vguiRadio);
	m_shareType2.SetTitle( "Video" );
	m_shareType2.SetSize( '96 16' );
	m_shareType2.SetPos( [8,32 + 20+20] );

	m_shareType3 = spawn(vguiRadio);
	m_shareType3.SetTitle( "Audio" );
	m_shareType3.SetSize( '96 16' );
	m_shareType3.SetPos( [8,32 + 20+20+20] );

	m_shareType4 = spawn(vguiRadio);
	m_shareType4.SetTitle( "Software" );
	m_shareType4.SetSize( '96 16' );
	m_shareType4.SetPos( [8,32 + 20+20+20+20]);

	m_shareType5 = spawn(vguiRadio);
	m_shareType5.SetTitle( "Images" );
	m_shareType5.SetSize( '96 16' );
	m_shareType5.SetPos( [8,32 + 20+20+20+20+20] );

	m_shareType0.CallOnChangeWithDelegate( WebSurf_ShareValueChanged, this );
	m_shareType1.CallOnChangeWithDelegate( WebSurf_ShareValueChanged, this );
	m_shareType2.CallOnChangeWithDelegate( WebSurf_ShareValueChanged, this );
	m_shareType3.CallOnChangeWithDelegate( WebSurf_ShareValueChanged, this );
	m_shareType4.CallOnChangeWithDelegate( WebSurf_ShareValueChanged, this );
	m_shareType5.CallOnChangeWithDelegate( WebSurf_ShareValueChanged, this );

	m_shareType0.CallOnPressedWithDelegate( WebSurf_ShareValue, this );
	m_shareType1.CallOnPressedWithDelegate( WebSurf_ShareValue, this );
	m_shareType2.CallOnPressedWithDelegate( WebSurf_ShareValue, this );
	m_shareType3.CallOnPressedWithDelegate( WebSurf_ShareValue, this );
	m_shareType4.CallOnPressedWithDelegate( WebSurf_ShareValue, this );
	m_shareType5.CallOnPressedWithDelegate( WebSurf_ShareValue, this );

	m_sharePanel.Add(m_shareType0);
	m_sharePanel.Add(m_shareType1);
	m_sharePanel.Add(m_shareType2);
	m_sharePanel.Add(m_shareType3);
	m_sharePanel.Add(m_shareType4);
	m_sharePanel.Add(m_shareType5);
}

void
vguiApp_WebSurf::Spawned(void)
{
	super::Spawned();

	classname = "vguiWindow";
	SetTitle( "WebSurf" );
	SetSize( [480,320] );
	SetMaxSize( [9999,9999] );
	SetIcon( "gfx/icon16/html" );
	SetStyleMask( vguiWindowStyleDefault | vguiWindowResizeable );
	CallOnResize(WebSurf_Resized);

	webView = spawn( vguiWebView );
	webView.SetSize( [480-16-21, 320-64] );
	webView.SetPos( [8, 32+24+24] );

	btnGo = spawn( vguiButton );
	btnGo.SetIcon( "gfx/icon16/world" );
	btnGo.SetSize([24,24]);
	btnGo.SetFuncWithDelegate( WebSurf_Navigate, this );

	btnBack = spawn( vguiButton );
	btnBack.SetIcon( "gfx/icon16/arrow_left" );
	btnBack.SetSize([24,24]);
	btnBack.SetFuncWithDelegate( WebSurf_Back, this );

	btnBookmark1 = spawn( vguiButton );
	btnBookmark1.SetTitle("Archive");
	btnBookmark1.SetIcon( "gfx/icon16/bullet_blue" );
	btnBookmark1.SetFuncWithDelegate( WebSurf_Bookmark1, this );

	btnBookmark2 = spawn( vguiButton );
	btnBookmark2.SetTitle("Gutenberg");
	btnBookmark2.SetIcon( "gfx/icon16/bullet_white" );
	btnBookmark2.SetFuncWithDelegate( WebSurf_Bookmark2, this );

	btnBookmark3 = spawn( vguiButton );
	btnBookmark3.SetTitle("Wikimedia");
	btnBookmark3.SetIcon( "gfx/icon16/bullet_green" );
	btnBookmark3.SetFuncWithDelegate( WebSurf_Bookmark3, this );

	btnBookmark4 = spawn( vguiButton );
	btnBookmark4.SetTitle("World History");
	btnBookmark4.SetIcon( "gfx/icon16/bullet_orange" );
	btnBookmark4.SetFuncWithDelegate( WebSurf_Bookmark4, this );

	btnFwd = spawn( vguiButton );
	btnFwd.SetIcon( "gfx/icon16/arrow_right" );
	btnFwd.SetSize([24,24]);
	btnFwd.SetFuncWithDelegate( WebSurf_Forward, this );

	btnReload = spawn( vguiButton );
	btnReload.SetIcon( "gfx/icon16/arrow_refresh" );
	btnReload.SetSize([24,24]);
	btnReload.SetFuncWithDelegate( WebSurf_Reload, this );

	addressField = spawn( vguiTextBox );
	addressField.SetSize([192-24-4,24]);
	addressField.CallOnEnterWithDelegate(WebSurf_Navigate, this);

	webView.CallOnPageUpdateWithDelegate(WebSurf_PageUpdated, this);

	btnSave = spawn( vguiButton );
	btnSave.SetIcon( "gfx/icon16/disk" );
	btnSave.SetSize([24,24]);
	btnSave.SetFuncWithDelegate( WebSurf_OpenSavePanel, this );

	btnShare = spawn( vguiButton );
	btnShare.SetIcon( "gfx/icon16/transmit" );
	btnShare.SetSize([24,24]);
	btnShare.SetFuncWithDelegate( WebSurf_OpenSharePanel, this );

	Add( webView );
	Add( btnSave );
	Add( btnShare );
	Add( btnGo );
	Add( btnBack );
	Add( btnFwd );
	Add( btnReload );
	Add( addressField );

	Add( btnBookmark1 );
	Add( btnBookmark2 );
	Add( btnBookmark3 );
	Add( btnBookmark4 );

	WebSurf_Resized();

	InitSavePanel();
	InitSharePanel();

	addressField.SetText( "https://www.archive.org/" );
	WebSurf_Navigate();
}
