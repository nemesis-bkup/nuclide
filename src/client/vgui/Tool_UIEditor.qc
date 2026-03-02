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
vguiUIEditor_EditWindow:vguiWindow
{
	void vguiUIEditor_EditWindow(void);

	virtual void Spawned(void);

	nonvirtual void EditWindow_Apply(void);
	nonvirtual void RefreshValues(void);

private:

	vguiTextBox m_textName;
	vguiLabel m_labelName;
	vguiTextBox m_textText;
	vguiLabel m_labelText;
	vguiTextBox m_textType;
	vguiLabel m_labelType;
	vguiTextBox m_textPosition;
	vguiLabel m_labelPosition;
	vguiTextBox m_textSize;
	vguiLabel m_labelSize;

	vguiButton btnApply;
	vguiButton btnClear;
	vguiScriptedItem targetItem;
};

void
vguiUIEditor_EditWindow::vguiUIEditor_EditWindow(void)
{
}

void
vguiUIEditor_EditWindow::RefreshValues(void)
{
	m_textName.SetText(targetItem.m_trItemName);
	m_textText.SetText(targetItem.m_trItemText);
	m_textType.SetText(itos(targetItem.m_trItemType));
	m_textPosition.SetText(vtos(targetItem.m_trItemRectMins));
	m_textSize.SetText(vtos(targetItem.m_trItemRectMaxs));
}


void
vguiUIEditor_EditWindow::EditWindow_Apply(void)
{

}


void
vguiUIEditor_EditWindow::EditWindow_Resized(void)
{
	vector windowSize = GetSize();

	m_textName.SetSize([windowSize[0]-64-16,24]);
	m_textText.SetSize([windowSize[0]-64-16,24]);
	m_textType.SetSize([windowSize[0]-64-16,24]);
	m_textPosition.SetSize([windowSize[0]-64-16,24]);
	m_textSize.SetSize([windowSize[0]-64-16,24]);

	btnApply.SetPos( [8,windowSize[1]-28] );
}

void
vguiUIEditor_EditWindow::Spawned(void)
{
	super::Spawned();

	classname = "vguiWindow";
	SetTitle( "Edit Item" );
	SetSize( [178,320] );
	SetPos( [8,32] );
	SetIcon( "gfx/icon16/vcard" );
	SetStyleMask( vguiWindowStyleDefault | vguiWindowResizeable );
	CallOnResize(EditWindow_Resized);

	btnApply = spawn( vguiButton );
	btnApply.SetTitle( "Apply" );
	btnApply.SetIcon( "gfx/icon16/apply" );
	btnApply.SetPos( [8,320-28] );
	btnApply.SetSize([64,24]);
	btnApply.SetFuncWithDelegate( EditWindow_Apply, this );

	m_labelName = spawn( vguiLabel );
	m_labelName.SetTitle("Name:");
	m_labelName.SetPos([8,32]);
	m_labelName.SetSize([64,24]);
	m_labelText = spawn( vguiLabel );
	m_labelText.SetTitle("Text:");
	m_labelText.SetPos(m_labelName.GetPos() + [0,26]);
	m_labelText.SetSize([64,24]);
	m_labelType = spawn( vguiLabel );
	m_labelType.SetTitle("Type:");
	m_labelType.SetPos(m_labelText.GetPos() + [0,26]);
	m_labelType.SetSize([64,24]);
	m_labelPosition = spawn( vguiLabel );
	m_labelPosition.SetTitle("Pos:");
	m_labelPosition.SetPos(m_labelType.GetPos() + [0,26]);
	m_labelPosition.SetSize([64,24]);
	m_labelSize = spawn( vguiLabel );
	m_labelSize.SetTitle("Size:");
	m_labelSize.SetPos(m_labelPosition.GetPos() + [0,26]);
	m_labelSize.SetSize([64,24]);

	m_textName = spawn( vguiTextBox );
	m_textName.SetPos(m_labelName.GetPos() + [m_labelName.GetWidth(), 0]);
	m_textName.SetSize([64,24]);
	m_textText = spawn( vguiTextBox );
	m_textText.SetPos(m_textName.GetPos() + [0, m_textName.GetHeight()]);
	m_textText.SetSize([64,24]);
	m_textType = spawn( vguiTextBox );
	m_textType.SetPos(m_textText.GetPos() + [0, m_textText.GetHeight()]);
	m_textType.SetSize([64,24]);
	m_textPosition = spawn( vguiTextBox );
	m_textPosition.SetPos(m_textType.GetPos() + [0, m_textType.GetHeight()]);
	m_textPosition.SetSize([64,24]);
	m_textSize = spawn( vguiTextBox );
	m_textSize.SetPos(m_textPosition.GetPos() + [0, m_textPosition.GetHeight()]);
	m_textSize.SetSize([64,24]);

	Add( btnApply );


	Add(  m_textName );
	Add(  m_labelName );
	Add(  m_textText );
	Add(  m_labelText );
	Add(  m_textType );
	Add(  m_labelType );
	Add(  m_textPosition );
	Add(  m_labelPosition );
	Add(  m_textSize );
	Add(  m_labelSize );
	EditWindow_Resized();
}


