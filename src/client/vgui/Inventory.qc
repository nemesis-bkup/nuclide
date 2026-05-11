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


class
vguiInventory:vguiWindow
{
    void vguiInventory(void);

    virtual void Spawned(void);

    nonvirtual void EntSpawner_Go(void);
    nonvirtual void EntSpawner_ScrollUpdate(void);
    nonvirtual void EntSpawner_ListUpdate(void);
    nonvirtual void EntSpawner_SelectionChanged(void);

private:

    vguiFeeder m_listPictures;
    vguiScrollBar m_scrollPictures;

    vguiFeeder m_listAudio;
    vguiScrollBar m_scrollAudio;

    vguiFeeder m_listVideos;
    vguiScrollBar m_scrollVideos;

    vguiFeeder m_listObjects;
    vguiScrollBar m_scrollObjects;

    vguiFeeder m_listTexts;
    vguiScrollBar m_scrollTexts;

    vguiFeeder m_listApps;
    vguiScrollBar m_scrollApps;

    bool m_isConnected;

    vguiButton m_button1;
    vguiButton m_button2;
    vguiButton m_button3;
    vguiButton m_button4;
    vguiButton m_button5;
    vguiButton m_button6;
    vguiButton m_button7;
    vguiButton m_setHeightOffset;
    vguiPanel m_heightWindow;
    vguiTextBox m_heightText;
    vguiButton m_sendButton;
    vguiToggleButton m_setSend;
    vguiToggleButton m_setInstantiate;
};

void
vguiInventory::vguiInventory(void)
{
    m_isConnected = false;
}

void
vguiInventory::EntSpawner_Go(void)
{
    Editor_SpawnSelection();
    EntSpawner_SelectionChanged();
}

void
vguiInventory::EntSpawner_ScrollUpdate(void)
{
    //m_scrollEntityDef.SetValue( m_listEntityDef.GetOffset() );
}

void
vguiInventory::EntSpawner_ListUpdate(void)
{
    //m_listEntityDef.SetOffset( m_scrollEntityDef.GetValue(), FALSE );
}

void
vguiInventory::EntSpawner_Resized(void)
{
    static void ResizeScrollers(vector windowSize, vguiList list, vguiScrollBar bar) {
        bar.SetPos( [windowSize[0]-21,32+24] );
        bar.SetLength( windowSize[1]-64-26 );
        list.SetPos( [8, 32+24] );
        list.SetSize( [windowSize[0]-16-21, windowSize[1]-64-26] );
    }

    vector windowSize = GetSize();

    //ResizeScrollers(windowSize, m_listEntityDef, m_scrollEntityDef);
    ResizeScrollers(windowSize, m_listPictures, m_scrollPictures);
    ResizeScrollers(windowSize, m_listAudio, m_scrollAudio);
    ResizeScrollers(windowSize, m_listVideos, m_scrollVideos);
    ResizeScrollers(windowSize, m_listObjects, m_scrollObjects);
    ResizeScrollers(windowSize, m_listTexts, m_scrollTexts);
    ResizeScrollers(windowSize, m_listApps, m_scrollApps);

    m_setHeightOffset.SetPos([GetWidth() - 28 - 24,GetHeight() - 28]);
    m_setSend.SetPos( m_setHeightOffset.GetPos() + [-32, 0]);
    m_setInstantiate.SetPos( m_setSend.GetPos() + [-28, 0]);
    m_sendButton.SetPos( [8,windowSize[1]-28] );
}

void
vguiInventory::EntSpawner_SelectionChanged(void)
{
    //string entityClass = m_listEntityDef.GetItem(m_listEntityDef.GetSelected());
    //Editor_SetSelectionEntity(entityClass);
}

void
vguiInventory::Pictures_SelectionChanged(void)
{
    string itemName = m_listPictures.GetItemAtColumn(m_listPictures.GetSelected(), 1);
    ncDict itemDict = ncUserInventory::GetItemDict(itemName, ITEM_PICTURE);

    if (!itemDict) {
        ncError("Invalid item %S for type %d", itemName, ITEM_PICTURE);
        return;
    }

    string mediaURL = itemDict.GetString("picture");
    string groupID = itemDict.GetString("group");
    Editor_SetSelectionDict(itemDict, "", INPUT_DATA);
}

