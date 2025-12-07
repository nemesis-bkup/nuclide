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

/** Trinity Menu File "menuDef"

This class represents objects that are parsed from "menuDef" entries
defined in the Quake III: Team Arena (2000) menu scripting language.

They are mainly used as a container for smaller items, which you
may want to move together without having to adjust
absolute screen values. As [items](@ref vguiTrUIItem) are placed relative to their parent
menuDef.

# SEE ALSO

[itemDef](@ref vguiTrUIItem)

*/
class
vguiTrUISubMenu:vguiView
{
public:
	void vguiTrUISubMenu(void);
	virtual void Draw(void);

private:
	vguiTrUIMenu m_trGlobal;

	int m_trSubBorder;
	int m_trSubStyle;
	string m_trSubSoundLoop;
	vector m_trSubRectMaxs;
	vector m_trSubRectMins;
    	bool m_trSubFullScreen;
    	string m_trSubName;
	vector m_trSubBorderColor;
	float m_trSubBorderAlpha;
	vector m_trSubFocusColor;
	float m_trSubFocusAlpha;
	vector m_trSubBackColor;
	float m_trSubBackAlpha;
	string m_trSubBackground;
};

void
vguiTrUISubMenu::vguiTrUISubMenu(void)
{
	m_trSubName = __NULL__;
	m_trSubFullScreen = false;
	m_trSubRectMins = g_vec_null;
	m_trSubRectMaxs = g_vec_null;
	m_trGlobal = __NULL__;
}

void
vguiTrUISubMenu::Draw(void)
{
	vector pos;
	vector size;

	pos = m_parent.m_vecOrigin + m_trSubRectMins;
	size = m_trSubRectMaxs;

	if (STRING_SET(m_trSubBackground)) {
		draw.Pic(pos, m_trSubBackground, size, [1,1,1], 1.0, 0);
	} else {
		draw.Rect(pos, size, m_trSubBackColor, m_trSubBackAlpha);
	}

	if (m_trSubBorder > 0) {
		draw.RectOutline(pos, size, 1.0f, m_trSubBorderColor, m_trSubBorderAlpha);
	}

	super::Draw();
}