class
vguiTool_UIEditor:vguiWindow
{
	void vguiTool_UIEditor(void);

	virtual void Spawned(void);

	nonvirtual void UIEditor_Go(void);
	nonvirtual void UIEditor_ScrollUpdate(void);
	nonvirtual void UIEditor_ListUpdate(void);

private:

	vguiList lsbEntries;
	vguiScrollBar scrlSong;
	vguiButton btnGo;
	bool m_isConnected;
};

void
vguiTool_UIEditor::vguiTool_UIEditor(void)
{
	m_isConnected = false;
}

void
vguiTool_UIEditor::UIEditor_Go(void)
{
	string targetItemName = lsbEntries.GetItem(lsbEntries.GetSelected());

	vguiUIEditor_EditWindow newEditor = spawn(vguiUIEditor_EditWindow);
	m_parent.Add(newEditor);

	for (vguiScriptedItem findItem = 0; (findItem = (vguiScriptedItem)find(findItem, ::classname, "vguiScriptedItem"));) {
		if (findItem.m_trItemName == targetItemName) {
			newEditor.targetItem = findItem;
			newEditor.RefreshValues();
		}
	}
}

void
vguiTool_UIEditor::UIEditor_ScrollUpdate(void)
{
	scrlSong.SetValue( lsbEntries.GetOffset() );
}

void
vguiTool_UIEditor::UIEditor_ListUpdate(void)
{
	lsbEntries.SetOffset( scrlSong.GetValue(), FALSE );
}

void
vguiTool_UIEditor::UIEditor_Resized(void)
{
	vector windowSize = GetSize();
	lsbEntries.SetSize( [windowSize[0]-16-21, windowSize[1]-64] );
	scrlSong.SetLength( windowSize[1]-64 );
	scrlSong.SetPos( [windowSize[0]-21,32] );

	btnGo.SetPos( [8,windowSize[1]-28] );
}

int
vguiTool_UIEditor::UIEditor_ItemCount(void)
{
	int itemCount = 0i;

	for (vguiWindow findWindows = 0; (findWindows = (vguiWindow)find(findWindows, ::classname, "vguiScriptedItem"));) {
		itemCount++;
	}

	return (itemCount);
}

void
vguiTool_UIEditor::Spawned(void)
{
	super::Spawned();

	classname = "vguiWindow";
	SetTitle( "UI Editor" );
	SetSize( [178,320] );
	SetIcon( "gfx/icon16/vcard" );
	SetStyleMask( vguiWindowStyleDefault | vguiWindowResizeable );
	CallOnResize(UIEditor_Resized);

	lsbEntries = spawn( vguiList );
	lsbEntries.SetSize( [480-16-21, 320-64] );
	lsbEntries.SetPos( [8, 32] );
	lsbEntries.CallOnScrollWithDelegate( UIEditor_ScrollUpdate, this );

	scrlSong = spawn( vguiScrollBar );
	scrlSong.SetLength( 320-64 );
	scrlSong.SetPos( [480-21,32] );
	scrlSong.SetMin( 0 );
	scrlSong.SetStep( 1 );
	scrlSong.CallOnChangeWithDelegate( UIEditor_ListUpdate, this );
	btnGo = spawn( vguiButton );
	btnGo.SetTitle( "Edit" );
	btnGo.SetIcon( "gfx/icon16/table_edit" );
	btnGo.SetPos( [8,320-28] );
	btnGo.SetSize([64,24]);
	btnGo.SetFuncWithDelegate( UIEditor_Go, this );

	int itemCount = UIEditor_ItemCount();
	lsbEntries.SetItemCount( itemCount );
	scrlSong.SetMax( itemCount );

	for (vguiScriptedItem findWindows = 0; (findWindows = (vguiScriptedItem)find(findWindows, ::classname, "vguiScriptedItem"));) {
		lsbEntries.AddItem( findWindows.m_trItemName );
	}

	Add( lsbEntries );
	Add( scrlSong );
	Add( btnGo );
	UIEditor_Resized();
}
