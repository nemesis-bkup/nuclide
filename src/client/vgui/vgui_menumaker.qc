/*
 * Copyright (c) 2016-2025 Vera Visions LLC.
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
vguiMenuMakerWindow:vguiWindow
{
public:
	void vguiMenuMakerWindow(void);

private:
	vguiPic m_previewImage;
	vguiLabel m_titleText;
	vguiLabel m_descriptionText;
	string m_textMenuName;
};

void
vguiMenuMakerWindow::vguiMenuMakerWindow(void)
{
	m_previewImage = __NULL__;
	m_titleText = __NULL__;
	m_descriptionText = __NULL__;
	m_textMenuName = __NULL__;
}

class
vguiMenuMakerButton:vguiButton
{
public:
	void vguiMenuMakerButton(void);

	virtual void OnMouseEntered(void);
	
	nonvirtual void SetPanelTitleOnHover(string imageIdent);
	nonvirtual void SetPanelImageOnHover(string imageIdent);
	nonvirtual void SetPanelDescriptionOnHover(string panelDescription);

private:
	string m_imagePreview;
	string m_hoverTitle;
	string m_hoverDescription;
};

void
vguiMenuMakerButton::vguiMenuMakerButton(void)
{
	m_imagePreview = __NULL__;
	m_hoverTitle = __NULL__;
	m_hoverDescription = __NULL__;
}

void
vguiMenuMakerButton::SetPanelTitleOnHover(string titleText)
{
	m_hoverTitle = titleText;
}

void
vguiMenuMakerButton::SetPanelImageOnHover(string imageIdent)
{
	m_imagePreview = imageIdent;
}

void
vguiMenuMakerButton::SetPanelDescriptionOnHover(string panelDescription)
{
	m_hoverDescription = panelDescription;
}
	
void
vguiMenuMakerButton::OnMouseEntered(void)
{
	vguiMenuMakerWindow parentWindow = (vguiMenuMakerButton)m_parent;
	
	parentWindow.m_titleText.SetTitle(m_hoverTitle);
	parentWindow.m_descriptionText.SetTitle(m_hoverDescription);
	parentWindow.m_previewImage.SetImage(m_imagePreview);
}

bool
VGUI_CloseMenu(void)
{
	for (vguiMenuMakerWindow windowSearch = 0; (windowSearch = (vguiMenuMakerWindow)find(windowSearch, ::classname, "vguiMenuMakerWindow"));) {
		windowSearch.Hide();
	}
}

bool
VGUI_CreateMenuFromDict(string textMenuName)
{
	if (!STRING_SET(textMenuName)) {
		return (false);
	}

	string declName = sprintf("vguimenu/%s.decl", textMenuName);

	for (vguiMenuMakerWindow windowSearch = 0; (windowSearch = (vguiMenuMakerWindow)find(windowSearch, ::classname, "vguiMenuMakerWindow"));) {
		if (windowSearch.m_textMenuName == textMenuName) {
			windowSearch.Show();
			return (true);
		}
	}

	ncTextMenuDict newMenuWindow = ncTextMenuDict::LoadDeclFromFile("window", declName);
	ncTextMenuDict newMenuCommands = ncTextMenuDict::LoadDeclFromFile("commands", declName);
	ncTextMenuDict newMenuText = ncTextMenuDict::LoadDeclFromFile("text", declName);
	ncTextMenuDict newMenuImages = ncTextMenuDict::LoadDeclFromFile("images", declName);
	ncTextMenuDict newMenuDescriptions = ncTextMenuDict::LoadDeclFromFile("description", declName);
	ncTextMenuDict newMenuTitles = ncTextMenuDict::LoadDeclFromFile("title", declName);
	vguiMenuMakerWindow newWindow = spawn(vguiMenuMakerWindow);
	vector windowSize = newMenuWindow.GetVector("size");
	
	vguiLabel lblSelectClass;
	vguiFrame frmClassInfo;

	newWindow.m_textMenuName = textMenuName;
	newWindow.SetSize(windowSize);
	newWindow.SetStyleMask(vguiWindowBorderless | vguiWindowFullscreen);

	lblSelectClass = spawn(vguiLabel);
	lblSelectClass.SetTitle(newMenuWindow.GetString("title"));
	lblSelectClass.SetTextSize(19);
	lblSelectClass.SetPos([40, 38]);
	lblSelectClass.SetSize([windowSize[0], 24]);

	frmClassInfo = spawn(vguiFrame);
	frmClassInfo.SetPos([176, 80]);
	frmClassInfo.SetSize([424, 312]);

	newWindow.m_previewImage = spawn(vguiPic);
	newWindow.m_previewImage.SetPos([190, 90]);

	newWindow.m_titleText = spawn(vguiLabel);
	newWindow.m_titleText.SetPos([338, 90]);
	newWindow.m_titleText.SetTextSize(19);
	newWindow.m_titleText.SetSize([320, 24]);

	newWindow.m_descriptionText = spawn(vguiLabel);
	newWindow.m_descriptionText.SetPos([338, 90 + 32 + 32]);
	newWindow.m_descriptionText.SetSize([250, 240]);

	g_uiDesktop.Add(newWindow);
	newWindow.Add(lblSelectClass);
	newWindow.Add(frmClassInfo);
	newWindow.Add(newWindow.m_previewImage);
	newWindow.Add(newWindow.m_titleText);
	newWindow.Add(newWindow.m_descriptionText);

	vector btnpos = [40,80];
	vguiMenuMakerButton btns[10];

	for (int i = 0; i < 10; i++) {
		float buttonHeight = 80 + (i * 32);
		string buttonText = newMenuText.GetString(itos(i));

		/* don't allow empty text buttons */
		if (!STRING_SET(buttonText)) {
			continue;
		}

		if (i == 0) {
			buttonHeight = 80 + (9 * 32);
		} else {
			buttonHeight = 80 + ((i-1) * 32);
		}
		
		btns[i] = spawn(vguiMenuMakerButton);
		btns[i].SetTitle(buttonText);
		btns[i].SetSize([124, 24]);
		btns[i].SetPos([40,buttonHeight]);
		btns[i].SetTag(i);
		btns[i].SetExec(newMenuCommands.GetString(itos(i)));
		
		string titlesText = newMenuTitles.GetString(itos(i));

		if (STRING_SET(titlesText)) {
			btns[i].SetPanelTitleOnHover(newMenuTitles.GetString(itos(i)));
		} else {
			btns[i].SetPanelTitleOnHover(newMenuText.GetString(itos(i)));
		}

		btns[i].SetPanelImageOnHover(newMenuImages.GetString(itos(i)));
		btns[i].SetPanelDescriptionOnHover(newMenuDescriptions.GetString(itos(i)));
		btns[i].SetKeyEquivalent(ftos((float)i));

		newWindow.Add(btns[i]);
		btnpos[1] += 32;
	}

	newWindow.Show();
	newWindow.SetPos((g_vidsize / 2) - (newWindow.GetSize() / 2));
	return (true);
}
