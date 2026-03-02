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

#ifdef CLIENT
/** VGUI: Editor Desktop

A simple desktop, that can be called upon or stuck onto surfaces.

@ingroup vgui
*/
class vguiDesktop_Editor:vguiDesktop
{
public:
	void vguiDesktop_Editor(void);

	/* overrides */
	virtual void Draw(void);
	virtual void Spawned(void);
	virtual bool Input(float flEVType, float flKey, float flChar, float flDevID);
	nonvirtual void UpdateSelectionOrigin(vector);

    nonvirtual void SetSelectionEntity(string entityClass);
    nonvirtual void SetSelectionProfileItem(string itemName, profileItem_t itemType);
    nonvirtual void SetSelectionURLItem(string itemURL, string itemType, string groupName);

private:
	vguiTextPrompt m_editorPlayerClassPrompt;
	vguiMenuBarItem m_panelGame;
	vguiMenu m_gameMenu;

	ncSelectionProxy m_currentSelection; /**< the box that's used to spawn geometric shapes. */
	bool m_currentSelectionUpdate;
	bool m_mouseHeld;
    bool m_altMouseHeld;
	vector m_vecMousePos;
};

void
vguiDesktop_Editor::vguiDesktop_Editor(void)
{
	m_editorPlayerClassPrompt = __NULL__;
	m_currentSelectionUpdate = false;
}

void
vguiDesktop_Editor::SetSelectionEntity(string entityClass)
{
	bool isNew = false;

	if (!m_currentSelection) {
		m_currentSelection = spawn(ncSelectionProxy);
		isNew = true;
	}
	ncSelectionProxy currentSel = (ncSelectionProxy)m_currentSelection;
    currentSel.SetSelectionEntity(entityClass);

	if (isNew) {
		UpdateSelectionOrigin(GetAbsPos() + (GetSize() / 2));
	}
}

void
vguiDesktop_Editor::SetSelectionURLItem(string itemURL, string itemType, string groupName)
{
	bool isNew = false;

	if (!m_currentSelection) {
		m_currentSelection = spawn(ncSelectionProxy);
		isNew = true;
	}
	ncSelectionProxy currentSel = (ncSelectionProxy)m_currentSelection;
    currentSel.SetSelectionURLItem(itemURL, itemType, groupName);

	if (isNew) {
		UpdateSelectionOrigin(GetAbsPos() + (GetSize() / 2));
	}
}

void
vguiDesktop_Editor::SetSelectionProfileItem(string itemName, profileItem_t itemType)
{
	bool isNew = false;

	if (!m_currentSelection) {
		m_currentSelection = spawn(ncSelectionProxy);
		isNew = true;
	}
	ncSelectionProxy currentSel = (ncSelectionProxy)m_currentSelection;
    currentSel.SetSelectionProfileItem(itemName, itemType);

	if (isNew) {
		UpdateSelectionOrigin(GetAbsPos() + (GetSize() / 2));
	}
}

void
vguiDesktop_Editor::UpdateSelectionOrigin(vector mousePos)
{
	ncSelectionProxy ourSel = (ncSelectionProxy)m_currentSelection;
    ourSel.MoveToMouseCoordinates(mousePos);
}

void
vguiDesktop_Editor::SpawnSelection(void)
{
	ncSelectionProxy ourSel = (ncSelectionProxy)m_currentSelection;
    ourSel.SpawnSelection();
}

void
vguiDesktop_Editor::ClearSelection(void)
{
	ncSelectionProxy ourSel = (ncSelectionProxy)m_currentSelection;
    ourSel.ClearSelection();
}

void
vguiDesktop_Editor::SelectNearPointer(void)
{
	ncSelectionProxy ourSel = (ncSelectionProxy)m_currentSelection;
    ourSel.MoveToMouseCoordinates(m_vecMousePos);
    ourSel.SelectNearPointer();
    EntError("SelectNearPointer");
}

void
vguiDesktop_Editor::Editor_BecomePlayer(void)
{
	localcmd("cmd switchToGame");
}

void
vguiDesktop_Editor::Editor_BecomeEditor(void)
{
	localcmd("cmd switchToEditor");
}

void
vguiDesktop_Editor::Editor_ChangePlayerClass_Done(vguiWidget sender)
{
	vguiTextPrompt lastPrompt = (vguiList)sender;
	string searchString = lastPrompt.textBox.GetText();
	localcmd(sprintf("cmd changePlayerClass %S\n", searchString));
}

