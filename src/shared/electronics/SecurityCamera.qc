
static bool
TraceAgainsTarget(ncMonster monster, ncEntity targetEntity)
{
	vector hitLocation = monster.GetOrigin();
	vector testCenter = targetEntity.GetOrigin();

	traceline(hitLocation, testCenter, MOVE_NORMAL, monster);

	if (trace_fraction == 1.0f || trace_ent == targetEntity) {
		return (true);
	}

	traceline(hitLocation, testCenter + [15.0f, 15.0f, 0.0f], MOVE_NORMAL, monster);

	if (trace_fraction == 1.0f || trace_ent == targetEntity) {
		return (true);
	}

	traceline(hitLocation, testCenter + [-15.0f, -15.0f, 0.0f], MOVE_NORMAL, monster);

	if (trace_fraction == 1.0f || trace_ent == targetEntity) {
		return (true);
	}

	traceline(hitLocation, testCenter + [-15.0f, 15.0f, 0.0f], MOVE_NORMAL, monster);

	if (trace_fraction == 1.0f || trace_ent == targetEntity) {
		return (true);
	}

	traceline(hitLocation, testCenter + [15.0f, -15.0f, 0.0f], MOVE_NORMAL, monster);

	if (trace_fraction == 1.0f || trace_ent == targetEntity) {
		return (true);
	}

	return (false);
}

void
ncSecurityCamera::ncSecurityCamera(void)
{
	m_securiCamScanDist = g_float_null;
	m_securiCamScanFOV = g_float_null;
	m_securiCamSightResume = g_float_null;
	m_securiCamSightTime = g_float_null;
	m_securiCamSweepAngle = g_float_null;
	m_securiCamSweepSpeed = g_float_null;
	m_securiCamSweepWait = g_float_null;
	m_securiCamAlertResumeTime = g_float_null;
	m_outputOnFoundPlayer = g_string_null;
}

#ifdef SERVER
void
ncSecurityCamera::SpawnKey(string keyName, string setValue)
{
	switch (keyName) {
	case "scanDist":
		m_securiCamScanDist = ReadFloat(setValue);
		break;
	case "scanFov":
		m_securiCamScanFOV = ReadFloat(setValue);
		break;
	case "sightResume":
		m_securiCamSightResume = ReadFloat(setValue);
		break;
	case "sightTime":
		m_securiCamSightTime = ReadFloat(setValue);
		break;
	case "sweepAngle":
		m_securiCamSweepAngle = ReadFloat(setValue);
		break;
	case "sweepSpeed":
		m_securiCamSweepSpeed = ReadFloat(setValue);
		break;
	case "sweepWait":
		m_securiCamSweepWait = ReadFloat(setValue);
		break;
	case "wait":
		m_securiCamAlertResumeTime = ReadFloat(setValue);
		break;
	case "OnFoundPlayer":
		m_outputOnFoundPlayer = PrepareOutput(m_outputOnFoundPlayer, setValue);
		break;
	default:
		super::SpawnKey(keyName, setValue);
	}
}

void
ncSecurityCamera::Spawned(void)
{
	super::Spawned();

	if (STRING_SET(m_outputOnFoundPlayer)) {
		m_outputOnFoundPlayer = CreateOutput(m_outputOnFoundPlayer);
	}

	m_securiCamSpawnYaw = angles[1];
}

void
ncSecurityCamera::Respawn(void)
{
	super::Respawn();
	SetHealth(GetSpawnFloat("health"));
	MakeVulnerable();
	SetSolid(SOLID_BBOX);
	SetMovetype(MOVETYPE_NONE);
}

void
ncSecurityCamera::Death(entity inflictor, entity attacker, int damagePoints, vector dir, vector absImpactPos, int hitBody)
{
	modelindex = 0;
}

void
ncSecurityCamera::EvaluateEntity(void)
{
	if (modelindex == 0) {
		return;
	}

	SecurityCameraMovement();
	SecurityCameraVisionTick();

	super::EvaluateEntity();
}

bool
ncSecurityCamera::SecurityCameraIsEnemy(entity enny)
{
	if (enny == __NULL__)
		return false;

	/* dead enny should not be considered valid */
	if ((enny.solid == SOLID_CORPSE) || (enny.health <= 0))
		return false;

	/* monsters ignore enny who uses notarget cheat, useful for development */
	if (enny.flags & FL_NOTARGET)
		return false;

	/* prevent from shooting non-sentient stuff */
	if (!(enny.flags & (FL_MONSTER | FL_CLIENT)))
		return false;

	return true;
}

