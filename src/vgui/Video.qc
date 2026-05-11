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

const string g_videoMat = "{\n" \
                "\t{\n" \
                "\t\tvideomap %s\n" \
                "\t}\n" \
                "}\n";

/** VGUI Widget: Picture Frame

@ingroup vgui
*/
class
vguiVideo:vguiWidget
{
public:
    void vguiVideo(void);

    virtual void Draw(void);
    virtual void Spawned(void);
    virtual void ReloadVideoResources(void);

    nonvirtual void SetVideo(string);
    nonvirtual void SetVideoURL(string);
    nonvirtual string GetVideo(void);
    nonvirtual void Play(void);
    nonvirtual void Stop(void);
    nonvirtual void Pause(void);

private:
    string m_strVideoMaterial;
    string m_strVideoFile;
};

void
vguiVideo::vguiVideo(void)
{
    m_strVideoMaterial = g_string_null;
    m_strVideoFile = g_string_null;
}

void
vguiVideo::Spawned(void)
{
    SetSize([16,16]);
}

void
vguiVideo::Play(void)
{
}

void
vguiVideo::Stop(void)
{
    SetVideo("");
}

void
vguiVideo::Pause(void)
{
    /* TODO? */
    gecko_navigate(m_strVideoMaterial, "cmd:pause");
}

void
vguiVideo::Draw(void)
{
    if (!STRING_SET(m_strVideoMaterial)) {
        drawfill(m_parent.m_vecOrigin + m_vecOrigin, m_vecSize, [0,0,0], 1.0f, 0);
        return;
    }

    if (!iscachedpic(m_strVideoMaterial)) {
        drawpic(m_parent.m_vecOrigin + m_vecOrigin, "conback", m_vecSize, [1,1,1], 1.0f, 0);
        return;
    }

    drawpic(m_parent.m_vecOrigin + m_vecOrigin, m_strVideoMaterial, m_vecSize, [1,1,1], 1.0f, 0);
}

void
vguiVideo::SetVideo(string strName)
{
    m_strVideoFile = strName;
    m_strVideoMaterial = strName;
    ReloadVideoResources();
}

void
vguiVideo::SetVideoURL(string strName)
{
    m_strVideoFile = strName;
    m_strVideoMaterial = "RemoteURL";
    ReloadVideoResources();
}


string
vguiVideo::GetVideo(void)
{
    return (m_strVideoFile);
}


void
vguiVideo::ReloadVideoResources(void)
{
    string newMaterial = sprintf(g_videoMat, m_strVideoFile);
    shaderforname(m_strVideoFile, newMaterial);
}
