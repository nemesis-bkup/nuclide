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

/** VGUI Widget: Image List

@ingroup vgui
*/
class vguiImageList:vguiList
{
public:
	void vguiImageList(void);

	virtual void Draw(void);

};


void vguiImageList::vguiImageList(void)
{
}

void vguiImageList::Draw(void)
{
	vguiTheme theme = GetTheme();
	int iMaxDisplay;
	if (!m_iItemCount) {
		return;
	}

	theme.DrawTextBackground(m_parent.m_vecOrigin + m_vecOrigin, m_vecSize, VGUI_STATE_NORMAL);

	vector vecOffset = [8,8];

	iMaxDisplay = bound(0, m_iItemCount, floor(m_vecSize[1] / 20));

	drawsetcliparea(m_parent.m_vecOrigin[0] + m_vecOrigin[0],m_parent.m_vecOrigin[1] + m_vecOrigin[1], m_vecSize[0] - 1, m_vecSize[1]);
	for (int i = m_iDrawOffset; i < iMaxDisplay + m_iDrawOffset; i++) {
		if (!m_strItems[i]) {
			break;
		}

		if (m_iSelected == i) {
			theme.DrawHighlight(m_parent.m_vecOrigin + m_vecOrigin + vecOffset + [-7,-3], [m_vecSize[0] - 2, 18], VGUI_STATE_NORMAL);
		} else if (i & 1) {
			drawfill(m_parent.m_vecOrigin + m_vecOrigin + vecOffset + [-7,-3], [m_vecSize[0] - 2, 18], [1,1,1], 0.1f);
		}

		drawpic(m_parent.m_vecOrigin + m_vecOrigin + vecOffset + [-2,-2], m_strItems[i], [16,16], [1,1,1], 1.0, 0);
		vecOffset[1] += 20;
	}
	drawresetcliparea();
}
