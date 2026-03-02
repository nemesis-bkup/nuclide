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

#define BROWSER_HOVER 8
#define BROWSER_MOUSEDOWN 4

/** VGUI Widget: Audio Stream

An audio stream.
Currently a wrapper around fteplug_cef.

@ingroup vgui
*/
class
vguiAudioStream:vguiPic
{
public:
	void vguiAudioStream(void);

	virtual bool Input(float, float, float, float);
	virtual void SizeChanged(vector, vector);
	virtual void OnRemove(void);

	nonvirtual void LoadRequest(string requestString);

	nonvirtual void PlayStream(void);
	nonvirtual void PauseStream(void);
	nonvirtual void RestartStream(void);
	nonvirtual void StopStream(void);
	nonvirtual void SeekBackward(void);
	nonvirtual void SeekForward(void);
	nonvirtual void VolumeUp(void);
	nonvirtual void VolumeDown(void);
	nonvirtual void VolumeMute(void);
	nonvirtual void Seek(float normalizedTime);

	nonvirtual string GetURL(void);

private:
	string m_webViewURL;
	string m_webViewName;
	float m_webViewRef;

	/* status cache */
	string m_pageTitle;
	string m_pageURL;
	string m_pageStatus;

	/* our options */
	bool m_focusLocked;

	nonvirtual void _InitializeWebContext(void);
};

void
vguiAudioStream::vguiAudioStream(void)
{
	m_webViewURL = "about:blank";
	m_webViewRef = 0;
	m_webViewName = __NULL__;
}

string
vguiAudioStream::GetURL(void)
{
	return (m_pageURL);
}

void
vguiAudioStream::LoadRequest(string requestString)
{
	if (checkcommand("cef") == 0) {
		SetImage("");
		return;
	}

	if (!STRING_SET(m_webViewName)) {
		_InitializeWebContext();
	}

	m_webViewURL = requestString;
	gecko_navigate(m_webViewName, m_webViewURL);
	ncLog("loading request for %S", m_webViewURL);
}

void
vguiAudioStream::OnRemove(void)
{
	gecko_destroy(m_webViewName);
}

void
vguiAudioStream::SizeChanged(vector vecOld, vector vecNew)
{
}

bool
vguiAudioStream::Input(float flEVType, float flKey, float flChar, float flDevID)
{
	return (false);
}

void
vguiAudioStream::PlayStream(void)
{
	gecko_navigate(m_webViewName, "cmd:focus");
	gecko_keyevent(m_webViewName, K_SPACE, IE_KEYDOWN, 0);
	gecko_navigate(m_webViewName, "cmd:unfocus");
}

void
vguiAudioStream::PauseStream(void)
{
	gecko_navigate(m_webViewName, "cmd:focus");
	gecko_keyevent(m_webViewName, 'k', IE_KEYDOWN, 0);
	gecko_navigate(m_webViewName, "cmd:unfocus");
}

void
vguiAudioStream::RestartStream(void)
{
	gecko_navigate(m_webViewName, "cmd:focus");
	gecko_keyevent(m_webViewName, '0', IE_KEYDOWN, 0);
	gecko_navigate(m_webViewName, "cmd:unfocus");
}

void
vguiAudioStream::StopStream(void)
{
	gecko_navigate(m_webViewName, "cmd:focus");
	gecko_keyevent(m_webViewName, K_END, IE_KEYDOWN, 0);
	gecko_navigate(m_webViewName, "cmd:unfocus");
}

void
vguiAudioStream::SeekBackward(void)
{
	gecko_navigate(m_webViewName, "cmd:focus");
	gecko_keyevent(m_webViewName, K_LEFTARROW, IE_KEYDOWN, 0);
	gecko_navigate(m_webViewName, "cmd:unfocus");
}

void
vguiAudioStream::SeekForward(void)
{
	gecko_navigate(m_webViewName, "cmd:focus");
	gecko_keyevent(m_webViewName, K_RIGHTARROW, IE_KEYDOWN, 0);
	gecko_navigate(m_webViewName, "cmd:unfocus");
}

void
vguiAudioStream::VolumeUp(void)
{
	gecko_navigate(m_webViewName, "cmd:focus");
	gecko_keyevent(m_webViewName, K_UPARROW, IE_KEYDOWN, 0);
	gecko_navigate(m_webViewName, "cmd:unfocus");
}

void
vguiAudioStream::VolumeDown(void)
{
	gecko_navigate(m_webViewName, "cmd:focus");
	gecko_keyevent(m_webViewName, K_DOWNARROW, IE_KEYDOWN, 0);
	gecko_navigate(m_webViewName, "cmd:unfocus");
}

void
vguiAudioStream::Seek(float normalizedTime)
{
	float volumeKey = rint(normalizedTime * 9);
	gecko_navigate(m_webViewName, "cmd:focus");
	gecko_keyevent(m_webViewName, '0' + volumeKey, IE_KEYDOWN, 0);
	gecko_navigate(m_webViewName, "cmd:unfocus");
}

void
vguiAudioStream::VolumeMute(void)
{
	gecko_navigate(m_webViewName, "cmd:focus");
	gecko_keyevent(m_webViewName, 'm', IE_KEYDOWN, 0);
	gecko_navigate(m_webViewName, "cmd:unfocus");
}

void
vguiAudioStream::_InitializeWebContext(void)
{
	m_webViewName = sprintf("vguiAudioStream%d", num_for_edict(this));
	m_webViewRef = gecko_create(m_webViewName, "http:");
}
