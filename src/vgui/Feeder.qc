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

.void(vguiWidget sender) tmpvguiFeeder1;
.void(vguiWidget sender) tmpvguiFeeder3;
.void(vguiWidget sender) tmpvguiFeeder2;
.vguiWidget tmpvguiFeeder1Delegate;
.vguiWidget tmpvguiFeeder2Delegate;
.vguiWidget tmpvguiFeeder3Delegate;

/** VGUI Widget: Feeder

@ingroup vgui
*/
class vguiFeeder:vguiWidget
{
public:
	void vguiFeeder(void);

	nonvirtual void SetOffset(int,int);

	nonvirtual void SetSelected(int);
	nonvirtual int GetSelected(void);

	nonvirtual int GetMaxVisibleItems(void);

	nonvirtual void AddItem(string);
	nonvirtual string GetItem(int);
	nonvirtual string GetItemAtColumn(int, int);

	nonvirtual void SetItemCount(int);
	nonvirtual int MaxItems(void);
	nonvirtual int GetItemCount(void);

	nonvirtual void RemoveAllItems(void);

	nonvirtual int GetOffset(void);

	nonvirtual void CallOnScroll(void(vguiWidget sender));
	nonvirtual void CallOnDoubleClick(void(vguiWidget sender));
	nonvirtual void CallOnDoubleClickWithDelegate(void(vguiWidget sender), vguiWidget theDelegate);
	nonvirtual void CallOnSelectionChanged(void(vguiWidget sender));
	nonvirtual void CallOnSelectionChangedWithDelegate(void(vguiWidget sender), vguiWidget theDelegate);

	nonvirtual void CallOnScrollWithDelegate(void(vguiWidget sender) a, vguiWidget theDelegate);
	nonvirtual void CallOnSelectionChangedWithDelegate(void(vguiWidget sender) a, vguiWidget theDelegate);

    nonvirtual void SetFeederType(feederTypes_t);
    nonvirtual void SetFeederColumn(int columNum);

	virtual void Draw(void);
	virtual bool Input(float, float, float, float);
	virtual void Spawned(void);

private:
	string m_strTitle;
	int m_iSelected;
	int m_iDrawOffset;
	float m_flClickTimer;
    feederTypes_t m_feederType;
    int m_feederColumn;
};

static void
vguiFeeder_CallFunctionWithDelegate(void(vguiWidget sender) targetFunc, vguiWidget delegateWidget, vguiWidget sender)
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

void vguiFeeder::vguiFeeder(void)
{
	m_iSelected = -1;
	m_iDrawOffset = 0;
	tmpvguiFeeder1 = __NULL__;
	tmpvguiFeeder2 = __NULL__;
	tmpvguiFeeder3 = __NULL__;
    m_feederType = 0;
    m_flClickTimer = 0.0f;
    m_strTitle = "";
    m_feederColumn = 0;
}

void vguiFeeder::SetFeederType(feederTypes_t newType)
{
	m_feederType = newType;
}

void vguiFeeder::SetFeederColumn(int columNum)
{
    m_feederColumn = columNum;
}


void vguiFeeder::Spawned(void)
{
	SetSize([96,16]);
}

void vguiFeeder::Draw(void)
{
	vguiTheme theme = GetTheme();
    int itemCount = GetItemCount();

	if (itemCount <= 0) {
		return;
	}

	theme.DrawTextBackground(m_parent.m_vecOrigin + m_vecOrigin, m_vecSize, VGUI_STATE_NORMAL);

	vector vecOffset = [8,8];

	int iMaxDisplay = GetMaxVisibleItems();


	drawsetcliparea(m_parent.m_vecOrigin[0] + m_vecOrigin[0],m_parent.m_vecOrigin[1] + m_vecOrigin[1], m_vecSize[0] - 1, m_vecSize[1]);
    int upperLimit = (0, iMaxDisplay + m_iDrawOffset, itemCount);

	for (int i = m_iDrawOffset; i < upperLimit; i++) {
        string itemText = Feeder_StringAtIndex(i, m_feederColumn, m_feederType);

		if (!STRING_SET(itemText)) {
			continue;
		}

		if (m_iSelected == i) {
			theme.DrawHighlight(m_parent.m_vecOrigin + m_vecOrigin + vecOffset + [-7,-3], [m_vecSize[0] - 2, 18], VGUI_STATE_NORMAL);
		} else if (i & 1) {
			drawfill(m_parent.m_vecOrigin + m_vecOrigin + vecOffset + [-7,-3], [m_vecSize[0] - 2, 18], [1,1,1], 0.1f);
		}

		if (m_iSelected == i) {
			theme.DrawHighlightText(m_parent.m_vecOrigin + m_vecOrigin + vecOffset, itemText, m_vecSize, g_fntDefault);
		} else {
			theme.DrawText(m_parent.m_vecOrigin + m_vecOrigin + vecOffset, itemText, m_vecSize, g_fntDefault);
		}

		vecOffset[1] += 20;
	}
	drawresetcliparea();
}

