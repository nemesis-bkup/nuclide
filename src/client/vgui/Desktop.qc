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
vguiDesktopTheme g_desktopTheme;
var int autocvar_desktop_timeFormat = 0i;
var int autocvar_desktop_screensaver = 0i;
var vector autocvar_desktop_defaultBackgroundColor = [0.227,0.431,0.647];
var vector autocvar_desktop_defaultPanelColor = [0.75, 0.75, 0.75];
var bool autocvar_desktop_timeBusted = true;

void VGUI_ShowMOTD(vguiWidget parentDesktop, bool fullScreen);
void VGUI_PlayerList(vguiWidget parentDesktop);
void VGUI_ShowServerInfo(vguiWidget parentDesktop);
vguiWindow VGUI_ModelSpawner(vguiWidget parentDesktop);

typedef enum
{
	TIMEFORMAT_12HOURS,
	TIMEFORMAT_24HOURS,
	TIMEFORMAT_SWATCH
} timeFormat_t;

/** VGUI: Desktop

A simple desktop, that can be called upon or stuck onto surfaces.

@ingroup vgui
*/
class vguiDesktop:vguiRootWindow
{
public:
	void vguiDesktop(void);

	/* overrides */
	virtual void Draw(void);
	virtual void Spawned(void);

	virtual bool Input(float flEVType, float flKey, float flChar, float flDevID);

	nonvirtual void OpenWebApp(string appName, string appIcon, string webURL, vector initialResolution, bool capturesMouse, bool isResizable);

	nonvirtual string GetTime(void);

private:
	string m_desktopBackground;
	vector m_desktopColor;
	vguiMenuBarItem m_panelMe;
	vguiMenu m_meMenu;
	float m_lastInputTime;
	vguiMenuBar m_menuBar;

	vguiMenuBarItem m_panelWorld;
	vguiMenu m_worldMenu;

	vguiMenuBarItem m_panelBuild;
	vguiMenu m_buildMenu;

	vguiMenuBarItem m_panelHelp;
	vguiMenu m_helpMenu;

	/* about panel */
	vguiPanel m_aboutPanel;
};

void
vguiDesktop::vguiDesktop(void)
{
	m_desktopBackground = g_string_null;
	m_desktopColor = autocvar_desktop_defaultBackgroundColor;
}

void
vguiDesktop::OpenWebApp(string appName, string appIcon, string webURL, vector initialResolution, bool capturesMouse, bool isResizable)
{
	vguiApp_WebDelegate newWindow = vguiApp_WebDelegate::NewWebAppWindow(appName, appIcon, webURL, initialResolution, capturesMouse, isResizable);
	Add(newWindow);
	m_meMenu.Hide();
	newWindow.SetPos([8, 32]);
}

bool
vguiDesktop::Input(float flEVType, float flKey, float flChar, float flDevID)
{
	return super::Input(flEVType, flKey, flChar, flDevID);
	m_lastInputTime = cltime;
}

string
vguiDesktop::GetTime(void)
{
	if (autocvar_desktop_timeFormat == TIMEFORMAT_SWATCH) {
		int currentTime = (int)stoi(strftime(autocvar_desktop_timeBusted, "%s"));
		float beats = (((currentTime + 3600) % 86400) / 86400 * 1000);
		//printf("%i = %s ? %f\n", currentTime, strftime(FALSE, "%s"), beats);
		return strcat("^x000", sprintf("@%03.0f", beats));
	} else if (autocvar_desktop_timeFormat == TIMEFORMAT_12HOURS) {
		string fancyTime = strftime(true - autocvar_desktop_timeBusted, "%I:%M %p");
		return strcat("^x000", fancyTime);
	} else {
		string fancyTime = strftime(true - autocvar_desktop_timeBusted, "%H:%M %Z");
		return strcat("^x000", fancyTime);
	}
}

void
vguiDesktop::OpenApplicationWindow(void)
{
	if (m_meMenu.Visible())
		m_meMenu.Hide();
	else
		m_meMenu.Show();
}

void
vguiDesktop::OpenWorldWindow(void)
{
	if (m_worldMenu.Visible())
		m_worldMenu.Hide();
	else
		m_worldMenu.Show();
}

void
vguiDesktop::OpenBuildWindow(void)
{
	if (m_buildMenu.Visible())
		m_buildMenu.Hide();
	else
		m_buildMenu.Show();
}

void
vguiDesktop::OpenHelpWindow(void)
{
	if (m_helpMenu.Visible())
		m_helpMenu.Hide();
	else
		m_helpMenu.Show();
}

void
vguiDesktop::OpenSettings(void)
{
	if (!STRING_SET(m_desktopBackground)) {
		m_desktopBackground = "gfx/shell/splash8bit.bmp";
	} else {
		m_desktopBackground = __NULL__;
	}

	m_meMenu.Hide();
}

