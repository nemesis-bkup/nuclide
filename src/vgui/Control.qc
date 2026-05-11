/*
 * Copyright (c) 2023 Vera Visions LLC.
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

/** VGUI: Abstract Control Class

This is an abstract control class for various VGUI related widgets.
@ingroup vgui
*/
class
vguiControl:vguiWidget
{
public:
    virtual void vguiControl(void);

    /** Set the control tag. Used for identification purposes. */
    nonvirtual void SetTag(int);
    /** Returns the control tag. Used for identification purposes. */
    nonvirtual int GetTag(void);

    /** Sets the key to be pressed to order to simulate a click event. */
    nonvirtual void SetKeyEquivalent(string);
    /** Returns the key to be pressed in order to simulate a click event. */
    nonvirtual string GetKeyEquivalent(void);

    /* overridable */
    /** Called when the mouse starts hovering over this element. */
    virtual void OnMouseEntered(void);
    /** Called when the mouse stops hovering over this element. */
    virtual void OnMouseExited(void);
    /** Called when the mouse starts klicking down on this element. */
    virtual void OnMouseDown(void);
    /** Called when the mouse stops klicking down on this element. This is when actions usually need to be triggered. */
    virtual void OnMouseUp(void);

    nonvirtual void SetPreModificationCallback(void(void) func, vguiControl delegateWidget);
    nonvirtual void SetPostModificationCallback(void(void) func, vguiControl delegateWidget);

    nonvirtual void _PreModificationCallback();
    nonvirtual void _PostModificationCallback();

    nonvirtual void SetPreInteractionCallback(void(void) func, vguiControl delegateWidget);
    nonvirtual void SetPostInteractionCallback(void(void) func, vguiControl delegateWidget);

    nonvirtual void _PreInteractionCallback();
    nonvirtual void _PostInteractionCallback();

private:
    int m_iTag;
    float m_keyEquivalent;
};

.void(vguiControl sender) tmpvguiControl1;
.vguiWidget tmpvguiControl1Delegate;
.void(vguiControl sender) tmpvguiControl2;
.vguiWidget tmpvguiControl2Delegate;
.void(vguiControl sender) tmpvguiControl3;
.vguiWidget tmpvguiControl3Delegate;
.void(vguiControl sender) tmpvguiControl4;
.vguiWidget tmpvguiControl4Delegate;

void
vguiControl::vguiControl(void)
{
    m_iTag = 0i;
    m_keyEquivalent = -1;
}

void
vguiControl::SetTag(int val)
{
    m_iTag = val;
}

int
vguiControl::GetTag(void)
{
    return m_iTag;
}

void
vguiControl::SetKeyEquivalent(string keyValue)
{
    m_keyEquivalent = stringtokeynum(keyValue);
}

string
vguiControl::GetKeyEquivalent(void)
{
    return keynumtostring(m_keyEquivalent);
}

void
vguiControl::OnMouseEntered(void)
{
}

void
vguiControl::OnMouseExited(void)
{
}

void
vguiControl::OnMouseDown(void)
{
}

void
vguiControl::OnMouseUp(void)
{
}

void
vguiControl::SetPreModificationCallback(void(void) func, vguiControl delegateWidget)
{
    tmpvguiControl1 = func;
    tmpvguiControl1Delegate = delegateWidget;
}

void
vguiControl::SetPostModificationCallback(void(void) func, vguiControl delegateWidget)
{
    tmpvguiControl2 = func;
    tmpvguiControl2Delegate = delegateWidget;
}

void
vguiControl::SetPreInteractionCallback(void(void) func, vguiControl delegateWidget)
{
    tmpvguiControl3 = func;
    tmpvguiControl3Delegate = delegateWidget;
}

void
vguiControl::SetPostInteractionCallback(void(void) func, vguiControl delegateWidget)
{
    tmpvguiControl4 = func;
    tmpvguiControl4Delegate = delegateWidget;
}

void
vguiControl_CallFunctionWithDelegateSender(void(vguiControl sender) targetFunc, vguiWidget delegateWidget, vguiControl sender)
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

void
vguiControl::_PreModificationCallback(void)
{
    vguiControl_CallFunctionWithDelegateSender(tmpvguiControl1, tmpvguiControl1Delegate ? tmpvguiControl1Delegate : m_parent, this);
}

void
vguiControl::_PostModificationCallback(void)
{
    vguiControl_CallFunctionWithDelegateSender(tmpvguiControl2, tmpvguiControl2Delegate ? tmpvguiControl2Delegate : m_parent, this);
}

void
vguiControl::_PreInteractionCallback(void)
{
    vguiControl_CallFunctionWithDelegateSender(tmpvguiControl3, tmpvguiControl3Delegate ? tmpvguiControl3Delegate : m_parent, this);
}

void
vguiControl::_PostInteractionCallback(void)
{
    vguiControl_CallFunctionWithDelegateSender(tmpvguiControl4, tmpvguiControl4Delegate ? tmpvguiControl4Delegate : m_parent, this);
}
