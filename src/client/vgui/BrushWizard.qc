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
vguiApp_BrushWizard:vguiApplication
{
    void vguiApp_BrushWizard(void);

    virtual void Spawned(void);

    nonvirtual void BrushWizard_Add(void);
    nonvirtual void BrushWizard_Create(void);
    nonvirtual void BrushWizard_Carve(void);

private:

    vguiButton m_newButton;
    vguiButton m_createButton;
    vguiButton m_carveButton;

    vguiTextBox m_minsX;
    vguiTextBox m_minsY;
    vguiTextBox m_minsZ;

    vguiTextBox m_maxsX;
    vguiTextBox m_maxsY;
    vguiTextBox m_maxsZ;

    vguiTextBox m_materialPath;
    vguiToggleButton m_carveToggle;
};

void
vguiApp_BrushWizard::vguiApp_BrushWizard(void)
{
}

void
vguiApp_BrushWizard::BrushWizard_Add(void)
{
    Editor_SetSelectionBrush(m_materialPath.GetText(), m_carveToggle.GetValue());
}

void
vguiApp_BrushWizard::BrushWizard_Create(void)
{
    Editor_SetSelectionBrush(m_materialPath.GetText(), false);
    Editor_SpawnSelection();
}

void
vguiApp_BrushWizard::BrushWizard_Carve(void)
{
    Editor_SetSelectionBrush(m_materialPath.GetText(), true);
    Editor_SpawnSelection();
}

void
vguiApp_BrushWizard::BrushWizard_Resized(void)
{
    vector windowSize = GetSize();
    m_newButton.SetPos( [8,windowSize[1]-28] );
    m_createButton.SetPos( [8+64,windowSize[1]-28] );

    m_carveButton.SetPos( m_createButton.GetPos() + [m_createButton.GetWidth(), 0] );
    m_carveToggle.SetPos( m_carveButton.GetPos() + [m_carveButton.GetWidth() + 4, 0] );
}

void
vguiApp_BrushWizard::BrushWizard_SetHeightOffset(void)
{

}

void
vguiApp_BrushWizard::BrushWizard_SetSize(void)
{

}

void
vguiApp_BrushWizard::BrushWizard_SetSizeChanged(void)
{
    vector newMins;
    newMins[0] = stof(m_minsX.GetText());
    newMins[1] = stof(m_minsY.GetText());
    newMins[2] = stof(m_minsZ.GetText());
    vector newMaxs;
    newMaxs[0] = stof(m_maxsX.GetText());
    newMaxs[1] = stof(m_maxsY.GetText());
    newMaxs[2] = stof(m_maxsZ.GetText());
    Editor_SetBrushSize(newMins, newMaxs);
}

void
vguiApp_BrushWizard::BrushWizard_SetMaterialChanged(void)
{
    Editor_SetSelectionBrush(m_materialPath.GetText(), m_carveToggle.GetValue());
}

void
vguiApp_BrushWizard::Spawned(void)
{
    super::Spawned();

    SetSize( [178,320] );
    SetStyleMask( vguiWindowStyleDefault | vguiWindowResizeable );
    CallOnResize(BrushWizard_Resized);

    m_newButton = spawn( vguiButton );
    m_newButton.SetTitle( "Add" );
    m_newButton.SetIcon( "gfx/icon16/add" );
    m_newButton.SetPos( [8,320-28] );
    m_newButton.SetSize([64,24]);
    m_newButton.SetFuncWithDelegate( BrushWizard_Add, this );

    m_createButton = spawn( vguiButton );
    m_createButton.SetTitle( "Create" );
    m_createButton.SetIcon( "gfx/icon16/cross" );
    m_createButton.SetPos( [8,320-28] );
    m_createButton.SetSize([64,24]);
    m_createButton.SetFuncWithDelegate( BrushWizard_Create, this );

    m_carveButton = spawn( vguiButton );
    m_carveButton.SetTitle( "Carve" );
    m_carveButton.SetIcon( "gfx/icon16/cross" );
    m_carveButton.SetPos( m_createButton.GetPos() + [m_createButton.GetWidth(), 0] );
    m_carveButton.SetSize([64,24]);
    m_carveButton.SetFuncWithDelegate( BrushWizard_Carve, this );

    m_minsX = spawn( vguiTextBox );
    m_minsX.SetPos( [ 8, 32 ] );
    m_minsX.SetSize( [ 124, 24 ] );
    m_minsX.SetText( "-32" );
    m_minsX.CallOnEnterWithDelegate( BrushWizard_SetSizeChanged, this);
    Add(m_minsX);

    m_minsY = spawn( vguiTextBox );
    m_minsY.SetPos( [ 8, 32+28 ] );
    m_minsY.SetSize( [ 124, 24 ] );
    m_minsY.SetText( "-32" );
    m_minsY.CallOnEnterWithDelegate( BrushWizard_SetSizeChanged, this);
    Add(m_minsY);

    m_minsZ = spawn( vguiTextBox );
    m_minsZ.SetPos( [ 8, 32+28+28 ] );
    m_minsZ.SetSize( [ 124, 24 ] );
    m_minsZ.SetText( "-32" );
    m_minsZ.CallOnEnterWithDelegate( BrushWizard_SetSizeChanged, this);
    Add(m_minsZ);

    m_maxsX = spawn( vguiTextBox );
    m_maxsX.SetPos( [ 8 + 128, 32 ] );
    m_maxsX.SetSize( [ 124, 24 ] );
    m_maxsX.SetText( "32" );
    m_maxsX.CallOnEnterWithDelegate( BrushWizard_SetSizeChanged, this);
    Add(m_maxsX);

    m_maxsY = spawn( vguiTextBox );
    m_maxsY.SetPos( [ 8 + 128, 32+28 ] );
    m_maxsY.SetSize( [ 124, 24 ] );
    m_maxsY.SetText( "32" );
    m_maxsY.CallOnEnterWithDelegate( BrushWizard_SetSizeChanged, this);
    Add(m_maxsY);

    m_maxsZ = spawn( vguiTextBox );
    m_maxsZ.SetPos( [ 8 + 128, 32+28+28 ] );
    m_maxsZ.SetSize( [ 124, 24 ] );
    m_maxsZ.SetText( "32" );
    m_maxsZ.CallOnEnterWithDelegate( BrushWizard_SetSizeChanged, this);
    Add(m_maxsZ);

    m_materialPath = spawn( vguiTextBox );
    m_materialPath.SetPos( [ 8, 32+28+28+28 ] );
    m_materialPath.SetSize( [ (124 * 2) + 4, 24 ] );
    m_materialPath.SetText( "detail_pbr/default" );
    m_materialPath.CallOnEnterWithDelegate( BrushWizard_SetMaterialChanged, this);
    Add(m_materialPath);

    m_carveToggle = spawn( vguiToggleButton );
    //m_carveToggle.SetIcon("gfx/icon16/brick_go");
    m_carveToggle.SetPos( m_carveButton.GetPos() + [m_carveButton.GetWidth() + 4, 0] );
    m_carveToggle.SetSize([24,24]);
    m_carveToggle.SetValue(0);
    Add( m_carveToggle );

    Add( m_newButton );
    Add( m_carveButton );
    Add( m_createButton );
    BrushWizard_Resized();
}
