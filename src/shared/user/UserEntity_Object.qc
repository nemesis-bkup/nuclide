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

void
ncUserEntity_Object::ncUserEntity_Object(void)
{
	colormod = [1,1,1];
}

#ifdef SERVER
void
ncUserEntity_Object::Save(float handle)
{
	super::Save(handle);
	SaveVector(handle, "colormod", colormod);
}

void
ncUserEntity_Object::Restore(string keyName, string setValue)
{
	switch (keyName) {
	case "colormod":
		colormod = ReadVector(setValue);
		break;
	default:
		super::Restore(keyName, setValue);
		break;
	}
}

void
ncUserEntity_Object::EvaluateEntity(void)
{
	EVALUATE_VECTOR(origin, 0, BASEFL_CHANGED_ORIGIN_X)
	EVALUATE_VECTOR(origin, 1, BASEFL_CHANGED_ORIGIN_Y)
	EVALUATE_VECTOR(origin, 2, BASEFL_CHANGED_ORIGIN_Z)
	EVALUATE_VECTOR(angles, 0, BASEFL_CHANGED_ANGLES_X)
	EVALUATE_VECTOR(angles, 1, BASEFL_CHANGED_ANGLES_Y)
	EVALUATE_VECTOR(angles, 2, BASEFL_CHANGED_ANGLES_Z)
	EVALUATE_FIELD(modelindex, BASEFL_CHANGED_MODELINDEX)
	EVALUATE_FIELD(solid, BASEFL_CHANGED_SOLID)
	EVALUATE_FIELD(movetype, BASEFL_CHANGED_FLAGS)
	EVALUATE_FIELD(flags, BASEFL_CHANGED_FLAGS)
	EVALUATE_FIELD(m_nuclideFlags, BASEFL_CHANGED_FLAGS)
	EVALUATE_VECTOR(mins, 0, BASEFL_CHANGED_SIZE)
	EVALUATE_VECTOR(mins, 1, BASEFL_CHANGED_SIZE)
	EVALUATE_VECTOR(mins, 2, BASEFL_CHANGED_SIZE)
	EVALUATE_VECTOR(maxs, 0, BASEFL_CHANGED_SIZE)
	EVALUATE_VECTOR(maxs, 1, BASEFL_CHANGED_SIZE)
	EVALUATE_VECTOR(maxs, 2, BASEFL_CHANGED_SIZE)
	EVALUATE_FIELD(frame, BASEFL_CHANGED_FRAME)
	EVALUATE_FIELD(skin, BASEFL_CHANGED_SKIN)
	EVALUATE_FIELD(effects, BASEFL_CHANGED_EFFECTS)
	EVALUATE_FIELD(scale, BASEFL_CHANGED_SCALE)
	EVALUATE_VECTOR(velocity, 0, BASEFL_CHANGED_VELOCITY_X)
	EVALUATE_VECTOR(velocity, 1, BASEFL_CHANGED_VELOCITY_Y)
	EVALUATE_VECTOR(velocity, 2, BASEFL_CHANGED_VELOCITY_Z)
	EVALUATE_VECTOR(avelocity, 0, BASEFL_CHANGED_ANGULARVELOCITY)
	EVALUATE_VECTOR(avelocity, 1, BASEFL_CHANGED_ANGULARVELOCITY)
	EVALUATE_VECTOR(avelocity, 2, BASEFL_CHANGED_ANGULARVELOCITY)
}

