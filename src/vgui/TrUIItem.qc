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

/** Trinity Menu File "itemDef"

This class represents objects that are parsed from "itemDef" entries
defined in the Quake III: Team Arena (2000) menu scripting language.

# See also

[menuDef](@ref vguiTrUISubMenu)

*/
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
	nonvirtual void OnMaxChars(void);
	nonvirtual void AddText(string toAdd);

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
	int m_trItemTextFont;
	int m_trItemOwnerDraw;
	float m_trItemOwnerDrawValue;
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
	string m_trItemMaxCharBuffer;

	/* 3D Model */
	string m_trItemModel;
	vector m_trItemModelOrigin;
	float m_trItemModelFOVX;
	float m_trItemModelFOVY;
	vector m_trItemModelRotation;
	vector m_trItemModelAngles;
	float m_trItemModelAnim;
	entity m_trItemModelDelegate;
	vector m_trItemModelAngularVelocity;
	entity m_trCamDelegate;
	vector m_trCamOrigin;
	vector m_trCamAngles;
	vector m_trCamAngularVelocity;

	/* text */
	int m_trItemMaxChars;
};

#ifdef MENU
__variant MenuGame_OwnerDrawValueForType(ncPlayer clientSlot, int ownerDraw, int typeValue);
bool MenuGame_OwnerDrawItemRect(ncPlayer clientSlot, vguiTrUIItem drawItem, int ownerDraw, int drawType);
bool MenuGame_OwnerDrawMenuRect(ncPlayer clientSlot, vguiTrUISubMenu drawMenu);
#endif

#ifdef CLIENT
__variant ClientGame_OwnerDrawValueForType(ncPlayer clientSlot, int ownerDraw, int typeValue);
bool ClientGame_OwnerDrawItemRect(ncPlayer clientSlot, vguiTrUIItem drawItem, int ownerDraw, int drawType);
bool ClientGame_OwnerDrawMenuRect(ncPlayer clientSlot, vguiTrUISubMenu drawMenu);

__variant HUD_OwnerDrawValueForType(int ownerDraw, int typeValue);
bool HUD_OwnerDrawItemRect(vector pos, vector size, int ownerDraw, int drawType);
#endif

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
	m_trItemTextFont = 0;
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
	m_trItemMaxCharBuffer = __NULL__;
	m_trItemOwnerDrawValue = 0.0f;

	m_trItemModel = g_string_null;
	m_trItemModelOrigin = g_vec_null;
	m_trItemModelFOVX = g_float_null;
	m_trItemModelFOVY = g_float_null;
	m_trItemModelRotation = g_vec_null;
	m_trItemModelAngles = g_vec_null;
	m_trItemModelAnim = g_float_null;
	m_trItemMaxChars = 0;
	m_trItemModelDelegate = g_entity_null;
	m_trCamAngularVelocity = g_vec_null;
	m_trCamDelegate = g_entity_null;
}

void
vguiTrUIItem::AddText(string toAdd)
{
	float stringLength = strlen(m_trItemText);

	if (m_trItemMaxChars > 0)
	if (stringLength >= m_trItemMaxChars) {
		m_trItemText = "";
		return;
	}

	m_trItemText = strcat(m_trItemText, toAdd);
	stringLength = strlen(m_trItemText);

	/* check if we've hit max chars */
	if (stringLength >= m_trItemMaxChars) {
		OnMaxChars();
		return;
	}
}

void
vguiTrUIItem::OnMaxChars(void)
{
	int commandCount;

	for (int i = 0; i < (commandCount = tokenizebyseparator(m_trItemMaxCharBuffer, ";", "\n")); i++) {
		string commandString = argv(i);

		if (STRING_SET(commandString)) {
			m_trGlobal.InterpretCommand(this, commandString);
		}
	}
}

void
vguiTrUIItem::OnMouseEntered(void)
{
	int commandCount;

	for (int i = 0; i < (commandCount = tokenizebyseparator(m_trItemEnterBuffer, ";", "\n")); i++) {
		string commandString = argv(i);

		if (STRING_SET(commandString)) {
			m_trGlobal.InterpretCommand(this, commandString);
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
			m_trGlobal.InterpretCommand(this, commandString);
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
			m_trGlobal.InterpretCommand(this, commandString);
		}
	}
}

