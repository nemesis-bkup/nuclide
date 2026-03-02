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
vguiTool_Gopher:vguiWindow
{
	void vguiTool_Gopher(void);

	virtual void Spawned(void);

	nonvirtual void AddText(int queryID, string);
	nonvirtual void AddEntry(string, string, string, string, string);
	nonvirtual void AddGopherLine(string, string, string, string, string);
	nonvirtual void GopherBrowser_Go(void);
	nonvirtual void GopherBrowser_ScrollUpdate(void);
	nonvirtual void GopherBrowser_ListUpdate(void);
	nonvirtual void GopherBrowser_Clear(void);

private:

	vguiImageList lsbIcons;
	vguiList lsbEntries;
	vguiList lsbCommands;
	vguiList lsbHosts;
	vguiList lsbPorts;
	vguiScrollBar scrlSong;
	vguiButton btnGo;
	vguiTextBox addressField;
	bool m_isConnected;
	vguiTextPrompt searchPrompt;

	float m_lastTextID;
	vguiTextViewPanel m_lastTextPanel;

	int m_selectedEntry;
};

void
vguiTool_Gopher::vguiTool_Gopher(void)
{
	m_isConnected = false;
	m_lastTextID = 0;
	m_selectedEntry = 0i;
}

void
vguiTool_Gopher::AddEntry(string type, string text, string selectorString, string targetHost, string targetPort)
{
	lsbIcons.AddItem( type );
	lsbEntries.AddItem( text );
	lsbCommands.AddItem( selectorString );
	lsbHosts.AddItem( targetHost );
	lsbPorts.AddItem( targetPort );
}

void
vguiTool_Gopher::AddText(int queryID, string lineString)
{
	if (m_lastTextID != queryID) {
		m_lastTextPanel = spawn(vguiTextViewPanel);
		m_lastTextID = queryID;
		m_parent.Add( m_lastTextPanel );

		m_lastTextPanel.SetIcon(lsbIcons.GetItem(lsbCommands.GetSelected()));
		m_lastTextPanel.SetTitle(lsbEntries.GetItem(lsbCommands.GetSelected()));
	}

	if (!m_lastTextPanel) {
		return;
	}

	m_lastTextPanel.textView.AddLine(strcat("^x000", lineString));
}

void
vguiTool_Gopher::AddGopherText(int queryID, string textNum)
{
	for (vguiWindow findWindows = 0; (findWindows = (vguiWindow)find(findWindows, ::classname, "vguiWindow"));) {
		if (findWindows.m_strTitle == "Gopher") {
				vguiTool_Gopher gopherWindow = (vguiTool_Gopher)findWindows;
				gopherWindow.AddText(queryID, textNum);
		}
	}
}

void
vguiTool_Gopher::AddGopherLine(string typeNum, string text, string selectorString, string targetHost, string targetPort)
{
	string imageIcon;

	switch (typeNum) {
	case "0": /* text file */
		imageIcon = "gfx/icon16/page_white_text";
		break;
	case "1": /* dir entry */
		imageIcon = "gfx/icon16/folder";
		break;
	case "5": /* binary file */
		imageIcon = "gfx/icon16/application";
		break;
	case "9": /* binary file */
		imageIcon = "gfx/icon16/application";
		break;
	case "7": /* remote copy */
		imageIcon = "gfx/icon16/find";
		break;
	case "+": /* remote copy */
		imageIcon = "gfx/icon16/copy";
		break;
	case "g": /* gif */
		imageIcon = "gfx/icon16/film";
		break;
	case "I": /* image */
		imageIcon = "gfx/icon16/monitor";
		break;
	default:
		imageIcon = "gfx/icon16/empty";
		break;
	}

	if (!STRING_SET(text)) {
		text = "    ";
	}

	if (!STRING_SET(selectorString)) {
		selectorString = "    ";
	}

	for (vguiWindow findWindows = 0; (findWindows = (vguiWindow)find(findWindows, ::classname, "vguiWindow"));) {
		if (findWindows.m_strTitle == "Gopher") {
				vguiTool_Gopher gopherWindow = (vguiTool_Gopher)findWindows;
				gopherWindow.AddEntry(imageIcon, text, selectorString, targetHost, targetPort);
		}
	}
}

