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

/*!QUAKED ncInteractiveSurface (1 0 0) (-8 -8 -8) (8 8 8)
Fully interactive surface

# KEYS
- "angles" : Sets the pitch, yaw and roll angles of the surface.
- "ui_class" : Which UI class to use
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
ncInteractiveSurface:ncEntity
{
public:
	void ncInteractiveSurface(void);

#ifdef SERVER
	virtual void SpawnKey(string,string);
	virtual void Spawned(void);
	virtual void EvaluateEntity(void);
	virtual float SendEntity(entity,float);
	virtual void Input(entity, string, string);
#endif

#ifdef CLIENT
	virtual float predraw(void);
	virtual void postdraw(void);
	virtual void RenderScene(void);
	virtual bool FocusCheck(vector,vector);
	virtual void ReloadVideoResources(void);
	virtual void ReceiveEntity(float,float);
	virtual bool Input(float,float,float,float);
#endif

private:
	NETWORKED_FLOAT(m_flScale)
	NETWORKED_STRING(m_strUIClass)
	NETWORKED_VECTOR(m_vecUIRes)
	NETWORKED_FLOAT(m_flUseDistance)
	NETWORKED_VECTOR(m_vecScreenLight)
	NETWORKED_BOOL(m_uiSurfaceEnabled)

#ifdef CLIENT
	entity m_UIChain;
	string m_strSurfaceMat;
	bool m_bInFocus;
	float m_flSurfaceMat;
	vector m_vecCursorPos;
	bool m_bCached;
	vector m_vecWorldSize;
#endif
};

typedef enumflags
{
	UISURFACEFL_ORIGIN,
	UISURFACEFL_ANGLES,
	UISURFACEFL_INTERFACE,
	UISURFACEFL_RESOLUTION,
	UISURFACEFL_SCALE,
	UISURFACEFL_DISTANCE,
	UISURFACEFL_LIGHT,
	UISURFACEFL_ENABLED,
};
