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

/** itemDef */
class
vguiTrUIItem:vguiWidget
{
public:
	void vguiTrUIItem(void);

	virtual void Draw(void);
	virtual bool Input(float, float, float, float);
	
	nonvirtual void OnMouseEntered(void);
	nonvirtual void OnMouseExited(void);
	nonvirtual void OnMouseDown(void);
	nonvirtual void OnMouseUp(void);

private:
	string m_trItemName;
	string m_trItemText;
	int m_trItemType;
	string m_trItemStyle;
	bool m_trItemDecoration;
	bool m_trItemVisible;
	vector m_trItemRectMins;
	vector m_trItemRectMaxs;
	float m_trItemTextScale;
	int m_trItemTextStyle;
	string m_trItemOwnerDraw;
	float m_trItemTextAlignX;
	float m_trItemTextAlignY;
	vector m_trItemFocusColor;
	float m_trItemFocusAlpha;
	vector m_trItemForeColor;
	float m_trItemForeAlpha;
	vector m_trItemBorderColor;
	float m_trItemBorderAlpha;
	vector m_trItemBackColor;
	float m_trItemBackAlpha;
	vguiTrUIMenu m_trGlobal;
	string m_trItemGroup;
	int m_trItemTextAlign;
	int m_trItemBorder;
	string m_trItemCvarTest;
	string m_trItemBackground;

	string m_trItemActionBuffer;
	string m_trItemEnterBuffer;
	string m_trItemExitBuffer;
};

void
vguiTrUIItem::vguiTrUIItem(void)
{
	m_trItemName = __NULL__;
	m_trItemText = __NULL__;
	m_trItemType = 0;
	m_trItemStyle = __NULL__;
	m_trItemDecoration = false;
	m_trItemRectMins = g_vec_null;
	m_trItemRectMaxs = g_vec_null;
	m_trItemTextScale = 0.0f;
	m_trItemTextStyle = 0i;
	m_trItemOwnerDraw = __NULL__;
	m_trGlobal = __NULL__;
	m_trItemTextAlignX = 0;
	m_trItemTextAlignY;
	m_trItemFocusColor = g_vec_null;
	m_trItemFocusAlpha = 0;
	m_trItemForeColor = g_vec_null;
	m_trItemForeAlpha = 0;
	m_trItemBorderColor = g_vec_null;
	m_trItemBorderAlpha = 0;
	m_trItemBackColor = g_vec_null;
	m_trItemBackAlpha = 0;
	m_trItemGroup = 0;
	m_trItemTextAlign = 0;
	m_trItemBorder = 0;
	m_trItemCvarTest = 0;
	m_trItemBackground = 0;
	m_trItemActionBuffer = __NULL__;
	m_trItemEnterBuffer = __NULL__;
	m_trItemExitBuffer = __NULL__;
}

void
vguiTrUIItem::InterpretCommand(string commandString)
{

	int commandWords = tokenize_console(commandString);
	string firstWord = argv(0);
	string secondWord = argv(1);
	string thirdWord = argv(2);
	string targetLookUp = sprintf("%d_%s", num_for_edict(m_trGlobal), secondWord);
	
	if (!STRING_SET(firstWord)) {
		return;
	}

	switch (firstWord) {
	case "exec":
		localcmd(sprintf("%s\n", substring(commandString, 5, -1)));
		break;
	case "uiscript":
		break;
	case "setbackground":
		for (vguiTrUIItem windowSearch = 0; (windowSearch = (vguiTrUIItem)find(windowSearch, ::classname, "vguiTrUIItem"));) {
			if (targetLookUp == windowSearch.m_trItemName) {
				precache_pic(thirdWord);
				windowSearch.m_trItemBackground = thirdWord;
			}
		}
		break;
	case "play":
		localcmd("play sound/common/wpn_select.wav\n");
		break;
	case "open":
		string fileToOpen = substring(commandString, 5, -1);
		
		if (STRING_SET(fileToOpen))
			localcmd(sprintf("trMenuOpen ui/%s.menu\n", substring(commandString, 5, -1)));
		break;
	case "show":
		for (vguiTrUIItem windowSearch = 0; (windowSearch = (vguiTrUIItem)find(windowSearch, ::classname, "vguiTrUIItem"));) {
			if (targetLookUp == windowSearch.m_trItemName)
				windowSearch.Show();
		}
		for (vguiTrUISubMenu windowSearch = 0; (windowSearch = (vguiTrUISubMenu)find(windowSearch, ::classname, "vguiTrUISubMenu"));) {
			if (targetLookUp == windowSearch.m_trSubName)
				windowSearch.Show();
		}
		break;
	case "close":
	case "hide":
		for (vguiTrUIItem windowSearch = 0; (windowSearch = (vguiTrUIItem)find(windowSearch, ::classname, "vguiTrUIItem"));) {
			if (targetLookUp == windowSearch.m_trItemName)
				windowSearch.Hide();
		}
		for (vguiTrUISubMenu windowSearch = 0; (windowSearch = (vguiTrUISubMenu)find(windowSearch, ::classname, "vguiTrUISubMenu"));) {
			if (targetLookUp == windowSearch.m_trSubName)
				windowSearch.Hide();
		}
		break;
	default:
		printf("InterpretCommand: %s\n", commandString);
	}
}


