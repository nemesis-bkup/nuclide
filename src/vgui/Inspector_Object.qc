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

class
vguiDesktopAppObjects:vguiWindow
{
    void vguiDesktopAppObjects(void);

    virtual void Spawned(void);

private:

    vguiList lsbTitles;
    vguiList lsbIDs;
    vguiScrollBar scrlSong;
    vguiButton btnPlay;
    vguiButton btnStop;
    vguiButton btnURL;
    vguiButton btnLibrary;
    vguiButton btnShare;
    vguiVideo object;
    vguiPic preview;
    vguiFrame m_outlineFrame;

    vguiTextPrompt urlPrompt;
    vguiWindow m_libraryWindow;
};

void
vguiDesktopAppObjects::vguiDesktopAppObjects(void)
{
}

void
vguiDesktopAppObjects::ObjectInventory_Play(void)
{
    bool useFFMPEG = false;
    string objectFile = lsbIDs.GetItem(lsbTitles.GetSelected());
    ncDict objectDict = ncDict::LoadDeclFromFile(objectFile, sprintf("objects/%s.object", objectFile));

    objectFile = objectDict.GetString("model");


    //object.SetModel(objectFile);
    preview.Hide();
    object.Show();
}


void
vguiDesktopAppObjects::ObjectInventory_Share(void)
{
    bool useFFMPEG = false;
    string objectName = lsbIDs.GetItem(lsbTitles.GetSelected());
    ncDict objectDict = ncDict::LoadDeclFromFile(objectName, sprintf("objects/%s.object", objectName));
    string objectTitle = objectDict.GetString("name");
    string objectPreview = objectDict.GetString("preview");
    string objectFile = objectDict.GetString("model");
    string colorMod = objectDict.GetString("color");
    string scaleMod = objectDict.GetString("scale");
    string newMins = objectDict.GetString("mins");
    string newMaxs = objectDict.GetString("maxs");
    string gui64 = objectDict.GetString("gui_base64");
    string guiOrg = objectDict.GetString("gui_origin");
    string guiAng = objectDict.GetString("gui_angle");
    string guiScale = objectDict.GetString("gui_scale");
    string guiRes = objectDict.GetString("gui_res");

    if (!STRING_SET(colorMod)) {
        colorMod = "1 1 1";
    }

    if (!STRING_SET(scaleMod)) {
        scaleMod = "1";
    }

    if (!STRING_SET(newMins)) {
        newMins = "-16 -16 0";
    }

    if (!STRING_SET(newMaxs)) {
        newMaxs = "16 16 16";
    }

    localcmd(sprintf("cmd shareObject %S %S %S %S %S %S %S %S %S %S %S\n", objectName, objectFile, colorMod, scaleMod, newMins, newMaxs, gui64, guiOrg, guiAng, guiScale, guiRes));
}

void
vguiDesktopAppObjects::ObjectInventory_Stop(void)
{
    preview.Show();
    object.Hide();
    object.Stop();
}

void
vguiDesktopAppObjects::ObjectInventory_URLOpened(vguiWidget sender)
{
    vguiTextPrompt lastPrompt = (vguiList)sender;
    string searchString = lastPrompt.textBox.GetText();
    object.SetVideoURL(searchString);
}


void
vguiDesktopAppObjects::ObjectInventory_Library(void)
{
    vector windowSize = GetSize();

    if (!m_libraryWindow.m_parent) {
        m_parent.Add(m_libraryWindow);
    }

    m_libraryWindow.Show();
    m_libraryWindow.SetPos(GetPos() + [0, windowSize[1]]);
}

void
vguiDesktopAppObjects::ObjectInventory_URL(void)
{
    if (!urlPrompt) {
        urlPrompt = spawn( vguiTextPrompt );
        m_parent.Add( urlPrompt );
        urlPrompt.SetOKAction(ObjectInventory_URLOpened, this);
        urlPrompt.SetIcon("gfx/icon16/world");
        urlPrompt.SetTitle("Open Remote URL");
        urlPrompt.SetPos(GetPos() + (GetSize() / 2) - (urlPrompt.GetSize() / 2));
        } else {
        urlPrompt.Show();
        urlPrompt.NowVisible();
    }
}

