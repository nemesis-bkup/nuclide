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

__weak __variant
ClientGame_OwnerDrawValueForType(ncPlayer clientSlot, int ownerDraw, int typeValue)
{
	/* update all ownerdraw items */
	switch (ownerDraw) {
	case CG_PLAYER_ARMOR_VALUE:
		return ftos(player.GetArmor());
	case CG_PLAYER_HEALTH:
		return ftos(player.GetHealth());
	case CG_PLAYER_AMMO_ICON:
        return "";
		break;
	case CG_PLAYER_AMMO_VALUE:
		if (weapon.AmmoRequired() == false) {
			return " ";
		} else {
			return ftos(weapon.GetAmmo1());
		}
	case CG_PLAYER_AMMOCLIP_VALUE:
		if (weapon.GetClipSize() == false) {
			return " ";
		} else {
			return ftos(weapon.GetClip());
		}
	case CG_PLAYER_WEAPON_NAME:
		return weapon.GetTitle();
	case CG_PLAYER_STAMINA:
		return player.GetStamina();
	case CG_PLAYER_SCORE:
		return getplayerkeyvalue(player_localnum, INFOKEY_P_FRAGS);
	case CG_1STPLACE:
		return getplayerkeyvalue(-1, INFOKEY_P_NAME);
	case CG_2NDPLACE:
		return getplayerkeyvalue(-2, INFOKEY_P_NAME);
	case CG_CAPFRAGLIMIT:
		return serverinfo.GetString("fraglimit");
	case CG_GAME_TYPE:
		return serverinfo.GetString("mode");
	case CG_PLAYER_STATUS:
		return getplayerkeyvalue(player_localnum, "status");
	case CG_BLUE_SCORE:
		return itos(teams.Score(1));
	case CG_RED_SCORE:
		return itos(teams.Score(2));
	case CG_RED_NAME:
		return teams.Name(1);
	case CG_BLUE_NAME:
		return teams.Name(2);
    case CG_PLAYER_LOCATION:
    	if (serverkeyfloat("areadefs") == 1) {
			ncUserInfo playerInfo = g_userInfo.LocalPlayerInfo();
            return (playerInfo.Location());
        }
		break;
	case CG_GAME_STATUS: /* in teamplay, says which team leads or if they're tied. otherwise player ranking */
    case CG_TEAMINFO:
	default:
		/* unimplemented, you can warn here if you don't mind spam */
		break;
	}


	return (__NULL__);
}

__weak bool
ClientGame_OwnerDrawItemRect(ncPlayer clientSlot, vguiScriptedItem drawItem, int ownerDraw, int drawType)
{
	switch (ownerDraw) {
	case CG_PLAYER_HEAD:
		ncUserInfo playerInfo = g_userInfo.LocalPlayerInfo();

		if (time & 1)
			draw.Pic(drawItem.GetItemPosition(), playerInfo.Avatar(), drawItem.GetItemSize(), [1,1,1], 1.0f, 0);
		else
			draw.Pic(drawItem.GetItemPosition(), "gfx/hud/health", drawItem.GetItemSize(), [1,1,1], 1.0f, 0);

		break;
	case CG_PLAYER_ARMOR_ICON:
		draw.Pic(drawItem.GetItemPosition(), "gfx/hud/armor", drawItem.GetItemSize(), [1,1,1], 1.0f, 0);
		break;
	case CG_PLAYER_AMMO_ICON:
		draw.Pic(drawItem.GetItemPosition(), "gfx/hud/armor", drawItem.GetItemSize(), [1,1,1], 1.0f, 0);
		break;
	case CG_PLAYER_ITEM:
		//draw.Pic(drawItem.GetItemPosition(), "gfx/hud/item", drawItem.GetItemSize(), [1,1,1], 1.0f, 0);
		break;
	case CG_PLAYER_HASFLAG:
		//draw.Pic(drawItem.GetItemPosition(), "gfx/hud/armor", drawItem.GetItemSize(), [1,1,1], 1.0f, 0);
		break;
	case CG_AREA_LAGOMETER:
		//draw.Pic(drawItem.GetItemPosition(), "gfx/hud/armor", drawItem.GetItemSize(), [1,1,1], 1.0f, 0);
		break;
	default:
		return (false);
	}

	return (true);
}

__weak bool
ClientGame_OwnerDrawMenuRect(ncPlayer clientSlot, vguiScriptedMenu drawMenu)
{
	return (false);
}
