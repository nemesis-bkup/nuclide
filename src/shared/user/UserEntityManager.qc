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

void
ncUserEntityManager::ncUserEntityManager(void)
{

}

#ifdef SERVER
void
ncUserEntityManager::StopVideos(void)
{
    for (ncUserEntity_Video eFind = world;(eFind = (ncUserEntity_Video)find(eFind, ::spawnclass, "ncUserEntity_Video"));) {
        eFind.Stop();
    }
}
void
ncUserEntityManager::RemoveAllObjects(void)
{
    for (entity eFind = world;(eFind = find(eFind, ::spawnclass, "ncUserEntity"));) {
        remove(eFind);
    }
}

void
ncUserEntityManager::RemoveClientObjects(ncPlayer playerRef)
{
    for (entity eFind = world;(eFind = find(eFind, ::spawnclass, "ncUserEntity"));) {
        if (eFind.owner == playerRef) {
            remove(eFind);
        }
    }
}
#endif

int
ncUserEntityManager::NumUserObjectsForClient(ncClient entOwner, string type)
{
    int objectEnum = 0i;

    for (entity eFind = world;(eFind = find(eFind, ::classname, type));) {
        if (eFind.owner == entOwner) {
            objectEnum++;
        }
    }
    return (objectEnum);
}

#ifdef CLIENT
void
ncUserEntityManager::IndexClientInventory(void)
{
    string profileName = cvars.GetString("cl_cred");
    int profileLength = strlen(profileName);

    /* index audio */
    searchhandle shSearchPicLibrary = search_begin( "decls/audio/*.audio", SEARCH_NAMESORT | SEARCH_MULTISEARCH, TRUE );
    searchhandle shSearchPicPlayer = search_begin( sprintf("data/players/%s/decls/audio/*.audio", profileName), SEARCH_NAMESORT | SEARCH_MULTISEARCH, TRUE );

    for ( int i = 0; i < search_getsize( shSearchPicPlayer ); i++ ) {
        string dictName = substring(search_getfilename( shSearchPicPlayer, i ), 26+profileLength, -7);
        ncDict videoDict = ncDict::LoadDeclFromFile(dictName, sprintf("audio/%s.audio", dictName));
    }
    for ( int i = 0; i < search_getsize( shSearchPicLibrary ); i++ ) {
        string dictName = substring(search_getfilename( shSearchPicLibrary, i ), 12, -7);
        ncDict videoDict = ncDict::LoadDeclFromFile(dictName, sprintf("audio/%s.audio", dictName));
    }

    /* index pictures */
    searchhandle shSearchPicLibrary = search_begin( "decls/pictures/*.picture", SEARCH_NAMESORT | SEARCH_MULTISEARCH, TRUE );
    searchhandle shSearchPicPlayer = search_begin( sprintf("data/players/%s/decls/pictures/*.picture", profileName), SEARCH_NAMESORT | SEARCH_MULTISEARCH, TRUE );

    for ( int i = 0; i < search_getsize( shSearchPicPlayer ); i++ ) {
        string dictName = substring(search_getfilename( shSearchPicPlayer, i ), 29+profileLength, -9);
        ncDict videoDict = ncDict::LoadDeclFromFile(dictName, sprintf("pictures/%s.picture", dictName));
    }

    for ( int i = 0; i < search_getsize( shSearchPicLibrary ); i++ ) {
        string dictName = substring(search_getfilename( shSearchPicLibrary, i ), 15, -9);
        ncDict videoDict = ncDict::LoadDeclFromFile(dictName, sprintf("pictures/%s.picture", dictName));
    }

    /* index video */
    searchhandle shSearchVideoLibrary = search_begin( "decls/videos/*.video", SEARCH_NAMESORT | SEARCH_MULTISEARCH, TRUE );
    searchhandle shSearchVideoPlayer = search_begin( sprintf("data/players/%s/decls/videos/*.video", profileName), SEARCH_NAMESORT | SEARCH_MULTISEARCH, TRUE );

    for ( int i = 0; i < search_getsize( shSearchVideoPlayer ); i++ ) {
        string dictName = substring(search_getfilename( shSearchVideoPlayer, i ), 27+profileLength, -7);
        ncDict videoDict = ncDict::LoadDeclFromFile(dictName, sprintf("videos/%s.video", dictName));
    }

    for ( int i = 0; i < search_getsize( shSearchVideoLibrary ); i++ ) {
        string dictName = substring(search_getfilename( shSearchVideoLibrary, i ), 13, -7);
        ncDict videoDict = ncDict::LoadDeclFromFile(dictName, sprintf("videos/%s.video", dictName));
    }
}
#endif