float
ncUserEntity_Object::SendEntity(entity ePEnt, float flChanged)
{
	if (!modelindex) {
		return (0);
	}

	if (clienttype(ePEnt) != CLIENTTYPE_REAL) {
		return (0);
	}

	WriteByte(MSG_ENTITY, ENT_USEROBJECT);

	/* optimisation */
	{
		/* we'll never network these if we aren't moving. */
		if (movetype == MOVETYPE_NONE) {
			flChanged &= ~BASEFL_CHANGED_VELOCITY_X;
			flChanged &= ~BASEFL_CHANGED_VELOCITY_Y;
			flChanged &= ~BASEFL_CHANGED_VELOCITY_Z;
			flChanged &= ~BASEFL_CHANGED_ANGULARVELOCITY;
		}

		if (m_modelBrushBased == true) {
			flChanged &= ~BASEFL_CHANGED_FLAGS;
			flChanged &= ~BASEFL_CHANGED_SCALE;
		}
	}

	/* broadcast how much data is expected to be read */
	WriteFloat(MSG_ENTITY, flChanged);

	SENDENTITY_COORD(origin[0], BASEFL_CHANGED_ORIGIN_X)
	SENDENTITY_COORD(origin[1], BASEFL_CHANGED_ORIGIN_Y)
	SENDENTITY_COORD(origin[2], BASEFL_CHANGED_ORIGIN_Z)
	SENDENTITY_ANGLE(angles[0], BASEFL_CHANGED_ANGLES_X)
	SENDENTITY_ANGLE(angles[1], BASEFL_CHANGED_ANGLES_Y)
	SENDENTITY_ANGLE(angles[2], BASEFL_CHANGED_ANGLES_Z)
	SENDENTITY_SHORT(modelindex, BASEFL_CHANGED_MODELINDEX)
	SENDENTITY_BYTE(solid, BASEFL_CHANGED_SOLID)
	SENDENTITY_BYTE(movetype, BASEFL_CHANGED_FLAGS)
	SENDENTITY_INT(flags, BASEFL_CHANGED_FLAGS)
	SENDENTITY_INT(m_nuclideFlags, BASEFL_CHANGED_FLAGS)
	SENDENTITY_COORD(mins[0], BASEFL_CHANGED_SIZE)
	SENDENTITY_COORD(mins[1], BASEFL_CHANGED_SIZE)
	SENDENTITY_COORD(mins[2], BASEFL_CHANGED_SIZE)
	SENDENTITY_COORD(maxs[0], BASEFL_CHANGED_SIZE)
	SENDENTITY_COORD(maxs[1], BASEFL_CHANGED_SIZE)
	SENDENTITY_COORD(maxs[2], BASEFL_CHANGED_SIZE)
	SENDENTITY_BYTE(frame, BASEFL_CHANGED_FRAME)
	SENDENTITY_FLOAT(skin, BASEFL_CHANGED_SKIN)
	SENDENTITY_INT(effects, BASEFL_CHANGED_EFFECTS)
	SENDENTITY_FLOAT(scale, BASEFL_CHANGED_SCALE)
	SENDENTITY_COORD(velocity[0], BASEFL_CHANGED_VELOCITY_X)
	SENDENTITY_COORD(velocity[1], BASEFL_CHANGED_VELOCITY_Y)
	SENDENTITY_COORD(velocity[2], BASEFL_CHANGED_VELOCITY_Z)
	SENDENTITY_COORD(avelocity[0], BASEFL_CHANGED_ANGULARVELOCITY)
	SENDENTITY_COORD(avelocity[1], BASEFL_CHANGED_ANGULARVELOCITY)
	SENDENTITY_COORD(avelocity[2], BASEFL_CHANGED_ANGULARVELOCITY)
	SENDENTITY_COORD(colormod[0], BASEFL_CHANGED_SKIN)
	SENDENTITY_COORD(colormod[1], BASEFL_CHANGED_SKIN)
	SENDENTITY_COORD(colormod[2], BASEFL_CHANGED_SKIN)
	return (1);
}
#endif

#ifdef CLIENT

float
ncUserEntity_Object::predraw(void)
{
	addentity(this);
	return (PREDRAW_NEXT);
}

/* called whenever we are in the proximity of a surface */
void
ncUserEntity_Object::RenderScene(void)
{
}

void
ncUserEntity_Object::VideoSave_Clicked(vguiWidget sender)
{
	printf("Saved %S %S\n", m_userPosterName, m_userPictureURL);
}

void
ncUserEntity_Object::ReceiveEntity(float flNew, float flChanged)
{
	READENTITY_COORD(origin[0], BASEFL_CHANGED_ORIGIN_X)
	READENTITY_COORD(origin[1], BASEFL_CHANGED_ORIGIN_Y)
	READENTITY_COORD(origin[2], BASEFL_CHANGED_ORIGIN_Z)
	READENTITY_ANGLE(angles[0], BASEFL_CHANGED_ANGLES_X)
	READENTITY_ANGLE(angles[1], BASEFL_CHANGED_ANGLES_Y)
	READENTITY_ANGLE(angles[2], BASEFL_CHANGED_ANGLES_Z)
	READENTITY_SHORT(modelindex, BASEFL_CHANGED_MODELINDEX)
	READENTITY_BYTE(solid, BASEFL_CHANGED_SOLID)
	READENTITY_BYTE(movetype, BASEFL_CHANGED_FLAGS)
	READENTITY_INT(flags, BASEFL_CHANGED_FLAGS)
	READENTITY_INT(m_nuclideFlags, BASEFL_CHANGED_FLAGS)
	READENTITY_COORD(mins[0], BASEFL_CHANGED_SIZE)
	READENTITY_COORD(mins[1], BASEFL_CHANGED_SIZE)
	READENTITY_COORD(mins[2], BASEFL_CHANGED_SIZE)
	READENTITY_COORD(maxs[0], BASEFL_CHANGED_SIZE)
	READENTITY_COORD(maxs[1], BASEFL_CHANGED_SIZE)
	READENTITY_COORD(maxs[2], BASEFL_CHANGED_SIZE)
	READENTITY_BYTE(frame, BASEFL_CHANGED_FRAME)
	READENTITY_FLOAT(skin, BASEFL_CHANGED_SKIN)
	READENTITY_INT(effects, BASEFL_CHANGED_EFFECTS)
	READENTITY_FLOAT(scale, BASEFL_CHANGED_SCALE)
	READENTITY_COORD(velocity[0], BASEFL_CHANGED_VELOCITY_X)
	READENTITY_COORD(velocity[1], BASEFL_CHANGED_VELOCITY_Y)
	READENTITY_COORD(velocity[2], BASEFL_CHANGED_VELOCITY_Z)
	READENTITY_COORD(avelocity[0], BASEFL_CHANGED_ANGULARVELOCITY)
	READENTITY_COORD(avelocity[1], BASEFL_CHANGED_ANGULARVELOCITY)
	READENTITY_COORD(avelocity[2], BASEFL_CHANGED_ANGULARVELOCITY)
	READENTITY_COORD(colormod[0], BASEFL_CHANGED_SKIN)
	READENTITY_COORD(colormod[1], BASEFL_CHANGED_SKIN)
	READENTITY_COORD(colormod[2], BASEFL_CHANGED_SKIN)

	if (scale == 0.0f) {
		scale = 1.0f;
	}

	if (flChanged & BASEFL_CHANGED_SIZE) {
		setsize(this, mins, maxs);
	}
	if (flChanged & BASEFL_CHANGED_MODELINDEX) {
		_ModelChanged();
	}
}
#endif

