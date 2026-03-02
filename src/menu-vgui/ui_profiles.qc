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

int g_iProfilesInitialized;
static vguiFeeder lsbProfiles;
static vguiScrollBar scrlProfiles;

static void
Profiles_Switch ( void )
{
	string strSong;
	strSong = lsbProfiles.GetItem( lsbProfiles.GetSelected() );
	localcmd( sprintf( "profile_switch %s\n", strSong) );
}

static void
Profiles_New ( void )
{
}

static void
Profiles_PurgeSelected ( void )
{
}

static void
Profiles_ScrollUpdate ( void )
{
	scrlProfiles.SetValue( lsbProfiles.GetOffset() );
}

static void
Profiles_ListUpdate ( void )
{
	lsbProfiles.SetOffset( scrlProfiles.GetValue(), FALSE );
}


void UI_Profiles_Show ( void )
{
	static vguiPanel winLoadGame;
	static vguiButton btnLoad;

	if ( !g_iProfilesInitialized ) {
		g_iProfilesInitialized = true;
		winLoadGame = spawn( vguiPanel );
		winLoadGame.SetTitle( "Switch Profile" );
		winLoadGame.SetSize( [256,180] );
		winLoadGame.SetIcon( "gfx/icon16/user" );

		lsbProfiles = spawn( vguiFeeder );
		lsbProfiles.SetSize( [192, 96] );
		lsbProfiles.SetPos( [8, 32] );
		lsbProfiles.SetFeederType( FEEDER_PLAYER_PROFILES );

		scrlProfiles = spawn( vguiScrollBar );
		scrlProfiles.SetLength( 96 );
		scrlProfiles.SetPos( [201,32] );
		scrlProfiles.SetMin( 0 );
		scrlProfiles.SetStep( 1 );
		scrlProfiles.CallOnChange( Profiles_ListUpdate );

		btnLoad = spawn( vguiButton );
		btnLoad.SetTitle( "Switch" );
		btnLoad.SetIcon( "gfx/icon16/arrow_right" );
		btnLoad.SetPos( [8,132] );
		btnLoad.SetSize([64,24]);
		btnLoad.SetFunc( Profiles_Switch );

		btnLoad = spawn( vguiButton );
		btnLoad.SetTitle( "New" );
		btnLoad.SetIcon( "gfx/icon16/new" );
		btnLoad.SetPos( [8,132] );
		btnLoad.SetSize([64,24]);
		btnLoad.SetFunc( Profiles_New );

		btnLoad = spawn( vguiButton );
		btnLoad.SetTitle( "Purge" );
		btnLoad.SetIcon( "gfx/icon16/cross" );
		btnLoad.SetPos( [8,132] );
		btnLoad.SetSize([64,24]);
		btnLoad.SetFunc( Profiles_PurgeSelected );

		g_uiDesktop.Add( winLoadGame );
		winLoadGame.Add( lsbProfiles );
		winLoadGame.Add( scrlProfiles );
		winLoadGame.Add( btnLoad );
	}

	winLoadGame.Show();
	winLoadGame.SetPos( ( g_vidsize / 2 ) - ( winLoadGame.GetSize() / 2 ) );
}
