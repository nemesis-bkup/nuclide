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

/*!QUAKED ncCamera (1 0 0) (-8 -8 -8) (8 8 8)

# OVERVIEW
A security camera entity. It can have a model, sweep around and be damaged.
It can also alert enemies in the area.

# KEYS
- "targetname" : Name used to identify entities.
- "health" : Health of the camera. If above 0, can be shot and destroyed.

*/
class
ncCamera:ncMediaSource
{
	void ncCamera(void);

#ifdef SERVER
	virtual void Spawned(void);
	virtual void Respawn(void);
	virtual void SpawnKey(string, string);
	virtual void EvaluateEntity(void);
	virtual float SendEntity(entity,float);
	virtual void Death(entity inflictor, entity attacker, int damagePoints, vector dir, vector absImpactPos, int hitBody);

#endif

#ifdef CLIENT
	virtual void postdraw(void);
	virtual void Draw(void);
	virtual void ReceiveEntity(float,float);
	virtual void ReloadVideoResources(void);
#endif

#ifdef CLIENT
private:
	bool m_bCached;
	float m_flSurfaceMat;
	string m_strSurfaceMat;
#endif
};



