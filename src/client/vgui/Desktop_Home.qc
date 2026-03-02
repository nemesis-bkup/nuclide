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
class vguiDesktop_Home:vguiDesktop_Editor
{
public:
	void vguiDesktop_Home(void);

	/* overrides */
	virtual void Draw(void);
	virtual void Spawned(void);
};

void
vguiDesktop_Home::vguiDesktop_Home(void)
{
}

void
vguiDesktop_Home::Editor_BecomePlayer(void)
{
	localcmd("cmd switchToGame");
}

void
vguiDesktop_Home::Editor_BecomeEditor(void)
{
	localcmd("cmd switchToEditor");
}


void
vguiDesktop_Home::Editor_ChangePlayerClass_Done(vguiWidget sender)
{
	vguiTextPrompt lastPrompt = (vguiList)sender;
	string searchString = lastPrompt.textBox.GetText();
	localcmd(sprintf("cmd changePlayerClass %S\n", searchString));
}

void
vguiDesktop_Home::Editor_ChangePlayerClass(void)
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
vguiDesktop_Home::Editor_EntitySpawner(void)
{
	vguiTool_EntityDefList newWindow = spawn(vguiTool_EntityDefList);
	Add(newWindow);
	m_meMenu.Hide();
	newWindow.SetPos([8, 32]);
}

void
vguiDesktop_Home::Editor_EntityClean(void)
{
	localcmd("cmd cleanMap\n");
}

void
vguiDesktop_Home::Editor_UIEditor(void)
{
	vguiTool_UIEditor newWindow = spawn(vguiTool_UIEditor);
	Add(newWindow);
	m_meMenu.Hide();
	newWindow.SetPos([8, 32]);
}

void
vguiDesktop_Home::Editor_UIEnable(void)
{
	localcmd("cmd enableHud;set g_showHud 1\n");
}

void
vguiDesktop_Home::Editor_UIDisable(void)
{
	localcmd("cmd disableHud;set g_showHud 0\n");
}

void
vguiDesktop_Home::OpenGameWindow(void)
{
	if (m_gameMenu.Visible())
		m_gameMenu.Hide();
	else
		m_gameMenu.Show();
}

void
vguiDesktop_Home::Spawned(void)
{
	int itemCount = ncUserInventory::GetItemCount(ITEM_APP);
	super::Spawned();

	vguiMenu appsMenu = m_meMenu.NewSubMenu("Games", "gfx/icon16/joystick", m_meMenu);

	for ( int i = 0; i < itemCount; i++ ) {
		ncDict appDict = ncUserInventory::GetItemDictByIndex(i, ITEM_APP);
		string dictName = appDict.Name();

		bool webShim = appDict.GetBool("webShim");

		if (webShim == false) {
			continue;
		}

		string appName = appDict.GetString("name");
		string appIcon = appDict.GetString("icon");
		string appURL = appDict.GetString("url");
		vector appResolution = appDict.GetVector("resolution");
		bool captureMouse = appDict.GetBool("captureMouse");
		bool isResizable = appDict.GetBool("resizable");

		if (appResolution == g_vec_null) {
			appResolution = [640,480];
		}

		appsMenu.NewCommandItem(appName, appIcon, sprintf("runWebApp %d %S %S %S %d %d %d %d", num_for_edict(this), appName, appIcon, appURL, appResolution[0], appResolution[1], captureMouse, isResizable));
	}

	m_meMenu.NewItem("Inventory", "gfx/icon16/box", OpenProfileInventory, this);

	vguiMenu netMenu = m_meMenu.NewSubMenu("Networking", "gfx/icon16/world", m_meMenu);
	netMenu.NewItem("IRC Chat", "gfx/icon16/comment", OpenIRC, this);
	netMenu.NewItem("Gopher", "gfx/icon16/sitemap_color", OpenGopher, this);
	netMenu.NewItem("Finger", "gfx/icon16/vcard", OpenFinger, this);

	/* libcef plugin users ONLY! */
	if (checkcommand("cef") != 0) {
		netMenu.NewItem("WebSurf", "gfx/icon16/world", OpenWebSurf, this);
	}

	vguiMenu toolsMenu = m_helpMenu.NewSubMenu("Utilities", "gfx/icon16/wrench", m_helpMenu);
	toolsMenu.NewItem("Text Editor", "gfx/icon16/page_edit", OpenEditor, this);
	toolsMenu.NewItem("Calculator", "gfx/icon16/calculator", OpenCalculator, this);
	toolsMenu.NewItem("Console", "gfx/icon16/application_xp_terminal", OpenConsole, this);
	toolsMenu.NewItem("Measure", "gfx/icon16/text_horizontalrule", OpenMeasure, this);
	toolsMenu.NewItem("Model Viewer", "gfx/icon16/images", OpenModelViewer, this);
	toolsMenu.NewItem("XTerminal", "gfx/icon16/application_osx_terminal", OpenXTerminal, this);

}

void
vguiDesktop_Home::Draw(void)
{
	vguiTheme currentTheme = GetTheme();

	m_menuBar.SetSize([g_vidsize[0], 24]);
	SetSize(g_vidsize);
	SetMaxSize(g_vidsize);

	vguiRootWindow::Draw();

	/* the time */
	currentTheme.DrawBorder(m_vecOrigin + [m_vecSize[0] - 65, 2], [63, 22], VGUI_BORDER_INSET, __NULL__);
	Font_DrawField(m_vecOrigin + [m_vecSize[0] - 65, 6], [63,18], GetTime(), g_fntDefault, AF_NONE);
}
#endif
