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

/* some installs may have the music in media/, others may be in music/ */
string
ncMusicController::GetPath(int id)
{
    if (autocvar_cl_musicstyle == MUSIC_AUTO) {
        return sprintf("%i", id);
    } else if (autocvar_cl_musicstyle == MUSIC_FLAC) {
        return sprintf("music/track%02i.flac", id);
    } else if (autocvar_cl_musicstyle == MUSIC_STEAMHL) {
        if (id >= 2 && id <= 28) {
            return g_steamhltracks[id - 2];
        }
    }

    return ("");
}

/* EV_MUSICTRACK */
void
ncMusicController::ParseTrack(string parm)
{
    int track;
    string path;

    track = stof(parm);
    path = ncMusicController::GetPath(track);
    ncLog("^2ncMusicController::ParseTrack:^7 Single track %i from %s", track, path);
    localcmd(sprintf("music %s -\n", path));
}

/* EV_MUSICLOOP */
void
ncMusicController::ParseLoop(string parm)
{
    int track;
    string path;

    track = stof(parm);
    path = ncMusicController::GetPath(track);
    ncLog("^2ncMusicController::ParseLoop:^7 Looping track %i from %s", track, path);
    localcmd(sprintf("music %s\n", path));
}

void
ncMusicController::Init(void)
{
    if (g_active)
        return;

    if (fileExists("media/gamestartup.ogg")) {
        localcmd("music media/gamestartup.ogg\n");
        return;
    }

    string tinfo = cvar_string("gameinfo_menutrack");
    print(tinfo);
    print("\n");

    if (tinfo) {
        localcmd(sprintf("music %s\n", tinfo));
    }
}
