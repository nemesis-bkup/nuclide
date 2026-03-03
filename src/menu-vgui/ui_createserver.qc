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

var int autocvar_ui_maxclients = 8i;


int g_iCreateServerInitialized;

void UI_CreateServer_Show ( void )
{
	static vguiScrollBar scrlMaps;
	static vguiPanel winCreate;
	static vguiButton btnCancel;
	static vguiButton btnStart;
	static vguiFeeder lsbMaps;
	static vguiFeederListBox lsbModes;
	static vguiLabel lblModes;
	static vguiFeederListBox lsbEntities;
	static vguiLabel lblEntities;
    static vguiLabel lblMaps;
	static vguiLabel lblHostname;
	static vguiTextBox txbHostname;
	static vguiLabel lblMaxplayers;
	static vguiTextBox txbMaxplayers;
	static vguiLabel lblPassword;
	static vguiTextBox txbPassword;
	static vguiCheckbox chkLAN;
    static vguiPic picMapPreview;

	static void CreateServer_Start ( void ) {
		int iEndMap = lsbMaps.GetSelected();
		if ( lsbMaps.GetSelected() == 0 ) {
			iEndMap = (int)( rint( random( 1, lsbMaps.GetItemCount() ) ) );
		}

		string gameType = lsbModes.GetItem();

		if (chkLAN.GetValue() == true) {
			cvar_set("sv_public", "0");	
		} else {
			cvar_set("sv_public", "2");	
		}

		cvar_set("ui_servername", txbHostname.GetText());
		cvar_set("ui_numPlayers", txbMaxplayers.GetText());
		cvar_set("ui_gameType", gameType);
		cvar_set("ui_map", lsbMaps.GetItem( iEndMap ));
		cvar_set("sv_password", txbPassword.GetText());
		localcmd("spawnServer\n");
		winCreate.Hide();
	}
	static void CreateServer_Cancel ( void ) {
		winCreate.Hide();
	}
	static void CreateServer_ListUpdate ( void ) {
		lsbMaps.SetOffset( scrlMaps.GetValue(), FALSE );
	}
	static void CreateServer_Scrolled ( void ) {
		scrlMaps.SetValue( lsbMaps.GetOffset() );
	}
	static void MapSelection_Changed(void) {
        picMapPreview.SetImage(MapLibrary_GetInfo(lsbMaps.GetSelected(), MAPINFO_PREVIEW));
    }

	if ( !g_iCreateServerInitialized ) {
		g_iCreateServerInitialized = TRUE;
		winCreate = spawn( vguiPanel );
		winCreate.SetTitle( "Create World" );
		winCreate.SetSize( '338 385' );
		winCreate.SetIcon( "gfx/icon16/world_add" );

		lblMaps = spawn( vguiLabel );
		lblMaps.SetPos( [175,32] );
		lblMaps.SetTitle( "Maps" );
        winCreate.Add(lblMaps);

        picMapPreview = spawn( vguiPic );
        picMapPreview.SetPos( lblMaps.GetPos() + [0, lblMaps.GetHeight() + 4] );
		picMapPreview.SetSize( [128,96] );
		picMapPreview.SetBorder(4);

		lsbMaps = spawn( vguiFeeder );
		lsbMaps.SetSize( [128,192] );
		lsbMaps.SetPos( picMapPreview.GetPos() + [0, picMapPreview.GetHeight() + 4] );
		lsbMaps.SetFeederType(FEEDER_ALLMAPS);
		lsbMaps.CallOnScroll( CreateServer_Scrolled );
		lsbMaps.SetSelected( 0 );
        lsbMaps.CallOnSelectionChanged(MapSelection_Changed);

		chkLAN = spawn( vguiCheckbox );
		chkLAN.SetTitle( "LAN only" );
		chkLAN.SetValue( TRUE );
		chkLAN.SetSize( '124 24' );
		chkLAN.SetPos( '20 186' );

		scrlMaps = spawn( vguiScrollBar );
		scrlMaps.SetLength( lsbMaps.GetHeight() );
		scrlMaps.SetPos(lsbMaps.GetPos() + [lsbMaps.GetWidth(), 0] );
		scrlMaps.SetMin( 0 );
		scrlMaps.SetStep( 1 );
		scrlMaps.SetMax( Feeder_Count(FEEDER_ALLMAPS) );
		scrlMaps.CallOnChange( CreateServer_ListUpdate );

		lblModes = spawn( vguiLabel );
		lblModes.SetPos( '20 218' );
		lblModes.SetTitle( "Gametype" );

		lsbModes = spawn( vguiFeederListBox );
		lsbModes.SetSize( '128 24' );
		lsbModes.SetPos( '20 234' );
		lsbModes.SetFeederType(FEEDER_GAMETYPES);
		lsbModes.SetText(cvar_string( "g_gametype" ));

		lblEntities = spawn( vguiLabel );
		lblEntities.SetPos(lsbModes.GetPos() + [0, lsbModes.GetHeight() + 16] );
		lblEntities.SetTitle( "Entities" );

		lsbEntities = spawn( vguiFeederListBox );
		lsbEntities.SetSize( '128 24' );
		lsbEntities.SetPos(lblEntities.GetPos() + [0, lblEntities.GetHeight() + 4] );
		//lsbEntities.SetFeederType(FEEDER_MAPENTITIES);

		btnStart = spawn( vguiButton );
		btnStart.SetTitle( "Start" );
		btnStart.SetSize( '64 24' );
		btnStart.SetPos( winCreate.GetSize() - '152 32' );
		btnStart.SetFunc( CreateServer_Start );

		btnCancel = spawn( vguiButton );
		btnCancel.SetTitle( "Cancel" );
		btnCancel.SetSize( '64 24' );
		btnCancel.SetPos( winCreate.GetSize() - '80 32' );
		btnCancel.SetFunc( CreateServer_Cancel );

		lblHostname = spawn( vguiLabel );
		lblHostname.SetPos( '20 32' );
		lblHostname.SetTitle( "Server name" );

		txbHostname = spawn( vguiTextBox );
		txbHostname.SetPos( [ 20, 50 ] );
		txbHostname.SetSize( [ 124, 24 ] );
		txbHostname.SetText( cvar_string( "hostname" ) );

		lblMaxplayers = spawn( vguiLabel );
		lblMaxplayers.SetPos( '20 84' );
		lblMaxplayers.SetTitle( "Max players" );

		txbMaxplayers = spawn( vguiTextBox );
		txbMaxplayers.SetPos( [ 20, 102 ] );
		txbMaxplayers.SetSize( [ 124, 24 ] );
		txbMaxplayers.SetText( cvar( "ui_maxclients" ) != 0 ? cvar_string( "ui_maxclients" ) : "8" );

		lblPassword = spawn( vguiLabel );
		lblPassword.SetPos( '20 136' );
		lblPassword.SetTitle( "Password" );

		txbPassword = spawn( vguiTextBox );
		txbPassword.SetPos( [ 20, 154 ] );
		txbPassword.SetSize( [ 124, 24 ] );
		txbPassword.SetText( cvar_string( "sv_password" ) );

		g_uiDesktop.Add( winCreate );
        winCreate.Add( picMapPreview );
		winCreate.Add( lsbMaps );
		winCreate.Add( lblModes );
		winCreate.Add( scrlMaps );
		winCreate.Add( lsbModes );
        winCreate.Add( lblEntities );
        winCreate.Add( lsbEntities );
		winCreate.Add( btnStart );
		winCreate.Add( btnCancel );
		winCreate.Add( lblHostname );
		winCreate.Add( txbHostname );
		winCreate.Add( lblMaxplayers );
		winCreate.Add( txbMaxplayers );
		winCreate.Add( lblPassword );
		winCreate.Add( txbPassword );
		winCreate.Add( chkLAN );
	}

	MapSelection_Changed();
	winCreate.Show();
	winCreate.SetPos( ( g_vidsize / 2 ) - ( winCreate.GetSize() / 2 ) );
}
