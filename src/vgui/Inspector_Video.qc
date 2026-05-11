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
vguiDesktopAppVideo:vguiWindow
{
    void vguiDesktopAppVideo(void);

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
    vguiVideo video;
    vguiPic preview;
    vguiFrame m_outlineFrame;

    vguiTextPrompt urlPrompt;
    vguiWindow m_libraryWindow;
};

void
vguiDesktopAppVideo::vguiDesktopAppVideo(void)
{
}

void
vguiDesktopAppVideo::VideoPlayer_Play(void)
{
    bool useFFMPEG = false;
    string videoFile = lsbIDs.GetItem(lsbTitles.GetSelected());
    ncDict videoDict = ncDict::LoadDeclFromFile(videoFile, sprintf("videos/%s.video", videoFile));

    videoFile = videoDict.GetString("video");

    if (substring(videoFile, 0, 5) == "http:") {
        useFFMPEG = true;
    } else if (substring(videoFile, 0, 6) == "https:") {
        useFFMPEG = true;
    } else if (substring(videoFile, 0, 5) == "rtmp:") {
        useFFMPEG = true;
    } else if (substring(videoFile, 0, 5) == "file:") {
        useFFMPEG = true;
    }

    if (useFFMPEG) {
        if ((checkcommand("ffmpeg_defaults") != 0)) {
            videoFile = strcat("avs:", videoFile);
        } else {
            ncError("Remote URL cannot be played without FTEQW's FFMPEG plugin");
        }
    }

    video.SetVideo(videoFile);
    preview.Hide();
    video.Show();
}


void
vguiDesktopAppVideo::VideoPlayer_Share(void)
{
    bool useFFMPEG = false;
    string videoName = lsbIDs.GetItem(lsbTitles.GetSelected());
    ncDict videoDict = ncDict::LoadDeclFromFile(videoName, sprintf("videos/%s.video", videoName));
    string videoTitle = videoDict.GetString("name");
    string videoPreview = videoDict.GetString("preview");
    string audioFile = videoDict.GetString("audio");
    string videoFile = videoDict.GetString("video");

    if (substring(videoFile, 0, 5) == "http:") {
        useFFMPEG = true;
    } else if (substring(videoFile, 0, 6) == "https:") {
        useFFMPEG = true;
    } else if (substring(videoFile, 0, 5) == "rtmp:") {
        useFFMPEG = true;
    } else if (substring(videoFile, 0, 5) == "file:") {
        useFFMPEG = true;
    }

    if (useFFMPEG) {
        if ((checkcommand("ffmpeg_defaults") != 0)) {
            videoFile = strcat("avs:", videoFile);
        } else {
            ncError("Remote URL cannot be played without FTEQW's FFMPEG plugin");
        }
    }

    string videoPreview = videoDict.GetString("preview");
    localcmd(sprintf("cmd shareVideo %S %S %S %S %S\n", videoName, videoTitle, videoPreview, videoFile, audioFile));
}

void
vguiDesktopAppVideo::VideoPlayer_Stop(void)
{
    preview.Show();
    video.Hide();
    video.Stop();
}

void
vguiDesktopAppVideo::VideoPlayer_URLOpened(vguiWidget sender)
{
    vguiTextPrompt lastPrompt = (vguiList)sender;
    string searchString = lastPrompt.textBox.GetText();
    video.SetVideoURL(searchString);
}


void
vguiDesktopAppVideo::VideoPlayer_Library(void)
{
    vector windowSize = GetSize();

    if (!m_libraryWindow.m_parent) {
        m_parent.Add(m_libraryWindow);
    }

    m_libraryWindow.Show();
    m_libraryWindow.SetPos(GetPos() + [0, windowSize[1]]);
}

void
vguiDesktopAppVideo::VideoPlayer_URL(void)
{
    if (!urlPrompt) {
        urlPrompt = spawn( vguiTextPrompt );
        m_parent.Add( urlPrompt );
        urlPrompt.SetOKAction(VideoPlayer_URLOpened, this);
        urlPrompt.SetIcon("gfx/icon16/world");
        urlPrompt.SetTitle("Open Remote URL");
        urlPrompt.SetPos(GetPos() + (GetSize() / 2) - (urlPrompt.GetSize() / 2));
        } else {
        urlPrompt.Show();
        urlPrompt.NowVisible();
    }
}

void
vguiDesktopAppVideo::VideoPlayer_ScrollUpdate(void)
{
    scrlSong.SetValue( lsbTitles.GetOffset() );
}

void
vguiDesktopAppVideo::VideoPlayer_ListUpdate(void)
{
    lsbTitles.SetOffset( scrlSong.GetValue(), FALSE );
}

void
vguiDesktopAppVideo::VideoPlayer_SelectionChanged(void)
{
    string videoFile = lsbIDs.GetItem(lsbTitles.GetSelected());
    ncDict videoDict = ncDict::LoadDeclFromFile(videoFile, sprintf("videos/%s.video", videoFile));
    videoFile = videoDict.GetString("preview");
    preview.SetImage(videoFile);
    preview.Show();
    video.Hide();
    video.Stop();
}

void
vguiDesktopAppVideo::VideoPlayer_LibraryResized(void)
{
}

void
vguiDesktopAppVideo::VideoPlayer_Resized(void)
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
    video.SetSize(frameSize);

    SetSize([frameSize[0] + 20, frameSize[1]+34+32]);

    btnPlay.SetPos( [8,GetHeight()-28] );
    btnStop.SetPos(btnPlay.GetPos() + [btnPlay.GetWidth(), 0] );
    btnLibrary.SetPos(btnStop.GetPos() + [btnStop.GetWidth(), 0] );
    btnURL.SetPos(btnLibrary.GetPos() + [btnLibrary.GetWidth(), 0] );
    btnShare.SetPos(btnURL.GetPos() + [btnURL.GetWidth(), 0] );

}