void
vguiTrUIItem::Draw3D(void)
{
	vector pos = m_parent.m_vecOrigin + m_trItemRectMins;
	vector size = m_trItemRectMaxs;

	if (!m_trItemModelDelegate) {
		m_trItemModelDelegate = spawn();
		setmodel(m_trItemModelDelegate, m_trItemModel);
		setorigin(m_trItemModelDelegate, m_trItemModelOrigin);
		m_trItemModelDelegate.angles = m_trItemModelAngles;
		m_trItemModelDelegate.frame = m_trItemModelAnim;
		m_trItemModelDelegate.movetype = MOVETYPE_FLY;
		m_trItemModelDelegate.solid = SOLID_NOT;
		m_trItemModelDelegate.avelocity = m_trItemModelAngularVelocity;

		m_trCamDelegate = spawn();
		m_trCamDelegate.movetype = MOVETYPE_FLY;
		m_trCamDelegate.solid = SOLID_NOT;
		m_trCamDelegate.angles = m_trCamAngles;
		m_trCamDelegate.avelocity = m_trCamAngularVelocity;
		m_trCamDelegate.origin = m_trCamOrigin;
		m_trItemModelDelegate.frame1time += clframetime;

	}

	clearscene();
	setproperty(VF_VIEWPORT, pos, size);
	setproperty(VF_AFOV, m_trItemModelFOVX);
	setproperty(VF_ORIGIN, m_trCamDelegate.origin);
	setproperty(VF_ANGLES, m_trCamDelegate.angles);

#ifndef MENU
	setproperty(VF_DRAWWORLD, false);
#endif

	/* sanity checks */
	if (m_trItemModelDelegate.frame < 0) {
		m_trItemModelDelegate.frame = 0;
	}

	addentity(m_trItemModelDelegate);
	m_trItemModelDelegate.frame1time = time;

	renderscene();
}

void
vguiTrUIItem::Draw(void)
{
	vector pos;
	vector textPos;
	vector size;
	int textAlignFlags = 0;

	pos = m_parent.m_parent.m_vecOrigin + m_parent.m_vecOrigin + m_trItemRectMins;
	size = m_trItemRectMaxs;
	textPos = pos + [m_trItemTextAlignX, m_trItemTextAlignY];

	bool hudResult = HUD_OwnerDrawItemRect(pos, size, m_trItemOwnerDraw, m_trItemType);

	if (hudResult == false) {
		hudResult = ClientGame_OwnerDrawItemRect((ncPlayer)pSeat->m_ePlayer, this, m_trItemOwnerDraw, m_trItemType);

		if (hudResult == true) {
			return;
		}
	}

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

	/* model stuff goes here */
	if (STRING_SET(m_trItemModel)) {
		Draw3D();
	}

	if (m_trItemBorder > 0) {
		draw.RectOutline(pos, size, 1.0f, m_trItemBorderColor, m_trItemBorderAlpha);
	}

	if (HasFlag(BUTTON_HOVER)) {
		drawfill(pos, size, m_trItemFocusColor, m_trItemFocusAlpha);
	}

	if (STRING_SET(m_trItemText)) {
		string foreColor = Font_RGBtoHex(m_trItemForeColor);
		font_s textFont;
		string destText;

		switch (m_trItemTextFont) {
		case 1:
			textFont = *m_trGlobal.m_trGlobalBigFont;
			break;
		case 2:
			textFont = *m_trGlobal.m_trGlobalExtraBigFont;
			break;
		case 3:
			textFont = *m_trGlobal.m_trGlobalSmallFont;
			break;
		case 4:
			textFont = *m_trGlobal.m_trGlobalBoldFont;
			break;
		case 5:
			textFont = *m_trGlobal.m_trGlobalConsoleFont;
			break;
		default:
			textFont = *m_trGlobal.m_trGlobalFont;
			break;
		}

		destText = HUD_OwnerDrawValueForType((ncPlayer)pSeat->m_ePlayer, m_trItemOwnerDraw, m_trItemType);

		if (destText == __NULL__) {
			destText = ClientGame_OwnerDrawValueForType((ncPlayer)pSeat->m_ePlayer, m_trItemOwnerDraw, m_trItemType);

			if (destText == __NULL__) {
				destText = m_trItemText;
			}
		}

		/* button */
		if (m_trItemType == 1 && HasFlag(BUTTON_HOVER)) {
			Font_DrawField(pos + [m_trItemTextAlignX, m_trItemTextAlignY], size, destText, textFont, textAlignFlags);
		} else {
			Font_DrawField(pos + [m_trItemTextAlignX, m_trItemTextAlignY], size, strcat(foreColor, destText), textFont, textAlignFlags);
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
