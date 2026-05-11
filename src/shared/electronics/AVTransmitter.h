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

/*!QUAKED ncAVTransmitter (1 0 0) (-8 -8 -8) (8 8 8)
Transmits a video, audio signal (with metadata) and more over the game network.

# KEYS
- "angles" : Sets the pitch, yaw and roll angles of the surface.
- "ui_class" : Which UI class to use
- "ui_res" : Resolution of the interface
- "ui_size" : Size of the interface in world coordinates
- "ui_menu" : Menu file to use (e.g. ui/testmenu1.menu)
- "channel" : Channel to transmit on.
- "video" : Video track to play by default.
- "audio" : Audio track to play by default.
- "dog" : Digital On-Screen Graphic to use by default. (Material names only)
- "top_text" : Top video text, styled inside the ui_menu file.
- "bottom_text" : Bottom video text, styled inside the ui_menu file.

# INPUTS
- "SwitchContainer" : Switches the video/audio track to a named set in `videos/filename.{roq,ogg}`
- "SwitchVideoTrack" : Switches the video track to a different .roq file.
- "SwitchAudioTrack" : Switches the audio track to a different .ogg file.
- "LoadVideo" : Loads video information from a named decl from `decls/videos/`
- "SetDOG" : Sets the DOG material.
- "SetTopText" : Sets the top video text.
- "SetBottomText" : Sets the top video text.
- "SetLight" : Sets the light color + style value, in RGB255. Fourth arg is style value.

# SPAWNFLAGSS
None yet

# TRIVIA
This entity was introduced in Nuclide (2025).
*/
class
ncAVTransmitter:ncMediaSource
{
public:
    void ncAVTransmitter(void);

#ifdef SERVER
    virtual void Input(entity,string,string);
    virtual void SpawnKey(string,string);
    virtual bool IsAlive(void);

    virtual void EvaluateEntity(void);
    virtual float SendEntity(entity,float);
    virtual void TransmitSingleVideo(string videoFile, bool advancesSchedule);
#endif

#ifdef CLIENT
    virtual void postdraw(void);
    nonvirtual void DrawDebug(void);
    virtual void ReceiveEntity(float,float);
#endif

private:
    NETWORKED_INT(m_tvChannelNum)
    NETWORKED_STRING(m_tvChannelVideo)
    NETWORKED_STRING(m_tvChannelAudio)
    NETWORKED_FLOAT(m_tvChannelTime)
    NETWORKED_STRING(m_tvChannelDOG)
    NETWORKED_STRING(m_tvChannelTopText)
    NETWORKED_STRING(m_tvChannelBottomText)
    NETWORKED_VECTOR(m_tvChannelLight)
    NETWORKED_STRING(m_tvChannelUI)
    NETWORKED_FLOAT(m_tvChannelLightStyle)

#ifdef CLIENT
    bool m_bCached;
    string m_tvChannelMat;
    string m_tvChannelVideoMat;
    entity m_tvChannelUIRootWindow;
    entity m_tvChannelUIMenu;
#endif
};

typedef enumflags
{
    TVCHANNELFL_ORIGIN,
    TVCHANNELFL_CHAN,
    TVCHANNELFL_UI,
    TVCHANNELFL_VIDEO,
    TVCHANNELFL_AUDIO,
    TVCHANNELFL_DOG,
    TVCHANNELFL_TOPTEXT,
    TVCHANNELFL_BOTTOMTEXT,
    TVCHANNELFL_LIGHT,
    TVCHANNELFL_SEEKTIME,
};
