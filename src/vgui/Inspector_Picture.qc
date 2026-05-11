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
vguiDesktopAppImageView:vguiWindow
{
    void vguiDesktopAppImageView(void);

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

    vguiWindow m_sizeWindow;
    vguiRadio m_sizeA0;
    vguiRadio m_sizeA1;
    vguiRadio m_sizeA2;
    vguiRadio m_sizeA3;
    vguiRadio m_sizeA4;
    vguiRadio m_sizeA5;
    vguiButton m_sizeShare;
    vguiTextBox m_sizeMultiplier;
};

void
vguiDesktopAppImageView::vguiDesktopAppImageView(void)
{
}


void
vguiDesktopAppImageView::ImageView_Share(void)
{
    float standardLength;
    float sizeValue;
    vector realSize;
    string videoName = lsbIDs.GetItem(lsbTitles.GetSelected());
    ncDict videoDict = ncDict::LoadDeclFromFile(videoName, sprintf("pictures/%s.picture", videoName));
    string videoFile = videoDict.GetString("preview");
    string videoTitle = videoDict.GetString("name");
    vector imageAspect = videoDict.GetVector("resolution");

    /* 2d normalize */
    if (imageAspect[0] > imageAspect[1]) {
        imageAspect[1] = imageAspect[1] / imageAspect[0];
        imageAspect[0] = 1.0f;
    } else {
        imageAspect[0] = imageAspect[0] / imageAspect[1];
        imageAspect[1] = 1.0f;
    }

    if (m_sizeA0.GetValue())
        sizeValue = 0;
    else if (m_sizeA1.GetValue())
        sizeValue = 1;
    else if (m_sizeA2.GetValue())
        sizeValue = 2;
    else if (m_sizeA3.GetValue())
        sizeValue = 3;
    else if (m_sizeA4.GetValue())
        sizeValue = 4;
    else if (m_sizeA5.GetValue())
        sizeValue = 5;

    /* poster formats, A0-A5 - longest side */
    switch (sizeValue) {
    case 0:
        standardLength = 118.9;
        break;
    case 1:
        standardLength = 84.1;
        break;
    case 2:
        standardLength = 59.4;
        break;
    case 3:
        standardLength = 42;
        break;
    case 4:
        standardLength = 29.7;
        break;
    case 5:
        standardLength = 21;
        break;
    }

    /* length * aspect = decent approximation for our image turned poster */
    realSize = [standardLength * imageAspect[0], standardLength * imageAspect[1]];

    /* to game units */
    realSize[0] *= (1/2.54);
    realSize[1] *= (1/2.54);
    float scaleMulti = (stof(m_sizeMultiplier.GetText()) * 0.01);

    if (scaleMulti <= 0) {
        scaleMulti = 1.0f;
    }

    realSize *= scaleMulti;
    localcmd(sprintf("cmd sharePicture %S %S %d %d %S\n", videoName, videoFile, realSize[0], realSize[1], videoTitle));
}

void
vguiDesktopAppImageView::ImageView_URLOpened(vguiWidget sender)
{
    vguiTextPrompt lastPrompt = (vguiList)sender;
    string searchString = lastPrompt.textBox.GetText();
    preview.SetImage(searchString);
}


void
vguiDesktopAppImageView::ImageView_Library(void)
{
    vector windowSize = GetSize();

    if (!m_libraryWindow.m_parent) {
        m_parent.Add(m_libraryWindow);
    }

    m_libraryWindow.Show();
    m_libraryWindow.SetPos(GetPos() + [0, windowSize[1]]);
}

void
vguiDesktopAppImageView::ImageView_URL(void)
{
    if (!urlPrompt) {
        urlPrompt = spawn( vguiTextPrompt );
        m_parent.Add( urlPrompt );
        urlPrompt.SetOKAction(ImageView_URLOpened, this);
        urlPrompt.SetIcon("gfx/icon16/world");
        urlPrompt.SetTitle("Open Remote URL");
        urlPrompt.SetPos(GetPos() + (GetSize() / 2) - (urlPrompt.GetSize() / 2));
        } else {
        urlPrompt.Show();
        urlPrompt.NowVisible();
    }
}

void
vguiDesktopAppImageView::ImageView_OpenShare(void)
{
    if (!m_sizeWindow.m_parent) {
        m_parent.Add(m_sizeWindow);
    }

    m_sizeWindow.Show();
    m_sizeWindow.NowVisible();
}