void
vguiDesktop_Editor::Editor_ChangePlayerClass(void)
{
	if (!m_editorPlayerClassPrompt) {
		m_editorPlayerClassPrompt = spawn( vguiTextPrompt );
		Add( m_editorPlayerClassPrompt );
		m_editorPlayerClassPrompt.SetOKAction(Editor_ChangePlayerClass_Done, this);
		m_editorPlayerClassPrompt.SetIcon("gfx/icon16/application_form_edit");
		m_editorPlayerClassPrompt.SetTitle("Change Player Class");
		m_editorPlayerClassPrompt.SetPos(GetPos() + (GetSize() / 2) - (m_editorPlayerClassPrompt.GetSize() / 2));
		} else {
		m_editorPlayerClassPrompt.Show();
		m_editorPlayerClassPrompt.NowVisible();
	}
}

void
vguiDesktop_Editor::Editor_EntitySpawner(void)
{
	vguiTool_EntityDefList newWindow = spawn(vguiTool_EntityDefList);
	Add(newWindow);
	m_meMenu.Hide();
	newWindow.SetPos([8, 32]);
}

void
vguiDesktop_Editor::Editor_EntityClean(void)
{
	localcmd("cmd cleanMap\n");
}

void
vguiDesktop_Editor::Editor_UIEditor(void)
{
	vguiTool_UIEditor newWindow = spawn(vguiTool_UIEditor);
	Add(newWindow);
	m_meMenu.Hide();
	newWindow.SetPos([8, 32]);
}

void
vguiDesktop_Editor::Editor_UIEnable(void)
{
	localcmd("cmd enableHud;set g_showHud 1\n");
}

void
vguiDesktop_Editor::Editor_UIDisable(void)
{
	localcmd("cmd disableHud;set g_showHud 0\n");
}

void
vguiDesktop_Editor::OpenGameWindow(void)
{
	if (m_gameMenu.Visible())
		m_gameMenu.Hide();
	else
		m_gameMenu.Show();
}

void
vguiDesktop_Editor::Spawned(void)
{
	super::Spawned();

	m_panelBuild = spawn(vguiMenuBarItem);
	m_panelBuild.SetTitle("#EDITOR_BUILD");
	m_panelBuild.SetPos(m_panelWorld.GetPos() + [m_panelWorld.GetWidth() + 2,0]);
	m_panelBuild.SetIcon("gfx/icon16/building");
	m_panelBuild.SetFuncWithDelegate(OpenBuildWindow, this);

	/* build items */
	m_buildMenu = spawn(vguiMenu);
	m_buildMenu.SetPos(m_panelBuild.GetPos() + [0, 29]);
	m_buildMenu.Hide();

	vguiMenu hudMenu = m_buildMenu.NewSubMenu("#EDITOR_HEADSUPDISPLAY", "gfx/icon16/joystick",m_buildMenu);
	hudMenu.NewItem("#EDITOR_UIEDIT", "gfx/icon16/user", Editor_UIEditor, this);
	hudMenu.NewItem("#EDITOR_ENABLE", "gfx/icon16/user", Editor_UIEnable, this);
	hudMenu.NewItem("#EDITOR_DISABLE", "gfx/icon16/user", Editor_UIDisable, this);


	vguiMenu entMenu = m_buildMenu.NewSubMenu("#EDITOR_ENTITIES", "gfx/icon16/joystick", m_buildMenu);
	entMenu.NewItem("#EDITOR_ENTITYDEFS", "gfx/icon16/user", Editor_EntitySpawner, this);
	entMenu.NewItem("#EDITOR_CLEANUP", "gfx/icon16/trash", Editor_EntityClean, this);

	m_panelGame = spawn(vguiMenuBarItem);
	m_panelGame.SetPos(m_panelBuild.GetPos() + [m_panelBuild.GetWidth() + 2,0]);
	m_panelGame.SetTitle("#EDITOR_GAME");
	m_panelGame.SetIcon("gfx/icon16/joystick");
	m_panelGame.SetFuncWithDelegate(OpenGameWindow, this);

	m_gameMenu = spawn(vguiMenu);
	m_gameMenu.SetPos(m_panelGame.GetPos() + [0, 29]);
	m_gameMenu.NewItem("#EDITOR_BE_PLAYER", "gfx/icon16/user", Editor_BecomePlayer, this);
	m_gameMenu.NewItem("#EDITOR_BE_EDITOR", "gfx/icon16/layout_edit", Editor_BecomeEditor, this);
	m_gameMenu.NewItem("#EDITOR_CHANGECLASS", "gfx/icon16/application_form_edit", Editor_ChangePlayerClass, this);
	m_gameMenu.Hide();

	m_panelHelp.SetPos(m_panelGame.GetPos() + [m_panelGame.GetWidth() + 2,0]);
	m_helpMenu.SetPos(m_panelHelp.GetPos() + [0, 29]);

	Add(m_panelBuild);
	Add(m_buildMenu);
	Add(m_panelGame);
	Add(m_gameMenu);
}

