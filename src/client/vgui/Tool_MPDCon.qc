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
mpdAmpCButton:vguiButton
{
    void mpdAmpCButton(void);

    /* overrides button drawing */
    virtual void Draw(void);

    nonvirtual void SetSheetInfo(vector p1, vector p2, vector sz);

private:
    string m_sheet;
    float m_sheetX;
    float m_sheetY;
    float m_sheetW;
    float m_sheetH;
    float m_sheetDownX;
    float m_sheetDownY;
};

void
mpdAmpCButton::mpdAmpCButton(void)
{
    m_sheet = "data/players/Default/desktop/amp/CBUTTONS";
}

void
mpdAmpCButton::Draw(void)
{
    if (m_iFlags & BUTTON_DOWN) {
        drawsubpic(m_parent.m_vecOrigin + m_vecOrigin, m_vecSize, m_sheet, [m_sheetDownX, m_sheetDownY], [m_sheetW, m_sheetH], [1,1,1], 1.0, 0);
    } else {
        drawsubpic(m_parent.m_vecOrigin + m_vecOrigin, m_vecSize, m_sheet, [m_sheetX, m_sheetY], [m_sheetW, m_sheetH], [1,1,1], 1.0, 0);
    }
}

void
mpdAmpCButton::SetSheetInfo(vector p1, vector p2, vector sz)
{
    m_sheetX = p1[0];
    m_sheetY = p1[1];
    m_sheetW = sz[0];
    m_sheetH = sz[1];
    m_sheetDownX = p2[0];
    m_sheetDownY = p2[1];
}

class
vguiTool_MPDCon:vguiApplication
{
    void vguiTool_MPDCon(void);

    virtual void Spawned(void);
    virtual void Draw(void);

    nonvirtual void RefreshTheme(void);

private:

    vguiList lsbSongs;
    vguiScrollBar scrlSong;

    mpdAmpCButton btnRewind;
    mpdAmpCButton btnPlay;
    mpdAmpCButton btnPause;
    mpdAmpCButton btnStop;
    mpdAmpCButton btnForward;
    mpdAmpCButton btnEject;

    string m_sheetPos;
    string m_sheetNum;
    string m_sheetText;
    string m_sheetBack;
};

void
vguiTool_MPDCon::vguiTool_MPDCon(void)
{
    m_sheetPos = "gfx/amp/default/posbar";
    m_sheetNum = "gfx/amp/default/nums_ex";
    m_sheetText= "gfx/amp/default/text";
}

void
vguiTool_MPDCon::RefreshTheme(void)
{
    filestream playlistColorFile;
    string tempString;
    string themeName = cvar_string("ui_mpd_theme");

    if (!STRING_SET(themeName)) {
        themeName = "";
    } else {
        themeName = strcat(themeName, "/");
    }

    playlistColorFile = fopen(strcat("gfx/amp/", themeName, "pledit.txt"), FILE_READ);

    if (playlistColorFile < 0) {
        ncError("Can't read media player playlist colors.");
    }

    /* TODO: parse this stuff */
    while ((tempString = fgets(playlistColorFile))) {
        tokenizebyseparator(tempString, "=");

        switch (argv(0)) {
        case "Normal":
            break;
        case "Current":
            break;
        }
    }

    btnRewind.m_sheet = strcat("gfx/amp/", themeName, "cbuttons");
    btnPlay.m_sheet = strcat("gfx/amp/", themeName, "cbuttons");
    btnPause.m_sheet = strcat("gfx/amp/", themeName, "cbuttons");
    btnStop.m_sheet = strcat("gfx/amp/", themeName, "cbuttons");
    btnForward.m_sheet = strcat("gfx/amp/", themeName, "cbuttons");
    btnEject.m_sheet = strcat("gfx/amp/", themeName, "cbuttons");
    m_sheetPos = strcat("gfx/amp/", themeName, "posbar");
    m_sheetNum = strcat("gfx/amp/", themeName, "nums_ex");
    m_sheetText= strcat("gfx/amp/", themeName, "text");
    m_sheetBack = strcat("gfx/amp/", themeName, "main");

    SetWindowBackground(m_sheetBack);
}

