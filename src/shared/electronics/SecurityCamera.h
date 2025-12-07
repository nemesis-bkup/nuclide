typedef enum
{
	CAMSWEEP_IDLE,
	CAMSWEEP_RIGHT,
	CAMSWEEP_RIGHT_WAIT,
	CAMSWEEP_LEFT,
	CAMSWEEP_LEFT_WAIT,
	CAMSWEEP_ALERTED,
	CAMSWEEP_RETURN
} camsweepstate_t;

/*!QUAKED ncSecurityCamera (1 0 0) (-8 -8 -8) (8 8 8)

# OVERVIEW
A security camera entity. It can have a model, sweep around and be damaged.
It can also alert enemies in the area.

# KEYS
- "targetname" : Name used to identify entities.
- "target" : Target to look at.
- "health" : Health of the camera. If above 0, can be shot and destroyed.
- "scanDist" : Distance at which the camera is able to see.
- "scanFov" : Field of view at which the camera is able to see.
- "sightResume" : Time to stop scanning for a player (but before activation trigger)
- "sightTime" : How long it takes for this camera to notice a player.
- "sweepAngle" : Angles to sweep over, in euler units.
- "sweepSpeed" : Speed at which to sweep, in euler units per second.
- "sweepWait" : Delay at which we switch directions, after having reached the end of a sweep.
- "wait" : Alert hold/resume time.

# OUTPUTS
- "OnFoundPlayer" : Called when the player has been spotted.

*/
class
ncSecurityCamera:ncActor
{
	void ncSecurityCamera(void);

#ifdef SERVER
	virtual void Spawned(void);
	virtual void Respawn(void);
	virtual void SpawnKey(string, string);
	virtual void EvaluateEntity(void);
	virtual void Death(entity inflictor, entity attacker, int damagePoints, vector dir, vector absImpactPos, int hitBody);

	nonvirtual bool SecurityCameraIsEnemy(entity);
	nonvirtual bool SecurityCameraCheck(ncActor toCheck);
	nonvirtual void SecurityCameraMovement(void);
	nonvirtual void SecurityCameraVisionTick(void);
#endif

private:
	float m_securiCamScanDist;
	float m_securiCamScanFOV;
	float m_securiCamSightResume;
	float m_securiCamSightTime;
	float m_securiCamSweepAngle;
	float m_securiCamSweepSpeed;
	float m_securiCamSweepWait;
	float m_securiCamAlertResumeTime;
	string m_outputOnFoundPlayer;

	entity m_securiCamTrackingRef;
	float m_securiCamTrackingTime;
	
	float m_securiCamSweepTime;
	camsweepstate_t m_securiCamSweepState;
	float m_securiCamSpawnYaw;
	float m_securiCamSweepWaitTime;
};