void
vguiTool_Gopher::GopherBrowser_Go(void)
{
	GopherBrowser_Clear();
	localcmd(sprintf("gopherVisit %s\n", addressField.GetText()));
}

void
vguiTool_Gopher::GopherBrowser_Clear(void)
{
	lsbIcons.RemoveAllItems();
	lsbEntries.RemoveAllItems();
	lsbCommands.RemoveAllItems();
	lsbHosts.RemoveAllItems();
	lsbPorts.RemoveAllItems();

	lsbIcons.SetItemCount( 90 );
	lsbCommands.SetItemCount( 90 );
	lsbEntries.SetItemCount( 90 );
	lsbHosts.SetItemCount( 90 );
	lsbPorts.SetItemCount( 90 );

	scrlSong.SetValue( 0 );
	lsbIcons.SetOffset( scrlSong.GetValue(), FALSE );
	lsbEntries.SetOffset( scrlSong.GetValue(), FALSE );
	lsbCommands.SetOffset( scrlSong.GetValue(), FALSE );
	lsbHosts.SetOffset( scrlSong.GetValue(), FALSE );
	lsbPorts.SetOffset( scrlSong.GetValue(), FALSE );
}

void
vguiTool_Gopher::GopherBrowser_SearchQuery(vguiWidget sender)
{
	vguiTextPrompt lastPrompt = (vguiList)sender;
	string searchString = lastPrompt.textBox.GetText();
	string targetHost = lsbHosts.GetItem(m_selectedEntry);
	string commandItem = lsbCommands.GetItem(m_selectedEntry);
	string targetPort = lsbPorts.GetItem(m_selectedEntry);

	GopherBrowser_Clear();
	localcmd(sprintf("gopherQuery %S %S %S %S\n", targetHost, targetPort, commandItem, searchString));
}

void
vguiTool_Gopher::GopherBrowser_EntryClicked(vguiWidget sender)
{
	vguiList listSender = (vguiList)sender;
	string commandType = lsbIcons.GetItem(m_selectedEntry);
	string commandItem = lsbCommands.GetItem(m_selectedEntry);
	string targetHost = lsbHosts.GetItem(m_selectedEntry);
	string targetPort = lsbPorts.GetItem(m_selectedEntry);

	if (commandType == "gfx/icon16/folder") {
		GopherBrowser_Clear();
		localcmd(sprintf("gopherQuery %S %S %S %S\n", targetHost, targetPort, commandItem, ""));
	} else if (commandType == "gfx/icon16/find") {
		if (!searchPrompt) {
			searchPrompt = spawn( vguiTextPrompt );
			m_parent.Add( searchPrompt );
			searchPrompt.SetOKAction(GopherBrowser_SearchQuery, this);
			searchPrompt.SetIcon("gfx/icon16/find");
			searchPrompt.SetTitle(lsbEntries.GetItem(listSender.GetSelected()));
			searchPrompt.SetPos(GetPos() + (GetSize() / 2) - (searchPrompt.GetSize() / 2));
		} else {
			searchPrompt.Show();
			searchPrompt.NowVisible();
		}
	} else if (commandType == "gfx/icon16/page_white_text") {
		localcmd(sprintf("gopherText %S %S %S %S\n", targetHost, targetPort, commandItem, ""));
	}
}

void
vguiTool_Gopher::GopherBrowser_ScrollUpdate(void)
{
	scrlSong.SetValue( lsbEntries.GetOffset() );
	lsbIcons.SetOffset( scrlSong.GetValue(), FALSE );
	lsbEntries.SetOffset( scrlSong.GetValue(), FALSE );
	lsbCommands.SetOffset( scrlSong.GetValue(), FALSE);
	lsbPorts.SetOffset( scrlSong.GetValue(), FALSE );
	lsbHosts.SetOffset( scrlSong.GetValue(), FALSE );
}

