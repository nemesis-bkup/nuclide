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
	BUTTON_HOVER,
	BUTTON_DOWN,
	BUTTON_LASTACTIVE,
	BUTTON_CUSTOMFLAGS
};

/* TODO: MOVE THESE INTO vguiButton! COMPILER NEEDS TO BE FIXED FIRST HOWEVER. */
.void(vguiControl sender) tmpvguiButton1;
.vguiWidget tmpvguiButton1Delegate;

/** VGUI Widget: Button

@ingroup vgui
*/
class vguiButton:vguiControl
{
public:
	void vguiButton(void);

	/** Sets the title of the button. */
	nonvirtual void SetTitle(string);
	/** Sets the icon of the button. */
	nonvirtual void SetIcon(string);
	/** Sets the color of the button text. */
	nonvirtual void SetColor(vector);
	/** Sets the color of the icon on the button. */
	nonvirtual void SetIconColor(vector);

	/** Gets the title of the button. */
	nonvirtual string GetTitle(void);
	/** Sets the function to call when the button is pressed. */
	nonvirtual void SetFunc(void(void));
	/** Sets the function to call when the button is pressed. */
	nonvirtual void SetAction(void(vguiControl sender));
	/** Sets the command to execute when the button is pressed. */
	nonvirtual void SetExec(string);

	/** Returns whether this button is disabled (true) or active (false). */
	nonvirtual bool ButtonDisabled(void);

    nonvirtual void ResizeToContents(void);

	/* overrides */
	virtual void Draw(void);
	virtual bool Input(float,float,float,float);
	virtual void Spawned(void);
	virtual vguiWidget InitWithFrame(vector pos, vector size);

private:
	vector m_vecIMGSize;
	vector m_vecColor;
	vector m_vecIconColor;
	float m_flAlpha;
	string m_strTitle;
	string m_strTitleActive;
	string m_strIcon;
	string m_strExec;
};

void
vguiButton::vguiButton(void)
{
	m_strExec = __NULL__;
	m_flAlpha = 1.0f;
	m_vecIconColor = [1,1,1];
	tmpvguiButton1 = 0;
	tmpvguiButton1Delegate = 0;
}

vguiWidget
vguiButton::InitWithFrame(vector atPos, vector withSize)
{
	vguiButton newButton = spawn(vguiButton);
	newButton.SetPos(atPos);
	newButton.SetSize(withSize);
	return (newButton);
}


void
vguiButton::Spawned(void)
{
	SetSize([96,24]);
}

void
vguiButton::SetColor(vector vecColor)
{
	m_vecColor = vecColor;
}

void
vguiButton::SetIconColor(vector vecColor)
{
	m_vecIconColor = vecColor;
}

void
vguiButton::ResizeToContents(void)
{
	vector newsize = [0.0f, 0.0f, 0.0f];

	if (STRING_SET(m_strIcon)) {
        newsize[0] = stringwidth(m_strTitle, TRUE, [g_fntDefault.iScaleX, g_fntDefault.iScaleY]) + 16 + (m_vecIMGSize[0] + 2);
	} else {
        newsize[0] = stringwidth(m_strTitle, TRUE, [g_fntDefault.iScaleX, g_fntDefault.iScaleY]) + 16;
    }

    newsize[1] = 24;
    SetSize(newsize);
}

void
vguiButton::SetTitle(string strName)
{
	m_strTitle = localize(strName);
	m_strTitleActive = sprintf("^3%s", m_strTitle);
	//m_strTitle = sprintf("%s%s", Font_RGBtoHex(UI_MAINCOLOR), strName);
	drawfont = g_fntDefault.iID;

	if (GetSize() == [0,0]) {
		ResizeToContents();
	}
}

string
vguiButton::GetTitle(void)
{
	return m_strTitle;
}

void
vguiButton::SetIcon(string strName)
{
	m_strIcon = strName;
	m_vecIMGSize = drawgetimagesize(strName);

	if (length(GetSize()) < length(m_vecIMGSize)) {
		SetSize(m_vecIMGSize + [4,4]);
	}
}