void
vguiTrUIItem::OnMouseEntered(void)
{
	int commandCount;

	for (int i = 0; i < (commandCount = tokenizebyseparator(m_trItemEnterBuffer, ";", "\n")); i++) {
		string commandString = argv(i);
		
		if (STRING_SET(commandString)) {
			InterpretCommand(commandString);
		}
	}
}

void
vguiTrUIItem::OnMouseExited(void)
{
	int commandCount;

	for (int i = 0; i < (commandCount = tokenizebyseparator(m_trItemExitBuffer, ";", "\n")); i++) {
		string commandString = argv(i);
		
		if (STRING_SET(commandString)) {
			InterpretCommand(commandString);
		}
	}
}

void
vguiTrUIItem::OnMouseDown(void)
{
}

void
vguiTrUIItem::OnMouseUp(void)
{
	int commandCount;

	for (int i = 0; i < (commandCount = tokenizebyseparator(m_trItemActionBuffer, ";", "\n")); i++) {
		string commandString = argv(i);
		
		if (STRING_SET(commandString)) {
			InterpretCommand(commandString);
		}
	}
}

void
vguiTrUIItem::Draw(void)
{
	vector pos;
	vector textPos;
	vector size;
	int textAlignFlags = 0;

	pos = m_parent.m_vecOrigin + m_trItemRectMins;
	size = m_trItemRectMaxs;
	textPos = pos + [m_trItemTextAlignX, m_trItemTextAlignY];

	switch (m_trItemTextAlign) {
	case 1:	/* center  */
		textAlignFlags = 0;
		break;
	case 2:	/* right  */
		textAlignFlags = AF_RIGHT;
		break;
	case 3:	/* center  */
		textAlignFlags = AF_TOP;
		break;
	default:
	case 0:	/* left  */
		textAlignFlags = AF_LEFT;
		break;
	}


	if (STRING_SET(m_trItemBackground)) {
		if (m_trItemType == 3) {
			draw.Pic(pos, m_trItemBackground, size, [1,1,1], 1.0, 0);
		} else {
			draw.Pic(pos, m_trItemBackground, size, m_trItemBackColor, m_trItemBackAlpha, 0);
		}
	} else {
		draw.Rect(pos, size, m_trItemBackColor, m_trItemBackAlpha);
	}

	if (m_trItemBorder > 0) {
		draw.RectOutline(pos, size, 1.0f, m_trItemForeColor, m_trItemForeAlpha);
	}


	if (HasFlag(BUTTON_HOVER)) {
		drawfill(pos, size, m_trItemFocusColor, m_trItemFocusAlpha);
	}

	if (STRING_SET(m_trItemText)) {
		string foreColor = Font_RGBtoHex(m_trItemForeColor);

		/* button */
		if (m_trItemType == 1 && HasFlag(BUTTON_HOVER)) {
			Font_DrawField(pos, size, m_trItemText, g_fntDefault, textAlignFlags);
		} else {
			Font_DrawField(pos, size, strcat(foreColor, m_trItemText), g_fntDefault, textAlignFlags);
		}
	}
}

bool
vguiTrUIItem::Input(float flEVType, float flKey, float flChar, float flDevID)
{
	bool mouseHover = false;
	float ret = false;

	if (m_trItemDecoration) {
		return (false);
	}

	if (Util_MouseAbove(g_vecMousePos, m_parent.m_vecOrigin + m_trItemRectMins, m_trItemRectMaxs)) {
		mouseHover = true;
	}

	if (mouseHover == true && HasFlag(BUTTON_HOVER) == false) {
		FlagAdd(BUTTON_HOVER);
		OnMouseEntered();
	} else if (HasFlag(BUTTON_HOVER) && mouseHover == false) {
		FlagRemove(BUTTON_HOVER);
		OnMouseExited();
	}

	if (flEVType == IE_KEYDOWN) {
		if (flKey == K_MOUSE1) {
			FlagRemove(BUTTON_LASTACTIVE);

			if (mouseHover) {
				OnMouseDown();

				FlagAdd(BUTTON_DOWN);
				FlagAdd(BUTTON_LASTACTIVE);
				ret = true;
			}
		}
	} else if (flEVType == IE_KEYUP) {
		if (flKey == K_MOUSE1) {
			if (m_iFlags & BUTTON_DOWN && mouseHover) {
				OnMouseUp();
				ret = true;
			}
			FlagRemove(BUTTON_DOWN);
		}
	}
	return (ret);
}
