/*
 * Copyright (c) 2016-2024 Vera Visions LLC.
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

var bool autocvar_vehicle_developer = false;
void
_ncVehicle_Log(string className, string functionName, float edictNum, string warnMessage)
{
	if (autocvar_g_logTimestamps)
		printf("^9%f ^2%s (%d) ^7: %s\n", time, functionName, edictNum, warnMessage);
	else
		printf("^2%s (%d) ^7: %s\n", functionName, edictNum, warnMessage);
}
#define ncVehicle_Log(...) if (autocvar_vehicle_developer == true) _ncVehicle_Log(classname, __FUNC__, num_for_edict(this), sprintf(__VA_ARGS__))

/** This entity class represents vehicles that are predicted across the network.

@ingroup baseclass
*/
class ncVehicle:ncSurfacePropEntity
{
public:
	void ncVehicle(void);

#ifdef CLIENT
	virtual void DriverRelink(void);
	virtual bool IsLocalDriver(void);
	virtual void PredictPreFrame(void);
	virtual void PredictPostFrame(void);
	virtual void ReceiveEntity(float,float);
	virtual void UpdateView(void);
	virtual bool HideViewWeapon(void);
	virtual bool HideCrosshair(void);
	virtual bool HidePlayermodel(void);
#endif

#ifdef SERVER
	nonvirtual vector GetExitPos(void);
	virtual void EvaluateEntity(void);
	virtual float SendEntity(entity,float);
	virtual void Save(float);
	virtual void Restore(string,string);
	virtual void Input(entity eAct, string strInput, string strData);
#endif

	nonvirtual entity GetDriver(void);
	virtual void PlayerUpdateFlags(void);
	virtual void PlayerAlign(void);
	virtual void PlayerEnter(ncPlayer);
	virtual void PlayerLeave(ncPlayer);
	virtual void PlayerInput(void);
	virtual float DriverAnimation(void);
	
	virtual bool CanDriverCrouch(void);
	virtual bool PreventPlayerMovement(void);
	virtual bool PreventPlayerFire(void);

private:
	int m_iVehicleFlags;
	int m_iMoveButtons;
	vector m_vecMoveValues;
	ncEntity m_eDriver;
	ncEntity m_eDriver_net;
	ncEntity m_eDriverLast;
	vector m_vecPlayerPos;
	vector m_vecExitPos;

	/* FIXME: Aren't those already defined in parent classes? */
	NETWORKED_VECTOR_N(angles)
	NETWORKED_VECTOR_N(origin)
	NETWORKED_VECTOR_N(velocity)

#ifdef CLIENT
	NETWORKED_FLOAT(driver_entnum)
#endif
};

enumflags
{
	VEHFL_CHANGED_ORIGIN,
	VEHFL_CHANGED_ANGLES,
	VEHFL_CHANGED_MODELINDEX,
	VEHFL_CHANGED_SOLID,
	VEHFL_CHANGED_MOVETYPE,
	VEHFL_CHANGED_SIZE,
	VEHFL_CHANGED_VELOCITY,
	VEHFL_CHANGED_DRIVER
};

enumflags
{
	VHF_FROZEN,
	VHF_NOATTACK
};

/*! \brief Shared-Entity: Model Based Vehicle */
/*!QUAKED ncSeat (1 0 0) (-50 -50 0) (50 50 70)
# OVERVIEW
Point entity defining a 4-wheel vehicle that you can drive.

# KEYS
- "targetname" : Name

# SPAWNFLAGS

None currently.

# NOTES

None currently.

# TRIVIA
This entity was introduced in Half-Life 2 (2004).

@ingroup sharedentity
@ingroup pointentity
*/
class ncVehicleSeat:ncVehicle
{
private:
	/* map-entity fields */
	vector m_vecSeatOffest;

	vector m_vecControlMins;
	vector m_vecControlMaxs;

	float m_flUseTime;
	NETWORKED_VECTOR(vehicleOrigin)
	NETWORKED_VECTOR(vehicleAngles)
    NETWORKED_FLOAT(m_flTurn)
	vector m_firstPersonOrg;

#ifdef SERVER
	vector entryPosition;
#endif

public:
	void ncVehicleSeat(void);

	virtual void Physics(void);
	virtual void PlayerInput(void);
	virtual void OnRemoveEntity(void);


#ifdef CLIENT
	virtual bool HideViewWeapon(void);
	virtual void PredictPreFrame(void);
	virtual void PredictPostFrame(void);
	virtual void ReceiveEntity(float,float);
	virtual void UpdateView(void);
#endif

#ifdef SERVER
	virtual void Respawn(void);
	virtual void OnPlayerUse(void);
	virtual void EvaluateEntity(void);
	virtual float SendEntity(entity,float);
	virtual void SpawnKey(string keyName, string setValue);
#endif
};