bool
ncSecurityCamera::SecurityCameraCheck(ncActor toCheck)
{
	/* cheapest check */
	if (toCheck.IsVulnerable() == false) {
		return (false);
	}

	/* slightly more expensive check */
	float distanceToEnemy = distance(GetOrigin(), toCheck.GetOrigin());
	if (distanceToEnemy > m_securiCamScanDist) {
		return (false);
	}

	/* much more expensive checks */
	vector v = normalize(toCheck.origin - GetOrigin());
	float flDot = v * anglesToForward(GetAngles());

	if (flDot < (m_securiCamScanFOV / 180)) {
		return (false);
	}

	if (TraceAgainsTarget(this, toCheck) == true) {
		if (SecurityCameraIsEnemy(toCheck) == true) {
			return (true);
		}
	}

	return (false);
}

void
ncSecurityCamera::SecurityCameraMovement(void)
{
	ncEntity targetEntity = GetTargetEntity();

	if ((m_securiCamSweepState == CAMSWEEP_ALERTED) && m_securiCamTrackingRef) {
		vector oldAngles = GetAngles();
		vector oldForward = anglesToForward(oldAngles);
		TurnToPos(m_securiCamTrackingRef.origin);
		angles = vectorLerp(oldForward, anglesToForward(GetAngles()), frametime);
		angles = vectoangles(angles);
		return;
	} else if (m_securiCamSweepState == CAMSWEEP_RETURN) {
		vector oldAngles = GetAngles();
		vector oldForward = anglesToForward(oldAngles);
		vector wishAngle = oldAngles;
		wishAngle[1] = m_securiCamSpawnYaw;
		wishAngle[1] += m_securiCamSweepTime;
		vector wishForward = anglesToForward(wishAngle);

		angles = vectoangles(vectorLerp(oldForward, wishForward, frametime));

		if (vlen(oldForward - wishForward) < 0.025) {
			m_securiCamSweepState = CAMSWEEP_IDLE;
		}

		return;
	} else if (targetEntity) {
		TurnToPos(targetEntity.GetOrigin());
	} else {
		angles[1] = m_securiCamSpawnYaw;
	}

	/* pick a direction if we lack any */
	if (m_securiCamSweepState == CAMSWEEP_IDLE) {
		if (random() < 0.5) {
			m_securiCamSweepState = CAMSWEEP_LEFT;
		} else {
			m_securiCamSweepState = CAMSWEEP_RIGHT;
		}
	}

	if (m_securiCamSweepState == CAMSWEEP_LEFT) {
		m_securiCamSweepTime -= (frametime * m_securiCamSweepSpeed);

		if (m_securiCamSweepTime < -m_securiCamSweepAngle) {
			m_securiCamSweepWaitTime = m_securiCamSweepWait;
			m_securiCamSweepTime = -m_securiCamSweepAngle;
			m_securiCamSweepState = CAMSWEEP_LEFT_WAIT;
		}
	} else if (m_securiCamSweepState == CAMSWEEP_RIGHT) {
		m_securiCamSweepTime += (frametime * m_securiCamSweepSpeed);

		if (m_securiCamSweepTime > m_securiCamSweepAngle) {
			m_securiCamSweepWaitTime = m_securiCamSweepWait;
			m_securiCamSweepTime = m_securiCamSweepAngle;
			m_securiCamSweepState = CAMSWEEP_RIGHT_WAIT;
		}
	} else if (m_securiCamSweepState == CAMSWEEP_LEFT_WAIT) {
		m_securiCamSweepWaitTime -= (frametime);

		if (m_securiCamSweepWaitTime < 0.0f) {
			m_securiCamSweepState = CAMSWEEP_RIGHT;
		}
	} else if (m_securiCamSweepState == CAMSWEEP_RIGHT_WAIT) {
		m_securiCamSweepWaitTime -= (frametime);

		if (m_securiCamSweepWaitTime < 0.0f) {
			m_securiCamSweepState = CAMSWEEP_LEFT;
		}
	
	}

	angles[1] += m_securiCamSweepTime;
}

void
ncSecurityCamera::SecurityCameraVisionTick(void)
{
	/* we're already tracking somebody in vision */
	if (m_securiCamTrackingRef) {
		/* has this camera been staring long enough? */
		if (m_securiCamTrackingTime < time) {
			m_securiCamTrackingTime = time + m_securiCamAlertResumeTime;

			/* still valid? */
			if (SecurityCameraCheck(m_securiCamTrackingRef) == true) {
				UseOutput(m_securiCamTrackingRef, m_outputOnFoundPlayer);
				printf("Can see you.\n");
				m_securiCamSweepState = CAMSWEEP_ALERTED;
			} else {
				m_securiCamTrackingRef = g_entity_null;
				printf("Can't see.\n");
				
				if (m_securiCamSweepState == CAMSWEEP_ALERTED) {
					m_securiCamSweepState = CAMSWEEP_RETURN;
				}
			}
		}
		return;
	}

	for (ncEntity w = world; (w = (ncEntity)findfloat(w, ::_isActor, 1));) {
		if (SecurityCameraCheck(w)) {
			if (!m_securiCamTrackingRef) {
				m_securiCamTrackingRef = w;
				m_securiCamTrackingTime = time + m_securiCamSightTime;
			}
		}
	}
}
#endif
