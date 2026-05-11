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
vguiTool_TVTuner:vguiApplication
{
    void vguiTool_TVTuner(void);

    virtual void Spawned(void);

private:

    int m_tvChannelNum;
    vguiButton btnPlay;
    vguiButton btnStop;
    vguiVideo video;
    vguiFrame m_outlineFrame;
    vguiTextPrompt urlPrompt;
};

void
vguiTool_TVTuner::vguiTool_TVTuner(void)
{
}

void
vguiTool_TVTuner::TV_PreviousChannel(void)
{
    m_tvChannelNum++;
    video.SetVideo(ncAVReceiver::GetMaterialForChannel(m_tvChannelNum));
}

void
vguiTool_TVTuner::TV_NextChannel(void)
{
    m_tvChannelNum--;
    video.SetVideo(ncAVReceiver::GetMaterialForChannel(m_tvChannelNum));
}

void
vguiTool_TVTuner::VideoPlayer_Resized(void)
{
    vector windowSize = GetSize();
    float scaleFactor = windowSize[0]/(160-16);
    vector frameSize;

    /* fill to width */
    frameSize[0] = (windowSize[0] - 16);
    frameSize[1] = (120-32) * scaleFactor;
    m_outlineFrame.SetSize(frameSize);
    video.SetPos(m_outlineFrame.GetPos() + [2,2]);
    video.SetSize(m_outlineFrame.GetSize() - [4,4]);
    btnPlay.SetPos( [8,windowSize[1]-28] );
    btnStop.SetPos( [8+32+2,windowSize[1]-28] );
}

void
vguiTool_TVTuner::Spawned(void)
{
    super::Spawned();

    classname = "vguiWindow";
    SetTitle( "TV Tuner" );
    SetSize( [160+16,120+32] );
    SetIcon( "gfx/icon16/television" );
    SetStyleMask( vguiWindowStyleDefault | vguiWindowResizeable );
    CallOnResize(VideoPlayer_Resized);

    m_outlineFrame = spawn(vguiFrame);
    m_outlineFrame.SetPos([8,32]);
    m_outlineFrame.SetSize([160,120]);

    video = spawn( vguiVideo );
    video.SetPos( [8,32] );
    video.SetSize([160-4,120-4]);

    btnPlay = spawn( vguiButton );
    btnPlay.SetIcon( "gfx/icon16/control_rewind" );
    btnPlay.SetSize([32,24]);
    btnPlay.SetFuncWithDelegate( TV_PreviousChannel, this );

    btnStop = spawn( vguiButton );
    btnStop.SetIcon( "gfx/icon16/control_fastforward" );
    btnStop.SetSize([32,24]);
    btnStop.SetFuncWithDelegate( TV_NextChannel, this );

    Add( m_outlineFrame );
    Add( video );
    Add( btnPlay );
    Add( btnStop );

    VideoPlayer_Resized();

    m_tvChannelNum = 0;
    video.SetVideo(ncAVReceiver::GetMaterialForChannel(m_tvChannelNum));
}
