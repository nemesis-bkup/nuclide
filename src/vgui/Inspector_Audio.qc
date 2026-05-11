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
vguiDesktopAppAudioPlayer:vguiWindow
{
    void vguiDesktopAppAudioPlayer(void);

    virtual void Spawned(void);

private:

    vguiList lsbTitles;
    vguiList lsbIDs;
    vguiScrollBar scrlSong;
    vguiButton btnURL;
    vguiButton btnLibrary;
    vguiButton btnShare;
    vguiPic preview;
    vguiFrame m_outlineFrame;
    vector m_imageAspect;

    vguiTextPrompt urlPrompt;
    vguiWindow m_libraryWindow;
};

void
vguiDesktopAppAudioPlayer::vguiDesktopAppAudioPlayer(void)
{
}


void
vguiDesktopAppAudioPlayer::AudioPlayer_Share(void)
{
    string videoFile = lsbIDs.GetItem(lsbTitles.GetSelected());
    ncDict videoDict = ncDict::LoadDeclFromFile(videoFile, sprintf("audio/%s.audio", videoFile));
    videoFile = videoDict.GetString("audio");
    string videoName = videoDict.GetString("name");
    string videoPreview = videoDict.GetString("preview");
    localcmd(sprintf("cmd shareAudio %S %S %S\n", videoName, videoFile, videoPreview));
}

void
vguiDesktopAppAudioPlayer::AudioPlayer_URLOpened(vguiWidget sender)
{
    vguiTextPrompt lastPrompt = (vguiList)sender;
    string searchString = lastPrompt.textBox.GetText();
    preview.SetImage(searchString);
}


void
vguiDesktopAppAudioPlayer::AudioPlayer_Library(void)
{
    vector windowSize = GetSize();

    if (!m_libraryWindow.m_parent) {
        m_parent.Add(m_libraryWindow);
    }

    m_libraryWindow.Show();
    m_libraryWindow.SetPos(GetPos() + [0, windowSize[1]]);
}

void
vguiDesktopAppAudioPlayer::AudioPlayer_URL(void)
{
    if (!urlPrompt) {
        urlPrompt = spawn( vguiTextPrompt );
        m_parent.Add( urlPrompt );
        urlPrompt.SetOKAction(AudioPlayer_URLOpened, this);
        urlPrompt.SetIcon("gfx/icon16/world");
        urlPrompt.SetTitle("Open Remote URL");
        urlPrompt.SetPos(GetPos() + (GetSize() / 2) - (urlPrompt.GetSize() / 2));
        } else {
        urlPrompt.Show();
        urlPrompt.NowVisible();
    }
}

void
vguiDesktopAppAudioPlayer::AudioPlayer_ScrollUpdate(void)
{
    scrlSong.SetValue( lsbTitles.GetOffset() );
}

void
vguiDesktopAppAudioPlayer::AudioPlayer_ListUpdate(void)
{
    lsbTitles.SetOffset( scrlSong.GetValue(), FALSE );
}

void
vguiDesktopAppAudioPlayer::AudioPlayer_Resized(void)
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
    SetSize([frameSize[0] + 20, frameSize[1]+34+32]);
    windowSize = GetSize();

    btnLibrary.SetPos( [8+24+2+24+2,windowSize[1]-28] );
    btnURL.SetPos( [8+24+2+24+2+24+2,windowSize[1]-28] );
    btnShare.SetPos( [8+24+2+24+2+24+2+24+2,windowSize[1]-28] );

    /* wider than higher */
    if (m_imageAspect[0] > m_imageAspect[1])
        preview.SetSize([frameSize[0] * m_imageAspect[0], frameSize[0] * m_imageAspect[1]]);
    else /* taller than wider */
        preview.SetSize([frameSize[1] * m_imageAspect[0], frameSize[1] * m_imageAspect[1]]);
}

void
vguiDesktopAppAudioPlayer::AudioPlayer_SelectionChanged(void)
{
    string videoFile = lsbIDs.GetItem(lsbTitles.GetSelected());
    ncDict videoDict = ncDict::LoadDeclFromFile(videoFile, sprintf("audio/%s.audio", videoFile));
    videoFile = videoDict.GetString("preview");
    m_imageAspect = [1,1];

    /* 2d normalize */
    if (m_imageAspect[0] > m_imageAspect[1]) {
        m_imageAspect[0] = 1.0f;
        m_imageAspect[1] = m_imageAspect[1] / m_imageAspect[0];
    } else {
        m_imageAspect[0] = m_imageAspect[0] / m_imageAspect[1];
        m_imageAspect[1] = 1.0f;
    }

    preview.SetImage(videoFile);
    preview.Show();
    AudioPlayer_Resized();
}

void
vguiDesktopAppAudioPlayer::AudioPlayer_LibraryResized(void)
{
}