void
vguiDesktop::OpenProfileInventory(void)
{
	vguiInventory newWindow = spawn(vguiInventory);
	Add(newWindow);
	m_meMenu.Hide();
	newWindow.SetPos([8, 32]);
}

void
vguiDesktop::OpenMPDAmp(void)
{
	vguiTool_MPDCon newWindow = spawn(vguiTool_MPDCon);
	Add(newWindow);
	m_meMenu.Hide();
	newWindow.SetPos([8, 32]);
}

void
vguiDesktop::OpenEditor(void)
{
	m_meMenu.Hide();
}

void
vguiDesktop::OpenIRC(void)
{
	m_meMenu.Hide();
}

void
vguiDesktop::OpenCalculator(void)
{
	vguiTool_Calculator newWindow = spawn(vguiTool_Calculator);
	Add(newWindow);
	m_meMenu.Hide();
	newWindow.SetPos([8, 32]);
}

void
vguiDesktop::OpenFinger(void)
{
	vguiTool_Finger newWindow = spawn(vguiTool_Finger);
	Add(newWindow);
	m_meMenu.Hide();
	newWindow.SetPos([8, 32]);
}

void
vguiDesktop::OpenWebSurf(void)
{
	vguiApp_WebSurf newWindow = spawn(vguiApp_WebSurf);
	Add(newWindow);
	m_meMenu.Hide();
	newWindow.SetPos([8, 32]);
}

void
vguiDesktop::OpenConsole(void)
{
	vguiTool_Console newWindow = spawn(vguiTool_Console);
	Add(newWindow);
	m_meMenu.Hide();
	newWindow.SetPos([8, 32]);
}

void
vguiDesktop::OpenGopher(void)
{
	vguiTool_Gopher newWindow = spawn(vguiTool_Gopher);
	Add(newWindow);
	m_meMenu.Hide();
	newWindow.SetPos([8, 32]);
}

void
vguiDesktop::OpenTVTuner(void)
{
	vguiTool_TVTuner newWindow = spawn(vguiTool_TVTuner);
	Add(newWindow);
	m_meMenu.Hide();
	newWindow.SetPos([8, 32]);
}

void
vguiDesktop::OpenMap(void)
{
	vguiTool_Map newWindow = spawn(vguiTool_Map);
	Add(newWindow);
	m_meMenu.Hide();
	newWindow.SetPos([8, 32]);
}

void
vguiDesktop::OpenMOTD(void)
{
	VGUI_ShowMOTD(this, false);
	m_meMenu.Hide();
}

void
vguiDesktop::OpenPlayerList(void)
{
	VGUI_PlayerList(this);
	m_meMenu.Hide();
}

void
vguiDesktop::OpenServerInfo(void)
{
	VGUI_ShowServerInfo(this);
	m_meMenu.Hide();
}

void
vguiDesktop::OpenModelViewer(void)
{
	Add(VGUI_ModelSpawner(this));
	m_helpMenu.Hide();
}

void
vguiDesktop::OpenHome(void)
{
	localcmd("spawnHome\n");
}

void
vguiDesktop::OpenHomeSet(void)
{
	localcmd(sprintf("set ui_home_location %S\n", mapname));
	localcmd(sprintf("set ui_home_org \"%v\"\n", pSeat->m_ePlayer.origin));
	localcmd(sprintf("set ui_home_ang \"%v\"\n", pSeat->m_ePlayer.v_angle));
	localcmd("home_set\n");
}

void
vguiDesktop::OpenMeasure(void)
{
	vguiTool_Measure newWindow = spawn(vguiTool_Measure);
	Add(newWindow);
	m_meMenu.Hide();
	newWindow.SetPos([8, 32]);
}


void
vguiDesktop::OpenXTerminal(void)
{
	vguiTool_XTerminal newWindow = spawn(vguiTool_XTerminal);
	Add(newWindow);
	m_meMenu.Hide();
	newWindow.SetPos([8, 32]);
}

void
vguiDesktop::OpenVoteMap(void)
{
	vguiVote_Map newWindow = spawn(vguiVote_Map);
	Add(newWindow);
	m_worldMenu.Hide();
	newWindow.SetPos([8, 32]);
}

void
vguiDesktop::OpenVotePlayers(void)
{
	vguiVote_Players newWindow = spawn(vguiVote_Players);
	Add(newWindow);
	m_worldMenu.Hide();
	newWindow.SetPos([8, 32]);
}

