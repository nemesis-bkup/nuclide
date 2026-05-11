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

//basic cube plane normals, for selection.
static nosave const vector axis[6] = {
    '-1 0 0',
    '0 -1 0',
    '0 0 -1',
    '1 0 0',
    '0 1 0',
    '0 0 1'
};
float dists[6];
int brushlist[2048];
#define MAX_FACEPOINTS 64
vector facepoints[MAX_FACEPOINTS];	//for temp usage


const vector ws_gridColor = [0.2f, 0.2f, 0.2f];
const vector ws_brushColor = [0.75f, 0.75f, 0.75f];
const float ws_gridAlpha = 1.0f;

class
vguiApp_WorldSpawn:vguiApplication
{
    void vguiApp_WorldSpawn(void);

    virtual void Spawned(void);

private:

    vguiToggleButton m_button1;
    vguiToggleButton m_button2;
    vguiToggleButton m_button3;
    vguiToggleButton m_button4;
    vguiToggleButton m_button5;
    vguiToggleButton m_button6;
    vguiToggleButton m_button7;
    vguiToggleButton m_button8;
    vguiButton m_button9;
    vguiButton m_button10;
    vguiButton m_button11;
    vguiButton m_button12;

    vgui3DView m_viewX;
    vgui3DView m_viewY;
    vgui3DView m_viewZ;
    vgui3DView m_viewPreview;

};

void
vguiApp_WorldSpawn::vguiApp_WorldSpawn(void)
{
}


void
vguiApp_WorldSpawn::WorldSpawn_Resized(void)
{

}

#define WIREFRAME_FOV 10.0f
#define WIREFRAME_ZOOM 10.0f

void
vguiApp_WorldSpawn::SetupWireframeX(void)
{
    float totalWidth = 4096.0f;
    float radFromFov = WIREFRAME_FOV * (MATH_PI / 180.0f);
    float newDistance = (totalWidth / 2.0f) / tan(radFromFov / 2.0f);
    vector camCenter = m_viewX.Get3DPos();
    vector overviewOffset = [camCenter[0], camCenter[1], newDistance];

    setproperty(VF_ORIGIN, overviewOffset);
    setproperty(VF_AFOV, WIREFRAME_FOV * (1.0/WIREFRAME_ZOOM));
}


void
vguiApp_WorldSpawn::SetupWireframeY(void)
{
    float totalWidth = 4096.0f;
    float radFromFov = WIREFRAME_FOV * (MATH_PI / 180.0f);
    float newDistance = (totalWidth / 2.0f) / tan(radFromFov / 2.0f);
    vector camCenter = m_viewY.Get3DPos();
    vector overviewOffset = [-newDistance, camCenter[1], camCenter[2]];

    setproperty(VF_ORIGIN, overviewOffset);
    setproperty(VF_AFOV, WIREFRAME_FOV * (1.0/WIREFRAME_ZOOM));
}



void
vguiApp_WorldSpawn::SetupWireframeZ(void)
{
    float totalWidth = 4096.0f;
    float radFromFov = WIREFRAME_FOV * (MATH_PI / 180.0f);
    float newDistance = (totalWidth / 2.0f) / tan(radFromFov / 2.0f);
    vector camCenter = m_viewZ.Get3DPos();
    vector overviewOffset = [camCenter[0], -newDistance, camCenter[2]];

    setproperty(VF_ORIGIN, overviewOffset);
    setproperty(VF_AFOV, WIREFRAME_FOV * (1.0/WIREFRAME_ZOOM));
}

void
vguiApp_WorldSpawn::DrawEngineBrushWireframe(int mod, int id)
{

    for(int facenum = 0;;)
    {
        int points = brush_getfacepoints(mod, id, ++facenum, &facepoints[0], facepoints.length);
        if (!points)
            break;	//end of face list, I guess

            R_BeginPolygon("chop");
        R_PolygonVertex(facepoints[0], '0 0', ws_brushColor, 1);
        for (int point = 1; point < points; point++)
        {
            R_PolygonVertex(facepoints[point], '0 0', ws_brushColor, 1);
            R_EndPolygon();
            R_PolygonVertex(facepoints[point], '0 0', ws_brushColor, 1);
        }
        R_PolygonVertex(facepoints[0], '0 0', ws_brushColor, 1);
        R_EndPolygon();
    }
};

