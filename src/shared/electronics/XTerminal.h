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

/*!QUAKED ncXTerminal (1 0 0) (-8 -8 -8) (8 8 8)

# OVERVIEW

A virtual X terminal. Requires the X11 server engine plugin
to run the actual X server on the host system.

An ncMediaSurface entity can set this as its input source in the
map and will display whatever gets launched on DISPLAY=:1
applications in the environment.

It defaults to a 1024x768 canvas.

The in-game object itself is capable of being interacted with
like any other ncActor or ncSurfacePropEntity.

Imagine it represents a computer tower of some sort.

# KEYS
- "targetname" : Name used to identify entities.
- "model" : Model to be used by this entity.
- "health" : Start health.
- "propdata" : Prop data name.
- "surfdata" : Surface data name.

# TRIVIA

This entity was introduced in Nuclide (2025)

# SEE ALSO

- [X terminal on Wikipedia](https://en.wikipedia.org/wiki/X_terminal)

*/
class
ncXTerminal:ncMediaSource
{
	void ncXTerminal(void);

#ifdef SERVER
	virtual void Spawned(void);
	virtual void Respawn(void);
	virtual void SpawnKey(string, string);
	virtual void EvaluateEntity(void);
	virtual float SendEntity(entity,float);
	virtual void Death(entity inflictor, entity attacker, int damagePoints, vector dir, vector absImpactPos, int hitBody);

#endif

#ifdef CLIENT
	virtual void Draw(void);
	virtual bool Input(float a,float b,float c,float d);
	virtual void ReceiveEntity(float,float);
#endif

#ifdef CLIENT
private:

	entity m_UIChain;
	entity m_xTermView;
#endif
};



