/*
 * Copyright (c) 2016-2020 Marco Cawthorne <marco@icculus.org>
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

/*! @file ncAddonManager.h
    @brief AddonC Manager

    Handles dispatching of information to the various ncAddonDelegate objects.
*/

class
ncAddonManager
{
public:
	/** Called when the plugin gets unloaded. */
	nonvirtual void Shutdown(void);

	/** Called when the server issues a console command. */
	nonvirtual bool ConsoleCommand(ncPlayer,string);
	/** Called when a client issues a client command. */
	nonvirtual bool ClientCommand(ncClient, string);
	/** Called when a ncPlayer joins the server. */
	nonvirtual void PlayerConnect(ncPlayer);
	/** Called when a ncPlayer leaves the server. */
	nonvirtual void PlayerDisconnect(ncPlayer);
	/** Called when a ncPlayer spawns, called sometime after joining. */
	nonvirtual void PlayerSpawn(ncPlayer);
	/** Called when a ncPlayer dies in the game. */
	nonvirtual void PlayerDeath(ncPlayer, ncEntity, ncEntity, string);
	/** Called when an NPC gets killed. */
	nonvirtual void NPCDeath(ncActor, ncEntity, ncEntity);

	/** Called when the plugin gets unloaded. */
	nonvirtual void LoadDefaultAddons(void);
};