void
vguiTool_MPDCon::Draw(void)
{
    super::Draw();
    vector infoPos = [112, 26];

    /* song info */
    Font_DrawTextScroll(m_vecOrigin + infoPos, strcat("^x000", " --- ", cvar_string("ui_mpd_songTrack"), ". ", cvar_string("ui_mpd_songArtist"), ": ", cvar_string("ui_mpd_songTitle")), [30*5,10], g_fntDefault);
    Font_DrawTextScroll(m_vecOrigin + infoPos + [-1, -1], strcat("^xFFF", " --- ", cvar_string("ui_mpd_songTrack"), ". ", cvar_string("ui_mpd_songArtist"), ": ", cvar_string("ui_mpd_songTitle")), [30*5,10], g_fntDefault);

    /* rate info */
    //Font_DrawText(m_vecOrigin + [111,43], strcat("^x000", cvar_string("ui_mpd_songRate")), g_fntDefault);

    /* duration info */
    float progression = cvar("ui_mpd_elapsed") / cvar("ui_mpd_duration");
    float minutes = cvar("ui_mpd_elapsed") / 60;
    float seconds = cvar("ui_mpd_elapsed") % 60;

    float digit1 = floor(minutes / 10);
    float digit2 = floor(minutes % 10);
    float digit3 = floor(seconds / 10);
    float digit4 = floor(seconds % 10);

    drawsubpic(m_parent.m_vecOrigin + m_vecOrigin + [47,26], [9,13], m_sheetNum, [digit1/12, 0], [1/12, 1], [1,1,1], 1.0, 0);
    drawsubpic(m_parent.m_vecOrigin + m_vecOrigin + [59,26], [9,13], m_sheetNum, [digit2/12, 0], [1/12, 1], [1,1,1], 1.0, 0);
    drawsubpic(m_parent.m_vecOrigin + m_vecOrigin + [76,26], [9,13], m_sheetNum, [digit3/12, 0], [1/12, 1], [1,1,1], 1.0, 0);
    drawsubpic(m_parent.m_vecOrigin + m_vecOrigin + [89,26], [9,13], m_sheetNum, [digit4/12, 0], [1/12, 1], [1,1,1], 1.0, 0);

    /* positional bar */
    drawsubpic(m_parent.m_vecOrigin + m_vecOrigin + [16,72], [248,10], m_sheetPos, [0, 0], [248/307, 1], [1,1,1], 1.0, 0);

    /* slider */
    drawsubpic(m_parent.m_vecOrigin + m_vecOrigin + [16 +((248-28) * progression),72], [28,10], m_sheetPos, [248/307, 0], [28/307, 1], [1,1,1], 1.0, 0);


    int rate = (int)cvar("ui_mpd_songRate");

    if (rate > 999)
        rate = 999;

    vector vecPos = [122,43];

    if (rate > 0) {
        while (rate > 0) {
            float digit = (float)rate % 10;
            drawsubpic(m_parent.m_vecOrigin + m_vecOrigin + vecPos, [5,6], m_sheetText, [(digit*5)/50 * 0.322580645161, 1/3], [5/155, 1/3], [1,1,1], 1.0, 0);
            rate = rate / 10;
            vecPos[0] -= 5;
        }
    } else {
            drawsubpic(m_parent.m_vecOrigin + m_vecOrigin + vecPos, [5,6], m_sheetText, [0, 1/3], [5/155, 1/3], [1,1,1], 1.0, 0);
    }

    rate = (int)cvar("ui_mpd_songFreq") / 1000;

    if (rate > 99)
        rate = 99;

    vector vecPos = [161,43];

    if (rate > 0) {
        while (rate > 0) {
            float digit = (float)rate % 10;
            drawsubpic(m_parent.m_vecOrigin + m_vecOrigin + vecPos, [5,6], m_sheetText, [(digit*5)/50 * 0.322580645161, 1/3], [5/155, 1/3], [1,1,1], 1.0, 0);
            rate = rate / 10;
            vecPos[0] -= 5;
        }
    } else {
            drawsubpic(m_parent.m_vecOrigin + m_vecOrigin + vecPos, [5,6], m_sheetText, [0, 1/3], [5/155, 1/3], [1,1,1], 1.0, 0);
    }

}

