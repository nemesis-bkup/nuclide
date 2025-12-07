void HUD_Init(void);
void HUD_Draw(void);
void HUD_DrawSpectator(void);
void HUD_SendStat(string, string);
float HUD_ClientInputFrame(float);
bool HUD_ConsoleCommand(string);
void HUD_Obituary(string, string, string, string);

void HUDProgs_Init(void);
void HUDProgs_Draw(void);
void HUDProgs_DrawSpectator(void);
void HUDProgs_DrawIntermission(void);
void HUDProgs_SendStat(string, string);
float HUDProgs_ClientInputFrame(float);
bool HUDProgs_ConsoleCommand(string);
void HUDProgs_Obituary(string, string, string, string);


/* Client Game codes for HUD UI MENU files */

#define CG_PLAYER_ARMOR_ICON		1
#define CG_PLAYER_ARMOR_VALUE		2
#define CG_PLAYER_HEAD				3
#define CG_PLAYER_HEALTH			4
#define CG_PLAYER_AMMO_ICON 		5
#define CG_PLAYER_AMMO_VALUE		6
#define CG_PLAYER_AMMOCLIP_VALUE	70
#define CG_PLAYER_WEAPON_ICON2D		71
#define CG_PLAYER_WEAPON_NAME		81
#define CG_PLAYER_STAMINA			73
