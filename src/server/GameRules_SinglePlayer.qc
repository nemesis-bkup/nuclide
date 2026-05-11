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


void
ncGameRule_SinglePlayer::ncGameRule_SinglePlayer(void)
{
}

void
ncGameRule_SinglePlayer::LevelDecodeParms(ncPlayer pl)
{
    g_landmarkpos[0] = parm1;
    g_landmarkpos[1] = parm2;
    g_landmarkpos[2] = parm3;
    pl.angles[0] = parm4;
    pl.angles[1] = parm5;
    pl.angles[2] = parm6;
    pl.velocity[0] = parm7;
    pl.velocity[1] = parm8;
    pl.velocity[2] = parm9;
    pl.flags = parm18;
}

void
ncGameRule_SinglePlayer::LevelChangeParms(ncPlayer pl)
{
    parm1 = g_landmarkpos[0];
    parm2 = g_landmarkpos[1];
    parm3 = g_landmarkpos[2];
    parm4 = pl.angles[0];
    parm5 = pl.angles[1];
    parm6 = pl.angles[2];
    parm7 = pl.velocity[0];
    parm8 = pl.velocity[1];
    parm9 = pl.velocity[2];
    parm18 = pl.flags;
}

void
ncGameRule_SinglePlayer::LevelNewParms(void)
{
    parm1 = parm2 = parm3 = parm4 = parm5 = parm6 = parm7 =
    parm8 = parm9 = 0;
    parm18 = 0;
}

void
ncGameRule_SinglePlayer::Save(float handle)
{

}

void
ncGameRule_SinglePlayer::Restore(string strKey, string strValue)
{

}

void
ncGameRule_SinglePlayer::Input(entity eAct, string strInput, string strData)
{
}

void
ncGameRule_SinglePlayer::RestoreComplete(void)
{
    g_grMode = this;
}

void
ncGameRule_SinglePlayer::InitPostEnts(void)
{
}

void
ncGameRule_SinglePlayer::Precache(void)
{
    precache.Entity("player");
}

void
ncGameRule_SinglePlayer::Shutdown(void)
{
}

void
ncGameRule_SinglePlayer::FrameStart(void)
{

}

string
ncGameRule_SinglePlayer::Title(void)
{
    return ("singleplayer");
}