void
vguiApp_WorldSpawn::DrawWireframeBrushes(vgui3DView targetView)
{
    //figure out the planes that we care about.
    vector org = targetView.Get3DPos();
    static vector vaxis[6];
    vector sizes = (WIREFRAME_FOV * (1.0/WIREFRAME_ZOOM));

    makevectors(targetView.Get3DAngles());
    vaxis[0] = v_right;
    vaxis[1] = v_up;
    vaxis[2] = v_forward;
    for (int i = 0; i < 3; i++)
        dists[i] = (org*vaxis[i]) + sizes[i];
    for (int i = 0; i < 3; i++)
    {
        vaxis[i+3] = -vaxis[i];
        dists[i+3] = (org*vaxis[i+3]) + sizes[i];
    }

    int numbrushes = brush_findinvolume(world.modelindex, vaxis, dists, dists.length, &brushlist[0], __NULL__, brushlist.length);

    //this can be a bit slow with lots of brushes. would be nice to batch them a bit better.
    while(numbrushes --> 0)
        DrawEngineBrushWireframe(world.modelindex, brushlist[numbrushes]);
}

void
vguiApp_WorldSpawn::DrawWireframeX(vector vert1, vector vert2, vector vert3, vector vert4)
{
    for (int x = -256; x < 256; x += 16) {
        for (int y = -256; y < 256; y += 16) {
            R_BeginPolygon("");
            R_PolygonVertex([ x + vert1[0], y + vert1[1]+ vert1[2] ], '0 0', ws_gridColor, ws_gridAlpha);
            R_PolygonVertex([ x + vert2[0], y + vert2[1]+ vert2[2] ], '1 0', ws_gridColor, ws_gridAlpha);
            R_EndPolygon();

            R_BeginPolygon("");
            R_PolygonVertex([ x + vert2[0], y + vert2[1]+ vert2[2] ], '1 0', ws_gridColor, ws_gridAlpha);
            R_PolygonVertex([ x + vert3[0], y + vert3[1]+ vert3[2] ], '1 1', ws_gridColor, ws_gridAlpha);
            R_EndPolygon();

            R_BeginPolygon("");
            R_PolygonVertex([ x + vert3[0], y + vert3[1]+ vert3[2] ], '1 1', ws_gridColor, ws_gridAlpha);
            R_PolygonVertex([ x + vert4[0], y + vert4[1]+ vert4[2] ], '0 1', ws_gridColor, ws_gridAlpha);
            R_EndPolygon();

            R_BeginPolygon("");
            R_PolygonVertex([ x + vert4[0], y + vert4[1]+ vert4[2] ], '0 1', ws_gridColor, ws_gridAlpha);
            R_PolygonVertex([ x + vert1[0], y + vert1[1]+ vert1[2] ], '0 0', ws_gridColor, ws_gridAlpha);
            R_EndPolygon();
        }
    }

    DrawWireframeBrushes(m_viewX);
}