void
vguiDesktop::OpenAbout(void)
{
	if (m_aboutPanel) {
		m_aboutPanel.Show();
		m_aboutPanel.SetPos((GetSize() / 2) - (m_aboutPanel.GetSize() / 2));
		return;
	}

	m_aboutPanel = spawn(vguiPanel);
	m_aboutPanel.SetPos((GetSize() / 2) - (m_aboutPanel.GetSize() / 2));
	m_aboutPanel.SetTitle("About ...");
	m_aboutPanel.SetSize([200,96]);
	m_aboutPanel.SetIcon("gfx/icon16/help");

	vguiPic m_aboutPic = spawn(vguiPic);
	m_aboutPic.SetPos([16,32]);
	m_aboutPic.SetSize([32,32]);
	m_aboutPic.SetImage("gfx/icon32/system");
	m_aboutPanel.Add(m_aboutPic);

	vguiLabel m_aboutString = spawn(vguiLabel);
	m_aboutString.SetPos([16+32+16,32]);
	m_aboutString.SetTitle(__DATE__);
	m_aboutPanel.Add(m_aboutString);

	m_aboutString = spawn(vguiLabel);
	m_aboutString.SetPos([16+32+16,48]);
	m_aboutString.SetTitle(__TIME__);
	m_aboutPanel.Add(m_aboutString);

	m_aboutString = spawn(vguiLabel);
	m_aboutString.SetPos([16+32+16,64]);
	m_aboutString.SetTitle("(C) 2025 Vera Visions");
	m_aboutPanel.Add(m_aboutString);

	Add(m_aboutPanel);

	m_meMenu.Hide();
}

void
vguiDesktop::Spawned(void)
{
	classname = "vguiDesktop";
	SetMinSize([640,480]);
	SetMaxSize([1024,768]);
	SetSize([640,480]);

	m_menuBar = spawn(vguiMenuBar);
	m_menuBar.SetPos([0,0]);
	m_menuBar.SetSize([g_vidsize[0], 24]);
	m_menuBar.m_panelColor = autocvar_desktop_defaultPanelColor;
	Add(m_menuBar);

	m_panelMe = spawn(vguiMenuBarItem);
	m_panelMe.SetTitle("Me");
	m_panelMe.SetPos([2,2]);
	m_panelMe.SetIcon("gfx/icon16/system");
	m_panelMe.SetFuncWithDelegate(OpenApplicationWindow, this);

	m_panelWorld = spawn(vguiMenuBarItem);
	m_panelWorld.SetTitle("World");
	m_panelWorld.SetPos(m_panelMe.GetPos() + [m_panelMe.GetWidth() + 2,0]);
	m_panelWorld.SetIcon("gfx/icon16/world");
	m_panelWorld.SetFuncWithDelegate(OpenWorldWindow, this);

	m_panelHelp = spawn(vguiMenuBarItem);
	m_panelHelp.SetTitle("Help");
	m_panelHelp.SetPos(m_panelWorld.GetPos() + [m_panelWorld.GetWidth() + 2,0]);
	m_panelHelp.SetIcon("gfx/icon16/help");
	m_panelHelp.SetFuncWithDelegate(OpenHelpWindow, this);

	/* me items */
	m_meMenu = spawn(vguiMenu);
	m_meMenu.SetPos(m_panelMe.GetPos() + [0, 29]);
	m_meMenu.Hide();
	m_meMenu.NewItem("Home", "gfx/icon16/house", OpenHome, this);
	m_meMenu.NewItem("Set Home", "gfx/icon16/house", OpenHomeSet, this);

	vguiMenu infoMenu = m_meMenu.NewSubMenu("Status", "gfx/icon16/user_comment", m_meMenu);
	infoMenu.NewCommandItem("Playing", "gfx/icon16/status_busy",  "setinfo status \"\"");
	infoMenu.NewCommandItem("Spectating", "gfx/icon16/status_online",  "setinfo status \"\"");
	infoMenu.NewCommandItem("Away", "gfx/icon16/status_away",  "setinfo status \"\"");

	vguiMenu infoMenu = m_meMenu.NewSubMenu("Movement", "gfx/icon16/cog", m_meMenu);
	infoMenu.NewCommandItem("1st Person", "gfx/icon16/eye", "pm_thirdPerson 0");
	infoMenu.NewCommandItem("3rd Person", "gfx/icon16/webcam",  "pm_thirdPerson 1");

	/* world items */
	m_worldMenu = spawn(vguiMenu);
	m_worldMenu.SetPos(m_panelWorld.GetPos() + [0, 29]);
	m_worldMenu.Hide();
	m_worldMenu.NewItem("Message of the Day", "gfx/icon16/newspaper", OpenMOTD, this);
	m_worldMenu.NewItem("Server Info", "gfx/icon16/server_chart", OpenServerInfo, this);
	m_worldMenu.NewItem("Player Info", "gfx/icon16/book_addresses", OpenPlayerList, this);
	m_worldMenu.NewItem("Map", "gfx/icon16/map", OpenMap, this);

	vguiMenu voteMenu = m_worldMenu.NewSubMenu("Voting", "gfx/icon16/cog", m_worldMenu);
	voteMenu.NewItem("Map", "gfx/icon16/map", OpenVoteMap, this);
	voteMenu.NewItem("Misc", "gfx/icon16/server_chart", OpenPlayerList, this);
	voteMenu.NewItem("Player", "gfx/icon16/book_addresses", OpenVotePlayers, this);

	/* help items */
	m_helpMenu = spawn(vguiMenu);
	m_helpMenu.SetPos(m_panelHelp.GetPos() + [0, 29]);
	m_helpMenu.Hide();
	m_helpMenu.NewItem("About", "gfx/icon16/help", OpenAbout, this);

	Add(m_panelMe);
	Add(m_meMenu);
	Add(m_panelWorld);
	Add(m_worldMenu);
	Add(m_panelHelp);
	Add(m_helpMenu);

	if (!g_desktopTheme) {
		g_desktopTheme = spawn(vguiDesktopTheme);
	}

	SetTheme(g_desktopTheme);
	g_desktopTheme.RefreshColorValues();
}