void
vguiDesktopAppVideo::Spawned(void)
{
    super::Spawned();

    classname = "vguiWindow";
    SetTitle( "Video Player" );
    SetSize( [160+16,140+32] );
    SetIcon( "gfx/icon16/film" );
    SetStyleMask( vguiWindowStyleDefault | vguiWindowResizeable );
    CallOnResize(VideoPlayer_Resized);

    /* library window */
    m_libraryWindow = spawn(vguiWindow);
    m_libraryWindow.Hide();
    m_libraryWindow.SetTitle( "Video Library" );
    m_libraryWindow.SetSize( [320+16,120+32] );
    m_libraryWindow.SetIcon( "gfx/icon16/book_open" );

    m_outlineFrame = spawn(vguiFrame);
    m_outlineFrame.SetPos([8,32]);
    m_outlineFrame.SetSize([160,120]);

    searchhandle shSearchVideoLibrary = search_begin( "decls/videos/*.video", SEARCH_NAMESORT | SEARCH_MULTISEARCH, TRUE );
    searchhandle shSearchVideoPlayer = search_begin( "data/players/Default/decls/videos/*.video", SEARCH_NAMESORT | SEARCH_MULTISEARCH, TRUE );
    lsbTitles = spawn( vguiList );
    lsbTitles.SetSize( [320 - 16-21, 96] );
    lsbTitles.SetPos( [8, 32] );
    lsbTitles.SetItemCount( search_getsize( shSearchVideoPlayer ) + search_getsize( shSearchVideoLibrary )  );
    lsbTitles.CallOnScrollWithDelegate( VideoPlayer_ScrollUpdate, this );
    lsbTitles.CallOnSelectionChangedWithDelegate( VideoPlayer_SelectionChanged, this);

    lsbIDs = spawn( vguiList );
    lsbIDs.SetItemCount( search_getsize( shSearchVideoPlayer ) + search_getsize( shSearchVideoLibrary ) );

    for ( int i = 0; i < search_getsize( shSearchVideoPlayer ); i++ ) {
        string dictName = substring(search_getfilename( shSearchVideoPlayer, i ), 34, -7);
        ncDict videoDict = ncDict::LoadDeclFromFile(dictName, sprintf("videos/%s.video", dictName));
        lsbIDs.AddItem( dictName);
        string videoName = videoDict.GetString("name");

        if (!STRING_SET(videoName))
            lsbTitles.AddItem( dictName );
        else
            lsbTitles.AddItem( videoName );
    }

    for ( int i = 0; i < search_getsize( shSearchVideoLibrary ); i++ ) {
        string dictName = substring(search_getfilename( shSearchVideoLibrary, i ), 13, -7);
        ncDict videoDict = ncDict::LoadDeclFromFile(dictName, sprintf("videos/%s.video", dictName));
        lsbIDs.AddItem( dictName);

        string videoName = videoDict.GetString("name");

        if (!STRING_SET(videoName))
            lsbTitles.AddItem( dictName );
        else
            lsbTitles.AddItem( videoName );
    }

    video = spawn( vguiVideo );
    video.SetPos( m_outlineFrame.GetPos() + [2,2] );

    preview = spawn( vguiPic );
    preview.SetPos( m_outlineFrame.GetPos() + [2,2] );

    scrlSong = spawn( vguiScrollBar );
    scrlSong.SetLength( 96 );
    scrlSong.SetPos( [320-8-21,32] );
    scrlSong.SetMin( 0 );
    scrlSong.SetStep( 1 );
    scrlSong.SetMax( lsbTitles.GetMaxVisibleItems() );
    scrlSong.CallOnChangeWithDelegate( VideoPlayer_ListUpdate, this );

    btnPlay = spawn( vguiButton );
    btnPlay.SetIcon( "gfx/icon16/control_play" );
    btnPlay.SetSize([24,24]);
    btnPlay.SetFuncWithDelegate( VideoPlayer_Play, this );

    btnStop = spawn( vguiButton );
    btnStop.SetIcon( "gfx/icon16/control_stop" );
    btnStop.SetSize([24,24]);
    btnStop.SetFuncWithDelegate( VideoPlayer_Stop, this );

    btnLibrary = spawn( vguiButton );
    btnLibrary.SetIcon( "gfx/icon16/book_open" );
    btnLibrary.SetSize([24,24]);
    btnLibrary.SetFuncWithDelegate( VideoPlayer_Library, this );

    btnURL = spawn( vguiButton );
    btnURL.SetIcon( "gfx/icon16/world_go" );
    btnURL.SetSize([24,24]);
    btnURL.SetFuncWithDelegate( VideoPlayer_URL, this );

    btnShare = spawn( vguiButton );
    btnShare.SetIcon( "gfx/icon16/building" );
    btnShare.SetSize([24,24]);
    btnShare.SetFuncWithDelegate( VideoPlayer_Share, this );

    m_libraryWindow.Add( lsbTitles );
    m_libraryWindow.Add( scrlSong );

    Add( m_outlineFrame );
    Add( video );
    Add( preview );
    Add( btnPlay );
    Add( btnLibrary );
    Add( btnStop );
    Add( btnURL );
    Add( btnShare );
    search_end( shSearchVideoLibrary );

    video.Hide();
    preview.Show();

    lsbTitles.SetSelected(0);
    VideoPlayer_SelectionChanged();
    VideoPlayer_Resized();
}
