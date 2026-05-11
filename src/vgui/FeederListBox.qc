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

static float m_pickerLastShown;

static void
vguiFeederListBox_CallFunctionWithDelegate(void(vguiWidget sender) targetFunc, vguiWidget delegateWidget, vguiWidget sender)
{
    entity oldSelf = self;

    if (delegateWidget) {
        self = delegateWidget;
    }

    if (targetFunc) {
        targetFunc(sender);
    }

    self = oldSelf;
}

/** VGUI Widget: List Box

A box containing a listing of items. Taking up as much space as any vguiTextBox.
When interacted with, gives you the choice of making a selection of an undefined
selection of items.

@ingroup vgui
*/
class vguiFeederListBox:vguiWidget
{
public:
    void vguiFeederListBox(void);

    nonvirtual string GetItem(void);
    nonvirtual void SelectionComplete(string);
    nonvirtual void ShowPicker(void);
    nonvirtual void HidePicker(void);
    nonvirtual void SetFeederType(float feederType);
    nonvirtual void SetText(string feederType);
    nonvirtual void CallOnSelectionChanged(void(vguiWidget sender) vFunc);
    nonvirtual void CallOnSelectionChangedWithDelegate(void(vguiWidget sender) vFunc, vguiWidget delegateWidget);

    virtual void Draw(void);
    virtual bool Input(float, float, float, float);
    virtual void Spawned(void);

private:
    vector m_vecSize;
    string m_strTitle;

    vguiFeeder m_listFeeder;
    feederTypes_t m_feederType;
};

void
vguiFeederListBox::vguiFeederListBox(void)
{
    m_strTitle = __NULL__;
}

void vguiFeederListBox::CallOnSelectionChanged(void(vguiWidget sender) vFunc)
{
    tmpvguiFeeder3 = vFunc;
    tmpvguiFeeder3Delegate = __NULL__;
}

void vguiFeederListBox::CallOnSelectionChangedWithDelegate(void(vguiWidget sender) vFunc, vguiWidget delegateWidget)
{
    tmpvguiFeeder3 = vFunc;
    tmpvguiFeeder3Delegate = delegateWidget;
}

void
vguiFeederListBox::SelectionComplete(string selectedString)
{
    m_strTitle = m_listFeeder.GetItem(m_listFeeder.GetSelected());
    vguiFeederListBox_CallFunctionWithDelegate(tmpvguiFeeder3, tmpvguiFeeder3Delegate, this);
    m_pickerLastShown = time + 0.25f;
}

void
vguiFeederListBox::SetText(string selectedString)
{
    m_strTitle = selectedString;
}

void
vguiFeederListBox::Spawned(void)
{
    SetSize([96,16]);
}

string
vguiFeederListBox::GetItem(void)
{
    return (m_strTitle);
}

void
vguiFeederListBox::SetFeederType(float feederType)
{
    m_feederType = feederType;
}

void
vguiFeederListBox::Draw(void)
{
    vguiTheme theme = GetTheme();
    vector pos = GetAbsPos();
    drawfill(pos, m_vecSize, [0,0,0], 0.5f);
    drawfill(pos, [m_vecSize[0], 1], [0,0,0], 0.5f);
    drawfill(pos + [0, m_vecSize[1] - 1], [m_vecSize[0], 1], [1,1,1], 0.5f);
    drawfill(pos + [0, 1], [1, m_vecSize[1] - 2], [0,0,0], 0.5f);
    drawfill(pos + [m_vecSize[0] - 1, 1], [1, m_vecSize[1] - 2], [1,1,1], 0.5f);
    theme.DrawText(pos + [4,6], m_strTitle, m_vecSize, g_fntDefault);
}

void
vguiFeederListBox::ShowPicker(void)
{
    for (vguiFeeder windowSearch = 0; (windowSearch = (vguiFeeder)find(windowSearch, ::classname, "vguiFeeder_Overlay"));) {
        windowSearch.Hide();
    }

    if (m_listFeeder) {
        m_listFeeder.Show();
        return;
    }

    m_listFeeder = spawn(vguiFeeder);
    m_listFeeder.classname = "vguiFeeder_Overlay";
    m_listFeeder.CallOnSelectionChangedWithDelegate(SelectionComplete, this);
    m_listFeeder.CallOnDoubleClickWithDelegate(HidePicker, this);
    m_listFeeder.SetFeederType(m_feederType);
    m_listFeeder.m_parent = GetParent();
    m_listFeeder.SetPos(GetPos());
    m_listFeeder.SetSize([GetWidth(), 96]);
    m_listFeeder.Show();
}

void
vguiFeederListBox::HidePicker(void)
{
    m_listFeeder.Hide();
}

bool
vguiFeederListBox::Input (float flEVType, float flKey, float flChar, float flDevID)
{
    bool ret = false;

    if (m_pickerLastShown > time) {
        return (false);
    }

    if (flEVType == IE_KEYUP) {
        if (flKey == K_MOUSE1) {
            if (MouseAbove() == true) {
                ShowPicker();
                //ret = true;
            } else {
                //HidePicker();
            }
        }
    }

    return (ret);
}
