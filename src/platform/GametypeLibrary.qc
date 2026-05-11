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
} gametype_t;

var gametype_t *g_gametypeLibrary;
var int g_gametypeCount;


void
ncGametypeLibrary::Init(void)
{
    Reload();
}

void
ncGametypeLibrary::Shutdown(void)
{
    g_gametypeCount = 0;

    if (g_gametypeLibrary) {
        memfree(g_gametypeLibrary);
        g_gametypeLibrary = 0;
    }
}

__variant
ncGametypeLibrary::GetInfo(int index, playerModelInfo_t infoType)
{
    switch (infoType) {
    case GAMETYPE_NAME:
        return g_gametypeLibrary[index].m_name;
        break;
    case GAMETYPE_PATH:
        return g_gametypeLibrary[index].m_path;
        break;
    }

    return (__NULL__);
}

string
ncGametypeLibrary::ModelPathForName(string searchName)
{
    for (int i = 0i; i < g_playerModelCount; i++) {
        if (g_gametypeLibrary[i].m_name == searchName) {
            return g_gametypeLibrary[i].m_path;
        }
    }

    return (__NULL__);
}

int
ncGametypeLibrary::Count(void)
{
    return (g_gametypeCount);
}

void
ncGametypeLibrary::Reload(void)
{
    /* scan and cache the models */
    searchhandle searchy = search_begin("progs/*.dat", SEARCH_MULTISEARCH | SEARCH_NAMESORT, TRUE);

    g_gametypeCount = (int)search_getsize(searchy);

    if (g_gametypeCount >= 1i) {
        g_gametypeLibrary = memalloc(sizeof(playerModel_t) * g_gametypeCount);

        for (int i = 0i; i < g_gametypeCount; i++) {
            g_gametypeLibrary[i].m_path = search_getfilename(searchy, i);
            g_gametypeLibrary[i].m_name = substring(g_gametypeLibrary[i].m_path, 6, -5);
            //ncLogAlways("...gametype %S added", g_gametypeLibrary[i].m_name);
        }
        search_end(searchy);
    }

    ncLogAlways("...indexed %i gametypes", g_gametypeCount);
}