void
vguiDesktopAppObjects::ObjectInventory_ScrollUpdate(void)
{
    scrlSong.SetValue( lsbTitles.GetOffset() );
}

void
vguiDesktopAppObjects::ObjectInventory_ListUpdate(void)
{
    lsbTitles.SetOffset( scrlSong.GetValue(), FALSE );
}

void
vguiDesktopAppObjects::ObjectInventory_SelectionChanged(void)
{
    string objectFile = lsbIDs.GetItem(lsbTitles.GetSelected());
    ncDict objectDict = ncDict::LoadDeclFromFile(objectFile, sprintf("objects/%s.object", objectFile));
    objectFile = objectDict.GetString("preview");
    preview.SetImage(objectFile);
    preview.Show();
    object.Hide();
    object.Stop();
}

void
vguiDesktopAppObjects::ObjectInventory_LibraryResized(void)
{
}

void
vguiDesktopAppObjects::ObjectInventory_Resized(void)
{
    vector windowSize = GetSize();
    float scaleFactor = windowSize[0]/(160-16);
    vector frameSize;

    /* fill to width */
    frameSize[0] = (windowSize[0] - 16);
    frameSize[1] = (120-32) * scaleFactor;
    m_outlineFrame.SetSize(frameSize);

    preview.SetPos(m_outlineFrame.GetPos() + [2,2]);
    frameSize = m_outlineFrame.GetSize() - [4,4];
    preview.SetSize(frameSize);
    object.SetSize(frameSize);

    SetSize([frameSize[0] + 20, frameSize[1]+34+32]);

    btnPlay.SetPos( [8,GetHeight()-28] );
    btnStop.SetPos(btnPlay.GetPos() + [btnPlay.GetWidth(), 0] );
    btnLibrary.SetPos(btnStop.GetPos() + [btnStop.GetWidth(), 0] );
    btnURL.SetPos(btnLibrary.GetPos() + [btnLibrary.GetWidth(), 0] );
    btnShare.SetPos(btnURL.GetPos() + [btnURL.GetWidth(), 0] );

}

