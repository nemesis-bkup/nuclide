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

typedef struct
{
    string m_name;
    string m_path;
    string m_preview;
    bool m_skinSupport;
    bool m_topBottomColor;
} playerModel_t;

var playerModel_t *g_playerModelLibrary;
var int g_playerModelCount;

/* these can technically be applied to other models. so these are not specific to each player model entry. */
var string *g_playerModelQWSkins;
var int g_playerModelQWSkinCount;

var string *g_playerSprays;
var int g_playerSprayCount;

void
ncPlayerModelLibrary::Init(void)
{
    Reload();
    ReloadSkins();
    ReloadSprays();
}

void
ncPlayerModelLibrary::Shutdown(void)
{
    g_playerModelCount = 0;

    if (g_playerModelLibrary) {
        memfree(g_playerModelLibrary);
        g_playerModelLibrary = 0;
    }
}

__variant
ncPlayerModelLibrary::GetInfo(int index, playerModelInfo_t infoType)
{
    switch (infoType) {
    case PLAYERMODEL_NAME:
        return g_playerModelLibrary[index].m_name;
        break;
    case PLAYERMODEL_PATH:
        return g_playerModelLibrary[index].m_path;
        break;
    case PLAYERMODEL_SKINSUPPORT:
        return g_playerModelLibrary[index].m_skinSupport;
        break;
    case PLAYERMODEL_TOPBOTTOMCOLOR:
        return g_playerModelLibrary[index].m_topBottomColor;
        break;
    }

    return (__NULL__);
}

string
ncPlayerModelLibrary::ModelPathForName(string searchName)
{
    for (int i = 0i; i < g_playerModelCount; i++) {
        if (g_playerModelLibrary[i].m_name == searchName) {
            return g_playerModelLibrary[i].m_path;
        }
    }

    return (__NULL__);
}

int
ncPlayerModelLibrary::Count(void)
{
    return (g_playerModelCount);
}

void
ncPlayerModelLibrary::Reload(void)
{
    /* scan and cache the models */
    searchhandle searchy = search_begin("models/player/*/*.bmp:models/player/*/*.tga:models/players/*/icon_blue.tga", SEARCH_MULTISEARCH | SEARCH_NAMESORT, TRUE);

    g_playerModelCount = (int)search_getsize(searchy);

    /* append the QW one */
    if (fileExists("progs/player.mdl")) {
        g_playerModelCount++;
    }

    if (g_playerModelCount >= 1i) {
        g_playerModelLibrary = memalloc(sizeof(playerModel_t) * g_playerModelCount);

        g_playerModelLibrary[0].m_preview = "nodraw";
        g_playerModelLibrary[0].m_name = "default";
        g_playerModelLibrary[0].m_path = "progs/player.mdl";
        g_playerModelLibrary[0].m_skinSupport = true;
        g_playerModelLibrary[0].m_topBottomColor = true;

        for (int i = 1i; i < g_playerModelCount; i++) {
            g_playerModelLibrary[i].m_preview = substring(search_getfilename(searchy, i-1), 0, -5);
            g_playerModelLibrary[i].m_path = strcat(g_playerModelLibrary[i].m_preview, ".mdl");
            tokenizebyseparator(g_playerModelLibrary[i].m_preview, "/");
            g_playerModelLibrary[i].m_name = argv(2);
            g_playerModelLibrary[i].m_skinSupport = false;
            g_playerModelLibrary[i].m_topBottomColor = true;


            precache_pic(g_playerModelLibrary[i].m_preview);
            //ncLogAlways("...player model %S added", g_playerModelLibrary[i].m_name);
        }
        search_end(searchy);
    }

    ncLogAlways("...indexed %i player models", g_playerModelCount);
}

int
ncPlayerModelLibrary::SkinCount(void)
{
    return (g_playerModelQWSkinCount);
}

string
ncPlayerModelLibrary::SkinName(int skinNum)
{
    return g_playerModelQWSkins[skinNum];
}

int
ncPlayerModelLibrary::SprayCount(void)
{
    return (g_playerSprayCount);
}

string
ncPlayerModelLibrary::SprayName(int skinNum)
{
    return g_playerSprays[skinNum];
}

void
ncPlayerModelLibrary::ReloadSkins(void)
{
    /* scan and cache the models */
    searchhandle searchy = search_begin("skins/*.bmp:skins/*.pcx", SEARCH_MULTISEARCH | SEARCH_NAMESORT, TRUE);

    g_playerModelQWSkinCount = (int)search_getsize(searchy);
    g_playerModelQWSkinCount++;

    if (g_playerModelQWSkinCount >= 1i) {
        g_playerModelQWSkins = memalloc(sizeof(string) * g_playerModelQWSkinCount);

        g_playerModelQWSkins[0] = "none";

        for (int i = 1i; i < g_playerModelQWSkinCount; i++) {
            g_playerModelQWSkins[i] = substring(search_getfilename(searchy, i-1), 6, -5);
            //ncLogAlways("...player skin %S added", g_playerModelQWSkins[i]);
        }
        search_end(searchy);
    }

    ncLogAlways("...indexed %i player skins", g_playerModelQWSkinCount);
}


void
ncPlayerModelLibrary::ReloadSprays(void)
{
    int sid = 0i;

    /* scan and cache the sprays */
    searchhandle searchy = search_begin("logos/*.*", SEARCH_NAMESORT, TRUE);

    for (int i = 0; i < search_getsize(searchy); i++) {
        string full = search_getfilename(searchy, i);
        string filename = substring(search_getfilename(searchy, i), 0, -5);
        string extension = substring(full, strlen(full) - 3, 3);

        if (extension == "bmp" || extension == "png" || extension == "jpg") {
            g_playerSprayCount++;
        }
    }

    if (g_playerSprayCount >= 1i) {
        /* only allocate what we truly need */
        g_playerSprays = memalloc(sizeof(string) * g_playerSprayCount);

        for (int i = 0i; i < (int)search_getsize(searchy); i++) {
            string full = search_getfilename(searchy, i);
            string filename = substring(full, 0, -5);
            string extension = substring(full, strlen(full) - 3, 3);

            if (extension == "bmp" || extension == "png" || extension == "jpg") {
                g_playerSprays[sid] = precache_pic(full);
                sid++;
            }
        }
        search_end(searchy);
    }

    ncLogAlways("...indexed %i player sprays", g_playerSprayCount);
}
