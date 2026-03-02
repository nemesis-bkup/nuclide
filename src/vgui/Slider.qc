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

enumflags
{
	SLIDER_HOVER,
	SLIDER_DOWN,
};

/** VGUI Widget: Slider

@ingroup vgui
*/
class vguiSlider:vguiWidget
{
public:
	void vguiSlider(void);

	nonvirtual void SetValue(float);
	nonvirtual float GetValue(void);
    nonvirtual void SetTitle(string);

	/* overrides */
	virtual void Draw(void);
	virtual bool Input(float, float, float, float);
	virtual void Spawned(void);

private:
	float m_flAlpha;
	vector m_vecSize;
	vector m_vecColor;

	float m_value;
    string m_strTitle;
	virtual void m_changed(float) = 0;
};

void vguiSlider::vguiSlider(void)
{
	m_vecColor = [76,88,68] / 255;
	m_flAlpha = 1.0f;
    m_strTitle = "";
}

void
vguiSlider::Spawned(void)
{
	SetSize([96,24]);
}

void
vguiSlider::SetTitle(string newTitle)
{
    m_strTitle = newTitle;
}

void vguiSlider::Draw(void)
{
	vguiTheme theme = GetTheme();

    theme.DrawSlider(m_parent.m_vecOrigin + m_vecOrigin, m_strTitle, "", m_vecSize, VGUI_STATE_NORMAL);

	if (HasFlag(BUTTON_DOWN)) {
		theme.DrawButton(m_parent.m_vecOrigin + m_vecOrigin + [m_vecSize[0] * m_value, (m_vecSize[1]/2) - 8], [8,16], VGUI_STATE_CHECKED);
	} else {
		theme.DrawButton(m_parent.m_vecOrigin + m_vecOrigin + [m_vecSize[0] * m_value, (m_vecSize[1]/2) - 8], [8,16], VGUI_STATE_NORMAL);
	}
}

bool vguiSlider::Input (float flEVType, float flKey, float flChar, float flDevID)
{
    vector mousePos = GetMousePos();

	if (MouseAbove() == true) {
		FlagAdd(BUTTON_HOVER);
	} else {
		FlagRemove(BUTTON_HOVER);
	}

	if (HasFlag(BUTTON_HOVER) && flEVType == IE_KEYDOWN && flKey == K_MOUSE1) {
		FlagAdd(BUTTON_DOWN);
	}

	if (flEVType == IE_KEYUP && flKey == K_MOUSE1) {
		if (HasFlag(BUTTON_DOWN)) {
            FlagRemove(BUTTON_DOWN);
		}
	}

	if (HasFlag(BUTTON_DOWN)) {
		if (mousePos[0] != g_lastmousepos[0] || mousePos[1] != g_lastmousepos[1]) {
			float mdelta;
            float posWidth = m_parent.m_vecOrigin[0] + m_vecOrigin[0];
			/* The - 10 is putting the slider in the middle of the cursor */
			mdelta = (mousePos[0] - 4) - (posWidth);
			m_value = ((float)mdelta / (float)m_vecSize[0]);
			m_value = bound(0.0f, m_value, 1.0f);
			g_lastmousepos[0] = mousePos[0];
			g_lastmousepos[1] = mousePos[1];

			if (m_changed) {
				m_changed(m_value);
			}
		}
	}
}

void
vguiSlider::SetValue(float val)
{
	m_value = bound(0.0, val, 1.0);
}


float
vguiSlider::GetValue(void)
{
	return (m_value);
}

void
vguiSlider::SetCallback(void(float val) vFunc)
{
	m_changed = vFunc;
}
