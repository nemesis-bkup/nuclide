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
vguiVote_Map:vguiWindow
{
    void vguiVote_Map(void);

    virtual void Spawned(void);

    nonvirtual void VoteMap_Go(void);
    nonvirtual void VoteMap_ScrollUpdate(void);
    nonvirtual void VoteMap_ListUpdate(void);

private:

    vguiList lsbEntries;
    vguiScrollBar scrlSong;
    vguiButton btnGo;
    bool m_isConnected;
};

void
vguiVote_Map::vguiVote_Map(void)
{
    m_isConnected = false;
}

void
vguiVote_Map::VoteMap_Go(void)
{
    ncCommand("callvote map %S\n", lsbEntries.GetItem(lsbEntries.GetSelected()));
    Close();
}

void
vguiVote_Map::VoteMap_ScrollUpdate(void)
{
    scrlSong.SetValue( lsbEntries.GetOffset() );
}

void
vguiVote_Map::VoteMap_ListUpdate(void)
{
    lsbEntries.SetOffset( scrlSong.GetValue(), FALSE );
}

void
vguiVote_Map::Finger_Resized(void)
{
    vector windowSize = GetSize();
    lsbEntries.SetSize( [windowSize[0]-16-21, windowSize[1]-64] );
    scrlSong.SetLength( windowSize[1]-64 );
    scrlSong.SetPos( [windowSize[0]-21,32] );

    btnGo.SetPos( [8,windowSize[1]-28] );
}

void
vguiVote_Map::Spawned(void)
{
    super::Spawned();

    classname = "vguiWindow";
    SetTitle( "Vote Map" );
    SetSize( [480,320] );
    SetIcon( "gfx/icon16/map" );
    SetStyleMask( vguiWindowStyleDefault | vguiWindowResizeable );
    CallOnResize(Finger_Resized);

    lsbEntries = spawn( vguiList );
    lsbEntries.SetSize( [480-16-21, 320-64] );
    lsbEntries.SetPos( [8, 32] );
    lsbEntries.CallOnScrollWithDelegate( VoteMap_ScrollUpdate, this );

    scrlSong = spawn( vguiScrollBar );
    scrlSong.SetLength( 320-64 );
    scrlSong.SetPos( [480-21,32] );
    scrlSong.SetMin( 0 );
    scrlSong.SetStep( 1 );
    scrlSong.CallOnChangeWithDelegate( VoteMap_ListUpdate, this );
    btnGo = spawn( vguiButton );
    btnGo.SetTitle( "Vote Map" );
    btnGo.SetIcon( "gfx/icon16/email_open_image" );
    btnGo.SetPos( [8,320-28] );
    btnGo.SetSize([64,24]);
    btnGo.SetFuncWithDelegate( VoteMap_Go, this );

    int mapCount = MapLibrary_GetMapCount();
    lsbEntries.SetItemCount( mapCount );
    scrlSong.SetMax( mapCount );

    for (int i = 0i; i < mapCount; i++) {
        string entName = MapLibrary_GetInfo(i, MAPINFO_NAME);

        if (STRING_SET(entName)) {
            lsbEntries.AddItem( entName );
        }
    }

    Add( lsbEntries );
    Add( scrlSong );
    Add( btnGo );
}
