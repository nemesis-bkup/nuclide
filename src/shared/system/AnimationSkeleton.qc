/*
 * Copyright (c) 2026 Vera Visions LLC.
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
ncAnimationSkeleton::OnRemoveEntity(void)
{
	if (m_skeletonObject) {
		skel_delete(m_skeletonObject);
		m_skeletonObject = 0;
	}
}

ncAnimationSkeleton
ncAnimationSkeleton::SkeletonForFile(string skeletonFile)
{
	float modelIndex = getmodelindex(skeletonFile, false);

	if (!modelIndex) {
		return (__NULL__);
	}

    for (ncAnimationSkeleton vars = __NULL__;(vars = (ncAnimationSkeleton)find(vars, ::classname, "ncAnimationSkeleton"));) {
		if (vars.m_inputFile == skeletonFile && vars.m_targetEntity == __NULL__) {
            return (vars);
        }
	}

	ncAnimationSkeleton newVars = spawn(ncAnimationSkeleton);
    newVars.m_inputFile = skeletonFile;
    newVars.m_modelIndex = modelIndex;
    newVars.m_skeletonObject = skel_create(modelIndex, false);
	newVars.m_targetEntity = __NULL__;
#ifdef CLIENT
	newVars.m_targetEntityNum = 0;
	newVars.drawmask = 0;
#endif
	ncError("Creating skeletonindex %d for (%d) %S", newVars.m_skeletonObject, modelIndex, skeletonFile);
    return (newVars);
}

float
ncAnimationSkeleton::SkeletonindexForEntity(entity targetEntity)
{
	if (!targetEntity) {
		return 0;
	}

	if (!targetEntity.modelindex) {
		return 0;
	}

    for (ncAnimationSkeleton vars = __NULL__;(vars = (ncAnimationSkeleton)find(vars, ::classname, "ncAnimationSkeleton"));) {
#ifdef CLIENT
		if (vars.m_targetEntityNum == targetEntity.entnum) {
#endif
#ifdef SERVER
		if (vars.m_targetEntity == targetEntity) {
#endif
			/* has the modelindex changed, perhaps? */
			if (vars.m_modelIndex != targetEntity.modelindex) {
				if (vars.m_skeletonObject) {
					skel_delete(vars.m_skeletonObject);
				}
				vars.m_inputFile = modelnameforindex(targetEntity.modelindex);
				vars.m_modelIndex = targetEntity.modelindex;
				vars.m_skeletonObject = skel_create(vars.m_modelIndex, false);
			}

#ifdef CLIENT
			vars.m_targetEntityNum = targetEntity.entnum;
			vars.m_targetEntity = targetEntity;
#endif
            return (vars.m_skeletonObject);
        }
	}

	ncAnimationSkeleton newVars = spawn(ncAnimationSkeleton);
    newVars.m_inputFile = modelnameforindex(targetEntity.modelindex);
    newVars.m_modelIndex = targetEntity.modelindex;
    newVars.m_skeletonObject = skel_create(newVars.m_modelIndex, false);
	newVars.m_targetEntity = targetEntity;

#ifdef CLIENT
	newVars.drawmask = 0;
	newVars.m_targetEntityNum = targetEntity.entnum;
	ncError("Creating skeletonindex %d for %d", newVars.m_skeletonObject, targetEntity.entnum);
#else
	ncError("Creating skeletonindex %d for %d", newVars.m_skeletonObject, num_for_edict(targetEntity));
#endif
    return (newVars.m_skeletonObject);
}

float
ncAnimationSkeleton::SkeletonindexForModelindex(float modelIndex)
{
	ncAnimationSkeleton newVars = SkeletonForFile(modelnameforindex(modelIndex));
    return (newVars.m_skeletonObject);
}
