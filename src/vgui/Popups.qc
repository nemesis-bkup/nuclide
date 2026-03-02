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

/** VGUI: Popups

Creates a variety of popup windows.

@ingroup vgui
*/
class vguiPopups
{
public:
    nonvirtual vguiWindow NewAlertPanel(string windowTitle, string windowText);
    nonvirtual vguiWindow NewChoice(string windowTitle, string windowText, string yesText, void(void) yesFunc, string noText, void(void) noFunc);
};

.void(void) m_choiceFirst;
.void(void) m_choiceSecond;
class
vguiPopupWindow:vguiWindow
{
public:
    void vguiPopupWindow(void);
};

void
vguiPopupWindow::vguiPopupWindow ( void ) {

}

void
vguiPopupWindow::Choice_First ( vguiWidget sender ) {
    vguiWindow sendingWindow = (vguiWindow)this;
    sendingWindow.m_choiceFirst();
	sendingWindow.Close();
}
void
vguiPopupWindow::Choice_Second ( vguiWidget sender ) {
    vguiWindow sendingWindow = (vguiWindow)this;
    sendingWindow.m_choiceSecond();
	sendingWindow.Close();
}
void
vguiPopupWindow::QuitGame_No ( vguiWidget sender ) {
    vguiWindow sendingWindow = (vguiWindow)this;
	sendingWindow.Close();
}

vguiWindow
vguiPopups::NewChoice(string windowTitle, string windowText, string yesText, void(void) yesFunc, string noText, void(void) noFunc)
{
    vguiPopupWindow winQuitGame;
    vguiLabel lblSure;
    vguiButton btnChoice1;
    vguiButton btnChoice2;

    winQuitGame = spawn( vguiPopupWindow );
    winQuitGame.SetTitle( windowTitle );
    winQuitGame.SetSize( '256 128' );
    winQuitGame.SetIcon( "gfx/icon16/information" );

    btnChoice2 = spawn( vguiButton );
    btnChoice2.SetTitle( noText );
    btnChoice2.SetSize( '64 24' );
    btnChoice2.SetPos( winQuitGame.GetSize() - '80 32' );

    btnChoice1 = spawn( vguiButton );
    btnChoice1.SetTitle( yesText );
    btnChoice1.SetSize( '64 24' );
    btnChoice1.SetPos( btnChoice2.GetPos() - [btnChoice2.GetWidth() + 4, 0] );

    lblSure = spawn( vguiLabel );
    lblSure.SetTitle( windowText );
    lblSure.SetSize( '256 16' );
    lblSure.SetPos( '0 48' );
    lblSure.SetAlignment(AF_NONE);

    winQuitGame.m_choiceFirst = yesFunc;
    winQuitGame.m_choiceSecond = noFunc;

    btnChoice1.SetFuncWithDelegate( vguiPopupWindow::Choice_First, winQuitGame );
    btnChoice2.SetFuncWithDelegate( vguiPopupWindow::Choice_Second, winQuitGame );

    winQuitGame.Add( btnChoice1 );
    winQuitGame.Add( btnChoice2 );
    winQuitGame.Add( lblSure );

    vguiTheme::PlaySound("window-question");

    winQuitGame.Show();
    winQuitGame.SetPos( ( g_vidsize / 2 ) - ( winQuitGame.GetSize() / 2 ) );

    return (winQuitGame);
}


vguiWindow
vguiPopups::NewAlertPanel(string windowTitle, string windowText)
{
    vguiPopupWindow winQuitGame;
    vguiLabel lblSure;
    vguiButton btnCancel;

    winQuitGame = spawn( vguiPopupWindow );
    winQuitGame.SetTitle( windowTitle );
    winQuitGame.SetSize( '256 128' );
    winQuitGame.SetIcon( "gfx/icon16/cross" );

    btnCancel = spawn( vguiButton );
    btnCancel.SetTitle( "OK" );
    btnCancel.SetSize( '64 24' );
    btnCancel.SetPos( winQuitGame.GetSize() - '80 32' );

    lblSure = spawn( vguiLabel );
    lblSure.SetTitle( windowText );
    lblSure.SetSize( '256 16' );
    lblSure.SetPos( '0 48' );
    lblSure.SetAlignment(AF_NONE);

    btnCancel.SetFuncWithDelegate( vguiPopupWindow::QuitGame_No, winQuitGame );

    winQuitGame.Add( btnCancel );
    winQuitGame.Add( lblSure );

    vguiTheme::PlaySound("dialog-error");
	winQuitGame.Show();
	winQuitGame.SetPos( ( g_vidsize / 2 ) - ( winQuitGame.GetSize() / 2 ) );
    return (winQuitGame);
}