void
vguiApp_WorldSpawn::DrawWireframeY(vector vert1, vector vert2, vector vert3, vector vert4)
{

    for (int x = -256; x < 256; x += 16) {
        for (int y = -256; y < 256; y += 16) {
            R_BeginPolygon("");
            R_PolygonVertex([ vert1[0], x + vert1[1], y + vert1[2] ], '0 0', ws_gridColor,ws_gridAlpha);
            R_PolygonVertex([ vert2[0], x + vert2[1], y + vert2[2] ], '1 0', ws_gridColor,ws_gridAlpha);
            R_EndPolygon();

            R_BeginPolygon("");
            R_PolygonVertex([ vert2[0], x + vert2[1], y + vert2[2] ], '1 0', ws_gridColor,ws_gridAlpha);
            R_PolygonVertex([ vert3[0], x + vert3[1], y + vert3[2] ], '1 1', ws_gridColor,ws_gridAlpha);
            R_EndPolygon();

            R_BeginPolygon("");
            R_PolygonVertex([ vert3[0], x + vert3[1], y + vert3[2] ], '1 1', ws_gridColor,ws_gridAlpha);
            R_PolygonVertex([ vert4[0], x + vert4[1], y + vert4[2] ], '0 1', ws_gridColor,ws_gridAlpha);
            R_EndPolygon();

            R_BeginPolygon("");
            R_PolygonVertex([ vert4[0], x + vert4[1], y + vert4[2] ], '0 1', ws_gridColor,ws_gridAlpha);
            R_PolygonVertex([ vert1[0], x + vert1[1], y + vert1[2] ], '0 0', ws_gridColor,ws_gridAlpha);
            R_EndPolygon();
        }
    }

    DrawWireframeBrushes(m_viewY);
}

void
vguiApp_WorldSpawn::DrawWireframeZ(vector vert1, vector vert2, vector vert3, vector vert4)
{

    for (int x = -256; x < 256; x += 16) {
        for (int y = -256; y < 256; y += 16) {
            R_BeginPolygon("");
            R_PolygonVertex([ x + vert1[0], vert1[1], y + vert1[2] ], '0 0', ws_gridColor, ws_gridAlpha);
            R_PolygonVertex([ x + vert2[0], vert2[1], y + vert2[2] ], '1 0', ws_gridColor, ws_gridAlpha);
            R_EndPolygon();

            R_BeginPolygon("");
            R_PolygonVertex([ x + vert2[0], vert2[1], y + vert2[2] ], '1 0', ws_gridColor, ws_gridAlpha);
            R_PolygonVertex([ x + vert3[0], vert3[1], y + vert3[2] ], '1 1', ws_gridColor, ws_gridAlpha);
            R_EndPolygon();

            R_BeginPolygon("");
            R_PolygonVertex([ x + vert3[0], vert3[1], y + vert3[2] ], '1 1', ws_gridColor, ws_gridAlpha);
            R_PolygonVertex([ x + vert4[0], vert4[1], y + vert4[2] ], '0 1', ws_gridColor, ws_gridAlpha);
            R_EndPolygon();

            R_BeginPolygon("");
            R_PolygonVertex([ x + vert4[0], vert4[1], y + vert4[2] ], '0 1', ws_gridColor, ws_gridAlpha);
            R_PolygonVertex([ x + vert1[0], vert1[1], y + vert1[2] ], '0 0', ws_gridColor, ws_gridAlpha);
            R_EndPolygon();
        }
    }

    DrawWireframeBrushes(m_viewZ);
}

void
vguiApp_WorldSpawn::DrawX(void)
{
    vector vert1, vert2, vert3, vert4;
    vector zPos = m_viewX.Get3DPos();
    vector zAng = m_viewX.Get3DAngles();

    makevectors(zAng);
    vert1 = zPos + (v_up * 16.0f);
    vert2 = zPos + [0, 0];
    vert3 = zPos + (v_right * 16.0f);
    vert4 = zPos + (v_up * 16.0f) + (v_right * 16.0f);

    SetupWireframeX();
    DrawWireframeX(vert1, vert2, vert3, vert4);
    drawcone(pSeat->m_ePlayer.origin, pSeat->m_ePlayer.angles, 6, 32, 16.0f, [0,1,0], 1.0f);
}

void
vguiApp_WorldSpawn::DrawY(void)
{
    vector vert1, vert2, vert3, vert4;
    vector zPos = m_viewY.Get3DPos();
    vector zAng = m_viewY.Get3DAngles();

    makevectors(zAng);
    vert1 = zPos + (v_up * 16.0f);
    vert2 = zPos + [0, 0];
    vert3 = zPos + (v_right * 16.0f);
    vert4 = zPos + (v_up * 16.0f) + (v_right * 16.0f);

    SetupWireframeY();
    DrawWireframeY(vert1, vert2, vert3, vert4);
    drawcone(pSeat->m_ePlayer.origin, pSeat->m_ePlayer.angles, 6, 32, 16.0f, [0,1,0], 1.0f);
}

