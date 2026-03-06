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
	WINDOW_DRAGGING,
	WINDOW_RESIZING,
};

typedef enumflags
{
	vguiWindowBorderless,
	vguiWindowTitled,
	vguiWindowClosable,
	vguiWindowMiniaturizable,
	vguiWindowResizeable,
	vguiWindowMovable,
	vguiWindowFullscreen
} vguiWindowStyle_t;

#define vguiWindowStyleDefault vguiWindowMovable | \
		vguiWindowTitled | \
		vguiWindowClosable | \
		vguiWindowMiniaturizable

/* TODO: MOVE THESE INTO vguiWindow! COMPILER NEEDS TO BE FIXED FIRST HOWEVER. */
.void(void) tmpvguiWindow1;
.void(void) tmpvguiWindow2;

/** VGUI: Window

Top-most window class in VGUILib.

@ingroup vgui
*/
class vguiWindow:vguiView
{
public:
	void vguiWindow(void);

	/** Set the title of the window widget. */
	nonvirtual void SetTitle(string);
	/** Returns the title of the window widget. */
	nonvirtual string GetTitle(void);

	/** Sets the icon of the window widget. */
	nonvirtual void SetIcon(string);
	/** Returns the icon of the window widget. */
	nonvirtual string GetIcon(void);

	/** Sets the style mask of the specified window. */
	nonvirtual void SetStyleMask(vguiWindowStyle_t);

	/** Called when the window is was resized by the user. */
	nonvirtual void CallOnResize(void(void) vFunc);
	/** Called when the window has been repositioned by the user. */
	nonvirtual void CallOnMove(void(void) vFunc);

	/** Call to close the window, and to destroy its contents. */
	nonvirtual void Close(void);

	/** Will focus the window when called. */
	nonvirtual bool Focus(void);
	nonvirtual void ShowContents();
	nonvirtual void HideContents();

	virtual void Add(vguiWidget wNew);

	nonvirtual void SetWindowBackground(string backgroundMaterial);

	/** Called when the vguiWindow got moved successfully. */
	virtual void WindowDidMove(vector, vector);
	/** Called when the vguiWindow got resized successfully. */
	virtual void WindowDidResize(vector, vector);
	/** Called when the vguiWindow was successfully closed. */
	virtual void WindowDidClose(void);

	/* overrides */
	virtual void Draw(void);
	virtual void SizeChanged(vector, vector);
	virtual bool Input(float, float, float, float);
	virtual void Spawned(void);
	virtual void NowVisible(void);
	virtual void NowHidden(void);
	virtual void OnRemove(void);

private:
	vector m_vecColor;
	float m_flAlpha;
	vector m_vecDragOffset;
	string m_strTitle;
	string m_strIcon;
	vguiButton m_btnClose;
	vguiWindowStyle_t m_styleMask;
	bool m_contentsVisible;
	string m_windowBackground;
};

void
vguiWindow::vguiWindow(void)
{
	m_styleMask = vguiWindowStyleDefault;
	m_contentsVisible = true;
	m_windowBackground = __NULL__;
	m_vecColor = g_vec_null;
	m_flAlpha = 1.0f;
	m_vecDragOffset = g_vec_null;
	m_strTitle = __NULL__;
	m_strIcon = __NULL__;
	m_btnClose = __NULL__;
}

void
vguiWindow::HideContents(void)
{
	m_contentsVisible = false;
}

void
vguiWindow::ShowContents(void)
{
	m_contentsVisible = true;
}

void
vguiWindow::NowVisible(void)
{
	Focus();
}

bool
vguiWindow::Focus(void)
{
	vguiWidget wLast = this;
	vguiWidget wEdit = GetRootWindow(); /* start at parent */
//	error("Focusing!!!\n");

	/* iterate through the main windows, we start at the parent of all windows... */
	do {
		//print(sprintf("At %S\n", wEdit.classname));
		wLast = wEdit;
		wEdit = wEdit.m_next; /* next window of parent */

		/* skip over ourselves. */
		if (wEdit == this) {
			wEdit = this.m_next;
			wLast.m_next = this.m_next;
		//	print("Skipping over ourselves...\n");
			//print(sprintf("At %S\n", wEdit.classname));
		}

		/* if empty... mark ourselves as the last window */
		if (wEdit == __NULL__) {
			//print("Last window is us...\n");
			wLast.m_next = this;
			this.m_next = __NULL__;
		}
	} while (wEdit);

	vguiRootWindow rootWindow = (vguiRootWindow)GetRootWindow();
	rootWindow.SetFocus(this);

	return true;
}