void
vguiDesktopAppImageView::ImageView_ScrollUpdate(void)
{
    scrlSong.SetValue( lsbTitles.GetOffset() );
}

void
vguiDesktopAppImageView::ImageView_ListUpdate(void)
{
    lsbTitles.SetOffset( scrlSong.GetValue(), FALSE );
}

void
vguiDesktopAppImageView::ImageView_Resized(void)
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
vguiDesktopAppImageView::ImageView_SelectionChanged(void)
{
    string videoName = lsbIDs.GetItem(lsbTitles.GetSelected());
    ncDict videoDict = ncDict::LoadDeclFromFile(videoName, sprintf("pictures/%s.picture", videoName));
    string videoFile = videoDict.GetString("preview");
    m_imageAspect = videoDict.GetVector("resolution");

    /* 2d normalize */
    if (m_imageAspect[0] > m_imageAspect[1]) {
        m_imageAspect[1] = m_imageAspect[1] / m_imageAspect[0];
        m_imageAspect[0] = 1.0f;
    } else {
        m_imageAspect[0] = m_imageAspect[0] / m_imageAspect[1];
        m_imageAspect[1] = 1.0f;
    }

    preview.SetImage(videoFile);
    preview.Show();
    ImageView_Resized();

    Editor_SetSelectionProfileItem(videoName, ITEM_PICTURE);
}

void
vguiDesktopAppImageView::ImageView_LibraryResized(void)
{
}

void
vguiDesktopAppImageView::ImageView_SizeChanged(void)
{
    m_sizeA0.SetValue( false );
    m_sizeA1.SetValue( false );
    m_sizeA2.SetValue( false );
    m_sizeA3.SetValue( false );
    m_sizeA4.SetValue( false );
    m_sizeA5.SetValue( false );
}

