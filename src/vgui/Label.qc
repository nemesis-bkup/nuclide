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


/** VGUI Widget: Label

@ingroup vgui
*/
class vguiLabel:vguiWidget
{
public:
	void vguiLabel(void);

	nonvirtual void SetTitle(string);

	virtual void Draw(void);
	virtual bool Input(float, float, float, float);
	virtual void Spawned(void);
	virtual void SetTextSize(int);
	virtual void SetAlignment(float);
	virtual void SetShadow(bool);

private:
	string m_strTitle;
	int m_labelFlags;
	int m_textSize;
	bool m_castShadow;
	vector m_titleColor;
};

void
vguiLabel::vguiLabel(void)
{
	m_strTitle = __NULL__;
	m_labelFlags = AF_TOP | AF_LEFT;
	m_castShadow = false;
	m_titleColor = g_vec_null;
}

void
vguiLabel::SetShadow(bool newState)
{
	m_castShadow = newState;
}

void
vguiLabel::Spawned(void)
{
	SetSize([0,0]);
}

void
vguiLabel::SetTitle (string strName)
{
	m_strTitle = localize(strName);
	drawfont = g_fntDefault.iID;

	if (GetSize() == [0,0]) {
	/* hack, add 2 just to make sure it doesn't immediately wrap. bug
	 * in engines' textfield thing in combo with ttf. */
		SetSize([2 + stringwidth(m_strTitle, TRUE, [g_fntDefault.iScaleX, g_fntDefault.iScaleY]), 16]);
	}
}

void
vguiLabel::SetTextSize(int val)
{
	m_textSize = val;
}

void
vguiLabel::SetAlignment(float alignment)
{
	m_labelFlags &= ~AF_LEFT;
	m_labelFlags &= ~AF_TOP;
	m_labelFlags &= ~AF_RIGHT;
	m_labelFlags &= ~AF_BOTTOM;
	m_labelFlags |= alignment;
}

void
vguiLabel::Draw(void)
{
	if (!STRING_SET(m_strTitle)) {
		return;
	}

	vguiTheme theme = GetTheme();
	vector pos;
	vector size;

	pos = m_parent.m_vecOrigin + m_vecOrigin;
	size = m_vecSize;

	if (m_castShadow) {
		if (!m_textSize)
			Font_DrawField(pos + [2,2], size, strcat("^x000", m_strTitle), g_fntDefault, m_labelFlags);
		else
			Font_DrawFieldAtHeight(pos + [2,2], size, m_textSize, strcat("^x000", m_strTitle), g_fntDefault, m_labelFlags);
	}

	if (!m_textSize)
		Font_DrawField(pos, size, m_strTitle, g_fntDefault, m_labelFlags);
	else
		Font_DrawFieldAtHeight(pos, size, m_textSize, m_strTitle, g_fntDefault, m_labelFlags);



	theme.DrawLabel(pos, m_strTitle, m_labelFlags, m_textSize, size, VGUI_STATE_NORMAL);
}

bool
vguiLabel::Input (float flEVType, float flKey, float flChar, float flDevID)
{
	return false;
}
