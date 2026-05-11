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

class
ncAnimationSkeleton:ncEntity
{
    void ncAnimationSkeleton(void);

    nonvirtual ncAnimationSkeleton SkeletonForFile(string fileName);
    nonvirtual float SkeletonindexForModelindex(float modelIndex);
    nonvirtual float SkeletonindexForEntity(entity);
    virtual void OnRemoveEntity(void);

private:
    string m_inputFile;
    float m_skeletonObject;
    float m_modelIndex;
    entity m_targetEntity;
    float m_targetEntityNum;
};

void
ncAnimationSkeleton::ncAnimationSkeleton(void)
{
    m_inputFile = __NULL__;
    m_modelIndex = 0;
    m_skeletonObject = 0;
    m_targetEntity = __NULL__;
    m_targetEntityNum = 0;
}
