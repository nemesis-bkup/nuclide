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

static void
vguiTextPrompt_CallFunctionWithDelegateSender(void(vguiControl sender) targetFunc, vguiWidget delegateWidget, vguiControl sender)
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

class
vguiTextPrompt:vguiWindow
{
    void vguiTextPrompt(void);

    virtual void Spawned(void);

    nonvirtual void Textprompt_OK(vguiWidget sender);
    nonvirtual void Textprompt_Cancel(vguiWidget sender);
    nonvirtual void SetOKAction(void(vguiWidget sender) func, vguiControl delegate);

private:

    vguiButton btnOK;
    vguiButton btnCancel;
    vguiTextBox textBox;
};

void
vguiTextPrompt::vguiTextPrompt(void)
{

}

void
vguiTextPrompt::Textprompt_OK(vguiWidget sender)
{
    vguiTextPrompt_CallFunctionWithDelegateSender(tmpvguiButton1, tmpvguiButton1Delegate, this);
    Hide();
}

void
vguiTextPrompt::Textprompt_Cancel(vguiWidget sender)
{
    textBox.SetText("");
    Hide();
}

void
vguiTextPrompt::SetOKAction(void(vguiWidget sender) func, vguiControl delegateWidget)
{
    //#warning "SetFunc in vguiButton is DEPRECATED. Compiler IS generating JUNK in the old way. Please override vguiButton and define a OnMouseDown/Up method instead"
    //m_vFunc = vFunc;
    tmpvguiButton1 = func;
    tmpvguiButton1Delegate = delegateWidget;
}

void
vguiTextPrompt::Spawned(void)
{
    super::Spawned();

    classname = "vguiWindow";
    SetTitle( "Text Prompt" );
    SetSize( [192+16,128-24] );
    SetIcon( "gfx/icon16/page_white_text" );

    btnOK = spawn( vguiButton );
    btnOK.SetTitle( "OK" );
    //btnOK.SetIcon( "gfx/icon16/control_play" );
    btnOK.SetPos( [8,64] );
    btnOK.SetSize([64,24]);
    btnOK.SetFuncWithDelegate( Textprompt_OK, this );

    btnCancel = spawn( vguiButton );
    btnCancel.SetTitle( "Cancel" );
    //btnOK.SetIcon( "gfx/icon16/control_play" );
    btnCancel.SetPos( [96-16,64] );
    btnCancel.SetSize([64,24]);
    btnCancel.SetFuncWithDelegate( Textprompt_Cancel, this );

    textBox = spawn( vguiTextBox );
    textBox.SetText( "" );
    textBox.SetPos( [8,32] );
    textBox.SetSize([192,24]);

    Add( btnCancel );
    Add( btnOK );
    Add( textBox );
}
