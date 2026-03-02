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

/** VGUI Widget: Vertical Gradient

@ingroup vgui
*/
class
vguiHGradient:vguiWidget
{
public:
	void vguiPic(void);

	virtual void Draw(void);
	virtual bool Input(float, float, float, float);
	virtual void Spawned(void);


private:
	vector m_gradientColor1;
	vector m_gradientColor2;
};

void
vguiHGradient::vguiHGradient(void)
{
	m_gradientColor1 = [1,1,1];
	m_gradientColor2 = [0,0,0];
}

void
vguiHGradient::Spawned(void)
{
	SetSize([16,16]);
}

void
vguiHGradient::Draw(void)
{
	drawfill(m_parent.m_vecOrigin + m_vecOrigin, m_vecSize, m_gradientColor1, 1.0f, 0);
	drawpic(m_parent.m_vecOrigin + m_vecOrigin, "gfx/icon16/hgradient", m_vecSize, m_gradientColor1, 1.0f, 0);
}

bool
vguiHGradient::Input (float flEVType, float flKey, float flChar, float flDevID)
{
	return false;
}
