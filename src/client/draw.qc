__weak __variant
ClientGame_OwnerDrawValueForType(ncPlayer clientSlot, int ownerDraw, int typeValue)
{
	/* update all ownerdraw items */
	switch (ownerDraw) {
	case CG_PLAYER_ARMOR_VALUE:
		return ftos(player.GetArmor());
		break;
	case CG_PLAYER_HEALTH:
		return ftos(player.GetHealth());
		break;
	case CG_PLAYER_AMMO_ICON:
		break;
	case CG_PLAYER_AMMO_VALUE:
		if (weapon.AmmoRequired() == false) {
			return " ";
		} else {
			return ftos(weapon.GetAmmo1());
		}
		break;
	case CG_PLAYER_AMMOCLIP_VALUE:
		if (weapon.GetClipSize() == false) {
			return " ";
		} else {
			return ftos(weapon.GetClip());
		}
		break;
	case CG_PLAYER_WEAPON_ICON2D:
		return weapon.GetIcon();
		break;
	case CG_PLAYER_WEAPON_NAME:
		return weapon.GetTitle();
		break;
	case CG_PLAYER_STAMINA:
		return player.GetStamina();
		break;
	default:
		/* unimplemented, you can warn here if you don't mind spam */
		break;
	}


	return (__NULL__);
}

__weak bool
ClientGame_OwnerDrawItemRect(ncPlayer clientSlot, vguiTrUIItem drawItem, int ownerDraw, int drawType)
{
	return (false);
}

__weak bool
ClientGame_OwnerDrawMenuRect(ncPlayer clientSlot, vguiTrUISubMenu drawMenu)
{
	return (false);
}