void
vguiWindow::Add(vguiWidget wNew)
{
	if (!wNew) {
		return;
	}

	wNew.m_parent = this;
}


void
vguiWindow::DrawChildren(void)
{
    for (vguiWidget widgets = 0; (widgets = findfloat(widgets, ::isVGUI, true));) {
        if (widgets.GetParent() == this && widgets.Visible()) {
			widgets.Draw();
        }
    }
}

bool
vguiWindow::InputChildren(float flEVType, float flKey, float flChar, float flDevID)
{
	vguiWidget wNext = this;
	vguiWidget wLast = __NULL__;
	vguiWidget wLastBefore = __NULL__;

	/* figure out the last window in the chain... */
	do {
		wLastBefore = wNext;
		wNext = wNext.m_windowNext;

		if (wNext) {
			wLast = wNext;
		}
	} while (wNext);

	//print(sprintf("Last widget: %S\n", wLast.classname));

	/* we've found a window, let's test inputs backwards. */
	while (STRING_SET(wLast.classname)) {
		bool test = false;

		if (wLast.Visible())
			test = wLast.Input(flEVType, flKey, flChar, flDevID);

		//print(sprintf("Testing input for... widget: %S %d\n", wLast.classname, test));

		/* input successful */
		if (test == true) {
			return (true);
		}

		/* select the former input */
		for (vguiWidget a = this; a != __NULL__; a = a.m_windowNext) {
			/* we've reached the end, take one from before */
			if (a == wLast) {
				wLast = wLastBefore;
				break;
			}
			wLastBefore = a;
		}

		/* the end of the world. */
		if (wLast == this)
			return (false);
	}

	return (false);
}


void
vguiWindow::SetStyleMask(vguiWindowStyle_t val)
{
	if (!(val & vguiWindowClosable)) {
		m_btnClose.Hide();
	}

	m_styleMask = val;
}

void
vguiWindow::CallOnResize(void(void) func)
{
	//#warning "SetFunc in vguiButton is DEPRECATED. Compiler IS generating JUNK in the old way. Please override vguiButton and define a OnMouseDown/Up method instead"
	//m_vFunc = vFunc;
	tmpvguiWindow1 = func;
}

void
vguiWindow::CallOnMove(void(void) func)
{
	//#warning "SetFunc in vguiButton is DEPRECATED. Compiler IS generating JUNK in the old way. Please override vguiButton and define a OnMouseDown/Up method instead"
	//m_vFunc = vFunc;
	tmpvguiWindow2 = func;
}


void
vguiWindow::Spawned(void)
{
	SetMinSize([64,64]);
	SetMaxSize([9999,9999]); // TODO: Make this the screen res

	m_strTitle = "Window";

	m_btnClose = spawn(vguiButton);
	m_btnClose.SetTitle(__NULL__);
	m_btnClose.SetIcon("gfx/icon16/cross_mono");
	m_btnClose.SetIconColor([1,1,1]);
	m_btnClose.SetColor(m_vecColor);
	m_btnClose.SetAction(Close, this);
	m_btnClose.SetSize([20,20]);
	Add(m_btnClose);

	SetSize([320,240]);
}

void
vguiWindow::OnRemove(void)
{
	super::OnRemove();
}

void
vguiWindow::NowHidden(void)
{
	vguiRootWindow rootWin = (vguiRootWindow)GetRootWindow();

    if (HasFocus() == true) {
        rootWin.SetFocusToNextWindow();
    }
}

void
vguiWindow::Close(void)
{
	Hide();

    vguiTheme::PlaySound("window-close");
	WindowDidClose();
}

void vguiWindow::SetTitle (string strName)
{
	m_strTitle = localize(strName);
}
string vguiWindow::GetTitle(void)
{
	return m_strTitle;
}

void vguiWindow::SetIcon (string strName)
{
	m_strIcon = strName;
}
string vguiWindow::GetIcon(void)
{
	return m_strIcon;
}

void vguiWindow::SizeChanged (vector vecOld, vector vecNew)
{
	m_btnClose.SetPos([vecNew[0] - 24, 4]);
}

void
vguiWindow::WindowDidMove(vector oldPosition, vector newPosition)
{

}

void
vguiWindow::WindowDidResize(vector oldSize, vector newSize)
{

}

void
vguiWindow::WindowDidClose(void)
{
	Remove();
}

void
vguiWindow::SetWindowBackground(string backgroundMaterial)
{
	m_windowBackground = backgroundMaterial;
}

