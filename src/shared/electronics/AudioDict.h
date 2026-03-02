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

/** Dictionary for audio recordings.

Generally defined in `decl/audio/filename.audio` or inside `decl/video/filename.video`
in the case of the ncVideoDict child-class.

# KEYS

- "name" : Localized name, or visually pleasing title.
- "info" : Description of the audio recording.
- "preview" : Path to preview material.
- "audio" : Sound shader or path to streaming audio file.

@ingroup decl
@ingroup sound
@ingroup electronics
*/
class
ncAudioDict:ncDict
{
public:
	void ncAudioDict(void);

private:
	string m_audioName;
	string m_audioInfo;
	string m_audioPreview;
	string m_audioTrack;
};
