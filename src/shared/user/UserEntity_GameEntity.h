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

/** Shared: User Placed/Controlled Game Entity

An in-world game entity that has been placed down by
a player.

It becomes active when a player initiates their respective game.
It becomes in-active when all players have left the game (aka gone
into editing mode.)

@ingroup userobjects
*/
class
ncUserEntity_GameEntity:ncUserEntity
{
public:
    void ncUserEntity_GameEntity(void);

#ifdef SERVER
    virtual void EvaluateEntity(void);
    virtual float SendEntity(entity ePEnt, float flChanged);
    virtual void Respawn(void);

    nonvirtual void Place(ncPlayer entityCreator, string className, string modelPath, vector atPos, vector withAngle);
    nonvirtual void InstatiateEntitiesByPlayer(ncPlayer entityCreator);
    nonvirtual void DeinstatiateEntitiesByPlayer(ncPlayer entityCreator);
#endif

#ifdef CLIENT
    virtual void ReceiveEntity(float flNew, float flChanged);
    virtual float predraw(void);
#endif

#ifdef SERVER
    virtual void Instantiate(void);
    virtual void Deinstantiate(void);
#endif

private:
    NETWORKED_STRING(m_gameEntClass)

#ifdef SERVER
    ncEntity m_spawnedEntity;
#endif
};
