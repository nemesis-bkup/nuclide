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

ncAnimationSkeleton
ncAnimationSkeleton::SkeletonForFile(string skeletonFile)
{
    for (ncAnimationSkeleton vars = __NULL__;(vars = (ncAnimationSkeleton)find(vars, ::classname, "ncAnimationSkeleton"));) {
		if (vars.m_inputFile == skeletonFile) {
            return (vars);
        }
	}

	ncAnimationSkeleton newVars = spawn(ncAnimationSkeleton);
    newVars.m_inputFile = skeletonFile;
    newVars.m_modelIndex = getmodelindex(skeletonFile, false);
    newVars.m_skeletonObject = skel_create(newVars.m_modelIndex, false);
	ncError("Creating skeletonindex %d for %S", newVars.m_skeletonObject, skeletonFile);
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
#ifdef CLIENT
				vars.m_targetEntityNum = targetEntity.entnum;
#endif
			}
            return (vars.m_skeletonObject);
        }
	}

	ncAnimationSkeleton newVars = spawn(ncAnimationSkeleton);
    newVars.m_inputFile = modelnameforindex(targetEntity.modelindex);
    newVars.m_modelIndex = targetEntity.modelindex;
    newVars.m_skeletonObject = skel_create(newVars.m_modelIndex, false);
	newVars.m_targetEntity = targetEntity;
#ifdef CLIENT
	newVars.m_targetEntityNum = targetEntity.entnum;
#endif
	ncError("Creating skeletonindex %d for %d", newVars.m_skeletonObject, num_for_edict(targetEntity));
    return (newVars.m_skeletonObject);
}

float
ncAnimationSkeleton::SkeletonindexForModelindex(float modelIndex)
{
	ncAnimationSkeleton newVars = SkeletonForFile(modelnameforindex(modelIndex));
    return (newVars.m_skeletonObject);
}
