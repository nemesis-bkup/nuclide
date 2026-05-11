typedef enum
{
    FEEDER_HEADS = 0,                       /**< TA model heads */
    FEEDER_MAPS,                            /**< text maps, filtered by ui_gameType */
    FEEDER_SERVERS,                         /**< currently filtered list of servers */
    FEEDER_CLANS,                           /**< clan names */
    FEEDER_ALLMAPS,                         /**< all maps available */
    FEEDER_REDTEAM_LIST,                    /**< red team (team 1) members */
    FEEDER_BLUETEAM_LIST,                   /**< blue team (team 2) members */
    FEEDER_PLAYER_LIST,                     /**< player list */
    FEEDER_TEAM_LIST,                       /**< teams? */
    FEEDER_MODS,                            /**< custom games */
    FEEDER_DEMOS,                           /**< demo recordings */
    FEEDER_SCOREBOARD,                      /**< TODO: research */
    FEEDER_Q3HEADS,                         /**< Q3 heads */
    FEEDER_SERVERSTATUS,                    /**< server status */
    FEEDER_FINDPLAYER,                      /**< find player result? */
    FEEDER_CINEMATICS,                      /**< pre-recorded cinematics */
    FEEDER_SAVEGAMES,                       /**< saved games */
    FEEDER_PICKSPAWN,                       /**< available spawn points */
    FEEDER_PARTY_MEMBERS,                   /**< current matchmaking/party/group member list */
    FEEDER_PARTY_MEMBERS_TALK,              /**< current talking matchmaking/party/group member list */
    FEEDER_MUTELIST,                        /**< current mute list */
    FEEDER_PLAYERSTALKING,                  /**< players talking in world */
    FEEDER_SPLITSCREENPLAYERS,              /**< split-screen player list */
    FEEDER_PARTY_MEMBERS_READY,             /**< ready party members */
    FEEDER_PLAYER_PROFILES,                 /**< player profiles */
    FEEDER_PLAYER_PROFILE_VIDEO_LIST,       /**< video in profile/PDA (like Doom III) */
    FEEDER_PLAYER_PROFILE_AUDIO_LIST,       /**< audio in profile */
    FEEDER_PLAYER_PROFILE_EMAIL_LIST,       /**< message in profile */
    FEEDER_PLAYER_PROFILE_PICTURE_LIST,     /**< picture in profile */
    FEEDER_PLAYER_PROFILE_SOFTWARE_LIST,    /**< software in profile */
    FEEDER_PLAYER_PROFILE_WEB_LIST,         /**< web url in profile */
    FEEDER_PLAYER_PROFILE_TEXT_LIST,        /**< text in profile */
    FEEDER_PLAYER_PROFILE_OBJECT_LIST,      /**< object in profile */
} feederTypes_t;

int Feeder_Count(feederTypes_t typeFeed);
string Feeder_StringAtIndex(int row, int column, feederTypes_t typeFeed);
