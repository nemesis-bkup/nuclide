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
vguiTool_Map:vguiWindow
{
	void vguiTool_Map(void);

	virtual void Draw(void);
	virtual void Spawned(void);

private:

	int m_tvChannelNum;
	vguiButton btnPlay;
	vguiButton btnStop;
	vguiFrame m_outlineFrame;
	vguiTextPrompt urlPrompt;
};

void
vguiTool_Map::vguiTool_Map(void)
{
}

void
vguiTool_Map::Map_SwitchToOverview(void)
{

}

void
vguiTool_Map::Map_SwitchTo3DView(void)
{

}

void
vguiTool_Map::Draw(void)
{
	super::Draw();

	g_overview.SetViewPosition(m_outlineFrame.m_parent.m_vecOrigin + m_outlineFrame.m_vecOrigin);
	g_overview.SetViewSize(m_outlineFrame.GetSize());
	g_overview.SetRadarPitch(90);
	g_overview.UpdateView();

	vector centerPos = m_outlineFrame.m_parent.m_vecOrigin + m_outlineFrame.m_vecOrigin;
	centerPos += (m_outlineFrame.GetSize() * 0.5) - [8,8];
	draw.Pic(centerPos, "gfx/icon16/bullet_white", [16,16], [1,1,1], 1.0, 0);
}

void
vguiTool_Map::VideoPlayer_Resized(void)
{
	vector windowSize = GetSize();
	m_outlineFrame.SetSize( [windowSize[0]-16, windowSize[1]-64] );

	btnPlay.SetPos( [8,windowSize[1]-28] );
	btnStop.SetPos( btnPlay.GetPos() + [32+2, 0] );
}

void
vguiTool_Map::Spawned(void)
{
	super::Spawned();

	classname = "vguiWindow";
	SetTitle( "Map" );
	SetSize( [160+16,120+32] );
	SetIcon( "gfx/icon16/map" );
	SetStyleMask( vguiWindowStyleDefault | vguiWindowResizeable );
	CallOnResize(VideoPlayer_Resized);

	m_outlineFrame = spawn(vguiFrame);
	m_outlineFrame.SetPos([8,32]);
	m_outlineFrame.SetSize([160,120]);

	btnPlay = spawn( vguiButton );
	btnPlay.SetIcon( "gfx/icon16/map_add" );
	btnPlay.SetSize([32,24]);
	btnPlay.SetFuncWithDelegate( Map_SwitchToOverview, this );

	btnStop = spawn( vguiButton );
	btnStop.SetIcon( "gfx/icon16/map_magnify" );
	btnStop.SetSize([32,24]);
	btnStop.SetFuncWithDelegate( Map_SwitchTo3DView, this );

	Add( m_outlineFrame );
	Add( btnPlay );
	Add( btnStop );

	VideoPlayer_Resized();
}
