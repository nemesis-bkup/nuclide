#pragma PROGS_DAT  "../../hud.dat"

const float baseIconSize = 32.0;
const float baseIconPadding = 16.0;
var float autocvar_cg_damageFill = 0.25f;

var float g_damageAlpha;
var vector g_damageLocation;
var int g_damageFlags;

font_s FONT_HUD;
var string g_ammoPic;

#define KILLMESSAGE_LIMIT 5i
#define KILLMESSAGE_TIME 4.0f

int g_killMsgCount;
float g_killMsgTime;
string g_killMsgRecord[KILLMESSAGE_LIMIT];


void
HUD_Init(void)
{
	font.Load("fonts/font16.font", FONT_HUD);
	g_ammoPic = 0;
}

void
HUD_DamageReceived(vector damageLocation, int damagePoints, int damageFlags)
{
	if (damagePoints <= 0i) {
		return;
	}

	g_damageAlpha = 1.0;
	g_damageLocation = damageLocation;
	g_damageFlags = damageFlags;

}

void
HUD_DrawSpectator(void)
{
	float palpha = 1.0f;
	string strText;

	vector hud_mins = screen.HUDMins();
	vector hud_size = screen.HUDSize();
	vector vecPos = g_vec_null;

	if (spectating.Mode() == SPECMODE_FREE) {
		palpha = 0.5f;
	}

	strText = sprintf("Tracking: %s", spectating.Name());
	vecPos[0] = hud_mins[0] + (hud_size[0] / 2) - (font.StringWidth(strText, true, FONT_HUD) / 2);
	vecPos[1] = hud_mins[1] + hud_size[1] - 60;
	draw.Text_A(vecPos, strText, palpha, FONT_HUD);

	strText = sprintf("Mode: %s", spectating.LocalizedMode());
	vecPos[0] = hud_mins[0] + (hud_size[0] / 2) - (font.StringWidth(strText, true, FONT_HUD) / 2);
	vecPos[1] = hud_mins[1] + hud_size[1] - 40;
	draw.Text_A(vecPos, strText, palpha, FONT_HUD);
}

void
HUD_WeaponSwitched(string weaponName)
{
	/* Here you could change the ammo icon based on the weapon you switched to */
	g_ammoPic = "gfx/hud/armor";
}


void
HUD_Obituary(string targetName, string attackerName, string weaponDef, string meansOfDeath)
{
	static void HUD_Obituary_Add(int id, string targetName, string attackerName, string weaponDef, string meansOfDeath) {
		string killMsg = entityDef.GetString(weaponDef, "msg_obituary");
		string killMsgGib = entityDef.GetString(weaponDef, "msg_gib");
		string killMsgSelf = entityDef.GetString(weaponDef, "msg_suicide");

		if (STRING_SET(killMsg)) {
			g_killMsgRecord[id] = sprintf(killMsg, targetName, attackerName);
		} else {
			g_killMsgRecord[id] = sprintf("%s killed %s", attackerName, targetName);
		}

		if (wordInString(meansOfDeath, "self")) {
			if (STRING_SET(killMsgSelf)) {
				g_killMsgRecord[id] = sprintf(killMsgSelf, targetName, attackerName);
			} else {
				g_killMsgRecord[id] = sprintf("%s ended their own life.", targetName);
			}
		} else if (wordInString(meansOfDeath, "gib")) {
			if (STRING_SET(killMsgGib)) {
				g_killMsgRecord[id] = sprintf(killMsgGib, targetName, attackerName);
			} else {
				g_killMsgRecord[id] = sprintf("%s gibbed %s.", attackerName , targetName);
			}
		}
	}

	if (g_killMsgCount < KILLMESSAGE_LIMIT) {
		HUD_Obituary_Add(g_killMsgCount, targetName, attackerName, weaponDef, meansOfDeath);
		g_killMsgCount++;
	} else {
		for (int i = 0i; i < (KILLMESSAGE_LIMIT-1); i++) {
			g_killMsgRecord[i] = g_killMsgRecord[i+1];
		}

		HUD_Obituary_Add(KILLMESSAGE_LIMIT-1, targetName, attackerName, weaponDef, meansOfDeath);
	}

	g_killMsgTime = time + KILLMESSAGE_TIME;
}

__variant
HUD_OwnerDrawValueForType(entity clientSlot, int ownerDraw, int typeValue)
{
	/* update all ownerdraw items */
	switch (ownerDraw) {
	case 73:
		return sprintf("%d%%", (1.0 - player.GetStamina()) * 100);
		break;
	default:
		/* unimplemented, you can warn here if you don't mind spam! */
		break;
	}

	return (__NULL__);
}

bool
HUD_OwnerDrawItemRect(vector pos, vector size, int ownerDraw, int type)
{
	if (ownerDraw == 73 && type == 8) {
		float scaleModifier = 1.0 - player.GetStamina();

		if (size[0] > size[1]) {
			size[0] *= scaleModifier;
		} else {
			size[1] *= scaleModifier;
		}

		draw.Rect(pos, size, [1,1,1], 1.0f);
		return (true);
	}

	return (false);
}
