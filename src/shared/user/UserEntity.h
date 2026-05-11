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

/** @defgroup userobjects User Objects
@ingroup entities

These objects will be subject to whitelisting, blacklisting,
muting, permissions and other such rules.

As they are user managed they are under constant scrutiny
by the server game and are only allowed to perform some tasks and interpret
some inputs. That is the idea behind such objects.

*/


/** Shared: User Placed/Controlled Object Superclass

Every user placed object is derived from this.

@ingroup userobjects
*/
class
ncUserEntity:ncMediaSurface
{
    void ncUserEntity(void);

    virtual void Spawned(void);

#ifdef SERVER
    nonvirtual ncUserEntity AllocateNewType(ncPlayer queryingPlayer, string entClass);
#endif

#ifdef CLIENT
    virtual void _ReceiveComplete(float, float);
    nonvirtual void RequestRemoval(void);

    virtual void OnGainedFocus(void);
    virtual void OnLostFocus(void);

    entity m_uiControlView;
#endif

private:
    int m_ownerClientID; /* matches client edict id */
    int m_ownerGroupID; /* matches group object id */
};

