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
vguiTool_Measure:vguiApplication
{
    void vguiTool_Measure(void);

    virtual void Spawned(void);

    nonvirtual void Measure_Add(void);
    nonvirtual void Measure_Clear(void);
    nonvirtual void Measure_ScrollUpdate(void);
    nonvirtual void Measure_ListUpdate(void);

private:

    vguiList lsbEntries;
    vguiScrollBar scrlSong;
    vguiButton btnGo;
    vguiButton btnClear;
    bool m_isConnected;
};

void
vguiTool_Measure::vguiTool_Measure(void)
{
    m_isConnected = false;
}

void
vguiTool_Measure::Measure_Add(void)
{
    lsbEntries.AddItem( sprintf("%v", pSeat->m_vecPredictedOrigin) );

    int itemCount = lsbEntries.GetItemCount();

    vector lastPos = stov(lsbEntries.GetItem(0));
    float totalDist = 0.0f;

    for (int i = 0; i < itemCount; i++) {
        string positionValue = lsbEntries.GetItem(i);
        vector positionVector = stov(positionValue);
        totalDist += vlen(positionVector - lastPos);
        lastPos = positionVector;
    }

    SetTitle(sprintf("Measure: %d u (%ix)", totalDist, itemCount));
}

void
vguiTool_Measure::Measure_Clear(void)
{
    lsbEntries.RemoveAllItems();
}

void
vguiTool_Measure::Measure_ScrollUpdate(void)
{
    scrlSong.SetValue( lsbEntries.GetOffset() );
}

void
vguiTool_Measure::Measure_ListUpdate(void)
{
    lsbEntries.SetOffset( scrlSong.GetValue(), FALSE );
}

void
vguiTool_Measure::Measure_Resized(void)
{
    vector windowSize = GetSize();
    lsbEntries.SetSize( [windowSize[0]-16-21, windowSize[1]-64] );
    scrlSong.SetLength( windowSize[1]-64 );
    scrlSong.SetPos( [windowSize[0]-21,32] );

    btnGo.SetPos( [8,windowSize[1]-28] );
    btnClear.SetPos( [8+64,windowSize[1]-28] );
}

void
vguiTool_Measure::Spawned(void)
{
    super::Spawned();

    classname = "vguiWindow";
    SetTitle( "Measure" );
    SetSize( [178,320] );
    SetIcon( "gfx/icon16/vcard" );
    SetStyleMask( vguiWindowStyleDefault | vguiWindowResizeable );
    CallOnResize(Measure_Resized);

    lsbEntries = spawn( vguiList );
    lsbEntries.SetSize( [480-16-21, 320-64] );
    lsbEntries.SetPos( [8, 32] );
    lsbEntries.CallOnScrollWithDelegate( Measure_ScrollUpdate, this );

    scrlSong = spawn( vguiScrollBar );
    scrlSong.SetLength( 320-64 );
    scrlSong.SetPos( [480-21,32] );
    scrlSong.SetMin( 0 );
    scrlSong.SetStep( 1 );
    scrlSong.CallOnChangeWithDelegate( Measure_ListUpdate, this );
    btnGo = spawn( vguiButton );
    btnGo.SetTitle( "Add" );
    btnGo.SetIcon( "gfx/icon16/add" );
    btnGo.SetPos( [8,320-28] );
    btnGo.SetSize([64,24]);
    btnGo.SetFuncWithDelegate( Measure_Add, this );

    btnClear = spawn( vguiButton );
    btnClear.SetTitle( "Clear" );
    btnClear.SetIcon( "gfx/icon16/cross" );
    btnClear.SetPos( [8,320-28] );
    btnClear.SetSize([64,24]);
    btnClear.SetFuncWithDelegate( Measure_Clear, this );

    lsbEntries.SetItemCount( 90 );
    scrlSong.SetMax( 90 );

    Add( lsbEntries );
    Add( scrlSong );
    Add( btnGo );
    Add( btnClear );
    Measure_Resized();
}
