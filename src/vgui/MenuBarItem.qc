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

/** VGUI Widget: Button

@ingroup vgui
*/
class vguiMenuBarItem:vguiButton
{
public:
	void vguiMenuBarItem(void);

	virtual void OnMouseUp(void);
};

void
vguiMenuBarItem::vguiMenuBarItem(void)
{
}


void
vguiMenuBarItem::OnMouseUp(void)
{
	for (vguiWidget menuEnum = 0; (menuEnum = (vguiWidget)find(menuEnum, ::classname, "vguiMenu"));) {
		menuEnum.Hide();
	}

	super::OnMouseUp();
}
