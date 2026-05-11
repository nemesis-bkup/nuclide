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

noref .vector origin;
noref .vector angles;
noref .vector mins;
noref .vector maxs;
noref .string model;
noref .float frame, frame2, lerpfrac, renderflags, frame1time;

.void(void) tmpvgui3DView1;
.vguiWidget tmpvgui3DViewDelegate1;
.float(float,float,float,float) tmpvgui3DView2;
.vguiWidget tmpvgui3DViewDelegate2;

/** VGUI Widget: 3D View

@ingroup vgui
*/
class vgui3DView:vguiWidget
{
public:
    void vgui3DView(void);

    /** Return the 3D-space position our camera within the 3D view is located at. */
    nonvirtual vector Get3DPos(void);
    /** Return the angle that the camera within the 3D view is aiming at. */
    nonvirtual vector Get3DAngles(void);
    /** Sets the position of the camera within the 3D-space. */
    nonvirtual void Set3DPos(vector);
    /** Sets the angle of the camera within the 3D-space. */
    nonvirtual void Set3DAngles(vector);
    /** Sets the function to call in order to draw the scene. */
    nonvirtual void SetDrawFunc(void(void));
    /** Sets the function to call for when input events happen within the 3D view. */
    nonvirtual void SetInputFunc(float(float, float, float, float));
    nonvirtual void SetDrawFuncWithDelegate(void(void), vguiControl);
    /** Sets the function to call for when input events happen within the 3D view. */
    nonvirtual void SetInputFuncWithDelegate(float(float, float, float, float), vguiControl);

    nonvirtual void SetAngularFieldOfView(float angularFov);
    nonvirtual void DrawWorld(bool newSetting);
    nonvirtual void DrawClear(bool newSetting);

    /* overrides */
    virtual void Draw(void);
    virtual bool Input(float, float, float, float);
    virtual void Spawned(void);

private:
    vector m_vec3DPos;
    vector m_vec3DAngles;
    float m_flFOV;
    bool m_drawWorld;
    bool m_drawClear;
    vector m_clearColor;
};

void
vgui3DView::vgui3DView(void)
{
    m_drawWorld = false;
    m_drawClear = false;
    m_flFOV = 90;
    m_vec3DPos = m_vec3DAngles = [0,0,0];
}

void
vgui3DView::DrawWorld(bool newSetting)
{
    m_drawWorld = newSetting;
}

void
vgui3DView::DrawClear(bool newSetting)
{
    m_drawClear = newSetting;
}


void
vgui3DView::Spawned(void)
{
    SetSize([64,64]);
}

void
vgui3DView::SetAngularFieldOfView(float angularFov)
{
    m_flFOV = angularFov;
}

void
vgui3DView::Set3DAngles(vector vecAngles)
{
    m_vec3DAngles = vecAngles;
}

vector
vgui3DView::Get3DAngles(void)
{
    return m_vec3DAngles;
}

void
vgui3DView::Set3DPos(vector vecPos)
{
    m_vec3DPos = vecPos;
}

vector
vgui3DView::Get3DPos(void)
{
    return m_vec3DPos;
}

void
vgui3DView::SetDrawFunc(void(void) vFunc)
{
    tmpvgui3DView1 = vFunc;
}

void
vgui3DView::SetInputFunc(float(float, float, float, float) vFunc)
{
    tmpvgui3DView2 = vFunc;
}

void
vgui3DView::SetDrawFuncWithDelegate(void(void) vFunc, vguiControl delegateWidget)
{
    tmpvgui3DView1 = vFunc;
    tmpvgui3DViewDelegate1 = delegateWidget;
}

void
vgui3DView::SetInputFuncWithDelegate(float(float, float, float, float) vFunc, vguiControl delegateWidget)
{
    tmpvgui3DView2 = vFunc;
    tmpvgui3DViewDelegate2 = delegateWidget;
}

static float
vgui3DView_CallInputFunctionWithDelegateSender(float(float, float, float, float) targetFunc, vguiWidget delegateWidget, vguiControl sender, float flEVType, float flKey, float flChar, float flDevID)
{
    entity oldSelf = self;
    float returnValue = 0;

    if (delegateWidget) {
        self = delegateWidget;
    }

    if (targetFunc) {
        returnValue = targetFunc(flEVType, flKey, flChar, flDevID);
    }

    self = oldSelf;
    return (returnValue);
}

void
vgui3DView::Draw(void)
{
    vector pos = GetAbsPos();

    if (!tmpvgui3DView1) {
        return;
    }

    clearscene();
    setproperty(VF_VIEWPORT, pos, m_vecSize);
    setproperty(VF_AFOV, m_flFOV);
    setproperty(VF_ORIGIN, m_vec3DPos);
    setproperty(VF_ANGLES, m_vec3DAngles);
#ifndef MENU
    setproperty(VF_DRAWWORLD, m_drawWorld);
#endif

    if (m_drawClear) {
        drawfill(pos, m_vecSize, m_clearColor, 1.0f, DRAWFLAG_NORMAL);
    }

    vguiControl_CallFunctionWithDelegateSender(tmpvgui3DView1, tmpvgui3DViewDelegate1 ? tmpvgui3DViewDelegate1 : m_parent, this);
    renderscene();
}

bool
vgui3DView::Input(float flEVType, float flKey, float flChar, float flDevID)
{
    if (!tmpvgui3DView2) {
        return false;
    }

    return vgui3DView_CallInputFunctionWithDelegateSender(tmpvgui3DView2, tmpvgui3DViewDelegate1 ? tmpvgui3DViewDelegate1 : m_parent, this, flEVType, flKey, flChar, flDevID);
}
