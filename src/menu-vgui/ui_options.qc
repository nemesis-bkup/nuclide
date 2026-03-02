/*
 * Copyright (c) 2016-2024 Vera Visions LLC.
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

int g_iOptionsWindowInitialized;
.vector colormod;
.vector absmin;
.vector absmax;

var string autocvar_ui_name = "Player";

void UI_Options_Show ( void )
{
	static vguiPanel winServers;
	static vguiButton btnCancel;
	static vguiButton btnApply;
	static vguiButton btnOK;

	static vguiButton tabMultiplayer;
	static vguiButton tabMouse;
	static vguiButton tabKeyboard;
	static vguiButton tabAudio;
	static vguiButton tabVideo;
	static vguiButton tabVoice;

    /* keyboard */
	static vguiButton tabPlayer1;
	static vguiButton tabPlayer2;
	static vguiButton tabPlayer3;
	static vguiButton tabPlayer4;

	static vguiFeeder lstKBDescr;
	static vguiFeeder lstKBKey;
	static vguiFeeder lstKBKeyAlt;
	static vguiButton btnKBUseDefaults;
	static vguiButton btnKBEditKey;
	static vguiButton btnKBClearKey;

    static vguiSlider au_sldVolume;
    static vguiSlider au_sldVoiceVolume;
    static vguiSlider au_sldMusicVolume;
    static vguiCheckbox au_chkHighQuality;
    static vguiCheckbox au_chkEAX;
    static vguiCheckbox au_chkHRTF;

	static vguiPic picPlayerModel;
	static vguiPic picPlayerSpray;
    static vgui3DView playerModel3D;
	static vguiLabel lblPlayerName;
	static vguiTextBox txbPlayerName;
    static vguiSlider sldTopColor;
    static vguiSlider sldBottomColor;
    static vguiLabel lblPlayerModel;
    static vguiFeederListBox lbxPlayerModel;
    static vguiLabel lblPlayerSkin;
    static vguiFeederListBox lbxPlayerSkin;
    static vguiLabel lblPlayerSpray;
    static vguiFeederListBox lbxPlayerSpray;

	static vguiLabel lblResolution;
	static vguiFeederListBox lbxResolution;
	static vguiLabel lblDisplayModes;
	static vguiFeederListBox lbxDisplayModes;
	static vguiLabel lblAspectRatio;
	static vguiFeederListBox lbxAspectRatio;
    static vguiSlider sldBrightness;
    static vguiSlider sldGamma;

    static vguiCheckbox chkMouseReverse;
	static vguiCheckbox chkMouseLook;
	static vguiCheckbox chkMouseFilter;
	static vguiCheckbox chkJoystick;
	static vguiCheckbox chkJoystickLook;
	static vguiCheckbox chkAutoAim;
    static vguiSlider au_sldMouseSensitivity;
    static entity g_ePreviewModel;
    static int g_iPreviewmodelSubUpdate;

	static void Multiplayer_Hide ( void ) {
		picPlayerModel.Hide();
		picPlayerSpray.Hide();
		lblPlayerName.Hide();
		txbPlayerName.Hide();
        playerModel3D.Hide();
        sldTopColor.Hide();
        sldBottomColor.Hide();
        lblPlayerModel.Hide();
        lbxPlayerModel.Hide();
        lblPlayerSkin.Hide();
        lbxPlayerSkin.Hide();
        lblPlayerSpray.Hide();
        lbxPlayerSpray.Hide();
	}
	static void Mouse_Hide ( void ) {
        chkMouseReverse.Hide();
        chkMouseLook.Hide();
        chkMouseFilter.Hide();
        chkJoystick.Hide();
        chkJoystickLook.Hide();
        chkAutoAim.Hide();
        au_sldMouseSensitivity.Hide();
	}
	static void Keyboard_Hide ( void ) {
        lstKBDescr.Hide();
        lstKBKey.Hide();
        lstKBKeyAlt.Hide();
        btnKBUseDefaults.Hide();
        btnKBEditKey.Hide();
        btnKBClearKey.Hide();
	}
	static void Audio_Hide ( void ) {
        au_sldVolume.Hide();
        au_sldVoiceVolume.Hide();
        au_sldMusicVolume.Hide();
        au_chkHighQuality.Hide();
        au_chkEAX.Hide();
        au_chkHRTF.Hide();
	}
	static void Video_Hide ( void ) {
		lblResolution.Hide();
		lblDisplayModes.Hide();
		lblAspectRatio.Hide();
		lbxResolution.Hide();
		lbxDisplayModes.Hide();
		lbxAspectRatio.Hide();
        sldBrightness.Hide();
        sldGamma.Hide();
	}
	static void Voice_Hide ( void ) {
	}

	static void Multiplayer_Show ( void ) {
		picPlayerModel.Show();
		picPlayerSpray.Show();
		lblPlayerName.Show();
		txbPlayerName.Show();
        playerModel3D.Show();
        sldTopColor.Show();
        sldBottomColor.Show();
        lblPlayerModel.Show();
        lbxPlayerModel.Show();
        lblPlayerSpray.Show();
        lbxPlayerSpray.Show();

        string playerModel = lbxPlayerModel.GetItem();

        if (playerModel == "default") {
            lblPlayerSkin.Show();
            lbxPlayerSkin.Show();
        } else {
            lblPlayerSkin.Hide();
            lbxPlayerSkin.Hide();
        }

		Mouse_Hide();
		Keyboard_Hide();
		Audio_Hide();
		Video_Hide();
		Voice_Hide();
	}
	static void Mouse_Show ( void ) {
		Multiplayer_Hide();
		Keyboard_Hide();
		Audio_Hide();
		Video_Hide();
		Voice_Hide();

        chkMouseReverse.Show();
        chkMouseLook.Show();
        chkMouseFilter.Show();
        chkJoystick.Show();
        chkJoystickLook.Show();
        chkAutoAim.Show();
        au_sldMouseSensitivity.Show();
	}
	static void Keyboard_Show ( void ) {
		Multiplayer_Hide();
		Mouse_Hide();
		Audio_Hide();
		Video_Hide();
		Voice_Hide();

        lstKBDescr.Show();
        lstKBKey.Show();
        lstKBKeyAlt.Show();
        btnKBUseDefaults.Show();
        btnKBEditKey.Show();
        btnKBClearKey.Show();
	}
	static void Audio_Show ( void ) {
		Multiplayer_Hide();
		Mouse_Hide();
		Keyboard_Hide();
		Video_Hide();
		Voice_Hide();

        au_sldVolume.Show();
        au_sldVoiceVolume.Show();
        au_sldMusicVolume.Show();
        au_chkHighQuality.Show();
        au_chkEAX.Show();
        au_chkHRTF.Show();
	}
	static void Video_Show ( void ) {
		lblResolution.Show();
		lblDisplayModes.Show();
		lblAspectRatio.Show();
		lbxResolution.Show();
		lbxDisplayModes.Show();
		lbxAspectRatio.Show();
        sldBrightness.Show();
        sldGamma.Show();

		Multiplayer_Hide();
		Mouse_Hide();
		Keyboard_Hide();
		Audio_Hide();
		Voice_Hide();
	}
	static void Voice_Show ( void ) {
		Multiplayer_Hide();
		Mouse_Hide();
		Keyboard_Hide();
		Audio_Hide();
		Video_Hide();
	}

    	static vector vecDistance = [ 128, 0, 0 ];
		static void ModelPreview_SetModel( string strModel ) {

            if (!fileExists(strModel)) {
                setmodel(g_ePreviewModel, "progs/player.mdl");
            } else {
                setmodel( g_ePreviewModel, strModel );
            }

			if ( !g_ePreviewModel ) {
				g_ePreviewModel = spawn();
				g_ePreviewModel.angles[1] -= 180;
			}

			AngleVectors( playerModel3D.Get3DAngles() );
			playerModel3D.Set3DPos( v_forward * -vecDistance[0] + v_right * vecDistance[1] + v_up * vecDistance[2] );

			/* TODO: ideally we'd like to update the submodel here according to
			   the cl_himodels cvar, but FTE doesn't like us doing that
			   apparently as skinobjects are not available directly upon
			   init. eventually I'll have to stage a sub-model update for
			   later. or maybe the engine should just get its stuff sorted.
			   for the time being, enjoy this message that I can point
			   to for when someone inexplicably points out the bug. */
				g_iPreviewmodelSubUpdate = 0;
		}
		static void PlayerModel_Changed(vguiWidget sender) {
            string playerModel = lbxPlayerModel.GetItem();

            ModelPreview_SetModel(ncPlayerModelLibrary::ModelPathForName(playerModel));

            if (playerModel == "default") {
                lblPlayerSkin.Show();
                lbxPlayerSkin.Show();
            } else {
                lblPlayerSkin.Hide();
                lbxPlayerSkin.Hide();
            }
        }

		static void ModelPreview_UpdateColor(void) {
            vector x = hsvToRGB(sldTopColor.GetValue() * 360, 100, 100);
            float topHex = x[2] + (x[1] << 8) + (x[0] << 16);
            x = hsvToRGB(sldBottomColor.GetValue() * 360, 100, 100);
            float bottomHex = x[2] + (x[1] << 8) + (x[0] << 16);
            string skinName = lbxPlayerSkin.GetItem();

            if (skinName == "none") {
                skinName = "";
            }

            string newSkin = sprintf("qwskin %S\nq1upper 0x%x\nq1lower 0x%x", skinName, topHex, bottomHex);
            setcustomskin(g_ePreviewModel, "", newSkin);
            ncLogAlways("new Skin: %s", newSkin);
        }


    static void PlayerSpray_Changed(vguiWidget sender) {
        string playerSpray = lbxPlayerSpray.GetItem();
        picPlayerSpray.SetImage(playerSpray);
    }

	static void Options_ReadSettings(void) {
		txbPlayerName.SetText( STRING_SET(cvar_string( "ui_name" )) ?  cvar_string( "ui_name" ) : cvar_string( "name" ) );
		chkMouseReverse.SetValue( cvar("m_pitch") < 0.0 ? TRUE : FALSE );
		chkMouseLook.SetValue( TRUE );
		chkMouseFilter.SetValue( cvar("m_filter") );
		chkJoystick.SetValue( TRUE );
		chkJoystickLook.SetValue( TRUE );
		chkAutoAim.SetValue( 1 - cvar("sv_aim") );
        au_sldMouseSensitivity.SetValue(cvar("sensitivity")/10);
        au_sldVolume.SetValue(cvar("volume"));
        au_sldVoiceVolume.SetValue(cvar("suitvolume"));
        au_sldMusicVolume.SetValue(cvar("bgmvolume"));
		au_chkHighQuality.SetValue( 1-cvar("loadas8bit") );
		au_chkEAX.SetValue( cvar("s_al_use_reverb") );
		au_chkHRTF.SetValue( (cvar_string("s_al_hrtf") == "Default HRTF") ? 1 : 0 );
		lstKBKeyAlt.SetSelected( 0 );
		lstKBKey.SetSelected( 0 );
		lstKBDescr.SetSelected( 0 );
		lbxResolution.SetText( ncRenderingManager::GetCurrent(RENDERER_RESOLUTION) );
		lbxDisplayModes.SetText( ncRenderingManager::GetCurrent(RENDERER_DISPLAYMODE) );
		lbxAspectRatio.SetText( ncRenderingManager::GetCurrent(RENDERER_ASPECTRATIO) );
        sldBrightness.SetValue(cvar("brightness"));
        sldGamma.SetValue(cvar("gamma"));
        sldTopColor.SetValue(cvar("ui_topcolor"));
        sldBottomColor.SetValue(cvar("ui_bottomcolor"));

        string modelName = cvar_string("model");
        string skinName = cvar_string("skin");
        string sprayName = cvar_string("ui_spraylogo");

        if (!STRING_SET(modelName)) {
            modelName = "default";
        }

        if (!STRING_SET(skinName)) {
            skinName = "none";
        }

        if (!STRING_SET(sprayName)) {
            sprayName = "logos/fte.png";
        }

		lbxPlayerModel.SetText( modelName );
		lbxPlayerSkin.SetText( skinName );
		lbxPlayerSpray.SetText( sprayName );
        picPlayerSpray.SetImage( sprayName);

        if (modelName == "default") {
            ModelPreview_SetModel("progs/player.mdl");
        } else {
            ModelPreview_SetModel(sprintf("models/player/%s/%s.mdl", modelName, modelName));
        }

        PlayerModel_Changed(__NULL__);
        PlayerSpray_Changed(__NULL__);
    }

	static void Options_Cancel ( void ) {
		winServers.Hide();
	}

	static void Options_Apply ( void ) {
		string playerName = txbPlayerName.GetText();
		cvar_set("name", playerName);
		cvar_set("ui_name", playerName);
        cvar_set("m_pitch", chkMouseReverse.GetValue() ? ftos(-fabs(cvar("m_pitch"))) : ftos(fabs(cvar("m_pitch"))));
        cvar_set("m_filter", chkMouseFilter.GetValue() ? "1" : "0");
        cvar_set("sv_aim", chkAutoAim.GetValue() ? "1" : "0");
        cvar_set("sensitivity", ftos(au_sldMouseSensitivity.GetValue() * 10));
        cvar_set("volume", ftos(au_sldVolume.GetValue() * 1));
        cvar_set("suitvolume", ftos(au_sldVoiceVolume.GetValue() * 1));
        cvar_set("bgmvolume", ftos(au_sldMusicVolume.GetValue() * 1));
        cvar_set("loadas8bit", au_chkHighQuality.GetValue() ? "0" : "1");
        cvar_set("s_al_use_reverb", au_chkEAX.GetValue() ? "1" : "0");
        cvar_set("s_al_hrtf", au_chkHRTF.GetValue() ? "Default HRTF" : "");

        string videoRes = lbxResolution.GetItem();
        tokenizebyseparator(videoRes, "x");
		cvar_set("vid_width", argv(0));
		cvar_set("vid_height", argv(1));
        cvar_set("brightness", ftos(sldBrightness.GetValue() * 1));
        cvar_set("gamma", ftos(sldGamma.GetValue() * 1));
        cvar_set("ui_topcolor", ftos(sldTopColor.GetValue() * 1));
        cvar_set("ui_bottomcolor", ftos(sldBottomColor.GetValue() * 1));

        if (lbxDisplayModes.GetItem() == "Fullscreen") {
            cvar_set("vid_fullscreen", "1");
        } else if (lbxDisplayModes.GetItem() == "Windowed") {
            cvar_set("vid_fullscreen", "0");
        } else if (lbxDisplayModes.GetItem() == "Borderless") {
            cvar_set("vid_fullscreen", "2");
        } else {
            cvar_set("vid_fullscreen", "0");
        }

        if (sldBrightness.Visible()) {
            localcmd("vid_restart\n");
        } else if (au_sldVolume.Visible()) {
            localcmd("snd_restart\n");
        } else if (chkMouseFilter.Visible()) {
            localcmd("in_restart\n");
        }

        vector x = hsvToRGB(sldTopColor.GetValue() * 360, 100, 100);
        float colorHex = x[2] + (x[1] << 8) + (x[0] << 16);
        cvar_set("topcolor", sprintf("0x%x", colorHex));
        x = hsvToRGB(sldBottomColor.GetValue() * 360, 100, 100);
        colorHex = x[2] + (x[1] << 8) + (x[0] << 16);
        cvar_set("bottomcolor", sprintf("0x%x", colorHex));

        string playerModel = lbxPlayerModel.GetItem();
        string skinName = lbxPlayerSkin.GetItem();
        string sprayName = lbxPlayerSpray.GetItem();

        if (skinName == "none") {
            skinName = "";
        }


        if (playerModel == "default") {
            cvar_set("model", "");
        } else {
            cvar_set("model", playerModel);
        }

        cvar_set("skin", skinName);
        cvar_set("ui_spraylogo", sprayName);
        localcmd(sprintf("setinfokeybob spray %S\n", sprayName));
	}
	static void Options_OK ( void ) {
		Options_Apply();
        localcmd("snd_restart\nvid_restart\ncfg_save\n");
		Options_Cancel();
	}

	static void Controls_ChangedSelection(vguiWidget sender) {
        vguiFeeder senderFeed = (vguiFeeder)sender;
        lstKBDescr.SetSelected(senderFeed.GetSelected());
        lstKBKey.SetSelected(senderFeed.GetSelected());
        lstKBKeyAlt.SetSelected(senderFeed.GetSelected());
    }

	static void Controls_Scrolled(vguiWidget sender) {
        vguiFeeder senderFeed = (vguiFeeder)sender;
		lstKBDescr.SetOffset( senderFeed.GetOffset(), FALSE );
		lstKBKey.SetOffset( senderFeed.GetOffset(), FALSE );
		lstKBKeyAlt.SetOffset( senderFeed.GetOffset(), FALSE );
    }



		static void ModelPreview_Draw ( void ) {
            static int initialSkinRefresh = 0;

            if (initialSkinRefresh == 0) {
                initialSkinRefresh = 1;
            } else if (initialSkinRefresh == 1) {
                ModelPreview_UpdateColor();
                initialSkinRefresh = 2;
            }

			addentity( g_ePreviewModel );
			g_ePreviewModel.frame1time += frametime;
		}

        static void
        cz_cbModelChanged(void)
        {
        #ifdef MODEL_PREVIEW
            string mdl = 0; //g_models[g_iModel];
        #else
            string mdl = 0; //cz_psModel.GetPic();
        #endif
            tokenizebyseparator(mdl, "/");
            localcmd(sprintf("seta ui_model %S\n", argv(2)));
            localcmd(sprintf("setinfo model %S\n", argv(2)));
            localcmd(sprintf("headmodel %S\n", argv(2)));
            localcmd(sprintf("team_model %S\n", argv(2)));
            localcmd(sprintf("team_headmodel %S\n", argv(2)));
        }

		static void ModelPreview_Input ( float flEVType, float flKey, float flChar, float flDevID ) {
            static int iMouseDrag = FALSE;
            static int iShiftDrag = FALSE;
            static vector vecDragOfs;
            vector vecDifference;
            vector modelPos = (g_ePreviewModel.absmin + (0.5 * (g_ePreviewModel.absmax - g_ePreviewModel.absmin)));
            modelPos[2] = (g_ePreviewModel.absmin[2] + (0.75 * (g_ePreviewModel.absmax[2] - g_ePreviewModel.absmin[2])));

            int iMouseOver =  Util_MouseAbove( winServers.GetMousePos(), playerModel3D.m_parent.GetPos() + playerModel3D.GetPos(), playerModel3D.GetSize() );

            if ( flEVType == IE_KEYDOWN ) {
                if ( flKey == K_MOUSE1 && iMouseOver == TRUE ) {
                    iMouseDrag = TRUE;
                    vecDragOfs = getmousepos();
                    return true;
                } else if ( flKey == K_MWHEELUP && iMouseOver == TRUE ) {
                    vecDistance[0] = bound( 0, --vecDistance[0], 512 );
                    makevectors( playerModel3D.Get3DAngles() );
                    playerModel3D.Set3DPos( modelPos + (v_forward * -vecDistance[0]) + (v_right * vecDistance[1]) + (v_up * vecDistance[2]) );
                    return true;
                } else if ( flKey == K_MWHEELDOWN && iMouseOver == TRUE ) {
                    vecDistance[0] = bound( 0, ++vecDistance[0], 512 );
                    makevectors( playerModel3D.Get3DAngles() );
                    playerModel3D.Set3DPos( modelPos + (v_forward * -vecDistance[0]) + (v_right * vecDistance[1]) + (v_up * vecDistance[2]) );
                    return true;
                }
            } else if ( flEVType == IE_KEYUP ) {
                if ( flKey == K_MOUSE1 ) {
                    iMouseDrag = FALSE;
                    ModelPreview_UpdateColor();
                } else if ( flKey == K_LSHIFT ) {
                    iShiftDrag = FALSE;
                }
            }

            if ( iMouseDrag == TRUE && iShiftDrag == FALSE ) {
                if ( flEVType == IE_MOUSEABS ) {
                    vecDifference = [ flChar, flKey ] - [ vecDragOfs[1], vecDragOfs[0] ];
                    playerModel3D.Set3DAngles( playerModel3D.Get3DAngles() + vecDifference );
                    makevectors( playerModel3D.Get3DAngles() );
                    playerModel3D.Set3DPos( modelPos + (v_forward * -vecDistance[0]) + (v_right * vecDistance[1]) + (v_up * vecDistance[2]) );
                    vecDragOfs = getmousepos();
                    return true;
                }
            } else if ( iMouseDrag == TRUE && iShiftDrag == TRUE ) {
                if ( flEVType == IE_MOUSEABS ) {
                    vecDifference = [ flChar, flKey ] - [ vecDragOfs[1], vecDragOfs[0] ];
                    vecDistance[1] -= vecDifference[1];
                    vecDistance[2] += vecDifference[0];
                    playerModel3D.Set3DPos( modelPos + (v_forward * -vecDistance[0]) + (v_right * vecDistance[1]) + (v_up * vecDistance[2]) );
                    vecDragOfs = getmousepos();
                    return true;
                }
            }
            return false;
		}

	if ( !g_iOptionsWindowInitialized ) {
		g_iOptionsWindowInitialized = TRUE;
		winServers = spawn( vguiPanel );
		winServers.SetTitle( "Options" );
		winServers.SetSize( '512 406' );
		winServers.SetIcon( "gfx/icon16/cog" );

		tabMultiplayer = spawn( vguiButton );
		tabMultiplayer.SetTitle( "Multiplayer" );
		tabMultiplayer.SetIcon( "gfx/icon16/vcard" );
		tabMultiplayer.SetPos( [8,32] );
		tabMultiplayer.SetFunc( Multiplayer_Show );
        tabMultiplayer.ResizeToContents();

		tabKeyboard = spawn( vguiButton );
		tabKeyboard.SetTitle( "Keyboard" );
		tabKeyboard.SetIcon( "gfx/icon16/keyboard" );
		tabKeyboard.SetPos( tabMultiplayer.GetPos() + [tabMultiplayer.GetWidth() + 8, 0] );
		tabKeyboard.SetFunc( Keyboard_Show );
        tabKeyboard.ResizeToContents();

		tabMouse = spawn( vguiButton );
		tabMouse.SetTitle( "Mouse" );
		tabMouse.SetIcon( "gfx/icon16/mouse" );
		tabMouse.SetPos( tabKeyboard.GetPos() + [tabKeyboard.GetWidth() + 8, 0] );
		tabMouse.SetFunc( Mouse_Show );
        tabMouse.ResizeToContents();

		tabAudio = spawn( vguiButton );
		tabAudio.SetTitle( "Audio" );
		tabAudio.SetIcon( "gfx/icon16/sound" );
		tabAudio.SetPos( tabMouse.GetPos() + [tabMouse.GetWidth() + 8, 0] );
		tabAudio.SetFunc( Audio_Show );
        tabAudio.ResizeToContents();

		tabVideo = spawn( vguiButton );
		tabVideo.SetTitle( "Video" );
		tabVideo.SetIcon( "gfx/icon16/monitor" );
		tabVideo.SetPos( tabAudio.GetPos() + [tabAudio.GetWidth() + 8, 0] );
		tabVideo.SetFunc( Video_Show );
        tabVideo.ResizeToContents();

		tabVoice = spawn( vguiButton );
		tabVoice.SetTitle( "Voice" );
		tabVoice.SetIcon( "gfx/icon16/telephone" );
		tabVoice.SetPos( tabVideo.GetPos() + [tabVideo.GetWidth() + 8, 0] );
		tabVoice.SetFunc( Voice_Show );
        tabVoice.ResizeToContents();

		btnOK = spawn( vguiButton );
		btnOK.SetTitle("OK");
		btnOK.SetPos([267,373]);
		btnOK.SetSize([72,24]);
		btnOK.SetFunc( Options_OK );

		btnCancel = spawn( vguiButton );
		btnCancel.SetTitle("Cancel");
		btnCancel.SetPos(  btnOK.GetPos() + [btnOK.GetWidth() + 8, 0] );
		btnCancel.SetSize([72,24]);
		btnCancel.SetFunc( Options_Cancel );

		btnApply = spawn( vguiButton );
		btnApply.SetTitle( "Apply" );
		btnApply.SetPos(  btnCancel.GetPos() + [btnCancel.GetWidth() + 8, 0] );
		btnApply.SetSize([72,24]);
		btnApply.SetFunc( Options_Apply );

		/* multiplayer tab */
		picPlayerModel = spawn(vguiPic);
		picPlayerModel.SetPos( [265, 87] );
		picPlayerModel.SetSize( [190, 203] );
		picPlayerModel.SetBorder(4);

		/* multiplayer tab */
		picPlayerSpray = spawn(vguiPic);
		picPlayerSpray.SetSize( [64, 64] );
		picPlayerSpray.SetPos( picPlayerModel.GetPos() - [picPlayerSpray.GetWidth() + 4, 0] );
		picPlayerSpray.SetBorder(4);
		winServers.Add(picPlayerSpray);

        playerModel3D = spawn(vgui3DView);
		playerModel3D.SetPos( [265, 87] );
		playerModel3D.SetSize( [190, 203] );
        playerModel3D.SetDrawFunc(ModelPreview_Draw);
        playerModel3D.SetInputFunc(ModelPreview_Input);
        playerModel3D.SetAngularFieldOfView(45);
		winServers.Add(playerModel3D);

        sldTopColor = spawn(vguiSlider);
        sldTopColor.SetSize([190,32]);
        sldTopColor.SetPos(picPlayerModel.GetPos() + [0, picPlayerModel.GetHeight() + 8]);
        sldTopColor.SetTitle("Top color");
        //au_sldMusicVolume.SetCallback(AudioVolume_Changed);
		winServers.Add(sldTopColor);

        sldBottomColor = spawn(vguiSlider);
        sldBottomColor.SetSize([190,32]);
        sldBottomColor.SetPos(sldTopColor.GetPos() + [0, sldTopColor.GetHeight() + 8]);
        sldBottomColor.SetTitle("Bottom color");
        //au_sldMusicVolume.SetCallback(AudioVolume_Changed);
		winServers.Add(sldBottomColor);

		lblPlayerName = spawn(vguiLabel);
		lblPlayerName.SetTitle( "Player name" );
		lblPlayerName.SetPos('20 87' );
		lblPlayerName.SetSize( [232, 16] );

		txbPlayerName = spawn( vguiTextBox );
		txbPlayerName.SetPos( lblPlayerName.GetPos() + [0, lblPlayerName.GetHeight() + 8] );
		txbPlayerName.SetSize( [ 124, 24 ] );

		lblPlayerModel = spawn(vguiLabel);
		lblPlayerModel.SetTitle( "Player model" );
		lblPlayerModel.SetPos('20 164' );
		lblPlayerModel.SetSize( [232, 16] );

		lbxPlayerModel = spawn(vguiFeederListBox);
		lbxPlayerModel.SetPos(lblPlayerModel.GetPos() + [0, lblPlayerModel.GetHeight() + 8]);
		lbxPlayerModel.SetSize( [232, 24] );
		lbxPlayerModel.SetFeederType(FEEDER_PLAYERMODELS);
        lbxPlayerModel.CallOnSelectionChanged(PlayerModel_Changed);

		lblPlayerSkin = spawn(vguiLabel);
		lblPlayerSkin.SetTitle( "Player skin" );
		lblPlayerSkin.SetPos(lbxPlayerModel.GetPos() + [0, lbxPlayerModel.GetHeight() + 24]);
		lblPlayerSkin.SetSize( [232, 16] );

		lbxPlayerSkin = spawn(vguiFeederListBox);
		lbxPlayerSkin.SetPos(lblPlayerSkin.GetPos() + [0, lblPlayerSkin.GetHeight() + 8]);
		lbxPlayerSkin.SetSize( [232, 24] );
		lbxPlayerSkin.SetFeederType(FEEDER_PLAYERSKINS);
        lbxPlayerSkin.CallOnSelectionChanged(ModelPreview_UpdateColor);

		lblPlayerSpray = spawn(vguiLabel);
		lblPlayerSpray.SetTitle( "Spray logo" );
		lblPlayerSpray.SetPos(lbxPlayerSkin.GetPos() + [0, lbxPlayerSkin.GetHeight() + 24]);
		lblPlayerSpray.SetSize( [232, 16] );

		lbxPlayerSpray = spawn(vguiFeederListBox);
		lbxPlayerSpray.SetPos(lblPlayerSpray.GetPos() + [0, lblPlayerSpray.GetHeight() + 8]);
		lbxPlayerSpray.SetSize( [232, 24] );
		lbxPlayerSpray.SetFeederType(FEEDER_PLAYERSPRAYS);
        lbxPlayerSpray.CallOnSelectionChanged(PlayerSpray_Changed);

		winServers.Add( picPlayerModel );
		winServers.Add( lblPlayerName );
		winServers.Add( txbPlayerName );
		winServers.Add( lblPlayerModel );
		winServers.Add( lbxPlayerModel );
		winServers.Add( lblPlayerSkin );
		winServers.Add( lbxPlayerSkin );
		winServers.Add( lblPlayerSpray );
		winServers.Add( lbxPlayerSpray );

		/* keyboard tab */
        lstKBDescr = spawn(vguiFeeder);
		lstKBDescr.SetSize( [218,258] );
		lstKBDescr.SetPos( tabMultiplayer.GetPos() + [0, tabMultiplayer.GetHeight() + 4 + 4] );
		lstKBDescr.SetFeederType(FEEDER_CONTROLS);
        lstKBDescr.SetFeederColumn(0i);
        lstKBDescr.CallOnSelectionChanged(Controls_ChangedSelection);
        lstKBDescr.CallOnScroll(Controls_Scrolled);
		winServers.Add( lstKBDescr );

        lstKBKey = spawn(vguiFeeder);
		lstKBKey.SetSize( [128,258] );
		lstKBKey.SetPos( lstKBDescr.GetPos() + [lstKBDescr.GetWidth(),0] );
		lstKBKey.SetFeederType(FEEDER_CONTROLS);
        lstKBKey.SetFeederColumn(3i);
        lstKBKey.CallOnSelectionChanged(Controls_ChangedSelection);
        lstKBKey.CallOnScroll(Controls_Scrolled);
		winServers.Add( lstKBKey );

        lstKBKeyAlt = spawn(vguiFeeder);
		lstKBKeyAlt.SetSize( [128,258] );
		lstKBKeyAlt.SetPos( lstKBKey.GetPos() + [lstKBKey.GetWidth(),0] );
		lstKBKeyAlt.SetFeederType(FEEDER_CONTROLS);
        lstKBKeyAlt.SetFeederColumn(4i);
        lstKBKeyAlt.CallOnSelectionChanged(Controls_ChangedSelection);
        lstKBKeyAlt.CallOnScroll(Controls_Scrolled);
		winServers.Add( lstKBKeyAlt );

        btnKBUseDefaults = spawn(vguiButton);
		btnKBUseDefaults.SetPos( lstKBDescr.GetPos() + [0,lstKBDescr.GetHeight() + 4] );
        btnKBUseDefaults.SetTitle("Use Defaults");
		winServers.Add( btnKBUseDefaults );

        btnKBClearKey = spawn(vguiButton);
		btnKBClearKey.SetPos([winServers.GetWidth() - (btnKBClearKey.GetWidth() + 8), btnKBUseDefaults.GetPosHeight()] );
        btnKBClearKey.SetTitle("Clear key");
		winServers.Add( btnKBClearKey );

        btnKBEditKey = spawn(vguiButton);
		btnKBEditKey.SetPos(btnKBClearKey.GetPos() - [btnKBEditKey.GetWidth() + 4]);
        btnKBEditKey.SetTitle("Edit key");
		winServers.Add( btnKBEditKey );

		/* mouse tab */
		chkMouseReverse = spawn( vguiCheckbox );
		chkMouseReverse.SetTitle( "Reverse mouse" );
		chkMouseReverse.SetSize( '124 24' );
		chkMouseReverse.SetPos( lstKBDescr.GetPos() + [48, 0] );
		winServers.Add( chkMouseReverse );

		chkMouseLook = spawn( vguiCheckbox );
		chkMouseLook.SetTitle( "Mouse look" );
		chkMouseLook.SetSize( '124 24' );
		chkMouseLook.SetPos( chkMouseReverse.GetPos() + [0, chkMouseReverse.GetHeight() + 4] );
		winServers.Add( chkMouseLook );

		chkMouseFilter = spawn( vguiCheckbox );
		chkMouseFilter.SetTitle( "Mouse filter" );
		chkMouseFilter.SetSize( '124 24' );
		chkMouseFilter.SetPos( chkMouseLook.GetPos() + [0, chkMouseLook.GetHeight() + 4] );
		winServers.Add( chkMouseFilter );

		chkJoystick = spawn( vguiCheckbox );
		chkJoystick.SetTitle( "Joystick" );
		chkJoystick.SetSize( '124 24' );
		chkJoystick.SetPos( chkMouseFilter.GetPos() + [0, chkMouseFilter.GetHeight() + 4] );
		winServers.Add( chkJoystick );

		chkJoystickLook = spawn( vguiCheckbox );
		chkJoystickLook.SetTitle( "Joystick look" );
		chkJoystickLook.SetSize( '124 24' );
		chkJoystickLook.SetPos( chkJoystick.GetPos() + [0, chkJoystick.GetHeight() + 4] );
		winServers.Add( chkJoystickLook );

		chkAutoAim = spawn( vguiCheckbox );
		chkAutoAim.SetTitle( "Auto-Aim" );
		chkAutoAim.SetSize( '124 24' );
		chkAutoAim.SetPos( chkJoystickLook.GetPos() + [0, chkJoystickLook.GetHeight() + 4] );
		winServers.Add( chkAutoAim );

        au_sldMouseSensitivity = spawn(vguiSlider);
        au_sldMouseSensitivity.SetSize([128,64]);
        au_sldMouseSensitivity.SetPos(chkAutoAim.GetPos() + [0, chkAutoAim.GetHeight() + 8]);
        au_sldMouseSensitivity.SetTitle("Mouse sensitivity");
        //au_sldMusicVolume.SetCallback(AudioVolume_Changed);
		winServers.Add(au_sldMouseSensitivity);

		/* video tab */
		lblResolution = spawn(vguiLabel);
		lblResolution.SetTitle( "Resolution" );
		lblResolution.SetPos('20 87' );
		lblResolution.SetSize( [232, 24] );

		lbxResolution = spawn(vguiFeederListBox);
		lbxResolution.SetPos(lblResolution.GetPos() + [0, lblResolution.GetHeight() + 8]);
		lbxResolution.SetSize( [232, 24] );
		lbxResolution.SetFeederType(FEEDER_VIDEO_RESOLUTIONS);

		lblDisplayModes = spawn(vguiLabel);
		lblDisplayModes.SetTitle( "Display Mode" );
		lblDisplayModes.SetPos('262 87' );
		lblDisplayModes.SetSize( [232, 24] );

		lbxDisplayModes = spawn(vguiFeederListBox);
		lbxDisplayModes.SetPos(lblDisplayModes.GetPos() + [0, lblDisplayModes.GetHeight() + 8]);
		lbxDisplayModes.SetSize( [232, 24] );
		lbxDisplayModes.SetFeederType(FEEDER_VIDEO_DISPLAYMODES);

		lblAspectRatio = spawn(vguiLabel);
		lblAspectRatio.SetTitle( "Aspect Ratio" );
		lblAspectRatio.SetPos('20 164' );
		lblAspectRatio.SetSize( [232, 24] );

		lbxAspectRatio = spawn(vguiFeederListBox);
		lbxAspectRatio.SetPos(lblAspectRatio.GetPos() + [0, lblAspectRatio.GetHeight() + 8]);
		lbxAspectRatio.SetSize( [232, 24] );
		lbxAspectRatio.SetFeederType(FEEDER_VIDEO_ASPECTRATIOS);

        sldBrightness = spawn(vguiSlider);
        sldBrightness.SetSize([(winServers.GetWidth() / 2) - 32,64]);
        sldBrightness.SetPos(lbxAspectRatio.GetPos() + [0, lbxAspectRatio.GetHeight() + 32]);
        sldBrightness.SetTitle("Brightness");
       // au_sldVolume.SetCallback(AudioVolume_Changed);
		winServers.Add(sldBrightness);

        sldGamma = spawn(vguiSlider);
        sldGamma.SetSize([(winServers.GetWidth() / 2) - 32,64]);
        sldGamma.SetPos(sldBrightness.GetPos() + [sldBrightness.GetWidth() + 8, 0]);
        sldGamma.SetTitle("Gamma");
        //au_sldVoiceVolume.SetCallback(AudioVolume_Changed);
		winServers.Add(sldGamma);

		winServers.Add( lblResolution );
		winServers.Add( lblDisplayModes );
		winServers.Add( lblAspectRatio );
		winServers.Add( lbxResolution );
		winServers.Add( lbxDisplayModes );
		winServers.Add( lbxAspectRatio );

		/* audio tab */
        au_sldVolume = spawn(vguiSlider);
        au_sldVolume.SetSize([128,64]);
        au_sldVolume.SetPos(lstKBDescr.GetPos() + [48, 32]);
        au_sldVolume.SetTitle("Sound volume");
       // au_sldVolume.SetCallback(AudioVolume_Changed);
		winServers.Add(au_sldVolume);

        au_sldVoiceVolume = spawn(vguiSlider);
        au_sldVoiceVolume.SetSize([128,64]);
        au_sldVoiceVolume.SetPos(au_sldVolume.GetPos() + [0, au_sldVolume.GetHeight() + 8]);
        au_sldVoiceVolume.SetTitle("Voice volume");
        //au_sldVoiceVolume.SetCallback(AudioVolume_Changed);
		winServers.Add(au_sldVoiceVolume);

        au_sldMusicVolume = spawn(vguiSlider);
        au_sldMusicVolume.SetSize([128,64]);
        au_sldMusicVolume.SetPos(au_sldVoiceVolume.GetPos() + [0, au_sldVoiceVolume.GetHeight() + 8]);
        au_sldMusicVolume.SetTitle("Music volume");
        //au_sldMusicVolume.SetCallback(AudioVolume_Changed);
		winServers.Add(au_sldMusicVolume);

		au_chkHighQuality = spawn( vguiCheckbox );
		au_chkHighQuality.SetTitle( "High quality sound" );
		au_chkHighQuality.SetSize( '124 24' );
		au_chkHighQuality.SetPos( au_sldVolume.GetPos() + [au_sldVolume.GetWidth() + 128, 0] );
		winServers.Add( au_chkHighQuality );

		au_chkEAX = spawn( vguiCheckbox );
		au_chkEAX.SetTitle( "EAX reverb" );
		au_chkEAX.SetSize( '124 24' );
		au_chkEAX.SetPos( au_chkHighQuality.GetPos() + [0, au_chkHighQuality.GetHeight() + 4] );
		winServers.Add( au_chkEAX );

		au_chkHRTF = spawn( vguiCheckbox );
		au_chkHRTF.SetTitle( "HRTF spatial" );
		au_chkHRTF.SetSize( '124 24' );
		au_chkHRTF.SetPos( au_chkEAX.GetPos() + [0, au_chkEAX.GetHeight() + 4] );
		winServers.Add( au_chkHRTF );


		/* voice tab */


		g_uiDesktop.Add( winServers );
		winServers.Add( btnOK );
		winServers.Add( btnCancel );
		winServers.Add( btnApply );
		winServers.Add( tabMultiplayer );
		winServers.Add( tabKeyboard );
		winServers.Add( tabMouse );
		winServers.Add( tabVideo );
		winServers.Add( tabAudio );
		//winServers.Add( tabVoice );

		Multiplayer_Show();
	}

    Options_ReadSettings();
	winServers.Show();
	winServers.SetPos( ( g_vidsize / 2 ) - ( winServers.GetSize() / 2 ) );
}