void
vguiInventory::InitPictures(void)
{
    int imageCount = ncUserInventory::GetItemCount(ITEM_PICTURE);
    m_listPictures = spawn( vguiFeeder );
    m_listPictures.SetSize( [480-16-21, 320-64] );
    m_listPictures.SetPos( [8, 48] );
    m_listPictures.CallOnScrollWithDelegate( EntSpawner_ScrollUpdate, this );
    m_listPictures.CallOnSelectionChangedWithDelegate(Pictures_SelectionChanged, this );
    m_listPictures.SetFeederType( FEEDER_PLAYER_PROFILE_PICTURE_LIST );

    m_scrollPictures = spawn( vguiScrollBar );
    m_scrollPictures.SetLength( 320-64 );
    m_scrollPictures.SetPos( [480-21,48] );
    m_scrollPictures.SetMin( 0 );
    m_scrollPictures.SetStep( 1 );
    m_scrollPictures.CallOnChangeWithDelegate( EntSpawner_ListUpdate, this );
    m_scrollPictures.SetMax( imageCount );

    Add( m_listPictures );
    Add( m_scrollPictures );
}

void
vguiInventory::Audio_SelectionChanged(void)
{
    string itemName = m_listAudio.GetItemAtColumn(m_listAudio.GetSelected(), 1);
    ncDict itemDict = ncUserInventory::GetItemDict(itemName, ITEM_AUDIO);

    if (!itemDict) {
        ncError("Invalid item %S for type %d", itemName, ITEM_AUDIO);
        return;
    }

    Editor_SetSelectionDict(itemDict, "", INPUT_DATA);
}

void
vguiInventory::InitAudio(void)
{
    int imageCount = ncUserInventory::GetItemCount(ITEM_AUDIO);
    m_listAudio = spawn( vguiFeeder );
    m_listAudio.SetSize( [480-16-21, 320-64] );
    m_listAudio.SetPos( [8, 48] );
    m_listAudio.CallOnScrollWithDelegate( EntSpawner_ScrollUpdate, this );
    m_listAudio.CallOnSelectionChangedWithDelegate(Audio_SelectionChanged, this );
    m_listAudio.SetFeederType( FEEDER_PLAYER_PROFILE_AUDIO_LIST );

    m_scrollAudio = spawn( vguiScrollBar );
    m_scrollAudio.SetLength( 320-64 );
    m_scrollAudio.SetPos( [480-21,48] );
    m_scrollAudio.SetMin( 0 );
    m_scrollAudio.SetStep( 1 );
    m_scrollAudio.CallOnChangeWithDelegate( EntSpawner_ListUpdate, this );
    m_scrollAudio.SetMax( imageCount );

    Add( m_listAudio );
    Add( m_scrollAudio );
}

void
vguiInventory::Videos_SelectionChanged(void)
{
    string itemName = m_listVideos.GetItemAtColumn(m_listVideos.GetSelected(), 1);
    ncDict itemDict = ncUserInventory::GetItemDict(itemName, ITEM_VIDEO);

    if (!itemDict) {
        ncError("Invalid item %S for type %d", itemName, ITEM_VIDEO);
        return;
    }

    string mediaURL = itemDict.GetString("video");
    string groupID = itemDict.GetString("group");
    Editor_SetSelectionDict(itemDict, "", INPUT_DATA);
}

void
vguiInventory::InitVideos(void)
{
    int imageCount = ncUserInventory::GetItemCount(ITEM_VIDEO);
    m_listVideos = spawn( vguiFeeder );
    m_listVideos.SetSize( [480-16-21, 320-64] );
    m_listVideos.SetPos( [8, 48] );
    m_listVideos.CallOnScrollWithDelegate( EntSpawner_ScrollUpdate, this );
    m_listVideos.CallOnSelectionChangedWithDelegate(Videos_SelectionChanged, this );
    m_listVideos.SetFeederType( FEEDER_PLAYER_PROFILE_VIDEO_LIST );

    m_scrollVideos = spawn( vguiScrollBar );
    m_scrollVideos.SetLength( 320-64 );
    m_scrollVideos.SetPos( [480-21,48] );
    m_scrollVideos.SetMin( 0 );
    m_scrollVideos.SetStep( 1 );
    m_scrollVideos.CallOnChangeWithDelegate( EntSpawner_ListUpdate, this );
    m_scrollVideos.SetMax( imageCount );

    Add( m_listVideos );
    Add( m_scrollVideos );
}

