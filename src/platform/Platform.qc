/*
 * Copyright (c) 2025 Vera Visions LLC.
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

var bool autocvar_vid_force480pRendering = false;
var bool autocvar_vid_forceIntegerConAutoscale = false;
var bool g_old480pSetting = 1;
var bool g_oldIntegerSetting = 1;

/* r_autoscale forces vid_conautoscale to be one of 4 integer values.
 * this is due to vid_conautoscale 0 scaling with in floating point... which
 * in turns results in skipped rows/columns and shimmering. */
void
Platform_AutoScale(void)
{
	vector psize = getproperty(VF_SCREENPSIZE);

	if (autocvar_vid_forceIntegerConAutoscale != g_oldIntegerSetting) {
		if (autocvar_vid_forceIntegerConAutoscale) {
			if (psize[1] >= (480 * 4)) {
				cvar_set("vid_conautoscale", "4");
			} else if (psize[1] >= (480 * 3)) {
				cvar_set("vid_conautoscale", "3");
			} else if (psize[1] >= (480 * 2)) {
				cvar_set("vid_conautoscale", "2");
			} else {
				cvar_set("vid_conautoscale", "1");
			}
		} else {
			cvar_set("vid_conautoscale", "0");
		}

		g_oldIntegerSetting = autocvar_vid_forceIntegerConAutoscale;
	}

	if (autocvar_vid_force480pRendering != g_old480pSetting) {
		if (autocvar_vid_force480pRendering)  {
			float scale = bound(0.0, 480 / psize[1], 1.0);
			cvar_set("r_renderscale", sprintf("-%f", scale));
		} else {
			cvar_set("r_renderscale", "1");
		}

		g_old480pSetting = autocvar_vid_force480pRendering;
	}
}

void
Platform_Init(void)
{
	string menuMap = "";

	InitStart();
	ncLogAlways("Built: %s %s", __DATE__, __TIME__);
	ncLogAlways("QCC: %s", __QCCVER__);

	/* old configs make the rate this low by default. */
	if (cvar("rate") <= 2500) {
		cvar_set("rate", "30000");
	}

	/* these absolutely must be set right */
	if (cvar("sv_bigcoords") <= 0) {
		cvar_set("sv_bigcoords", "1");
	}

	Platform_RegisterCommands();
	Locale_Init();
	GameLibrary_Init();
	MapLibrary_Init();
	ModeLibrary_Init();
	Saves_Init();
    Updates_Init();
	Platform_RendererRestarted();
	ncConstantManager::Init();

	ncProfileManager::Init();
    ncControlBindingsManager::Init();
    ncPlayerModelLibrary::Init();
    ncGametypeLibrary::Init();

	menuMap = GameLibrary_GetInfo(GAMEINFO_MENUMAP);

	/* if we're already in a game? don't interrupt it with videos,
	   music or other background fluff */
	if (clientstate() == 2) {
		return;
	}

    Platform_PlayStartupVideos();

	if (STRING_SET(menuMap)) {
		localcmd(strcat("map_background ", menuMap, "\n"));
	}

    ncMusicController::Init();
	InitEnd();
}

void
Platform_Shutdown(void)
{
	FragNet_SignOff();
	ncMPDController::Shutdown();
    ncControlBindingsManager::Shutdown();
    ncPlayerModelLibrary::Shutdown();
    ncGametypeLibrary::Shutdown();

	/* remember to save last */
	ncProfileManager::Shutdown();
}

void
Platform_RendererRestarted(void)
{
	Background_RendererRestarted();
	Locale_Reload();
}

bool
Platform_Draw(vector screensize)
{
	/* set new scale whenever the resolution changes */
	if (Platform_DimensionsChanged(screensize) == true) {
		Platform_CalculateRenderingScale(screensize);
	}

	Platform_AutoScale();

	FragNet_Frame();
	Gopher_Frame();
	Finger_Frame();
	ncMPDController::Frame();

	g_background = cvar("_background");

	/* make sure input carries over when a map background is active */
	if (g_background) {
		if (getkeydest() != KEY_MENU) {
			setkeydest(KEY_MENU);
			setmousetarget(TARGET_MENU);
			setcursormode(TRUE, "gfx/cursor");
		}
	}

	/* clear rich presence whenever the state suddenly changes */
	if (g_gamestate != clientstate()) {
		g_gamestate = clientstate();

		if (g_gamestate == 1)
			RichPresence_Clear();
	}

	/* rich presence sanity check */
	if (RichPresence_WasSet() == false) {
		if (clientstate() == 2)
			RichPresence_Set("status", "In-game (Unknown)");
		else
			RichPresence_Set("status", "Main Menu");
	}

	/* ensure menu background draws the controls */
	if (g_background) {
		return (true);
	}

	/* if the menu is not visible and we're no background map... */
	if (!g_active && !g_background) {
		/* make sure we're redirecting input when the background's gone */
		if (getkeydest() != KEY_GAME) {
			setkeydest(KEY_GAME);
			setmousetarget(TARGET_CLIENT);
			setcursormode(FALSE);
		}

		/* don't draw the menu below */
		return (false);
	}

	return (g_active);
}

var int g_loading_stage;
var int g_current_loading_size;
var int g_total_loading_size;
var string g_connection_protocol;
var string g_level_shot_name;
var string g_lastLoadingState;

int Platform_GetLoadingStage(void)
{
	return (g_loading_stage);
}

int Platform_GetCurrentLoadingSize(void)
{
	return (g_current_loading_size);
}

int Platform_GetTotalLoadingSize(void)
{
	return (g_total_loading_size);
}

string Platform_GetConnectionProtocol(void)
{
	return (g_connection_protocol);
}

string Platform_GetLevelShotName(void)
{
	return (g_level_shot_name);
}

void
Platform_DrawLoading(vector screenSize)
{
	g_connection_protocol = serverkey("protocol");
	string loadState = serverkey("loadstate");

    if (loadState != g_lastLoadingState) {
        tokenize_console(loadState);
        g_loading_stage = (int)stof(argv(0));
        g_current_loading_size = (int)stof(argv(1));
        g_total_loading_size = (int)stof(argv(2));
        g_level_shot_name = argv(3);
        g_lastLoadingState = loadState;
    }

	if (STRING_SET(g_level_shot_name))
		if (iscachedpic(g_level_shot_name))
			drawpic( [0,0], g_level_shot_name, screenSize, [1,1,1], 1.0f );
}

void
Platform_CalculateRenderingScale(vector screensize)
{
	g_vidsize[0] = screensize[0];
	g_vidsize[1] = screensize[1];
	g_menuofs[0] = (g_vidsize[0] / 2) - 320;
	g_menuofs[1] = (g_vidsize[1] / 2) - 240;
}

bool
Platform_DimensionsChanged(vector screensize)
{
	return ((screensize[0] != g_vidsize[0]) || (screensize[1] != g_vidsize[1])) ? (true) : (false);
}


bool
Platform_HasStartupVideos(void)
{
	string videoFile = "";
	videoFile = GameLibrary_GetInfo(GAMEINFO_INTROVIDEO);

	if (STRING_SET(videoFile)) {
		return (true);
	}

	return (false);
}

void
Platform_PlayStartupVideos(void)
{
	string videoFile = "";
	videoFile = GameLibrary_GetInfo(GAMEINFO_INTROVIDEO);

	if (STRING_SET(videoFile)) {
        ncLog("Video to play on startup: %s", videoFile);
		localcmd(strcat("playvideo ", videoFile, "\n"));
	} else {
        ncLog("Video to play on startup not defined");
    }
}
