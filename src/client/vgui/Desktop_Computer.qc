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
/** VGUI: Computer Desktop

used by ncComputerDesktop

@ingroup vgui
*/
class vguiDesktop_Computer:vguiDesktop
{
public:
    void vguiDesktop_Computer(void);

    /* overrides */
    virtual void Draw(void);
    virtual void Spawned(void);

private:
    vguiTextPrompt m_editorPlayerClassPrompt;
    vguiMenuBarItem m_panelGame;
    vguiMenu m_gameMenu;

    string m_currentClass;
    entity m_currentSelection; /**< the box that's used to spawn geometric shapes. */
    bool m_currentSelectionUpdate;
    bool m_mouseHeld;
    vector m_vecMousePos;
};

void
vguiDesktop_Computer::vguiDesktop_Computer(void)
{
    m_editorPlayerClassPrompt = __NULL__;
    m_currentSelectionUpdate = false;
}

void
vguiDesktop_Computer::SetSelectionEntity(string entityClass)
{
    bool isNew = false;
    if (!m_currentSelection) {
        m_currentSelection = spawn(ncRenderableEntity);
        isNew = true;
    }

    string entModel = EntityDef_GetKeyValue(entityClass, "editor_model");
    string entColor = EntityDef_GetKeyValue(entityClass, "editor_color");
    string entMins = EntityDef_GetKeyValue(entityClass, "editor_mins");
    string entMaxs = EntityDef_GetKeyValue(entityClass, "editor_maxs");

    /* various fallbacks */
    if (!STRING_SET(entModel)) {
        entModel = EntityDef_GetKeyValue(entityClass, "model");
    }

    if (!STRING_SET(entMins)) {
        entMins = EntityDef_GetKeyValue(entityClass, "mins");
    }

    if (!STRING_SET(entMaxs)) {
        entMaxs = EntityDef_GetKeyValue(entityClass, "maxs");
    }

    ncRenderableEntity currentSel = (ncRenderableEntity)m_currentSelection;

    currentSel.SetModel(entModel);
    currentSel.SetSize(stov(entMins), stov(entMaxs));
    m_currentClass = entityClass;
}

void
vguiDesktop_Computer::UpdateSelectionOrigin(vector mousePos)
{
    ncRenderableEntity ourSelf = (ncRenderableEntity)m_currentSelection;
    g_view.SetupView();
    vector traceStart = unproject([mousePos[0], mousePos[1], 0]);
    vector traceEnd = unproject([mousePos[0], mousePos[1], 1024]);
    other = world;
    traceline(traceStart, traceEnd, MOVE_OTHERONLY, g_view.m_viewTarget);
    ourSelf.SetOrigin(trace_endpos - [0,0,m_currentSelection.mins[2]]);

}

void
vguiDesktop_Computer::SpawnSelection(void)
{
    ncCommand("cmd shareEntity %S %S \"%v\" \"%v\"\n", m_currentClass, m_currentSelection.model, m_currentSelection.origin, m_currentSelection.angles);
    //ncRenderableEntity currentSel = (ncRenderableEntity)m_currentSelection;
    //currentSel.Destroy();
    //m_currentSelection = 0;
}

void
vguiDesktop_Computer::Editor_BecomePlayer(void)
{
    ncCommand("cmd switchToGame");
}

void
vguiDesktop_Computer::Editor_BecomeEditor(void)
{
    ncCommand("cmd switchToEditor");
}

void
vguiDesktop_Computer::Editor_ChangePlayerClass_Done(vguiWidget sender)
{
    vguiTextPrompt lastPrompt = (vguiList)sender;
    string searchString = lastPrompt.textBox.GetText();
    ncCommand("cmd changePlayerClass %S", searchString);
}

void
vguiDesktop_Computer::Editor_ChangePlayerClass(void)
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
vguiDesktop_Computer::Editor_EntitySpawner(void)
{
    vguiTool_EntityDefList newWindow = spawn(vguiTool_EntityDefList);
    Add(newWindow);
    m_meMenu.Hide();
    newWindow.SetPos([8, 32]);
}

void
vguiDesktop_Computer::Editor_EntityClean(void)
{
    ncCommand("cmd cleanMap");
}

void
vguiDesktop_Computer::Editor_UIEditor(void)
{
    vguiTool_UIEditor newWindow = spawn(vguiTool_UIEditor);
    Add(newWindow);
    m_meMenu.Hide();
    newWindow.SetPos([8, 32]);
}

void
vguiDesktop_Computer::Editor_UIEnable(void)
{
    ncCommand("cmd enableHud;set g_showHud 1");
}

void
vguiDesktop_Computer::Editor_UIDisable(void)
{
    ncCommand("cmd disableHud;set g_showHud 0");
}

void
vguiDesktop_Computer::OpenGameWindow(void)
{
    if (m_gameMenu.Visible())
        m_gameMenu.Hide();
    else
        m_gameMenu.Show();
}

void
vguiDesktop_Computer::Spawned(void)
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

    Add(m_panelBuild);
    Add(m_buildMenu);

    m_panelHelp.SetPos(m_panelBuild.GetPos() + [m_panelBuild.GetWidth() + 2,0]);
    m_helpMenu.SetPos(m_panelHelp.GetPos() + [0, 29]);


#if 0
    searchhandle shSearchAppLibrary = search_begin( "decls/apps/*.app", SEARCH_NAMESORT | SEARCH_MULTISEARCH, TRUE );
    searchhandle shSearchAppPlayer = search_begin( "data/players/Default/decls/apps/*.app", SEARCH_NAMESORT | SEARCH_MULTISEARCH, TRUE );

    vguiMenu appsMenu = m_meMenu.NewSubMenu("Games", "gfx/icon16/joystick", m_meMenu);

    for ( int i = 0; i < search_getsize( shSearchAppLibrary ); i++ ) {
        string dictName = substring(search_getfilename( shSearchAppLibrary, i ), 11, -5);
        ncDict appDict = ncDict::LoadDeclFromFile(dictName, sprintf("apps/%s.app", dictName));

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

        appsMenu.NewCommandItem(appName, appIcon, sprintf("runWebApp %S %S %S %d %d %d %d", appName, appIcon, appURL, appResolution[0], appResolution[1], captureMouse, isResizable));
    }

    for ( int i = 0; i < search_getsize( shSearchAppPlayer ); i++ ) {
        string dictName = substring(search_getfilename( shSearchAppPlayer, i ), 32, -5);
        ncDict appDict = ncDict::LoadDeclFromFile(dictName, sprintf("apps/%s.app", dictName));

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

    vguiMenu mediaMenu = m_buildMenu.NewSubMenu("Multimedia", "gfx/icon16/film_link", m_buildMenu);
    mediaMenu.NewItem("Video Player", "gfx/icon16/film", OpenVideoPlayer, this);

    /* libcef plugin users ONLY! */
    if (checkcommand("cef") != 0) {
        mediaMenu.NewItem("Audio Player", "gfx/icon16/music", OpenAudioPlayer, this);
    }

    mediaMenu.NewItem("MPD Client", "gfx/icon16/ipod", OpenMPDAmp, this);
    mediaMenu.NewItem("TV Tuner", "gfx/icon16/television", OpenTVTuner, this);
    mediaMenu.NewItem("Image Viewer", "gfx/icon16/picture", OpenImageViewer, this);
#endif

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
vguiDesktop_Computer::Draw(void)
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

#endif
