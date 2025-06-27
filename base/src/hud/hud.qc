#pragma PROGS_DAT  "../../hud.dat"

const float baseIconSize = 32.0;
const float baseIconPadding = 16.0;
var float autocvar_cg_damageFill = 0.25f;

var float g_damageAlpha;
var vector g_damageLocation;
var int g_damageFlags;

font_s FONT_HUD;
var string g_ammoPic;

void
HUD_Init(void)
{
	font.Load("fonts/font16.font", FONT_HUD);
	g_ammoPic = 0;
}

void
HUD_Draw(void)
{

	vector hud_mins = screen.HUDMins();
	vector hud_size = screen.HUDSize();
	vector hudSize = hud_size;
	vector iconPos = hud_mins + (hudSize / 2);
	iconPos[1] = (hudSize[1] - baseIconSize) - baseIconPadding;

	string healthValue = ftos(player.GetHealth());
	string armorValue = ftos(player.GetArmor());
	string ammoValue = ftos(weapon.GetAmmo1());

	if (g_damageAlpha > 0.0f) {
		if (autocvar_cg_damageFill > 0.0) {
			vector screenSize = screen.Size();
			vector finalColor = [1,1,1];
			finalColor[1] = finalColor[2] = 1.0 - (g_damageAlpha * autocvar_cg_damageFill);
			draw.Pic(hud_mins, "fade_modulate", screenSize, finalColor, 1.0, DRAWFLAG_NORMAL);
		}

		g_damageAlpha -= clframetime;
	}

	/* health, armor icons */
	draw.RText(iconPos + [-((baseIconSize/2) + (baseIconPadding/2)) - baseIconPadding, 0], healthValue, FONT_HUD);
	draw.Pic(iconPos + [-((baseIconSize/2) + (baseIconPadding/2)), 0], "gfx/hud/health", [baseIconSize, baseIconSize], [1,1,1], 1.0f, DRAWFLAG_NORMAL);

	draw.Text(iconPos + [(baseIconSize/2) + (baseIconPadding/2) + baseIconSize + baseIconPadding, 0], armorValue, FONT_HUD);
	draw.Pic(iconPos + [(baseIconSize/2) + (baseIconPadding/2), 0], "gfx/hud/armor", [baseIconSize, baseIconSize], [1,1,1], 1.0f, DRAWFLAG_NORMAL);

	/* ammo */
	if (weapon.AmmoRequired() == true) {
		iconPos[0] = (hudSize[0] - baseIconSize) - baseIconPadding;
		iconPos[1] = (hudSize[1] - baseIconSize) - baseIconPadding;
		draw.Pic(iconPos, g_ammoPic, [baseIconSize, baseIconSize], [1,1,1], 1.0f, DRAWFLAG_NORMAL);
		iconPos[0] -= baseIconSize + baseIconPadding;
		draw.RText(iconPos, ammoValue, FONT_HUD);
	}
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
	vector vecPos;

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