void
vguiButton::SetAction(void(vguiControl sender) func)
{
	//#warning "SetFunc in vguiButton is DEPRECATED. Compiler IS generating JUNK in the old way. Please override vguiButton and define a OnMouseDown/Up method instead"
	//m_vFunc = vFunc;
	tmpvguiButton1 = func;
}

void
vguiButton::SetFunc(void(void) func)
{
	//#warning "SetFunc in vguiButton is DEPRECATED. Compiler IS generating JUNK in the old way. Please override vguiButton and define a OnMouseDown/Up method instead"
	//m_vFunc = vFunc;
	tmpvguiButton1 = func;
}

void
vguiButton::SetFuncWithDelegate(void(void) func, vguiControl delegateWidget)
{
	//#warning "SetFunc in vguiButton is DEPRECATED. Compiler IS generating JUNK in the old way. Please override vguiButton and define a OnMouseDown/Up method instead"
	//m_vFunc = vFunc;
	tmpvguiButton1 = func;
	tmpvguiButton1Delegate = delegateWidget;
}

void
vguiButton::SetExec(string exe)
{
	m_strExec = exe;
}

bool
vguiButton::ButtonDisabled(void)
{
	if (STRING_SET(m_strExec)) {
		return (false);
	}

	if (tmpvguiButton1) {
		return (false);
	}

	return (true);
}

void
vguiButton::Draw(void)
{
	vguiTheme theme = GetTheme();

	if (IsEnabled() == false) {
		theme.DrawButton(GetAbsPos(), GetSize(), VGUI_STATE_DISABLED);
	} else if (m_iFlags & BUTTON_DOWN) {
		theme.DrawButton(GetAbsPos(), GetSize(), VGUI_STATE_ACTIVE);
	} else if (m_iFlags & BUTTON_HOVER) {
		theme.DrawButton(GetAbsPos(), GetSize(), VGUI_STATE_HOVER);
	} else {
		theme.DrawButton(GetAbsPos(), GetSize(), VGUI_STATE_NORMAL);
	}

	theme.DrawControlTextWithIcon(GetAbsPos(), m_strTitle, m_keyEquivalent, m_strIcon, m_vecIconColor, [16,16], GetSize(), VGUI_STATE_NORMAL, g_fntDefault);
}

static void
vguiButton_CallFunctionWithDelegateSender(void(vguiControl sender) targetFunc, vguiWidget delegateWidget, vguiControl sender)
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

bool
vguiButton::Input(float flEVType, float flKey, float flChar, float flDevID)
{
	bool ret = false;
	bool mouseHover = false;

	if (IsEnabled() == false) {
		return (false);
	}

	if (MouseAbove()) {
		mouseHover = true;
	}

	if (mouseHover == true && HasFlag(BUTTON_HOVER) == false) {
		FlagAdd(BUTTON_HOVER);
		OnMouseEntered();
	} else if (HasFlag(BUTTON_HOVER) && mouseHover == false) {
		FlagRemove(BUTTON_HOVER);
		OnMouseExited();
	}

	if (flEVType == IE_KEYDOWN) {
		if (flKey == K_MOUSE1) {
			FlagRemove(BUTTON_LASTACTIVE);

			if (mouseHover) {
				OnMouseDown();

				FlagAdd(BUTTON_DOWN);
				FlagAdd(BUTTON_LASTACTIVE);
				ret = true;
			}
		}
	} else if (flEVType == IE_KEYUP) {
		/* simulate click */
		if (m_keyEquivalent >= 0) {
			if (flKey == m_keyEquivalent) {
				m_iFlags |= BUTTON_DOWN;
				mouseHover = true;
				flKey = K_MOUSE1;
			}
		}

		if (flKey == K_MOUSE1) {
			if ((m_iFlags & BUTTON_DOWN) && (mouseHover == true)) {
				OnMouseUp();

				vguiButton_CallFunctionWithDelegateSender(tmpvguiButton1, tmpvguiButton1Delegate ? tmpvguiButton1Delegate : m_parent, this);

				if (STRING_SET(m_strExec)) {
					localcmd(sprintf("%s\n", m_strExec));
				}

				ret = true;
			}

			FlagRemove(BUTTON_DOWN);
		}
	}
	return (ret);
}
