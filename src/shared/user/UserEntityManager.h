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

/** Shared: User Placed/Controlled Object Superclass

Every user placed object is derived from this.
ncUserEntity objects will be subject to whitelisting, blacklisting,
muting, permissions and other such rules.

*/
class
ncUserEntityManager:ncIO
{
	void ncUserEntityManager(void);
	nonvirtual int NumUserObjectsForClient(ncClient, string type);

#ifdef CLIENT
	nonvirtual void IndexClientInventory(void);
#endif

#ifdef SERVER
	nonvirtual void StopVideos(void);
	nonvirtual void RemoveAllObjects(void);
	nonvirtual void RemoveClientObjects(ncPlayer playerRef);
#endif
};