void
vguiInventory::Objects_SelectionChanged(void)
{

    Editor_SetSelectionProfileItem(m_listObjects.GetItemAtColumn(m_listObjects.GetSelected(), 1), ITEM_OBJECT);
}

void
vguiInventory::InitObjects(void)
{
    int imageCount = ncUserInventory::GetItemCount(ITEM_OBJECT);
    m_listObjects = spawn( vguiFeeder );
    m_listObjects.SetSize( [480-16-21, 320-64] );
    m_listObjects.SetPos( [8, 48] );
    m_listObjects.CallOnScrollWithDelegate( EntSpawner_ScrollUpdate, this );
    m_listObjects.CallOnSelectionChangedWithDelegate(Objects_SelectionChanged, this );
    m_listObjects.SetFeederType( FEEDER_PLAYER_PROFILE_OBJECT_LIST );

    m_scrollObjects = spawn( vguiScrollBar );
    m_scrollObjects.SetLength( 320-64 );
    m_scrollObjects.SetPos( [480-21,48] );
    m_scrollObjects.SetMin( 0 );
    m_scrollObjects.SetStep( 1 );
    m_scrollObjects.CallOnChangeWithDelegate( EntSpawner_ListUpdate, this );
    m_scrollObjects.SetMax( imageCount );

    Add( m_listObjects );
    Add( m_scrollObjects );
}


void
vguiInventory::Apps_SelectionChanged(void)
{
    string itemName = m_listApps.GetItemAtColumn(m_listApps.GetSelected(), 1);
    ncDict itemDict = ncUserInventory::GetItemDict(itemName, ITEM_APP);

    if (!itemDict) {
        ncError("Invalid item %S for type %d", itemName, ITEM_APP);
        return;
    }

    string mediaURL = itemDict.GetString("url");
    string groupID = itemDict.GetString("group");
    Editor_SetSelectionDict(itemDict, "", INPUT_DATA);
}

void
vguiInventory::InitApps(void)
{
    int imageCount = ncUserInventory::GetItemCount(ITEM_APP);
    m_listApps = spawn( vguiFeeder );
    m_listApps.SetSize( [480-16-21, 320-64] );
    m_listApps.SetPos( [8, 48] );
    m_listApps.CallOnScrollWithDelegate( EntSpawner_ScrollUpdate, this );
    m_listApps.CallOnSelectionChangedWithDelegate(Apps_SelectionChanged, this );
    m_listApps.SetFeederType( FEEDER_PLAYER_PROFILE_SOFTWARE_LIST );

    m_scrollApps = spawn( vguiScrollBar );
    m_scrollApps.SetLength( 320-64 );
    m_scrollApps.SetPos( [480-21,48] );
    m_scrollApps.SetMin( 0 );
    m_scrollApps.SetStep( 1 );
    m_scrollApps.CallOnChangeWithDelegate( EntSpawner_ListUpdate, this );
    m_scrollApps.SetMax( imageCount );

    Add( m_listApps );
    Add( m_scrollApps );
}

void
vguiInventory::Texts_SelectionChanged(void)
{

    string itemName = m_listVideos.GetItemAtColumn(m_listVideos.GetSelected(), 1);
    ncDict itemDict = ncUserInventory::GetItemDict(itemName, ITEM_TEXT);

    if (!itemDict) {
        ncError("Invalid item %S for type %d", itemName, ITEM_TEXT);
        return;
    }

    string mediaURL = itemDict.GetString("url");
    string groupID = itemDict.GetString("group");
    Editor_SetSelectionDict(itemDict, "", INPUT_DATA);
}

