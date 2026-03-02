musictrack_t moonSpawnMusic;

void
CodeCallback_Precache(void)
{
    moonSpawnMusic = precache.Music("music/suspense.ogg");
}

void
CodeCallback_PlayerSpawn(entity playerTarget)
{
    music.PlayOnceOnClient(moonSpawnMusic, playerTarget);
    ncError("wut");
}