bool vguiFeeder::Input (float flEVType, float flKey, float flChar, float flDevID)
{
	bool ret = false;
    int itemCount = GetItemCount();
	bool iMouseOver = MouseAbove();

	if (itemCount <= 0) {
		return (false);
	}

	if (iMouseOver == false) {
        return (false);
    }

	int iMaxDisplay = GetMaxVisibleItems();

	vector vecOffset = [8,8];
	if (flEVType == IE_KEYDOWN) {
		if (flKey == K_MOUSE1) {
            int upperLimit = (0, iMaxDisplay + m_iDrawOffset, itemCount);

			for (int i = m_iDrawOffset; i < upperLimit; i++) {
				if (Util_MouseAbove(g_vecMousePos, m_parent.m_vecOrigin + m_vecOrigin + vecOffset, [m_vecSize[0] - 16, 20])) {
					/* last item as last time */
					if (m_iSelected == i) {
						/* double click timer */
						if (m_flClickTimer > time) {
							if (tmpvguiFeeder2)
								vguiFeeder_CallFunctionWithDelegate(tmpvguiFeeder2, tmpvguiFeeder2Delegate, this);
						}
					}
					m_iSelected = i;

					vguiFeeder_CallFunctionWithDelegate(tmpvguiFeeder3, tmpvguiFeeder3Delegate, this);

					m_flClickTimer = time + 0.5f;
					ret = true;
				}
				vecOffset[1] += 20;
			}
		} else if (flKey == K_MWHEELUP && iMouseOver) {
			SetOffset(m_iDrawOffset - (iMaxDisplay / 4), TRUE);
			ret = true;
		} else if (flKey == K_MWHEELDOWN && iMouseOver) {
			SetOffset(m_iDrawOffset + (iMaxDisplay / 4), TRUE);
			ret = true;
		}
	}
	return (ret);
}

int vguiFeeder::GetMaxVisibleItems(void)
{
    int itemCount = GetItemCount();
	int iMaxDisplay = bound(0, itemCount, rint(m_vecSize[1] / 20));
	return iMaxDisplay;
}

void vguiFeeder::SetOffset (int iOffset, int iCallBack)
{
    int itemCount = GetItemCount();
	int iMaxDisplay = bound(0, itemCount, floor(m_vecSize[1] / 20));
	m_iDrawOffset = bound(0, iOffset, itemCount - iMaxDisplay);

	if (tmpvguiFeeder1 && iCallBack) {
		vguiFeeder_CallFunctionWithDelegate(tmpvguiFeeder1, tmpvguiFeeder1Delegate, this);
	}
}
int vguiFeeder::GetOffset(void)
{
	return m_iDrawOffset;
}

void vguiFeeder::SetItemCount (int iCount)
{

}
int vguiFeeder::MaxItems(void)
{
	return Feeder_Count(m_feederType);
}
int vguiFeeder::GetItemCount(void)
{
	return MaxItems();
}
void vguiFeeder::RemoveAllItems(void)
{

}

string vguiFeeder::GetItem (int iIndex)
{
	if (iIndex < 0i || GetItemCount() <= 0i) {
		ncError("vguiFeeder: GetItem on empty/unselected list! %i/%i", iIndex, GetItemCount());
		return "ERROR";
	}
	return Feeder_StringAtIndex(iIndex, m_feederColumn, m_feederType);
}

string vguiFeeder::GetItemAtColumn (int iIndex, int iColumn)
{
	if (iIndex < 0i || GetItemCount() <= 0i) {
		ncError("vguiFeeder: GetItem on empty/unselected list! %i/%i", iIndex, GetItemCount());
		return "ERROR";
	}
	return Feeder_StringAtIndex(iIndex, iColumn, m_feederType);
}


void vguiFeeder::SetSelected (int iVal)
{
	m_iSelected = iVal;
}
int vguiFeeder::GetSelected(void)
{
	return m_iSelected;
}

void vguiFeeder::AddItem (string strItem)
{
}

void vguiFeeder::CallOnScroll (void(vguiWidget sender) vFunc)
{
	tmpvguiFeeder1 = vFunc;
}

void vguiFeeder::CallOnSelectionChanged (void(vguiWidget sender) vFunc)
{
	tmpvguiFeeder3 = vFunc;
}

void vguiFeeder::CallOnScrollWithDelegate(void(vguiWidget sender) vFunc, vguiWidget delegateWidget)
{
	tmpvguiFeeder1 = vFunc;
	tmpvguiFeeder1Delegate = delegateWidget;
}

void vguiFeeder::CallOnSelectionChangedWithDelegate(void(vguiWidget sender) vFunc, vguiWidget delegateWidget)
{
	tmpvguiFeeder3 = vFunc;
	tmpvguiFeeder3Delegate = delegateWidget;
}

void vguiFeeder::CallOnDoubleClick (void(vguiWidget sender) vFunc)
{
	tmpvguiFeeder2 = vFunc;
}

void vguiFeeder::CallOnDoubleClickWithDelegate(void(vguiWidget sender) vFunc, vguiWidget delegateWidget)
{
	tmpvguiFeeder2 = vFunc;
	tmpvguiFeeder2Delegate = delegateWidget;
}