void vguiWindow::Draw(void)
{
	vguiTheme theme = GetTheme();

	if (STRING_SET(m_windowBackground)) {
		drawpic(m_vecOrigin, m_windowBackground, m_vecSize, [1,1,1], 1.0f, 0);
	} else {
		if (m_styleMask & vguiWindowFullscreen)
			theme.DrawWindowBackground([0, 0], g_vidsize, VGUI_STATE_ACTIVE);
		else if  (!(m_styleMask & vguiWindowBorderless))
			theme.DrawWindow(m_vecOrigin, m_vecSize, VGUI_STATE_ACTIVE);
		else
			theme.DrawWindowBackground(m_vecOrigin, m_vecSize, VGUI_STATE_ACTIVE);
	}

	if (m_styleMask & vguiWindowResizeable) {
		drawpic(m_vecOrigin + m_vecSize - [16,16], "gfx/icon16/corner", [16,16], m_vecColor, 1.0f, 0);
	}

	if (m_styleMask & vguiWindowTitled) {
		theme.DrawWindowTitle(m_vecOrigin, m_vecSize, m_strTitle, m_strIcon, g_fntDefault, VGUI_STATE_ACTIVE);
	}

	if (m_contentsVisible) {
		DrawChildren();
	}

#ifdef UI_DEVELOPER
	if (m_iFlags & WINDOW_DRAGGING) {
		Font_DrawText([8, g_vidsize[1] - 18], sprintf("Window Position: %d, %d\n", m_vecOrigin[0], m_vecOrigin[1]), g_fntDefault);
	}
	if (m_iFlags & WINDOW_RESIZING) {
		Font_DrawText([8, g_vidsize[1] - 18], sprintf("Window Size: %d, %d\n", m_vecSize[0], m_vecSize[1]), g_fntDefault);
	}
#endif

	if  (!(STRING_SET(m_windowBackground)) && !(m_styleMask & vguiWindowFullscreen) && !(m_styleMask & vguiWindowBorderless)) {
		theme.DrawWindowBorder(m_vecOrigin, m_vecSize, VGUI_STATE_ACTIVE);
	}
}

bool vguiWindow::Input (float flEVType, float flKey, float flChar, float flDevID)
{
	bool ret = false;
	vguiRootWindow rootWin = (vguiRootWindow)GetRootWindow();
	vector mousePos = rootWin.GetMousePos();
	bool hadFocus = HasFocus();

	if (flEVType == IE_KEYDOWN) {
		if (flKey == K_MOUSE1) {
			if (m_styleMask & vguiWindowResizeable && Util_MouseAbove(mousePos, GetAbsPos() + (m_vecSize - [16,16]), [16,16])) {
				m_iFlags |= WINDOW_RESIZING;
				ret = true;
				return Focus();
			} else if (m_styleMask & vguiWindowMovable && Util_MouseAbove(mousePos, GetAbsPos(), [m_vecSize[0] - 32, 16])) {
				m_iFlags |= WINDOW_DRAGGING;
				ret = true;
				m_vecDragOffset = GetPos() - mousePos;
				return Focus();
			}
		}
	} else if (flEVType == IE_KEYUP) {
		if (flKey == K_MOUSE1) {
			m_iFlags -= (m_iFlags & WINDOW_DRAGGING);
			m_iFlags -= (m_iFlags & WINDOW_RESIZING);
		}
	}

	if (m_iFlags & WINDOW_RESIZING) {
		if (flEVType == IE_MOUSEABS) {
			vector oldSize = m_vecSize;
			vector newSize = GetSize() + ([flKey, flChar] - GetPos() - m_vecSize);
			SetSize(newSize);
			WindowDidResize(oldSize, newSize);

			if (tmpvguiWindow1)
				tmpvguiWindow1();
		}
		ret = true;
	} else if (m_iFlags & WINDOW_DRAGGING) {
		if (flEVType == IE_MOUSEABS) {
			vector oldPos = GetPos();
			vector newPos = GetPos() + ([flKey, flChar] - GetPos()) + m_vecDragOffset;
			SetPos(newPos);
			WindowDidMove(oldPos, newPos);

			if (tmpvguiWindow2)
				tmpvguiWindow2();
		}
		ret = true;
	}

	if (m_contentsVisible) {
		/* if we hadn't had a successful input yet, pass it onto the children */
		if (ret == false) {
			ret = vguiView::Input(flEVType, flKey, flChar, flDevID);
		}
	}

	/* don't send clicks to elements behind our window */
	if (flEVType == IE_KEYDOWN && flKey == K_MOUSE1 && ret == false && Util_MouseAbove(mousePos, GetAbsPos(), m_vecSize)) {
		ret = true;
	}

	/* if an input was a success? refocus */
	if (hadFocus == false && ret == true) {
		Focus();
	}

	return (ret);
}