void
vguiTool_Gopher::Gopher_Resized(void)
{
	vector windowSize = GetSize();
	lsbIcons.SetSize( [32, windowSize[1]-64] );
	lsbEntries.SetSize( [windowSize[0]-16-21-32, windowSize[1]-64] );
	scrlSong.SetLength( windowSize[1]-64 );
	scrlSong.SetPos( [windowSize[0]-21,32] );

	btnGo.SetPos( [8,windowSize[1]-28] );
	addressField.SetPos( [96-16,windowSize[1]-28] );
}

void
vguiTool_Gopher::GopherBrowser_SelectionChanged(vguiWidget sender)
{
	vguiList listSender = (vguiList)sender;
	int value = listSender.GetSelected();
	lsbIcons.SetSelected( value );
	lsbEntries.SetSelected( value );
	lsbCommands.SetSelected( value );
	lsbPorts.SetSelected( value );
	lsbHosts.SetSelected( value );
	m_selectedEntry = value;
}

void
vguiTool_Gopher::GopherBrowser_ListUpdate(void)
{
	lsbIcons.SetOffset( scrlSong.GetValue(), FALSE );
	lsbEntries.SetOffset( scrlSong.GetValue(), FALSE );
	lsbCommands.SetOffset( scrlSong.GetValue(), FALSE );
	lsbPorts.SetOffset( scrlSong.GetValue(), FALSE );
	lsbHosts.SetOffset( scrlSong.GetValue(), FALSE );
}

void
vguiTool_Gopher::Spawned(void)
{
	super::Spawned();

	classname = "vguiWindow";
	SetTitle( "Gopher" );
	SetSize( [480,320] );
	SetIcon( "gfx/icon16/sitemap_color" );
	SetStyleMask( vguiWindowStyleDefault | vguiWindowResizeable );
	CallOnResize(Gopher_Resized);

	lsbCommands = spawn( vguiList );
	lsbHosts = spawn( vguiList );
	lsbPorts = spawn( vguiList );

	lsbIcons = spawn( vguiImageList );
	lsbIcons.SetSize( [32, 320-64] );
	lsbIcons.SetPos( [8, 32] );
	lsbIcons.CallOnScrollWithDelegate( GopherBrowser_ScrollUpdate, this );
	lsbIcons.CallOnSelectionChangedWithDelegate(GopherBrowser_SelectionChanged, this);

	lsbEntries = spawn( vguiList );
	lsbEntries.SetSize( [480-16-21-32, 320-64] );
	lsbEntries.SetPos( [8 + 32, 32] );
	lsbEntries.CallOnDoubleClickWithDelegate( GopherBrowser_EntryClicked, this );
	lsbEntries.CallOnScrollWithDelegate( GopherBrowser_ScrollUpdate, this );
	lsbEntries.CallOnSelectionChangedWithDelegate(GopherBrowser_SelectionChanged, this);

	scrlSong = spawn( vguiScrollBar );
	scrlSong.SetLength( 320-64 );
	scrlSong.SetPos( [480-21,32] );
	scrlSong.SetMin( 0 );
	scrlSong.SetStep( 1 );
	scrlSong.CallOnChangeWithDelegate( GopherBrowser_ListUpdate, this );

	btnGo = spawn( vguiButton );
	btnGo.SetTitle( "Go" );
	btnGo.SetIcon( "gfx/icon16/control_play" );
	btnGo.SetPos( [8,320-28] );
	btnGo.SetSize([64,24]);
	btnGo.SetFuncWithDelegate( GopherBrowser_Go, this );

	addressField = spawn( vguiTextBox );
	addressField.SetText( "tcp://gopher.floodgap.com:70/" );
	addressField.SetPos( [96-16,320-28] );
	addressField.SetSize([192,24]);

	scrlSong.SetMax( 100 );

	Add( lsbIcons );
	Add( lsbEntries );
	Add( scrlSong );
	Add( btnGo );
	Add( addressField );
}