float
fakesin(float input, int offset)
{
	input += (float)offset * 0.01;
	return input - (input & 0x007FFFFF);
}

var float autocvar_desktop_jx = 2000;
var float autocvar_desktop_jy = 3000;
void
vguiDesktop::DrawScreenSaver(void)
{
	int itemCount = 100;
	//drawfill(m_vecOrigin, m_vecSize, [0,0,0], 1.0f, 0);


	switch (autocvar_desktop_screensaver) {
	case 0:
		itemCount = 0;
		break;
	case 1:
		itemCount = 10;
		break;
	case 2:
		itemCount = 100;
		break;
	}

	for (int i = itemCount; i > 0; i--) {
		vector logoPos;
		vector systemLogo;
		float cx = m_vecSize[0] / 2;
		float cy = m_vecSize[1] / 2;
		float xp, yp;
		float lightMod = 1.0f;
		vector randomColor;
		string image;

		switch (autocvar_desktop_screensaver) {
		case 1:
			xp = sin((i*autocvar_desktop_jx) + cltime);
			yp = sin((i*autocvar_desktop_jy) + cltime);
			randomColor = [1,1,1];
			image = "gfx/icon32/system";
			break;
		case 2:
			xp = fakesin(cltime, i) * 1.5f;
			yp = fakesin(cltime, i) * 1.5f;
			lightMod = 0.75f;
			image = "gfx/icon32/side_tex";

			randomColor[0] = randomWithSeed(i*49);
			randomColor[1] = randomWithSeed(i*12);
			randomColor[2] = randomWithSeed(i*4);
			randomColor = normalize(randomColor);
			break;
		}

		if (randomWithSeed(i*5) < 0.5) {
			systemLogo[0] = (xp * randomWithSeed(i*19)) * cx;
			logoPos[0] = (systemLogo[0] + cx);
		} else {
			systemLogo[0] = (xp * randomWithSeed(i*19)) * -cx;
			logoPos[0] = (systemLogo[0] + cx);
		}

		if (randomWithSeed(i*15) < 0.5) {
			systemLogo[1] = (yp * randomWithSeed(i*24)) * cy;
			logoPos[1] = (systemLogo[1] + cy);
		} else {
			systemLogo[1] = (yp * randomWithSeed(i*24)) * -cy;
			logoPos[1] = (systemLogo[1] + cy);
		}

		vector logoSize = [32 * yp,32 * yp];
		drawpic(m_vecOrigin + logoPos, image, logoSize, randomColor * fabs(yp) * lightMod, 1.0f, 1);
	}
}

void
vguiDesktop::Draw(void)
{
	vguiTheme currentTheme = GetTheme();

	SetSize(g_vidsize);

	if (m_lastInputTime + 5.0 < time) {
		DrawScreenSaver();
	}

	if (STRING_SET(m_desktopBackground)) {
		drawpic(m_vecOrigin, m_desktopBackground, m_vecSize, [1,1,1], 1.0f, 0);
	} else {
		//drawfill(m_vecOrigin, m_vecSize, m_desktopColor, 1.0f, 0);
		drawpic(m_vecOrigin, "gfx/conback", m_vecSize, m_desktopColor, 1.0f, 1);
	}

	super::Draw();

	/* the time */
	currentTheme.DrawBorder(m_vecOrigin + [m_vecSize[0] - 65, 2], [63, 22], VGUI_BORDER_INSET, __NULL__);
	Font_DrawField(m_vecOrigin + [m_vecSize[0] - 65, 6], [63,18], GetTime(), g_fntDefault, AF_NONE);
}
#endif
