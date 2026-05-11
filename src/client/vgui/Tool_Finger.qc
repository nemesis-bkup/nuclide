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
vguiTool_Finger:vguiApplication
{
    void vguiTool_Finger(void);

    virtual void Launched(void);
    virtual void LaunchKey(string keyName, string setValue);

    nonvirtual void AddEntry(string);
    nonvirtual void AddFingerLine(string);

    nonvirtual void FingerBrowser_Go(void);
    nonvirtual void FingerBrowser_ScrollUpdate(void);
    nonvirtual void FingerBrowser_ListUpdate(void);

private:

    vguiList lsbEntries;
    vguiScrollBar scrlSong;
    vguiButton btnGo;
    vguiTextBox addressField;
    bool m_isConnected;
    string m_fingerTarget;
};

void
vguiTool_Finger::vguiTool_Finger(void)
{
    m_isConnected = false;
}

void
vguiTool_Finger::AddEntry(string text)
{
    lsbEntries.AddItem( text );
}

void
vguiTool_Finger::AddFingerLine(string text)
{
    for (vguiWindow findWindows = 0; (findWindows = (vguiWindow)find(findWindows, ::classname, "vguiTool_Finger"));) {
        vguiTool_Finger FingerWindow = (vguiTool_Finger)findWindows;
        FingerWindow.AddEntry(text);
    }
}

void
vguiTool_Finger::LaunchKey(string keyName, string setValue)
{
    switch (keyName) {
    case "target":
        m_fingerTarget = setValue;
        break;
    default:
        super::LaunchKey(keyName, setValue);
        break;
    }
}

void
vguiTool_Finger::FingerBrowser_Go(void)
{
    ncCommand("finger %s", addressField.GetText());
}

void
vguiTool_Finger::FingerBrowser_ScrollUpdate(void)
{
    scrlSong.SetValue( lsbEntries.GetOffset() );
}

void
vguiTool_Finger::FingerBrowser_ListUpdate(void)
{
    lsbEntries.SetOffset( scrlSong.GetValue(), FALSE );
}

void
vguiTool_Finger::Finger_Resized(void)
{
    vector windowSize = GetSize();
    lsbEntries.SetSize( [windowSize[0]-16-21, windowSize[1]-64] );
    scrlSong.SetLength( windowSize[1]-64 );
    scrlSong.SetPos( [windowSize[0]-21,32] );

    btnGo.SetPos( [8,windowSize[1]-28] );
    addressField.SetPos( [96-16,windowSize[1]-28] );
}

void
vguiTool_Finger::Launched(void)
{
    super::Launched();

    SetSize( [480,320] );
    SetStyleMask( vguiWindowStyleDefault | vguiWindowResizeable );
    CallOnResize(Finger_Resized);

    lsbEntries = spawn( vguiList );
    lsbEntries.SetSize( [480-16-21, 320-64] );
    lsbEntries.SetPos( [8, 32] );
    lsbEntries.CallOnScrollWithDelegate( FingerBrowser_ScrollUpdate, this );

    scrlSong = spawn( vguiScrollBar );
    scrlSong.SetLength( 320-64 );
    scrlSong.SetPos( [480-21,32] );
    scrlSong.SetMin( 0 );
    scrlSong.SetStep( 1 );
    scrlSong.CallOnChangeWithDelegate( FingerBrowser_ListUpdate, this );

    btnGo = spawn( vguiButton );
    btnGo.SetTitle( "Go" );
    btnGo.SetIcon( "gfx/icon16/control_play" );
    btnGo.SetPos( [8,320-28] );
    btnGo.SetSize([64,24]);
    btnGo.SetFuncWithDelegate( FingerBrowser_Go, this );

    addressField = spawn( vguiTextBox );
    addressField.SetText( m_fingerTarget );
    addressField.SetPos( [96-16,320-28] );
    addressField.SetSize([192,24]);

    lsbEntries.SetItemCount( 100 );
    scrlSong.SetMax( 100 );

    Add( lsbEntries );
    Add( scrlSong );
    Add( btnGo );
    Add( addressField );
}