void
vguiInventory::InitTexts(void)
{
    int imageCount = ncUserInventory::GetItemCount(ITEM_TEXT);
    m_listTexts = spawn( vguiFeeder );
    m_listTexts.SetSize( [480-16-21, 320-64] );
    m_listTexts.SetPos( [8, 48] );
    m_listTexts.CallOnScrollWithDelegate( EntSpawner_ScrollUpdate, this );
    m_listTexts.CallOnSelectionChangedWithDelegate(Texts_SelectionChanged, this );
    m_listTexts.SetFeederType( FEEDER_PLAYER_PROFILE_TEXT_LIST );

    m_scrollTexts = spawn( vguiScrollBar );
    m_scrollTexts.SetLength( 320-64 );
    m_scrollTexts.SetPos( [480-21,48] );
    m_scrollTexts.SetMin( 0 );
    m_scrollTexts.SetStep( 1 );
    m_scrollTexts.CallOnChangeWithDelegate( EntSpawner_ListUpdate, this );
    m_scrollTexts.SetMax( imageCount );

    Add( m_listTexts );
    Add( m_scrollTexts );
}

void
vguiInventory::Inventory_Category0(void)
{
    m_listPictures.Hide();
    m_scrollPictures.Hide();
    m_listAudio.Hide();
    m_scrollAudio.Hide();
    m_listVideos.Hide();
    m_scrollVideos.Hide();
    m_listObjects.Hide();
    m_scrollObjects.Hide();
    m_listTexts.Hide();
    m_scrollTexts.Hide();
    m_listApps.Hide();
    m_scrollApps.Hide();
}

void
vguiInventory::Inventory_ShowPictures(void)
{
    Inventory_Category0();
    m_listPictures.Show();
    m_scrollPictures.Show();
}

void
vguiInventory::Inventory_ShowAudio(void)
{
    Inventory_Category0();
    m_listAudio.Show();
    m_scrollAudio.Show();
}

void
vguiInventory::Inventory_ShowVideos(void)
{
    Inventory_Category0();
    m_listVideos.Show();
    m_scrollVideos.Show();
}

void
vguiInventory::Inventory_ShowObjects(void)
{
    Inventory_Category0();
    m_listObjects.Show();
    m_scrollObjects.Show();
}

void
vguiInventory::Inventory_ShowTexts(void)
{
    Inventory_Category0();
    m_listTexts.Show();
    m_scrollTexts.Show();
}

void
vguiInventory::Inventory_ShowApps(void)
{
    Inventory_Category0();
    m_listApps.Show();
    m_scrollApps.Show();
}

void
vguiInventory::Inventory_SetHeightOffset(void)
{
    vector windowSize = GetSize();

    if (!m_heightWindow.m_parent) {
        m_parent.Add(m_heightWindow);
    }

    m_heightWindow.Show();
    m_heightWindow.SetPos(GetPos() + [0, windowSize[1]]);
}

void
vguiInventory::Inventory_SetHeightOffsetChanged(void)
{
    Editor_SetHeightOffset(stof(m_heightText.GetText()));
}

void
vguiInventory::Inventory_ModeModified(void)
{
    m_setSend.SetValue(0);
    m_setInstantiate.SetValue(0);
}

void
vguiInventory::Inventory_ModeChanged(void)
{
    if (m_setSend.GetValue() == 1) {
        Editor_SetSpawnMode(INPUT_DATA);
    } else if (m_setInstantiate.GetValue() == 1) {
        Editor_SetSpawnMode(SPAWN_OBJECT);
    }
}

