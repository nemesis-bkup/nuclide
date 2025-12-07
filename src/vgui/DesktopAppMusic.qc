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
vguiDesktopAppMusic:vguiWindow
{
	void vguiDesktopAppMusic(void);

	virtual void Spawned(void);

private:

	vguiList lsbSongs;
	vguiScrollBar scrlSong;
	vguiButton btnPlay;
	vguiButton btnStop;
};

void
vguiDesktopAppMusic::vguiDesktopAppMusic(void)
{
}

void
vguiDesktopAppMusic::MusicPlayer_Play(void)
{
	string strSong;
	strSong = lsbSongs.GetItem( lsbSongs.GetSelected() );
	localcmd( sprintf( "play %S\n", strSong ) );
}

void
vguiDesktopAppMusic::MusicPlayer_Stop(void)
{
	localcmd( "stopsound\n" );
}

void
vguiDesktopAppMusic::MusicPlayer_ScrollUpdate(void)
{
	scrlSong.SetValue( lsbSongs.GetOffset() );
}

void
vguiDesktopAppMusic::MusicPlayer_ListUpdate(void)
{
	lsbSongs.SetOffset( scrlSong.GetValue(), FALSE );
}

void
vguiDesktopAppMusic::Spawned(void)
{
	super::Spawned();

	classname = "vguiWindow";
	SetTitle( "Music Player" );
	SetSize( [256,180] );
	SetIcon( "gfx/icon16/ipod" );

	searchhandle shSongs = search_begin( "music/*.flac:music/*.wav:music/*.ogg:media/*.mp3:sound/music/*.mp3", SEARCH_NAMESORT | SEARCH_MULTISEARCH, TRUE );
	lsbSongs = spawn( vguiList );
	lsbSongs.SetSize( [192, 96] );
	lsbSongs.SetPos( [8, 32] );
	lsbSongs.SetItemCount( search_getsize( shSongs ) );
	lsbSongs.CallOnScrollWithDelegate( MusicPlayer_ScrollUpdate, this );

	for ( int i = 0; i < search_getsize( shSongs ); i++ ) {
		lsbSongs.AddItem( search_getfilename( shSongs, i ) );
	}

	scrlSong = spawn( vguiScrollBar );
	scrlSong.SetLength( 96 );
	scrlSong.SetPos( [201,32] );
	scrlSong.SetMin( 0 );
	scrlSong.SetStep( 1 );
	scrlSong.SetMax( lsbSongs.GetMaxVisibleItems() );
	scrlSong.CallOnChangeWithDelegate( MusicPlayer_ListUpdate, this );

	btnPlay = spawn( vguiButton );
	btnPlay.SetTitle( "Play" );
	btnPlay.SetIcon( "gfx/icon16/control_play" );
	btnPlay.SetPos( [8,132] );
	btnPlay.SetSize([64,24]);
	btnPlay.SetFuncWithDelegate( MusicPlayer_Play, this );

	btnStop = spawn( vguiButton );
	btnStop.SetTitle( "Stop" );
	btnStop.SetIcon( "gfx/icon16/control_stop" );
	btnStop.SetPos( [96,132] );
	btnStop.SetSize([64,24]);
	btnStop.SetFuncWithDelegate( MusicPlayer_Stop, this );

	Add( lsbSongs );
	Add( scrlSong );
	Add( btnPlay );
	Add( btnStop );
	search_end( shSongs );
}
