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

vguiWindow VGUI_ModelSpawner(void);
vguiDesktopTheme g_desktopTheme;

var int autocvar_desktop_timeFormat = 0i;

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
class vguiDesktop:vguiView
{
public:
	void vguiDesktop(void);

	/* overrides */
	virtual void Draw(void);
	virtual void Spawned(void);

	nonvirtual string GetTime(void);

private:
	string m_desktopBackground;
	vector m_desktopColor;

	vector m_panelColor;
	vguiButton m_panelApplications;
	
	vguiView m_panelApplicationsView;
};

void
vguiDesktop::vguiDesktop(void)
{
	m_desktopBackground = g_string_null;
	m_desktopColor = [0.1,0.1,0.5];
	m_panelColor = [0.75, 0.75, 0.75];
}

string
vguiDesktop::GetTime(void)
{
	if (autocvar_desktop_timeFormat == TIMEFORMAT_SWATCH) {
		float currentTime = gettime(1);
		float beats = (((currentTime+3600)%86400) / 86400 * 1000);
		return strcat("^x000", sprintf("@%03.0f", beats));
	} else if (autocvar_desktop_timeFormat == TIMEFORMAT_12HOURS) {
		string fancyTime = strftime(true, "%I:%M %p");
		return strcat("^x000", fancyTime);
	} else {
		string fancyTime = strftime(true, "%H:%M %Z");
		return strcat("^x000", fancyTime);
	}
}

void
vguiDesktop::OpenApplicationWindow(void)
{
	if (m_panelApplicationsView.Visible())
		m_panelApplicationsView.Hide();
	else
		m_panelApplicationsView.Show();
}

void
vguiDesktop::OpenSettings(void)
{
	if (!STRING_SET(m_desktopBackground)) {
		m_desktopBackground = "gfx/shell/splash8bit.bmp";
	} else {
		m_desktopBackground = __NULL__;
	}

	m_panelApplicationsView.Hide();
}

void
vguiDesktop::OpenModelViewer(void)
{
	vguiDesktopAppMusic newWindow = spawn(vguiDesktopAppMusic);
	Add(newWindow);
	m_panelApplicationsView.Hide();
}

void
vguiDesktop::Spawned(void)
{
	SetMinSize([640,480]);
	SetMaxSize([1024,768]);
	SetSize([640,480]);

	m_panelApplications = spawn(vguiButton);
	m_panelApplications.SetTitle("Eko");
	m_panelApplications.SetPos([2,2]);
	m_panelApplications.SetSize([54,22]);
	m_panelApplications.SetIcon("gfx/icon16/cup");
	m_panelApplications.SetFuncWithDelegate(OpenApplicationWindow, this);

	m_panelApplicationsView = spawn(vguiView);
	m_panelApplicationsView.SetPos([0, 29]);
	m_panelApplicationsView.SetSize([128,22]);
	m_panelApplicationsView.Hide();

	vguiButton settingsButton = spawn(vguiButton);
	settingsButton.SetTitle("Enable Background");
	settingsButton.SetPos([0,0]);
	settingsButton.SetIcon("gfx/icon16/map");
	settingsButton.SetSize([128,22]);
	settingsButton.SetFuncWithDelegate(OpenSettings, this);

	vguiButton modelViewer = spawn(vguiButton);
	modelViewer.SetTitle("Model Spawner");
	modelViewer.SetPos([0,23]);
	modelViewer.SetIcon("gfx/icon16/map");
	modelViewer.SetSize([128,22]);
	modelViewer.SetFuncWithDelegate(OpenModelViewer, this);

	m_panelApplicationsView.Add(settingsButton);
	m_panelApplicationsView.Add(modelViewer);

	Add(m_panelApplications);
	Add(m_panelApplicationsView);

	if (!g_desktopTheme) {
		g_desktopTheme = spawn(vguiDesktopTheme);
	}

	SetTheme(g_desktopTheme);
	g_desktopTheme.RefreshColorValues();
}

void
vguiDesktop::Draw(void)
{
	vguiTheme currentTheme = GetTheme();

	if (STRING_SET(m_desktopBackground)) {
		drawpic(m_vecOrigin, m_desktopBackground, m_vecSize, [1,1,1], 1.0f, 0);
	} else {
		drawfill(m_vecOrigin, m_vecSize, m_desktopColor, 1.0f, 0);
	}

	/* draw the panel */
	drawfill(m_vecOrigin, [m_vecSize[0], 28], m_panelColor, 1.0f, 0);
	drawfill(m_vecOrigin + [0,26], [m_vecSize[0], 1], m_panelColor * 0.5, 1.0f, 0);
	drawfill(m_vecOrigin + [0,27], [m_vecSize[0], 1], m_panelColor * 0.1, 1.0f, 0);

	currentTheme.DrawBorder(m_vecOrigin + [m_vecSize[0] - 65, 2], [63, 22], VGUI_BORDER_INSET, __NULL__);
	Font_DrawField(m_vecOrigin + [m_vecSize[0] - 65, 6], [63,18], GetTime(), g_fntDefault, AF_NONE);

	float offset = 0;
	for (vguiWindow winEnum = 0; (winEnum = (vguiWindow)find(winEnum, ::classname, "vguiWindow"));) {
		if (winEnum.m_parent != this) {
			continue;
		}
		currentTheme.DrawBorder(m_vecOrigin + [64, 2] + [offset,0], [128, 22], VGUI_BORDER_INSET, __NULL__);
		Font_DrawText(m_vecOrigin + [64, 6] + [offset,0], strcat("^x000", winEnum.m_strTitle), g_fntDefault);
		offset += 129;
	}

	super::Draw();
}