void
vguiDesktopAppObjects::Spawned(void)
{
    super::Spawned();

    classname = "vguiWindow";
    SetTitle( "Object Inventory" );
    SetSize( [160+16,140+32] );
    SetIcon( "gfx/icon16/box" );
    SetStyleMask( vguiWindowStyleDefault | vguiWindowResizeable );
    CallOnResize(ObjectInventory_Resized);

    /* library window */
    m_libraryWindow = spawn(vguiWindow);
    m_libraryWindow.Hide();
    m_libraryWindow.SetTitle( "Object Library" );
    m_libraryWindow.SetSize( [320+16,120+32] );
    m_libraryWindow.SetIcon( "gfx/icon16/book_open" );

    m_outlineFrame = spawn(vguiFrame);
    m_outlineFrame.SetPos([8,32]);
    m_outlineFrame.SetSize([160,120]);

    searchhandle shSearchVideoLibrary = search_begin( "decls/objects/*.object", SEARCH_NAMESORT | SEARCH_MULTISEARCH, TRUE );
    searchhandle shSearchObjectInventory = search_begin( "data/players/Default/decls/objects/*.object", SEARCH_NAMESORT | SEARCH_MULTISEARCH, TRUE );
    lsbTitles = spawn( vguiList );
    lsbTitles.SetSize( [320 - 16-21, 96] );
    lsbTitles.SetPos( [8, 32] );
    lsbTitles.SetItemCount( search_getsize( shSearchObjectInventory ) + search_getsize( shSearchVideoLibrary )  );
    lsbTitles.CallOnScrollWithDelegate( ObjectInventory_ScrollUpdate, this );
    lsbTitles.CallOnSelectionChangedWithDelegate( ObjectInventory_SelectionChanged, this);

    lsbIDs = spawn( vguiList );
    lsbIDs.SetItemCount( search_getsize( shSearchObjectInventory ) + search_getsize( shSearchVideoLibrary ) );

    for ( int i = 0; i < search_getsize( shSearchObjectInventory ); i++ ) {
        string dictName = substring(search_getfilename( shSearchObjectInventory, i ), 35, -8);
        ncDict objectDict = ncDict::LoadDeclFromFile(dictName, sprintf("objects/%s.object", dictName));
        lsbIDs.AddItem( dictName);
        string objectName = objectDict.GetString("name");

        if (!STRING_SET(objectName))
            lsbTitles.AddItem( dictName );
        else
            lsbTitles.AddItem( objectName );
    }

    for ( int i = 0; i < search_getsize( shSearchVideoLibrary ); i++ ) {
        string dictName = substring(search_getfilename( shSearchVideoLibrary, i ), 14, -8);
        ncDict objectDict = ncDict::LoadDeclFromFile(dictName, sprintf("objects/%s.object", dictName));
        ncDict objectDict = ncDict::LoadDeclFromFile(dictName, sprintf("objects/%s.video", dictName));
        lsbIDs.AddItem( dictName);

        string objectName = objectDict.GetString("name");

        if (!STRING_SET(objectName))
            lsbTitles.AddItem( dictName );
        else
            lsbTitles.AddItem( objectName );
    }

    object = spawn( vguiVideo );
    object.SetPos( m_outlineFrame.GetPos() + [2,2] );

    preview = spawn( vguiPic );
    preview.SetPos( m_outlineFrame.GetPos() + [2,2] );

    scrlSong = spawn( vguiScrollBar );
    scrlSong.SetLength( 96 );
    scrlSong.SetPos( [320-8-21,32] );
    scrlSong.SetMin( 0 );
    scrlSong.SetStep( 1 );
    scrlSong.SetMax( lsbTitles.GetMaxVisibleItems() );
    scrlSong.CallOnChangeWithDelegate( ObjectInventory_ListUpdate, this );

    btnPlay = spawn( vguiButton );
    btnPlay.SetIcon( "gfx/icon16/control_play" );
    btnPlay.SetSize([24,24]);
    btnPlay.SetFuncWithDelegate( ObjectInventory_Play, this );

    btnStop = spawn( vguiButton );
    btnStop.SetIcon( "gfx/icon16/control_stop" );
    btnStop.SetSize([24,24]);
    btnStop.SetFuncWithDelegate( ObjectInventory_Stop, this );

    btnLibrary = spawn( vguiButton );
    btnLibrary.SetIcon( "gfx/icon16/book_open" );
    btnLibrary.SetSize([24,24]);
    btnLibrary.SetFuncWithDelegate( ObjectInventory_Library, this );

    btnURL = spawn( vguiButton );
    btnURL.SetIcon( "gfx/icon16/world_go" );
    btnURL.SetSize([24,24]);
    btnURL.SetFuncWithDelegate( ObjectInventory_URL, this );

    btnShare = spawn( vguiButton );
    btnShare.SetIcon( "gfx/icon16/building" );
    btnShare.SetSize([24,24]);
    btnShare.SetFuncWithDelegate( ObjectInventory_Share, this );

    m_libraryWindow.Add( lsbTitles );
    m_libraryWindow.Add( scrlSong );

    Add( m_outlineFrame );
    Add( object );
    Add( preview );
    Add( btnPlay );
    Add( btnLibrary );
    Add( btnStop );
    Add( btnURL );
    Add( btnShare );
    search_end( shSearchVideoLibrary );

    object.Hide();
    preview.Show();

    lsbTitles.SetSelected(0);
    ObjectInventory_SelectionChanged();
    ObjectInventory_Resized();
}
