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

/** VGUI Widget: Menu, containing multiple menu items

@ingroup vgui
*/
class vguiMenu:vguiView
{
public:
    void vguiMenu(void);

    /* overrides */
    virtual void Add(vguiWidget);
    virtual void NowVisible(void);

    nonvirtual vguiMenuItem NewItem(string title, string icon, void(void) func, vguiControl delegate);
    nonvirtual vguiMenuItem NewCommandItem(string title, string icon, string commandString);
    nonvirtual vguiMenu NewSubMenu(string title, string icon, vguiMenu parentMenu);

private:
    vector m_nextItemPos;
    vguiMenu m_parentMenu;
};

void
vguiMenu::vguiMenu(void)
{
    m_nextItemPos = g_vec_null;
    m_parentMenu = __NULL__;
}

void
vguiMenu::Add(vguiWidget wNew)
{
    super::Add(wNew);
}

vguiMenuItem
vguiMenu::NewItem(string title, string icon, void(void) func, vguiControl delegate)
{
    vguiMenuItem newItem = spawn(vguiMenuItem);
    newItem.SetTitle(title);
    newItem.SetPos(m_nextItemPos);
    newItem.SetIcon(icon);
    newItem.SetSize([128,22]);
    newItem.SetFuncWithDelegate(func, delegate);
    newItem.m_parentMenu = this;
    Add(newItem);
    m_nextItemPos[1] += 22;
    return (newItem);
}

vguiMenuItem
vguiMenu::NewCommandItem(string title, string icon, string commandString)
{
    vguiMenuItem newItem = spawn(vguiMenuItem);
    newItem.SetTitle(title);
    newItem.SetPos(m_nextItemPos);
    newItem.SetIcon(icon);
    newItem.SetSize([128,22]);
    newItem.SetExec(commandString);
    newItem.m_parentMenu = this;
    Add(newItem);
    m_nextItemPos[1] += 22;
    return (newItem);
}

void
vguiMenu::MenuToggle(void)
{
    if (Visible()) {
        Hide();
    } else {
        Show();
    }
}

void
vguiMenu::NowVisible(void)
{
    if (m_parentMenu) {
        m_parentMenu.Show();
    }
}

vguiMenu
vguiMenu::NewSubMenu(string title, string icon, vguiMenu parentMenu)
{
    /* first the button for the menu */
    vguiMenuItem newItem = spawn(vguiMenuItem);
    newItem.SetTitle(title);
    newItem.SetPos(m_nextItemPos);
    newItem.SetIcon(icon);
    newItem.SetSize([128,22]);

    /* now things for the menu itself */
    vguiMenu newMenu = spawn(vguiMenu);
    newItem.SetFuncWithDelegate(vguiMenu::MenuToggle, newMenu);
    newMenu.SetPos(m_nextItemPos + [128, 0]);
    newMenu.m_parentMenu = parentMenu;
    Add(newItem);
    m_nextItemPos[1] += 22;

    /* add & hide the new menu by default */
    Add(newMenu);
    newMenu.Hide();

    return (newMenu);
}

