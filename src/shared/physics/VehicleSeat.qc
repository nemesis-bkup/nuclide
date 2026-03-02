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


#define VEH_SKIDDING VFL_USE_RELEASED

#define VEHSF_NOFLIP 2048

enumflags
{
	VEHFL_DRIVER,
	VEHFL_MODELINDEX,
	VEHFL_ORIGIN,
	VEHFL_ANGLES,
	VEHFL_VELOCITY,
	VEHFL_TURNING,
	VEHFL_FLAGS
};



void
ncVehicleSeat::ncVehicleSeat(void)
{
	m_eDriver = __NULL__;
	m_iVehicleFlags |= VHF_FROZEN;
}

#ifdef CLIENT
bool
ncVehicleSeat::HideViewWeapon(void)
{
	return (true);
}
#endif

void
ncVehicleSeat::Physics(void)
{
#ifdef CLIENT
	DriverRelink();
#endif

	/* if nobody is in the car, we need to run physics here
	 * with fake input frames */
	if (GetDriver() == __NULL__) {
#ifdef SERVER
		m_vecMoveValues = [0,0,0];
		m_iMoveButtons = 0;
#endif

#ifdef CLIENT
		setorigin(this, origin);
#endif
	} else {
		//crossprint(sprintf("Driver: %s\n", GetDriver().classname));
	}

	HandleThink();
}

void
ncVehicleSeat::OnRemoveEntity(void)
{
}

#ifdef CLIENT
var bool autocvar_car_firstPerson = false;

void
ncVehicleSeat::UpdateView(void)
{
	vector vecStart, vecEnd;

	if (1) {
		makevectors(angles);
		g_view.SetCameraOrigin(origin + (v_forward * m_firstPersonOrg[0]) + (v_right * m_firstPersonOrg[1]) + (v_up * m_firstPersonOrg[2]));
		//g_view.SetClientAngle(angles);
		return;
	}

	pSeat->m_vecPredictedOrigin = origin;
	makevectors(view_angles);
	vecStart = [pSeat->m_vecPredictedOrigin[0], pSeat->m_vecPredictedOrigin[1], pSeat->m_vecPredictedOrigin[2] + 16] + (v_right * 4);
	vecEnd = vecStart + (v_forward * -256) + [0,0,16] + (v_right * 4);
	other = world;
	traceline(vecStart, vecEnd, MOVE_OTHERONLY, this);
	g_view.SetCameraOrigin(trace_endpos + (v_forward * 16));
	g_view.SetClientAngle(view_angles);
}

#endif

#ifdef CLIENT
void
ncVehicleSeat::PredictPreFrame(void)
{
	SAVE_STATE(modelindex)
	SAVE_STATE(origin)
	SAVE_STATE(angles)
	SAVE_STATE(velocity)
	SAVE_STATE(m_flTurn)
	SAVE_STATE(flags)
	SAVE_STATE(driver_entnum)
}

void
ncVehicleSeat::PredictPostFrame(void)
{
	ROLL_BACK(modelindex)
	ROLL_BACK(angles)
	ROLL_BACK(origin)
	ROLL_BACK(velocity)
	ROLL_BACK(m_flTurn)
	ROLL_BACK(flags)
	ROLL_BACK(driver_entnum)
}
#endif

void
ncVehicleSeat::WeaponInput(void)
{

}

void
ncVehicleSeat::PlayerInput(void)
{
	m_vecMoveValues = input_movevalues;
	m_iMoveButtons = input_buttons;

#ifdef SERVER
	/* allow us to exit */
	if (m_flUseTime < time) {
		if (input_buttons & INPUT_BUTTON5) {
			eActivator = m_eDriver;
			OnPlayerUse();
			input_buttons &= ~INPUT_BUTTON5;
		}
	}
#endif

	WeaponInput();

	/* only allow use key */
	input_buttons = (input_buttons & INPUT_BUTTON5);
}

#ifdef SERVER
void
ncVehicleSeat::OnPlayerUse(void)
{
	if (m_flUseTime > time)
		return;

	if (eActivator) {
		ncPlayer theActivator = (ncPlayer)eActivator;

		if (theActivator.vehicle) {
			ncVehicle ourVehicle = (ncVehicle)theActivator.vehicle;
			ourVehicle.PlayerLeave(theActivator);
			return;
		}
	}

	if (m_eDriver == eActivator) {
		PlayerLeave((ncPlayer)eActivator);
		setorigin(eActivator, entryPosition);
	} else if (!m_eDriver) {
		angles = fixAngle(angles);
		if ((angles[2] > 45) || (angles[2] < -45)) {
			angles = [0,angles[1],200];
			velocity = [0,0,200];
		}

		entryPosition = eActivator.origin;

		PlayerEnter((ncPlayer)eActivator);
		ncPlayer theActivator = (ncPlayer)eActivator;
		Client_FixAngle(theActivator, angles);
		m_vecPlayerPos = [0,0,0];
	}
	m_flUseTime = time + 2.0f;
}

void
ncVehicleSeat::Respawn(void)
{
	super::Respawn();

	SetMovetype(MOVETYPE_NONE);
	SetSolid(SOLID_BBOX);
	SetOrigin(GetSpawnVector("origin"));
	SetAngles(GetSpawnVector("angles"));
	SetModel(GetSpawnString("model"));

	m_vecSeatOffest = GetSpawnVector("seatOffset");

	PlayerUse = OnPlayerUse;
	setsize( this, GetSpawnVector("mins"), GetSpawnVector("maxs"));

	if (m_eDriver)
		PlayerLeave((ncPlayer)m_eDriver);

	SendFlags = -1;
}
#endif