#ifdef SERVER
static vector
Cmd_GetViewPoint(ncPlayer viewEnt)
{
	vector traceStart;
	vector traceEnd;

	traceStart = viewEnt.origin + viewEnt.view_ofs;
	makevectors(viewEnt.v_angle);
	traceEnd = traceStart + (v_forward * 4096);
	traceline(traceStart, traceEnd, MOVE_HITMODEL, viewEnt);
	return (trace_endpos);
}

ncUserEntity_Object
ncUserEntity_Object::Place(ncPlayer pictureSharer, string pictureName, string pictureURL, vector renderTint, float forceScale, vector newMins, vector newMaxs, string gui64, vector guiOrg, vector guiAng, float guiScale, vector guiRes)
{
	ncUserEntity_Object userPicture;
	vector src;
	vector co;
	vector forwardDir;
	vector planeNormal;
	vector endPos;

	endPos = Cmd_GetViewPoint((ncPlayer)pictureSharer);

	precache_model(pictureURL);

	/* spawn the new one */
	userPicture = spawn(ncUserEntity_Object);
	userPicture.Spawn();

	userPicture.real_owner = pictureSharer;
	userPicture.SetScale(forceScale);
	userPicture.SetModel(pictureURL);
	userPicture.targetname = sprintf("%d_%s", num_for_edict(userPicture), pictureName);
	userPicture.colormod = (renderTint);
	userPicture.SetSolid(SOLID_BBOX);
	userPicture.SetSize(newMins, newMaxs);
	userPicture.SetOrigin(endPos);

    /* there is a display attached to this object */
	if (STRING_SET(gui64) && guiScale != 0.0) {
		ncMediaSurface attachedScreen = spawn(ncMediaSurface);
        attachedScreen.Spawn();
        vector modelAngles = userPicture.GetAngles();
        vector screenAngles = modelAngles + guiAng;

        if (guiAng[2] == -1) {
            guiScale *= -1;
        }

		vector screenPosition = endPos + anglesToForward(modelAngles) * guiOrg[0];
		screenPosition += anglesToRight(modelAngles) * guiOrg[1];
		screenPosition += anglesToUp(modelAngles) * guiOrg[2];
		attachedScreen.SetOrigin(screenPosition);
		attachedScreen.SetAngles(screenAngles);
        printf("%v; %v = %v\n", modelAngles, guiAng, modelAngles + guiAng);
		attachedScreen.m_flScale = guiScale;
		attachedScreen.m_flUseDistance = 128;
		attachedScreen.m_vecUIRes = [guiRes[0],guiRes[1]];
		attachedScreen.m_vecScreenLight = [255,255,255];
		attachedScreen.m_uiSurfaceEnabled = true;
		//attachedScreen.m_vecWorldSize = guiRes * guiScale;
		attachedScreen.SetParent(userPicture.targetname);
		attachedScreen.m_gui64 = gui64;
	} else if (STRING_SET(gui64) && guiScale == 0.0) {
		ncMediaSource attachedSource = spawn(ncMediaSource);
        attachedSource.modelindex = 1;
        attachedSource.Spawn();
        attachedSource.modelindex = 1;
		attachedSource.SetOrigin(userPicture.GetOrigin());
		attachedSource.SetAngles(userPicture.GetAngles());
		attachedSource.m_mediaSize = [guiRes[0],guiRes[1]];
		attachedSource.SetParent(userPicture.targetname);
		attachedSource.m_gui64 = gui64;
        attachedSource.targetname = strcat(userPicture.targetname, "_source");
        attachedSource.SendFlags = -1;
        attachedSource.SetSize(newMins, newMaxs);
	}
	userPicture.SetOriginUnstick(endPos);

    return (userPicture);
}
#endif