void
vguiDesktopAppAudioPlayer::Spawned(void)
{
    super::Spawned();

    classname = "vguiWindow";
    SetTitle( "Audio Player" );
    SetSize( [160+16,140+32] );
    SetIcon( "gfx/icon16/music" );
    SetStyleMask( vguiWindowStyleDefault | vguiWindowResizeable );
    CallOnResize(AudioPlayer_Resized);

    /* library window */
    m_libraryWindow = spawn(vguiWindow);
    m_libraryWindow.Hide();
    m_libraryWindow.SetTitle( "Audio Library" );
    m_libraryWindow.SetSize( [320+16,120+32] );
    m_libraryWindow.SetIcon( "gfx/icon16/book_open" );

    m_outlineFrame = spawn(vguiFrame);
    m_outlineFrame.SetPos([8,32]);
    m_outlineFrame.SetSize([160,120]);

    searchhandle shSearchPicLibrary = search_begin( "decls/audio/*.audio", SEARCH_NAMESORT | SEARCH_MULTISEARCH, TRUE );
    searchhandle shSearchPicPlayer = search_begin( "data/players/Default/decls/audio/*.audio", SEARCH_NAMESORT | SEARCH_MULTISEARCH, TRUE );
    lsbTitles = spawn( vguiList );
    lsbTitles.SetSize( [320 - 16-21, 96] );
    lsbTitles.SetPos( [8, 32] );
    lsbTitles.SetItemCount( search_getsize( shSearchPicPlayer ) + search_getsize( shSearchPicLibrary ) );
    lsbTitles.CallOnScrollWithDelegate( AudioPlayer_ScrollUpdate, this );
    lsbTitles.CallOnSelectionChangedWithDelegate( AudioPlayer_SelectionChanged, this);

    lsbIDs = spawn( vguiList );
    lsbIDs.SetItemCount( search_getsize( shSearchPicLibrary ) + search_getsize( shSearchPicPlayer ) );

    for ( int i = 0; i < search_getsize( shSearchPicPlayer ); i++ ) {
        string dictName = substring(search_getfilename( shSearchPicPlayer, i ), 33, -7);
        ncDict videoDict = ncDict::LoadDeclFromFile(dictName, sprintf("audio/%s.audio", dictName));
        lsbIDs.AddItem( dictName );

        string videoName = videoDict.GetString("name");

        if (!STRING_SET(videoName))
            lsbTitles.AddItem( dictName );
        else
            lsbTitles.AddItem( videoName );
    }

    for ( int i = 0; i < search_getsize( shSearchPicLibrary ); i++ ) {
        string dictName = substring(search_getfilename( shSearchPicLibrary, i ), 12, -7);
        ncDict videoDict = ncDict::LoadDeclFromFile(dictName, sprintf("audio/%s.audio", dictName));
        lsbIDs.AddItem( dictName );

        string videoName = videoDict.GetString("name");

        if (!STRING_SET(videoName))
            lsbTitles.AddItem( dictName );
        else
            lsbTitles.AddItem( videoName );
    }
    search_end( shSearchPicLibrary );
    search_end( shSearchPicPlayer );

    preview = spawn( vguiPic );
    preview.SetPos( [8,32] );

    scrlSong = spawn( vguiScrollBar );
    scrlSong.SetLength( 96 );
    scrlSong.SetPos( [320-8-21,32] );
    scrlSong.SetMin( 0 );
    scrlSong.SetStep( 1 );
    scrlSong.SetMax( lsbTitles.GetMaxVisibleItems() );
    scrlSong.CallOnChangeWithDelegate( AudioPlayer_ListUpdate, this );

    btnLibrary = spawn( vguiButton );
    btnLibrary.SetIcon( "gfx/icon16/book_open" );
    btnLibrary.SetSize([24,24]);
    btnLibrary.SetFuncWithDelegate( AudioPlayer_Library, this );

    btnURL = spawn( vguiButton );
    btnURL.SetIcon( "gfx/icon16/world_go" );
    btnURL.SetSize([24,24]);
    btnURL.SetFuncWithDelegate( AudioPlayer_URL, this );

    btnShare = spawn( vguiButton );
    btnShare.SetIcon( "gfx/icon16/building" );
    btnShare.SetSize([24,24]);
    btnShare.SetFuncWithDelegate( AudioPlayer_Share, this );

    m_libraryWindow.Add( lsbTitles );
    m_libraryWindow.Add( scrlSong );

    Add( m_outlineFrame );
    Add( preview );
    Add( btnLibrary );
    Add( btnURL );
    Add( btnShare );

    preview.Show();

    lsbTitles.SetSelected(0);
    AudioPlayer_SelectionChanged();
    AudioPlayer_Resized();
}