#ifdef CLIENT
void
ncVehicleSeat::ReceiveEntity(float flNew, float flSendFlags)
{
	if (flSendFlags & VEHFL_DRIVER) {
		driver_entnum = readentitynum();
		DriverRelink();
	}

	if (flSendFlags & VEHFL_MODELINDEX) {
		entityDefID = readint();
		EntityDef_SetFromEntNum(this, entityDefID);
		modelindex = readshort();
		m_vecSeatOffest[0] = readfloat();
		m_vecSeatOffest[1] = readfloat();
		m_vecSeatOffest[2] = readfloat();
		setsize( this, [-50,-50,0], [50,50,64]);

		m_firstPersonOrg = GetSpawnVector("firstPersonOffset");
	}


	if (flSendFlags & VEHFL_ORIGIN) {
		origin[0] = readcoord();
		origin[1] = readcoord();
		origin[2] = readcoord();
		setorigin(this, origin);
	}

	if (flSendFlags & VEHFL_ANGLES) {
		angles[0] = readfloat();
		angles[1] = readfloat();
		angles[2] = readfloat();
	}

	if ((flSendFlags & VEHFL_ORIGIN) || (flSendFlags & VEHFL_ANGLES)) {
		makevectors(angles);
	}

	if (flSendFlags & VEHFL_VELOCITY) {
		velocity[0] = readfloat();
		velocity[1] = readfloat();
		velocity[2] = readfloat();
	}

	if (flSendFlags & VEHFL_TURNING)
		m_flTurn = readfloat();

	if (flSendFlags & VEHFL_FLAGS)
		flags = readfloat();

	if (flNew) {
		SetMovetype(MOVETYPE_NONE);
		SetSolid(SOLID_BBOX);
	}

	PredictPreFrame();
}
#endif

#ifdef SERVER
void
ncVehicleSeat::SpawnKey(string keyName, string setValue)
{
	switch (keyName) {
	default:
		super::SpawnKey(keyName, setValue);
		break;
	}
}

void
ncVehicleSeat::EvaluateEntity(void)
{

	PlayerAlign();
	//DriverRelink();

	/* while the engine is still handling physics for these, we can't
	 * predict when origin/angle might change */
	if (ATTR_CHANGED(origin))
		SetSendFlags(VEHFL_ORIGIN);

	if (ATTR_CHANGED(angles)) {
		SetSendFlags(VEHFL_ANGLES);
	}
	if (ATTR_CHANGED(modelindex))
		SetSendFlags(VEHFL_MODELINDEX);
	if (ATTR_CHANGED(velocity))
		SetSendFlags(VEHFL_VELOCITY);
	if (ATTR_CHANGED(m_flTurn))
		SetSendFlags(VEHFL_TURNING);
	if (ATTR_CHANGED(m_eDriver))
		SetSendFlags(VEHFL_DRIVER);
	if (ATTR_CHANGED(flags))
		SetSendFlags(VEHFL_FLAGS);

	SAVE_STATE(origin)
	SAVE_STATE(angles)
	SAVE_STATE(modelindex);
	SAVE_STATE(velocity)
	SAVE_STATE(m_flTurn)
	SAVE_STATE(m_eDriver)
	SAVE_STATE(flags)
}

float
ncVehicleSeat::SendEntity(entity ePVSent, float flSendFlags)
{
	WriteByte(MSG_ENTITY, ENT_VEH_SEAT);
	WriteFloat(MSG_ENTITY, flSendFlags);

	if (flSendFlags & VEHFL_DRIVER) {
		WriteEntity(MSG_ENTITY, m_eDriver);
	}

	if (flSendFlags & VEHFL_MODELINDEX) {
		WriteInt(MSG_ENTITY, entityDefID);
		WriteShort(MSG_ENTITY, modelindex);
		WriteFloat(MSG_ENTITY, m_vecSeatOffest[0]);
		WriteFloat(MSG_ENTITY, m_vecSeatOffest[1]);
		WriteFloat(MSG_ENTITY, m_vecSeatOffest[2]);
	}

	if (flSendFlags & VEHFL_ORIGIN) {
		WriteCoord(MSG_ENTITY, origin[0]);
		WriteCoord(MSG_ENTITY, origin[1]);
		WriteCoord(MSG_ENTITY, origin[2]);
	}

	if (flSendFlags & VEHFL_ANGLES) {
		WriteFloat(MSG_ENTITY, angles[0]);
		WriteFloat(MSG_ENTITY, angles[1]);
		WriteFloat(MSG_ENTITY, angles[2]);
	}

	if (flSendFlags & VEHFL_VELOCITY) {
		WriteFloat(MSG_ENTITY, velocity[0]);
		WriteFloat(MSG_ENTITY, velocity[1]);
		WriteFloat(MSG_ENTITY, velocity[2]);
	}

	if (flSendFlags & VEHFL_TURNING)
		WriteFloat(MSG_ENTITY, m_flTurn);

	if (flSendFlags & VEHFL_FLAGS)
		WriteFloat(MSG_ENTITY, flags);

	return true;
}
#endif

