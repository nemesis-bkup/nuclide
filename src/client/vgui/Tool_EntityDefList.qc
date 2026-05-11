/*
 * Copyright (c) 2025 Vera Visions LLC.
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

class
vguiTool_EntityDefList:vguiApplication
{
    void vguiTool_EntityDefList(void);

    virtual void Spawned(void);

    nonvirtual void EntSpawner_Go(void);
    nonvirtual void EntSpawner_ScrollUpdate(void);
    nonvirtual void EntSpawner_ListUpdate(void);
    nonvirtual void EntSpawner_SelectionChanged(void);

private:

    vguiList lsbEntries;
    vguiScrollBar scrlSong;
    vguiButton btnGo;
    bool m_isConnected;
};

void
vguiTool_EntityDefList::vguiTool_EntityDefList(void)
{
    m_isConnected = false;
}

void
vguiTool_EntityDefList::EntSpawner_Go(void)
{
    Editor_SpawnSelection();
    EntSpawner_SelectionChanged();
}

void
vguiTool_EntityDefList::EntSpawner_ScrollUpdate(void)
{
    scrlSong.SetValue( lsbEntries.GetOffset() );
}

void
vguiTool_EntityDefList::EntSpawner_ListUpdate(void)
{
    lsbEntries.SetOffset( scrlSong.GetValue(), FALSE );
}

void
vguiTool_EntityDefList::EntSpawner_Resized(void)
{
    vector windowSize = GetSize();
    lsbEntries.SetSize( [windowSize[0]-16-21, windowSize[1]-64] );
    scrlSong.SetLength( windowSize[1]-64 );
    scrlSong.SetPos( [windowSize[0]-21,32] );
    btnGo.SetPos( [8,windowSize[1]-28] );
}

void
vguiTool_EntityDefList::EntSpawner_SelectionChanged(void)
{
    string entityClass = lsbEntries.GetItem(lsbEntries.GetSelected());
    Editor_SetSelectionEntity(entityClass);
}

void
vguiTool_EntityDefList::Spawned(void)
{
    super::Spawned();

    classname = "vguiWindow";
    SetTitle( "EntSpawner" );
    SetSize( [178,320] );
    SetIcon( "gfx/icon16/vcard" );
    SetStyleMask( vguiWindowStyleDefault | vguiWindowResizeable );
    CallOnResize(EntSpawner_Resized);

    lsbEntries = spawn( vguiList );
    lsbEntries.SetSize( [480-16-21, 320-64] );
    lsbEntries.SetPos( [8, 32] );
    lsbEntries.CallOnScrollWithDelegate( EntSpawner_ScrollUpdate, this );
    lsbEntries.CallOnSelectionChangedWithDelegate(EntSpawner_SelectionChanged, this );

    scrlSong = spawn( vguiScrollBar );
    scrlSong.SetLength( 320-64 );
    scrlSong.SetPos( [480-21,32] );
    scrlSong.SetMin( 0 );
    scrlSong.SetStep( 1 );
    scrlSong.CallOnChangeWithDelegate( EntSpawner_ListUpdate, this );
    btnGo = spawn( vguiButton );
    btnGo.SetTitle( "Spawn" );
    btnGo.SetIcon( "gfx/icon16/control_play" );
    btnGo.SetPos( [8,320-28] );
    btnGo.SetSize([64,24]);
    btnGo.SetFuncWithDelegate( EntSpawner_Go, this );

    lsbEntries.SetItemCount( EntityDef_Count() );
    int ultimateCount = 0;

    for (int i = 0i; i < EntityDef_Count(); i++) {
        string entName = EntityDef_ClassForIndex(i);
        string entColor = EntityDef_GetKeyValue(entName, "editor_color");

        /* only ents with a color set are valid to be placed by editors */
        if (STRING_SET(entName) && STRING_SET(entColor)) {
            lsbEntries.AddItem( EntityDef_ClassForIndex(i) );
            ultimateCount++;
        }
    }
    scrlSong.SetMax( ultimateCount );

    Add( lsbEntries );
    Add( scrlSong );
    Add( btnGo );
    EntSpawner_SelectionChanged();

    EntSpawner_Resized();
}
