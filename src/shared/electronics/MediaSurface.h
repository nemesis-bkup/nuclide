/*
 * Copyright (c) 2022-2025 Vera Visions LLC.
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

/*!QUAKED ncMediaSurface (1 0 0) (-8 -8 -8) (8 8 8)
Fully interactive surface

# KEYS
- "angles" : Sets the pitch, yaw and roll angles of the surface.
- "ui_res" : Resolution of the interface
- "ui_size" : Size of the interface in world coordinates
- "ui_menu" : Menu file to use (e.g. ui/testmenu1.menu)

# SPAWNFLAGSS
None yet

# NOTES
Similar to surfaces in Doom III and Duke 4

# TRIVIA
This entity was introduced in Nuclide (2022).
*/
class
ncMediaSurface:ncEntity
{
public:
	void ncMediaSurface(void);

#ifdef SERVER
	virtual void OnMapFinishedLoading(void);
	virtual void SpawnKey(string,string);
	virtual void Spawned(void);
	virtual void EvaluateEntity(void);
	virtual float SendEntity(entity,float);
	virtual void Input(entity, string, string);
#endif

#ifdef CLIENT
	virtual float predraw(void);
	virtual void postdraw(void);
	virtual void postframe(void);
	virtual void RenderScene(void);
    virtual void OnRemoveEntity(void);
	virtual bool FocusCheck(vector,vector);
	virtual void ReloadVideoResources(void);
	virtual void ReceiveEntity(float,float);
	virtual bool Input(float,float,float,float);
	virtual void _ReceiveComplete(float, float);
    virtual void ReceiveEvent(float);

	virtual void OnGainedFocus(void);
	virtual void OnLostFocus(void);
#endif

private:
	NETWORKED_FLOAT(m_flScale)
	NETWORKED_STRING(m_strUIClass)
	NETWORKED_VECTOR(m_vecUIRes)
	NETWORKED_FLOAT(m_flUseDistance)
	NETWORKED_VECTOR(m_vecScreenLight)
	NETWORKED_BOOL(m_uiSurfaceEnabled)
	NETWORKED_FLOAT(m_mediaSourceEntityNum)
	NETWORKED_ENTITY(m_mediaSource)
	NETWORKED_STRING(m_gui64)
    NETWORKED_STRING(m_acceptsData)

#ifdef CLIENT
	entity m_uiRootWindow;
	entity m_uiInteractive;
	float m_flSurfaceMat;
	string m_strSurfaceMat;
	bool m_bInFocus;
	bool m_bWasInFocus;
	vector m_vecCursorPos;
	bool m_bCached;
	vector m_vecWorldSize;
    float m_refreshRate;
    float m_lastRefresh;
    float m_lastMouseInputTime;
    vector m_lastCursorPos;
#endif

#ifdef SERVER
	string m_outputOnActivate;
	string m_outputOnActivateFailed;
	string m_outputOnOutput1;
	string m_outputOnOutput2;
	string m_outputOnOutput3;
	string m_outputOnOutput4;
	string m_outputOnOutput5;
	string m_outputOnOutput6;
	string m_outputOnOutput7;
	string m_outputOnOutput8;
	string m_outputOnOutput9;
	string m_outputOnOutput10;
	string m_outputOnOutput11;
	string m_outputOnOutput12;
	string m_outputOnOutput13;
	string m_outputOnOutput14;
	string m_outputOnOutput15;
	string m_outputOnOutput16;
    string m_lastDataCommand;
#endif
};

typedef enumflags
{
	UISURFACEFL_ORIGIN,
	UISURFACEFL_ANGLES,
	UISURFACEFL_INTERFACE,
	UISURFACEFL_SOURCE,
	UISURFACEFL_RESOLUTION,
	UISURFACEFL_SCALE,
	UISURFACEFL_DISTANCE,
	UISURFACEFL_LIGHT,
	UISURFACEFL_ENABLED,
};


#define MEDIASURFACE_EVENT_COMMAND 1
#define MEDIASURFACE_EVENT_OPENURL 2