void
vguiDesktopAppImageView::Spawned(void)
{
    int imageCount = ncUserInventory::GetItemCount(ITEM_PICTURE);

    super::Spawned();

    classname = "vguiWindow";
    SetTitle( "ImageView" );
    SetSize( [160+16,140+32] );
    SetIcon( "gfx/icon16/picture" );
    SetStyleMask( vguiWindowStyleDefault | vguiWindowResizeable );
    CallOnResize(ImageView_Resized);

    /* library window */
    m_libraryWindow = spawn(vguiWindow);
    m_libraryWindow.Hide();
    m_libraryWindow.SetTitle( "Picture Library" );
    m_libraryWindow.SetSize( [320+16,120+32] );
    m_libraryWindow.SetIcon( "gfx/icon16/book_open" );

    m_outlineFrame = spawn(vguiFrame);
    m_outlineFrame.SetPos([8,32]);
    m_outlineFrame.SetSize([160,120]);

    lsbTitles = spawn( vguiList );
    lsbTitles.SetSize( [320 - 16-21, 96] );
    lsbTitles.SetPos( [8, 32] );
    lsbTitles.SetItemCount( imageCount );
    lsbTitles.CallOnScrollWithDelegate( ImageView_ScrollUpdate, this );
    lsbTitles.CallOnSelectionChangedWithDelegate( ImageView_SelectionChanged, this);

    lsbIDs = spawn( vguiList );
    lsbIDs.SetItemCount( imageCount );

    for ( int i = 0; i < imageCount; i++ ) {
        ncDict videoDict = ncUserInventory::GetItemDictByIndex(i, ITEM_PICTURE);
        string dictName = videoDict.Name();
        lsbIDs.AddItem( dictName );

        string videoName = videoDict.GetString("name");

        if (!STRING_SET(videoName)) {
            lsbTitles.AddItem( dictName );
        } else {
            lsbTitles.AddItem( videoName );
        }
    }

    preview = spawn( vguiPic );
    preview.SetPos( [8,32] );

    scrlSong = spawn( vguiScrollBar );
    scrlSong.SetLength( 96 );
    scrlSong.SetPos( [320-8-21,32] );
    scrlSong.SetMin( 0 );
    scrlSong.SetStep( 1 );
    scrlSong.SetMax( lsbTitles.GetMaxVisibleItems() );
    scrlSong.CallOnChangeWithDelegate( ImageView_ListUpdate, this );

    btnLibrary = spawn( vguiButton );
    btnLibrary.SetIcon( "gfx/icon16/book_open" );
    btnLibrary.SetSize([24,24]);
    btnLibrary.SetFuncWithDelegate( ImageView_Library, this );

    btnURL = spawn( vguiButton );
    btnURL.SetIcon( "gfx/icon16/world_go" );
    btnURL.SetSize([24,24]);
    btnURL.SetFuncWithDelegate( ImageView_URL, this );

    btnShare = spawn( vguiButton );
    btnShare.SetIcon( "gfx/icon16/building" );
    btnShare.SetSize([24,24]);
    btnShare.SetFuncWithDelegate( ImageView_OpenShare, this );

    m_libraryWindow.Add( lsbTitles );
    m_libraryWindow.Add( scrlSong );

    Add( m_outlineFrame );
    Add( preview );
    Add( btnLibrary );
    Add( btnURL );
    Add( btnShare );

    preview.Show();

    /* set up the poster size/sharing window */
    m_sizeWindow = spawn(vguiWindow);
    m_sizeWindow.SetTitle( "Place Poster" );
    m_sizeWindow.SetSize( '192 200' );
    m_sizeWindow.SetIcon( "gfx/icon16/new" );
    m_sizeWindow.SetPos(GetPos() + GetSize());

    m_sizeShare = spawn(vguiButton);
    m_sizeShare.SetTitle( "Place" );
    m_sizeShare.SetSize( '64 24' );
    m_sizeShare.SetPos( m_sizeWindow.GetSize() - '152 32' );
    m_sizeShare.SetFuncWithDelegate( ImageView_Share, this );

    m_sizeMultiplier = spawn(vguiTextBox);
    m_sizeMultiplier.SetPos(m_sizeShare.GetPos() - [0, m_sizeShare.GetHeight()]);
    m_sizeMultiplier.SetText("100");

    m_sizeA0 = spawn(vguiRadio);
    m_sizeA0.SetTitle( "A0" );
    m_sizeA0.SetSize( '96 16' );
    m_sizeA0.SetPos( [32,32] );

    m_sizeA1 = spawn(vguiRadio);
    m_sizeA1.SetTitle( "A1" );
    m_sizeA1.SetSize( '96 16' );
    m_sizeA1.SetPos( [32,32 + 20] );
    m_sizeA1.SetValue( TRUE );

    m_sizeA2 = spawn(vguiRadio);
    m_sizeA2.SetTitle( "A2" );
    m_sizeA2.SetSize( '96 16' );
    m_sizeA2.SetPos( [32,32 + 20+20] );

    m_sizeA3 = spawn(vguiRadio);
    m_sizeA3.SetTitle( "A3" );
    m_sizeA3.SetSize( '96 16' );
    m_sizeA3.SetPos( [32,32 + 20+20+20] );

    m_sizeA4 = spawn(vguiRadio);
    m_sizeA4.SetTitle( "A4" );
    m_sizeA4.SetSize( '96 16' );
    m_sizeA4.SetPos( [32,32 + 20+20+20+20]);

    m_sizeA5 = spawn(vguiRadio);
    m_sizeA5.SetTitle( "A5" );
    m_sizeA5.SetSize( '96 16' );
    m_sizeA5.SetPos( [32,32 + 20+20+20+20+20] );

    m_sizeA0.CallOnChangeWithDelegate( ImageView_SizeChanged, this );
    m_sizeA1.CallOnChangeWithDelegate( ImageView_SizeChanged, this );
    m_sizeA2.CallOnChangeWithDelegate( ImageView_SizeChanged, this );
    m_sizeA3.CallOnChangeWithDelegate( ImageView_SizeChanged, this );
    m_sizeA4.CallOnChangeWithDelegate( ImageView_SizeChanged, this );
    m_sizeA5.CallOnChangeWithDelegate( ImageView_SizeChanged, this );

    m_sizeWindow.Add(m_sizeA0);
    m_sizeWindow.Add(m_sizeA1);
    m_sizeWindow.Add(m_sizeA2);
    m_sizeWindow.Add(m_sizeA3);
    m_sizeWindow.Add(m_sizeA4);
    m_sizeWindow.Add(m_sizeA5);
    m_sizeWindow.Add(m_sizeShare);
    m_sizeWindow.Add(m_sizeMultiplier);

    lsbTitles.SetSelected(0);
    ImageView_SelectionChanged();
    ImageView_Resized();
}