void
vguiApp_WorldSpawn::DrawZ(void)
{
    vector vert1, vert2, vert3, vert4;
    vector zPos = m_viewZ.Get3DPos();
    vector zAng = m_viewZ.Get3DAngles();

    makevectors(zAng);
    vert1 = zPos + (v_up * 16.0f);
    vert2 = zPos + [0, 0];
    vert3 = zPos + (v_right * 16.0f);
    vert4 = zPos + (v_up * 16.0f) + (v_right * 16.0f);

    SetupWireframeZ();
    DrawWireframeZ(vert1, vert2, vert3, vert4);
    drawcone(pSeat->m_ePlayer.origin, pSeat->m_ePlayer.angles, 6, 32, 16.0f, [0,1,0], 1.0f);
}

void
vguiApp_WorldSpawn::Draw3DView(void)
{
    drawcone(pSeat->m_ePlayer.origin, pSeat->m_ePlayer.angles, 6, 32, 16.0f, [0,1,0], 1.0f);
    addentities(MASK_CLIENTENTITY);
}

void
vguiApp_WorldSpawn::Selection_ModeModified(void)
{
    m_button1.SetValue(0);
    m_button2.SetValue(0);
    m_button3.SetValue(0);
}

void
vguiApp_WorldSpawn::Transform_ModeModified(void)
{
    m_button4.SetValue(0);
    m_button5.SetValue(0);
    m_button6.SetValue(0);
    m_button7.SetValue(0);
    m_button8.SetValue(0);
}

void
vguiApp_WorldSpawn::Selection_ModeChanged(void)
{
}

void
vguiApp_WorldSpawn::Transform_ModeChanged(void)
{
}

bool
vguiApp_WorldSpawn::Input(float flEVType, float flKey, float flChar, float flDevID)
{

}

