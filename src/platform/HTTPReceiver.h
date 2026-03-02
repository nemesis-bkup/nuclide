/*
 * Copyright (c) 2016-2022 Vera Visions LLC.
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

/**
@defgroup modserver Mod Server
@ingroup menu
@brief Remotely available modifications, addons control/install functions

The ModServer API manages the retrieval of custom game info
(usually modifications) into the [Game Library](@ref gamelibrary).

This is kept separate, in case where
connections to remote sources is disallowed.

@{
*/

/* Emscripten builds and mods? Forgetaboutit! */
#ifndef WEBMENU

/** uri_get callback id for mod-list retrieval */
#define MODSERVER_REQ_LIST 100
/** uri_get callback id for mod-item retrieval */
#define MODSERVER_REQ_ITEM 101
/** uri_get callback id for mod package name retrieval */
#define MODSERVER_REQ_PKGNAMES 102

/** Called as an eventual result of the uri_get builtin. */
void URI_Get_Callback(float id, float code, string data, int resourcebytes);
#endif

/** @} */ // end of modserver