void
vguiDesktop_Editor::UpdateCurrentSelection(void)
{
	if (!m_currentSelection) {
		return;
	}

	m_currentSelection.drawmask = MASK_ENGINE;

	if (m_currentSelectionUpdate == false) {
		return;
	}

	UpdateSelectionOrigin(m_vecMousePos);
}

void
vguiDesktop_Editor::Draw(void)
{
	vguiTheme currentTheme = GetTheme();

	SetSize(g_vidsize);

	currentTheme.DrawBorder(m_vecOrigin + [m_vecSize[0] - 65, 2], [63, 22], VGUI_BORDER_INSET, __NULL__);
	Font_DrawField(m_vecOrigin + [m_vecSize[0] - 65, 6], [63,18], GetTime(), g_fntDefault, AF_NONE);

	float offset = 0;
	for (vguiWindow winEnum = 0; (winEnum = (vguiWindow)find(winEnum, ::classname, "vguiWindow"));) {
		if (!winEnum.Visible() || winEnum.m_parent != this) {
			continue;
		}
		currentTheme.DrawBorder(m_vecOrigin + [64, 2] + [offset,0], [128, 22], VGUI_BORDER_INSET, __NULL__);
		drawpic(m_vecOrigin + [64,6] + [4 + offset, 0], winEnum.m_strIcon, [16,16], [1,1,1], 1.0f, 0);
		Font_DrawText(m_vecOrigin + [64 + 18, 6] + [4 + offset,4], strcat("^x000", winEnum.m_strTitle), g_fntDefault);
		offset += 129;
	}

	vguiView::Draw();
}

bool
vguiDesktop_Editor::Input(float flEVType, float flKey, float flChar, float flDevID)
{
	switch (flEVType) {
	case IE_KEYDOWN:
		if (flKey == K_MOUSE1) {
			m_mouseHeld = true;
		}

		if (flKey == K_MOUSE2) {
            m_altMouseHeld = true;
        }

        if (m_currentSelection) {
            if (flKey == K_LSHIFT) {
                m_currentSelectionUpdate = true;
            }
            if (flKey == K_MWHEELUP) {
                if (!m_currentSelectionUpdate)
                    m_currentSelection.angles[1] += 10;
                else
                    m_currentSelection.angles[1] += 1;
            }
            if (flKey == K_MWHEELDOWN) {
                if (!m_currentSelectionUpdate)
                    m_currentSelection.angles[1] -= 10;
                else
                    m_currentSelection.angles[1] -= 1;
            }
        }
		break;
	case IE_KEYUP:
		if (flKey == K_MOUSE1) {
			if (m_mouseHeld == true && m_currentSelectionUpdate) {
				SpawnSelection();
			}
			m_mouseHeld = false;
		}
		if (flKey == K_MOUSE2) {
            /* clear selection with mouse2 */
            if (m_altMouseHeld == true && STRING_SET(m_currentSelection.m_itemName)) {
                ClearSelection();
            } else if (m_altMouseHeld == true) {
                SelectNearPointer();
            }

			m_altMouseHeld = false;
		}
		if (flKey == K_LSHIFT) {
			m_currentSelectionUpdate = false;
		}
		break;
	case IE_MOUSEABS:
		m_vecMousePos[0] = flKey;
		m_vecMousePos[1] = flChar;
		break;
	case IE_MOUSEDELTA:
		m_vecMousePos[0] += flKey;
		m_vecMousePos[1] += flChar;
		break;
	default:
		return (true);
	}

	if (!m_currentSelection) {
		m_lastInputTime = cltime;
		return super::Input(flEVType, flKey, flChar, flDevID);
	}

	UpdateCurrentSelection();

	m_lastInputTime = cltime;
	return super::Input(flEVType, flKey, flChar, flDevID);
}
#endif
