/*
 * Copyright (c) 2016-2026 Vera Visions LLC.
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


static string g_renderingResolutions[] = {
    "640x480",
    "800x600",
    "960x720",
    "1024x768",
    "1152x864",
    "1280x960",
    "1440x1080",
    "1600x1200",
    "1920x1440",
    "2048x1536",
    "1280x1024",
    "1800x1440",
    "2560x2048",
    "856x480",
    "1024x576",
    "1280x720",
    "1366x768",
    "1600x900",
    "1920x1080",
    "2048x1152",
    "2560x1440",
    "3840x2160",
    "4096x2304",
    "1024x640",
    "1152x720",
    "1280x800",
    "1440x900",
    "1680x1050",
    "1920x1200",
    "2304x1440",
    "2560x1600"
};

static string g_renderingDisplayModes[] = {
    "Windowed",
    "Fullscreen",
    "Borderless",
};

static string g_renderingAspects[] = {
    "Fill",
    "1:1",
    "4:3",
    "5:4",
    "16:9",
    "16:10",
    "21:9",
};

static string g_renderingAPIs[] = {
    "OpenGL",
    "Vulkan",
};

void
ncRenderingManager::Init(void)
{

}

void
ncRenderingManager::Shutdown(void)
{

}

__variant
ncRenderingManager::GetInfo(int index, rendererInfo_t infoBit)
{
    if (index < 0 || index >= Count(infoBit)) {
        return (__NULL__);
    }

    switch (infoBit) {
    case RENDERER_RESOLUTION:
        return g_renderingResolutions[index];
        break;
    case RENDERER_DISPLAYMODE:
        return g_renderingDisplayModes[index];
        break;
    case RENDERER_ASPECTRATIO:
        return g_renderingAspects[index];
        break;
    case RENDERER_API:
        return g_renderingAPIs[index];
        break;
    }
    return (__NULL__);
}

int
ncRenderingManager::Count(rendererInfo_t infoBit)
{
    switch (infoBit) {
    case RENDERER_RESOLUTION:
        return g_renderingResolutions.length;
        break;
    case RENDERER_DISPLAYMODE:
        return g_renderingDisplayModes.length;
        break;
    case RENDERER_ASPECTRATIO:
        return g_renderingAspects.length;
        break;
    case RENDERER_API:
        return g_renderingAPIs.length;
        break;
    }
    return 0;
}

__variant
ncRenderingManager::GetCurrent(rendererInfo_t infoBit)
{
    switch (infoBit) {
    case RENDERER_RESOLUTION:
        string testRes = strcat(cvar_string("vid_width"), "x", cvar_string("vid_height"));
        return (testRes);
        break;
    case RENDERER_DISPLAYMODE:
        float fullscreenMode = cvar("vid_fullscreen");

        switch (fullscreenMode) {
        case 1:
            return "Fullscreen";
        case 2:
            return "Borderless";
        default:
            return "Windowed";
        }
        break;
    case RENDERER_ASPECTRATIO:
        return g_renderingAspects[0];
        break;
    case RENDERER_API:
        return "OpenGL";
        break;
    }
    return (__NULL__);
}