void
vguiTool_MPDCon::MusicPlayer_Play(void)
{
    ncCommand( "mpd_playSong" );
}

void
vguiTool_MPDCon::MusicPlayer_Stop(void)
{
    ncCommand( "mpd_stopSong" );
}

void
vguiTool_MPDCon::MusicPlayer_Pause(void)
{
    ncCommand( "mpd_pauseSong" );
}

void
vguiTool_MPDCon::MusicPlayer_Forward(void)
{
    ncCommand( "mpd_nextSong" );
}

void
vguiTool_MPDCon::MusicPlayer_Rewind(void)
{
    ncCommand( "mpd_prevSong" );
}

void
vguiTool_MPDCon::MusicPlayer_Eject(void)
{
}

void
vguiTool_MPDCon::Spawned(void)
{
    super::Spawned();

    classname = "vguiWindow";
    SetTitle( "MPDCon" );
    SetSize( [275,116] );
    SetIcon( "gfx/icon16/ipod" );
    SetStyleMask(vguiWindowStyleDefault - vguiWindowTitled);

    m_btnClose.SetPos([264,3]);
    m_btnClose.SetIcon( "" );
    m_btnClose.SetSize([9,9]);

    btnRewind = spawn( mpdAmpCButton );
    btnRewind.SetIcon( "gfx/icon16/control_rewind" );
    btnRewind.SetPos( [16,88] );
    btnRewind.SetSize([23,18]);
    btnRewind.SetFuncWithDelegate( MusicPlayer_Rewind, this );
    btnRewind.SetSheetInfo([0, 0], [0, 18/36], [23/136, 18/36]);

    btnPlay = spawn( mpdAmpCButton );
    btnPlay.SetIcon( "gfx/icon16/control_play" );
    btnPlay.SetPos( [39,88] );
    btnPlay.SetSize([23,18]);
    btnPlay.SetFuncWithDelegate( MusicPlayer_Play, this );
    btnPlay.SetSheetInfo([23/136, 0], [23/136, 18/36], [23/136, 18/36]);

    btnPause = spawn( mpdAmpCButton );
    btnPause.SetIcon( "gfx/icon16/control_pause" );
    btnPause.SetPos( [62,88] );
    btnPause.SetSize([23,18]);
    btnPause.SetFuncWithDelegate( MusicPlayer_Pause, this );
    btnPause.SetSheetInfo([46/136, 0], [46/136, 18/36], [23/136, 18/36]);

    btnStop = spawn( mpdAmpCButton );
    btnStop.SetIcon( "gfx/icon16/control_stop" );
    btnStop.SetPos( [85,88] );
    btnStop.SetSize([23,18]);
    btnStop.SetFuncWithDelegate( MusicPlayer_Stop, this );
    btnStop.SetSheetInfo([69/136, 0], [69/136, 18/36], [23/136, 18/36]);

    btnForward = spawn( mpdAmpCButton );
    btnForward.SetIcon( "gfx/icon16/control_fastforward" );
    btnForward.SetPos( [108,88] );
    btnForward.SetSize([22,18]);
    btnForward.SetFuncWithDelegate( MusicPlayer_Forward, this );
    btnForward.SetSheetInfo([92/136, 0], [92/136, 18/36], [22/136, 18/36]);

    btnEject = spawn( mpdAmpCButton );
    btnEject.SetIcon( "gfx/icon16/control_eject" );
    btnEject.SetPos( [136,89] );
    btnEject.SetSize([22,16]);
    btnEject.SetFuncWithDelegate( MusicPlayer_Eject, this );
    btnEject.SetSheetInfo([115/136, 0], [115/136, 18/36], [22/136, 16/36]);

    Add( btnRewind );
    Add( btnPlay );
    Add( btnPause );
    Add( btnStop );
    Add( btnForward );
    Add( btnEject );

    ncCommand( "mpd_connectToHost" );

    RefreshTheme();
}