void
vguiInventory::Spawned(void)
{
    super::Spawned();

    SetTitle( "Inventory" );
    SetSize( [192,320] );
    SetMinSize( [192,160] );
    SetIcon( "gfx/icon16/box" );
    SetStyleMask( vguiWindowStyleDefault | vguiWindowResizeable );
    CallOnResize(EntSpawner_Resized);


    m_button2 = spawn( vguiButton );
    m_button2.SetIcon( "gfx/icon16/pictures" );
    m_button2.SetPos( [8,32] );
    m_button2.SetSize([24,24]);
    m_button2.SetFuncWithDelegate( Inventory_ShowPictures, this );
    Add( m_button2 );

    m_button3 = spawn( vguiButton );
    m_button3.SetIcon( "gfx/icon16/music" );
    m_button3.SetPos( m_button2.GetPos() + [m_button2.GetWidth(), 0] );
    m_button3.SetSize([24,24]);
    m_button3.SetFuncWithDelegate( Inventory_ShowAudio, this );
    Add( m_button3 );

    m_button4 = spawn( vguiButton );
    m_button4.SetIcon( "gfx/icon16/film" );
    m_button4.SetPos( m_button3.GetPos() + [m_button3.GetWidth(), 0] );
    m_button4.SetSize([24,24]);
    m_button4.SetFuncWithDelegate( Inventory_ShowVideos, this );
    Add( m_button4 );

    m_button5 = spawn( vguiButton );
    m_button5.SetIcon( "gfx/icon16/brick" );
    m_button5.SetPos( m_button4.GetPos() + [m_button4.GetWidth(), 0] );
    m_button5.SetSize([24,24]);
    m_button5.SetFuncWithDelegate( Inventory_ShowObjects, this );
    Add( m_button5 );

    m_button6 = spawn( vguiButton );
    m_button6.SetIcon( "gfx/icon16/page_white_stack" );
    m_button6.SetPos( m_button5.GetPos() + [m_button5.GetWidth(), 0] );
    m_button6.SetSize([24,24]);
    m_button6.SetFuncWithDelegate( Inventory_ShowTexts, this );
    Add( m_button6 );

    m_button7 = spawn( vguiButton );
    m_button7.SetIcon( "gfx/icon16/application_xp_terminal" );
    m_button7.SetPos( m_button6.GetPos() + [m_button6.GetWidth(), 0] );
    m_button7.SetSize([24,24]);
    m_button7.SetFuncWithDelegate( Inventory_ShowApps, this );
    Add( m_button7 );

    m_setHeightOffset = spawn( vguiButton );
    m_setHeightOffset.SetIcon("gfx/icon16/text_linespacing");
    m_setHeightOffset.SetSize([24,24]);
    m_setHeightOffset.SetFuncWithDelegate( Inventory_SetHeightOffset, this );
    Add( m_setHeightOffset );

    InitPictures();
    InitAudio();
    InitVideos();
    InitObjects();
    InitApps();
    InitTexts();

    /* height offset window */
    m_heightWindow = spawn(vguiPanel);
    m_heightWindow.Hide();
    m_heightWindow.SetTitle( "Set Height Offset" );
    m_heightWindow.SetSize( [124+16,64] );
    m_heightWindow.SetIcon( "gfx/icon16/text_linespacing" );

    m_heightText = spawn( vguiTextBox );
    m_heightText.SetPos( [ 8, 32 ] );
    m_heightText.SetSize( [ 124, 24 ] );
    m_heightText.SetText( "0" );
    m_heightText.CallOnEnterWithDelegate( Inventory_SetHeightOffsetChanged, this);
    m_heightWindow.Add(m_heightText);

    m_sendButton = spawn( vguiButton );
    m_sendButton.SetTitle( "Send" );
    m_sendButton.SetIcon( "gfx/icon16/transmit_blue" );
    m_sendButton.SetPos( [8,320-28] );
    m_sendButton.SetSize([64,24]);
    m_sendButton.SetFuncWithDelegate( Editor_SpawnSelection, this );
    Add( m_sendButton );

    m_setSend = spawn( vguiToggleButton );
    m_setSend.SetIcon("gfx/icon16/table_go");
    m_setSend.SetPreInteractionCallback(Inventory_ModeModified, this);
    m_setSend.SetPostInteractionCallback(Inventory_ModeChanged, this);
    m_setSend.SetSize([24,24]);
    Add( m_setSend );

    m_setInstantiate = spawn( vguiToggleButton );
    m_setInstantiate.SetIcon("gfx/icon16/brick_go");
    m_setInstantiate.SetSize([24,24]);
    m_setInstantiate.SetPreInteractionCallback(Inventory_ModeModified, this);
    m_setInstantiate.SetPostInteractionCallback(Inventory_ModeChanged, this);
    m_setInstantiate.SetValue(1);
    Add( m_setInstantiate );

    Inventory_ShowPictures();
    EntSpawner_SelectionChanged();
    EntSpawner_Resized();
    Inventory_ModeChanged();
}
