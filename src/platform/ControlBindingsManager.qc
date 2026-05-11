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
    string m_description;
    string m_commandKey;
    string m_cachedKeys;
    string m_cachedKey1;
    string m_cachedKey2;
} controlBind_t;

var controlBind_t *g_controlBindings;
var int g_controlBindingsCount;

void
ncControlBindingsManager::Init(void)
{
    Reload();
}

void
ncControlBindingsManager::Shutdown(void)
{
    g_controlBindingsCount = 0;

    if (g_controlBindings) {
        memfree(g_controlBindings);
        g_controlBindings = 0;
    }
}

__variant
ncControlBindingsManager::GetInfo(int index, controlBindInfo_t infoType)
{
    switch (infoType) {
    case BIND_DESCRIPTION:
        return g_controlBindings[index].m_description;
        break;
    case BIND_KEYCOMMAND:
        return g_controlBindings[index].m_commandKey;
        break;
    case BIND_ALL_KEYS:
        return g_controlBindings[index].m_cachedKeys;
        break;
    case BIND_FIRST_KEY:
        return g_controlBindings[index].m_cachedKey1;
        break;
    case BIND_SECOND_KEY:
        return g_controlBindings[index].m_cachedKey2;
        break;
    }

    return (__NULL__);
}

int
ncControlBindingsManager::Count(void)
{
    return (g_controlBindingsCount);
}

void
ncControlBindingsManager::Reload(void)
{
    /* Parse the action list */
    int count = 0;
    int i = 0;
    string sTemp = __NULL__;
    filestream fs_actlst = 0;

    Shutdown();

    fs_actlst = fopen("gfx/shell/kb_act.lst", FILE_READ);

    /* count the valid entries */
    if (fs_actlst >= 0) {
        while ((sTemp = fgets(fs_actlst))) {
            /* anything but 2 keywords == invalid */
            if (tokenize_console(sTemp) == 2) {
                count++;
            }
        }
    } else {
        ncWarning("Cannot parse gfx/shell/kb_act.lst!");
        return;
    }

    g_controlBindingsCount = count;
    g_controlBindings = memalloc(sizeof(controlBind_t) * g_controlBindingsCount);

    fseek(fs_actlst, 0);
    sTemp = __NULL__;

    /* fill in the description/command list */
    while ((sTemp = fgets(fs_actlst))) {
        if (tokenize_console(sTemp) == 2) {
            /* in FTE the voip command is different */
            if (argv(0) == "+voicerecord") {
                g_controlBindings[i].m_commandKey = "+voip";
            } else {
                g_controlBindings[i].m_commandKey = argv(0);
            }

            g_controlBindings[i].m_description = argv(1);
            //ncLogAlways("... %i %s = %s", i, argv(0), argv(1));
            i++;
        }
    }

    fclose(fs_actlst);
    _InternalRefresh();

    ncLogAlways("...indexed %i entries about bindings", count);
}

void
ncControlBindingsManager::LoadGameDefaults(void)
{
    /* Parse the action list */
    string sTemp;
    filestream fs_def = fopen("gfx/shell/kb_def.lst", FILE_READ);

    if (fs_def >= 0) {
        localcmd("unbindall\n");

        while ((sTemp = fgets(fs_def))) {
            /* act upon valid entries */
            if (tokenize_console(sTemp) == 2)
                if (argv(1) == "+voicerecord")
                    localcmd(sprintf("bind \"%s\" \"+voip\"\n", argv(0)));
                else
                    localcmd(sprintf("bind \"%s\" \"%s\"\n", argv(0), argv(1)));
        }
        fclose(fs_def);
        _InternalRefresh();
    } else {
        ncWarning("Cannot parse gfx/shell/kb_def.lst!");
    }
}


void
ncControlBindingsManager::_InternalRefresh(void)
{
    int j, k, i;

    for (i = 0; i < g_controlBindingsCount; i++) {
        string cmd = g_controlBindings[i].m_commandKey;

        if (cmd == " ") {
            g_controlBindings[i].m_cachedKeys = "";
            continue;
        }

        g_controlBindings[i].m_cachedKeys = findkeysforcommand(cmd);
        tokenize(g_controlBindings[i].m_cachedKeys);

        /* clear */
        g_controlBindings[i].m_cachedKey1 = g_controlBindings[i].m_cachedKey2 = " ";

        /* we only support the first two bindings */
        for (j = 0; j < 2; ++j) {
            k = stof(argv(j));

            if (k == -1) {
                continue;
            }

            if (j) {
                g_controlBindings[i].m_cachedKey2 = keynumtostring(k);
            } else {
                g_controlBindings[i].m_cachedKey1 = keynumtostring(k);
            }
        }

        if (!STRING_SET(g_controlBindings[i].m_cachedKey1)) {
            g_controlBindings[i].m_cachedKey1 = " ";
        }

        if (!STRING_SET(g_controlBindings[i].m_cachedKey2)) {
            g_controlBindings[i].m_cachedKey2 = " ";
        }
    }
}