void
vguiApp_WorldSpawn::Spawned(void)
{
    super::Spawned();

    SetSize( [600,420] );
    SetMinSize( [600,420] );
    SetStyleMask( vguiWindowStyleDefault | vguiWindowResizeable );
    CallOnResize(WorldSpawn_Resized);

    m_button1 = spawn(vguiToggleButton);
    m_button1.SetPos([8,40]);
    m_button1.SetIcon("gfx/icon32/side_select");
    m_button1.SetPreInteractionCallback(Selection_ModeModified, this);
    m_button1.SetPostInteractionCallback(Selection_ModeChanged, this);
    m_button1.SetSize([22,22]);

    m_button2 = spawn(vguiToggleButton);
    m_button2.SetPos(m_button1.GetPos() + [0, 22]);
    m_button2.SetIcon("gfx/icon32/side_selectface");
    m_button2.SetPreInteractionCallback(Selection_ModeModified, this);
    m_button2.SetPostInteractionCallback(Selection_ModeChanged, this);
    m_button2.SetSize([22,22]);

    m_button3 = spawn(vguiToggleButton);
    m_button3.SetPos(m_button2.GetPos() + [0, 22]);
    m_button3.SetIcon("gfx/icon32/side_selectwhole");
    m_button3.SetPreInteractionCallback(Selection_ModeModified, this);
    m_button3.SetPostInteractionCallback(Selection_ModeChanged, this);
    m_button3.SetSize([22,22]);

    m_button4 = spawn(vguiToggleButton);
    m_button4.SetPos(m_button3.GetPos() + [0, 28]);
    m_button4.SetIcon("gfx/icon32/side_resize");
    m_button4.SetPreInteractionCallback(Transform_ModeModified, this);
    m_button4.SetPostInteractionCallback(Transform_ModeChanged, this);
    m_button4.SetSize([22,22]);

    m_button5 = spawn(vguiToggleButton);
    m_button5.SetPos(m_button4.GetPos() + [0, 22]);
    m_button5.SetIcon("gfx/icon32/side_move");
    m_button5.SetPreInteractionCallback(Transform_ModeModified, this);
    m_button5.SetPostInteractionCallback(Transform_ModeChanged, this);
    m_button5.SetSize([22,22]);

    m_button6 = spawn(vguiToggleButton);
    m_button6.SetPos(m_button5.GetPos() + [0, 22]);
    m_button6.SetIcon("gfx/icon32/side_rotate");
    m_button6.SetPreInteractionCallback(Transform_ModeModified, this);
    m_button6.SetPostInteractionCallback(Transform_ModeChanged, this);
    m_button6.SetSize([22,22]);

    m_button7 = spawn(vguiToggleButton);
    m_button7.SetPos(m_button6.GetPos() + [0, 22]);
    m_button7.SetIcon("gfx/icon32/side_scale");
    m_button7.SetPreInteractionCallback(Transform_ModeModified, this);
    m_button7.SetPostInteractionCallback(Transform_ModeChanged, this);
    m_button7.SetSize([22,22]);

    m_button8 = spawn(vguiToggleButton);
    m_button8.SetPos(m_button7.GetPos() + [0, 22]);
    m_button8.SetIcon("gfx/icon32/side_cut");
    m_button8.SetPreInteractionCallback(Transform_ModeModified, this);
    m_button8.SetPostInteractionCallback(Transform_ModeChanged, this);
    m_button8.SetSize([22,22]);

    m_button9 = spawn(vguiButton);
    m_button9.SetPos(m_button8.GetPos() + [0, 28]);
    m_button9.SetIcon("gfx/icon32/side_tex");
    m_button9.SetSize([22,22]);

    m_button10 = spawn(vguiButton);
    m_button10.SetPos(m_button9.GetPos() + [0, 22]);
    m_button10.SetIcon("gfx/icon32/side_entspec");
    m_button10.SetSize([22,22]);

    m_button11 = spawn(vguiButton);
    m_button11.SetPos(m_button10.GetPos() + [0, 22]);
    m_button11.SetIcon("gfx/icon32/side_surfspec");
    m_button11.SetSize([22,22]);

    m_button12 = spawn(vguiButton);
    m_button12.SetPos(m_button11.GetPos() + [0, 22]);
    m_button12.SetIcon("gfx/icon32/side_patchspec");
    m_button12.SetSize([22,22]);

    m_viewPreview = spawn(vgui3DView);
    m_viewPreview.SetSize([268,184]);
    m_viewPreview.SetPos([40,40]);
    m_viewPreview.SetDrawFuncWithDelegate(Draw3DView, this);
    m_viewPreview.DrawWorld(true);

    m_viewX = spawn(vgui3DView);
    m_viewX.SetSize([268,184]);
    m_viewX.SetPos([316,40]);
    m_viewX.SetDrawFuncWithDelegate(DrawX, this);
    m_viewX.Set3DAngles([90, 0, 0]);
    m_viewX.DrawClear(true);

    m_viewY = spawn(vgui3DView);
    m_viewY.SetSize([268,184]);
    m_viewY.SetPos([40,232]);
    m_viewY.SetDrawFuncWithDelegate(DrawY, this);
    m_viewY.Set3DAngles([0, 0, 0]);
    m_viewY.DrawClear(true);

    m_viewZ = spawn(vgui3DView);
    m_viewZ.SetSize([268,184]);
    m_viewZ.SetPos([316,232]);
    m_viewZ.SetDrawFuncWithDelegate(DrawZ, this);
    m_viewZ.Set3DAngles([0, 90, 0]);
    m_viewZ.DrawClear(true);

    /* default states */
    m_button1.SetValue(1);
    m_button4.SetValue(1);

    Add( m_button1 );
    Add( m_button2 );
    Add( m_button3 );
    Add( m_button4 );
    Add( m_button5 );
    Add( m_button6 );
    Add( m_button7 );
    Add( m_button8 );
    Add( m_button9 );
    Add( m_button10 );
    Add( m_button11 );
    Add( m_button12 );
    Add( m_viewPreview );
    Add( m_viewX );
    Add( m_viewY );
    Add( m_viewZ );
    WorldSpawn_Resized();
}
