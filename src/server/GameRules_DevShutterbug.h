/*
 * Copyright (c) 2025 Marco Cawthorne <marco@icculus.org>
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

/** Internal Editor game rule

Can not be overriden

*/
class ncGameRule_DevShutterbug:ncRuleDelegate
{
public:
    void ncGameRule_DevShutterbug(void);

    /* overrides */
    virtual void Save(float);
    virtual void Restore(string,string);
    virtual void RestoreComplete(void);

    /* level transitions */
    /** Overridable: Called to set up new level parms for any ncPlayer. */
    virtual void LevelNewParms(void);
    /** Overridable: Called to store parms for a specific ncPlayer. */
    virtual void LevelChangeParms(ncPlayer);
    /** Overridable: Called to decode parms for a specific ncPlayer. */
    virtual void LevelDecodeParms(ncPlayer);
    /** Overridable: Called when a ncPlayer spawns, called sometime after joining. */
    virtual void PlayerSpawn(ncPlayer);

    /** Overridable: Called when all map entities have initialized. */
    virtual void InitPostEnts(void);

    virtual bool PlayerRequestRespawn(ncPlayer);

    /* logic */
    /** Overridable: Called from initents(). */
    virtual void Precache(void);

    /** Overridable: Called from SV_Shutdown(). */
    virtual void Shutdown(void);

    /** Overridable: Called every server frame. */
    virtual void FrameStart(void);

    virtual void IntermissionEnd();


    /** Returns the title of the gamemode running. */
    virtual string Title(void);

    /** Overridable: Called when the server issues a console command. */
    virtual bool ConsoleCommand(ncPlayer,string);
    /** Overridable: Called when a client issues a client command. */
    virtual bool ClientCommand(ncClient,string);

    nonvirtual int NumActiveGamePlayers(void);
    nonvirtual int NumActiveEditors(void);

private:
    ncClient m_sessionCreator;
    bool m_shotTaken;
};
