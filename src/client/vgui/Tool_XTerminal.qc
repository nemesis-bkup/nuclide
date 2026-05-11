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

class
vguiTool_XTerminal:vguiApplication
{
    void vguiTool_XTerminal(void);

    virtual void Spawned(void);
    nonvirtual void XTerminal_Resized(void);

private:
    vguiXView webView;
};

void
vguiTool_XTerminal::vguiTool_XTerminal(void)
{
}

void
vguiTool_XTerminal::XTerminal_Resized(void)
{
    vector windowSize = GetSize();
    webView.SetSize( [windowSize[0]-16, windowSize[1]-64] );
}

void
vguiTool_XTerminal::Spawned(void)
{
    super::Spawned();

    SetTitle( "XTerminal" );
    SetSize( [480,320] );
    SetIcon( "gfx/icon16/world" );
    SetStyleMask( vguiWindowStyleDefault | vguiWindowResizeable );
    CallOnResize(XTerminal_Resized);

    webView = spawn( vguiXView );
    webView.SetSize( [480-16-21, 320-64] );
    webView.SetPos( [8, 32] );

    Add( webView );
}
