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

class
ncAVTransmitter:ncActor
{
public:
	void ncAVTransmitter(void);

#ifdef SERVER
	virtual void Input(entity,string,string);
	virtual void SpawnKey(string,string);
	virtual bool IsAlive(void);

	virtual void EvaluateEntity(void);
	virtual float SendEntity(entity,float);
#endif

#ifdef CLIENT
	virtual void ReceiveEntity(float,float);
	virtual void ReloadVideoResources(void);
	virtual void UpdateReceivers(void);
	nonvirtual void FlipImages(void);
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
	NETWORKED_FLOAT(m_tvChannelLightStyle)

#ifdef CLIENT
	bool m_bCached;
	string m_tvChannelMat;
	string m_tvChannelVideoMat;
#endif
};

typedef enumflags
{
	TVCHANNELFL_ORIGIN,
	TVCHANNELFL_CHAN,
	TVCHANNELFL_VIDEO,
	TVCHANNELFL_AUDIO,
	TVCHANNELFL_DOG,
	TVCHANNELFL_TOPTEXT,
	TVCHANNELFL_BOTTOMTEXT,
	TVCHANNELFL_LIGHT,
	TVCHANNELFL_SEEKTIME,
};
