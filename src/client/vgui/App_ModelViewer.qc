/*
 * Copyright (c) 2016-2026 Vera Visions LLC.
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
vguiApp_ModelViewer:vguiApplication
{
public:
    void vguiApp_ModelViewer(void);

    virtual void Launched(void);
    virtual void LaunchKey(string keyName, string setValue);
    virtual msg_result Message(string messageType, string messageData, vguiWidget sender);

private:
    entity m_loadedModelEntity;
    vector m_vecDistance;
    string m_modelSearchPath;

    /* widgets */
    vgui3DView m_viewModel;
    vguiRect m_picBackground;
    vguiButton m_btnTabRenderer;
    vguiButton m_btnTabSequence;
    vguiButton m_btnTabBody;
    vguiButton m_btnTabTexture;
    vguiList m_lstModels;
    vguiScrollBar m_scrlModels;
    vguiButton m_btnLoadModel;

    /* tab: renderer */
    vguiCheckbox m_chkBackground;
    vguiCheckbox m_chkGround;
    vguiCheckbox m_chkMirror;
    vguiButton m_btnSpawnProp;
    vguiButton m_btnSpawnDoll;
    vguiButton m_btnFirstperson;
    vguiButton m_btnResetCam;
    vguiButton m_btnSetViewModel;

    // tab: sequences */
    vguiLabel m_lblSeqFrame;
    vguiButton m_btnSeqNext;
    vguiButton m_btnSeqPrev;

    string m_modelPath;
    bool m_flyControls;
    int iMouseDrag;
    int iShiftDrag;
    vector vecDragOfs;
    vector m_movementDir;
};

void
vguiApp_ModelViewer::vguiApp_ModelViewer(void)
{
    m_loadedModelEntity = __NULL__;
    m_vecDistance = [ 90, 0, 0 ];
    m_viewModel = __NULL__;
    m_picBackground = __NULL__;
    m_btnTabRenderer = __NULL__;
    m_btnTabSequence = __NULL__;
    m_btnTabBody = __NULL__;
    m_btnTabTexture = __NULL__;
    m_lstModels = __NULL__;
    m_scrlModels = __NULL__;
    m_btnLoadModel = __NULL__;
    m_chkBackground = __NULL__;
    m_chkGround = __NULL__;
    m_chkMirror = __NULL__;
    m_btnSpawnProp = __NULL__;
    m_btnSpawnDoll = __NULL__;
    m_btnFirstperson = __NULL__;
    m_btnResetCam = __NULL__;
    m_btnSetViewModel = __NULL__;
    m_lblSeqFrame = __NULL__;
    m_btnSeqNext = __NULL__;
    m_btnSeqPrev = __NULL__;
    m_modelPath = "models/";
    m_flyControls = false;
}

void
vguiApp_ModelViewer::SetViewModel(void)
{
    if (pSeat == __NULL__) {
        return;
    }
    ncRenderableEntity theModel = (ncRenderableEntity)pSeat->m_eViewModel;
    ncRenderableEntity theModel2 = (ncRenderableEntity)pSeat->m_eViewModelL;

    if (theModel && theModel.classname == "vm") {
        theModel.modelindex = getmodelindex(m_loadedModelEntity.model);
        theModel2.modelindex =
        theModel2.modelindex2 =
        theModel2.modelindex3 =
        theModel2.modelindex4 =
        theModel.modelindex2 =
        theModel.modelindex3 =
        theModel.modelindex4 = 0;

        if (theModel) {
            theModel._UpdateBoneCount();
        }

        if (theModel2) {
            theModel2._UpdateBoneCount();
        }
    }
}

void
vguiApp_ModelViewer::Firstperson(void)
{
    m_vecDistance = [ 0, 0, 0 ];
    m_viewModel.Set3DAngles([0,0,0]);
    m_viewModel.Set3DPos([0,0,0]);
}

void
vguiApp_ModelViewer::ResetCam(void)
{
    vector modelPos = (m_loadedModelEntity.absmin + (0.5 * (m_loadedModelEntity.absmax - m_loadedModelEntity.absmin)));
    m_vecDistance = [ 90, 0, 0 ];
    m_viewModel.Set3DAngles([0,180,0]);
    m_viewModel.Set3DPos(modelPos);
    makevectors(m_viewModel.Get3DAngles());
    m_viewModel.Set3DPos(modelPos + (v_forward * -m_vecDistance[0]) + (v_right * m_vecDistance[1]) + (v_up * m_vecDistance[2]));
}

void
vguiApp_ModelViewer::SpawnProp(void)
{
    ncCommand("propSpawn %S", m_loadedModelEntity.model);
}

void
vguiApp_ModelViewer::SpawnDoll(void)
{
    ncCommand("ragdollCreate %S", m_loadedModelEntity.model);
}

void
vguiApp_ModelViewer::SetFrame(int iFrame)
{
    float maxFrame = modelframecount(m_loadedModelEntity.modelindex) - 1;
    m_loadedModelEntity.frame = (float)iFrame;

    if (m_loadedModelEntity.frame < 0) {
        m_loadedModelEntity.frame = 0;
    }

    m_lblSeqFrame.SetTitle(sprintf("Frame %d: %s", m_loadedModelEntity.frame, frametoname(m_loadedModelEntity.modelindex, m_loadedModelEntity.frame)));
    m_loadedModelEntity.frame1time = 0;
}

void
vguiApp_ModelViewer::SetFrameP(void)
{
    vguiApp_ModelViewer::SetFrame(m_loadedModelEntity.frame + 1);
}

void
vguiApp_ModelViewer::SetFrameM(void)
{
    vguiApp_ModelViewer::SetFrame(m_loadedModelEntity.frame - 1);
}

void
vguiApp_ModelViewer::SetModel(string strModel)
{
    setmodel(m_loadedModelEntity, strModel);
    SetTitle(sprintf("%s (%s)", ApplicationTitle(), strModel));
    vguiApp_ModelViewer::SetFrame(0);
    vguiApp_ModelViewer::ResetCam();
}

void
vguiApp_ModelViewer::Draw3DView (void)
{
    if (!m_loadedModelEntity) {
        m_loadedModelEntity = spawn();
        vguiApp_ModelViewer::SetModel("models/error.vvm");
    }

    addentity(m_loadedModelEntity);
    m_loadedModelEntity.frame1time += frametime;

    if (m_chkGround.GetValue() == TRUE) {
        vector vert1, vert2, vert3, vert4;
        vector wireColor = [0.8f, 0.8f, 0.9f];

        vert1 = [16,0];
        vert2 = [0, 0];
        vert3 = [0, 16];
        vert4 = [16, 16];

        for (int x = -256; x < 256; x += 16) {
            for (int y = -256; y < 256; y += 16) {
                R_BeginPolygon("");
                R_PolygonVertex([ x + vert1[0], y + vert1[1] ], '0 0', wireColor, 1.0f);
                R_PolygonVertex([ x + vert2[0], y + vert2[1] ], '1 0', wireColor, 1.0f);
                R_EndPolygon();

                R_BeginPolygon("");
                R_PolygonVertex([ x + vert2[0], y + vert2[1] ], '1 0', wireColor, 1.0f);
                R_PolygonVertex([ x + vert3[0], y + vert3[1] ], '1 1', wireColor, 1.0f);
                R_EndPolygon();

                R_BeginPolygon("");
                R_PolygonVertex([ x + vert3[0], y + vert3[1] ], '1 1', wireColor, 1.0f);
                R_PolygonVertex([ x + vert4[0], y + vert4[1] ], '0 1', wireColor, 1.0f);
                R_EndPolygon();

                R_BeginPolygon("");
                R_PolygonVertex([ x + vert4[0], y + vert4[1] ], '0 1', wireColor, 1.0f);
                R_PolygonVertex([ x + vert1[0], y + vert1[1] ], '0 0', wireColor, 1.0f);
                R_EndPolygon();
            }
        }
    }

    if (m_movementDir[0]) {
        makevectors(m_viewModel.Get3DAngles());
        vector addedOffset = (v_forward * (m_movementDir[0] * frametime));
        m_viewModel.Set3DPos(m_viewModel.Get3DPos() + addedOffset);
    }

    if (m_movementDir[1]) {
        makevectors(m_viewModel.Get3DAngles());
        vector strafeOffset = (v_right * (m_movementDir[1] * frametime));
        m_viewModel.Set3DPos(m_viewModel.Get3DPos() + strafeOffset);
    }

    if (m_chkBackground.GetValue() == TRUE) {
        m_picBackground.Show();
    } else {
        m_picBackground.Hide();
    }
}

float
vguiApp_ModelViewer::Input3DView(float flEVType, float flKey, float flChar, float flDevID)
{
    int iMouseDrag = FALSE;
    int iShiftDrag = FALSE;
    vector vecDragOfs;
    vector vecDifference;
    vector modelPos = (m_loadedModelEntity.absmin + (0.5 * (m_loadedModelEntity.absmax - m_loadedModelEntity.absmin)));

    int iMouseOver =  Util_MouseAbove(getmousepos(), m_viewModel.m_parent.GetPos() + m_viewModel.GetPos(), m_viewModel.GetSize());

    if (flEVType == IE_KEYDOWN) {
        if (flKey == K_MOUSE1 && iMouseOver == true) {
            iMouseDrag = TRUE;
            vecDragOfs = GetMousePos();
            return true;
        } else if (flKey == K_MWHEELUP && iMouseOver == true) {
            m_vecDistance[0] = bound(0, --m_vecDistance[0], 512);
            makevectors(m_viewModel.Get3DAngles());
            m_viewModel.Set3DPos(modelPos + (v_forward * -m_vecDistance[0]) + (v_right * m_vecDistance[1]) + (v_up * m_vecDistance[2]));
            return true;
        } else if (flKey == K_MWHEELDOWN && iMouseOver == true) {
            m_vecDistance[0] = bound(0, ++m_vecDistance[0], 512);
            makevectors(m_viewModel.Get3DAngles());
            m_viewModel.Set3DPos(modelPos + (v_forward * -m_vecDistance[0]) + (v_right * m_vecDistance[1]) + (v_up * m_vecDistance[2]));
            return true;
        } else if (flKey == K_LSHIFT && iMouseOver == true) {
            iShiftDrag = TRUE;
        }
    } else if (flEVType == IE_KEYUP) {
        if (flKey == K_MOUSE1) {
            iMouseDrag = FALSE;
        } else if (flKey == K_LSHIFT) {
            iShiftDrag = FALSE;
        }
    }

    if (iMouseDrag == TRUE && iShiftDrag == FALSE) {
        if (flEVType == IE_MOUSEABS) {
            vecDifference = [ flChar, flKey ] - [ vecDragOfs[1], vecDragOfs[0] ];
            m_viewModel.Set3DAngles(m_viewModel.Get3DAngles() + vecDifference);
            makevectors(m_viewModel.Get3DAngles());
            m_viewModel.Set3DPos(modelPos + (v_forward * -m_vecDistance[0]) + (v_right * m_vecDistance[1]) + (v_up * m_vecDistance[2]));
            vecDragOfs = GetMousePos();
            return true;
        }
    } else if (iMouseDrag == TRUE && iShiftDrag == TRUE) {
        if (flEVType == IE_MOUSEABS) {
            vecDifference = [ flChar, flKey ] - [ vecDragOfs[1], vecDragOfs[0] ];
            m_vecDistance[1] -= vecDifference[1];
            m_vecDistance[2] += vecDifference[0];
            makevectors(m_viewModel.Get3DAngles());
            m_viewModel.Set3DPos(modelPos + (v_forward * -m_vecDistance[0]) + (v_right * m_vecDistance[1]) + (v_up * m_vecDistance[2]));
            vecDragOfs = GetMousePos();
            return true;
        }
    }
    return false;
}

float
vguiApp_ModelViewer::Input3DView_FlyMode(float flEVType, float flKey, float flChar, float flDevID)
{
    vector vecDifference;
    vector modelPos = (m_loadedModelEntity.absmin + (0.5 * (m_loadedModelEntity.absmax - m_loadedModelEntity.absmin)));
    int iMouseOver =  Util_MouseAbove(getmousepos(), m_viewModel.m_parent.GetPos() + m_viewModel.GetPos(), m_viewModel.GetSize());

    if (flEVType == IE_KEYDOWN) {
        if (flKey == K_MOUSE1 && iMouseOver == true) {
            iMouseDrag = TRUE;
            vecDragOfs = GetMousePos();
            return true;
        } else if (flKey == K_MWHEELUP && iMouseOver == true) {
            m_vecDistance[0] = bound(0, --m_vecDistance[0], 512);
            makevectors(m_viewModel.Get3DAngles());
            m_viewModel.Set3DPos(modelPos + (v_forward * -m_vecDistance[0]) + (v_right * m_vecDistance[1]) + (v_up * m_vecDistance[2]));
            return true;
        } else if (flKey == K_MWHEELDOWN && iMouseOver == true) {
            m_vecDistance[0] = bound(0, ++m_vecDistance[0], 512);
            makevectors(m_viewModel.Get3DAngles());
            m_viewModel.Set3DPos(modelPos + (v_forward * -m_vecDistance[0]) + (v_right * m_vecDistance[1]) + (v_up * m_vecDistance[2]));
            return true;
        } else if (flKey == K_LSHIFT && iMouseOver == true) {
            iShiftDrag = TRUE;
        }
    } else if (flEVType == IE_KEYUP) {
        if (flKey == K_MOUSE1) {
            iMouseDrag = FALSE;
        } else if (flKey == K_LSHIFT) {
            iShiftDrag = FALSE;
        }
    }

    if (iMouseDrag) {
        m_movementDir = [200, 0, 0];
    } else {
        m_movementDir = [0, 0, 0];
    }

    if (iMouseDrag == TRUE && iShiftDrag == FALSE) {
        if (flEVType == IE_MOUSEABS) {
            vecDifference = [ flChar, flKey ] - [ vecDragOfs[1], vecDragOfs[0] ];
            m_viewModel.Set3DAngles(m_viewModel.Get3DAngles() + vecDifference);
            makevectors(m_viewModel.Get3DAngles());
            //m_viewModel.Set3DPos(modelPos + (v_forward * -m_vecDistance[0]) + (v_right * m_vecDistance[1]) + (v_up * m_vecDistance[2]));
            vecDragOfs = GetMousePos();
            return true;
        }
    } else if (iMouseDrag == TRUE && iShiftDrag == TRUE) {
        if (flEVType == IE_MOUSEABS) {
            vecDifference = [ flChar, flKey ] - [ vecDragOfs[1], vecDragOfs[0] ];
            m_vecDistance[1] -= vecDifference[1];
            m_vecDistance[2] += vecDifference[0];
            makevectors(m_viewModel.Get3DAngles());
            //m_viewModel.Set3DPos(modelPos + (v_forward * -m_vecDistance[0]) + (v_right * m_vecDistance[1]) + (v_up * m_vecDistance[2]));
            vecDragOfs = GetMousePos();
            return true;
        }
    }

    return false;
}

void
vguiApp_ModelViewer::Resize(void)
{
    // Resize the background and viewer
    vector vWinSize = GetSize();
    m_picBackground.SetSize([vWinSize[0] - 12 - 192, vWinSize[1] - 128 ]);
    m_viewModel.SetSize(m_picBackground.GetSize());
    m_btnTabRenderer.SetPos([ 6, vWinSize[1] - 92 ]);
    m_btnTabSequence.SetPos(m_btnTabRenderer.GetPos() + [ m_btnTabRenderer.GetWidth() + 1, 0 ]);
    m_btnTabBody.SetPos(m_btnTabSequence.GetPos() + [ m_btnTabSequence.GetWidth() + 1, 0 ]);
    m_btnTabTexture.SetPos(m_btnTabBody.GetPos() + [ m_btnTabBody.GetWidth() + 1, 0 ]);
    m_chkBackground.SetPos(m_btnTabRenderer.GetPos() + [ 0, 30 ]);
    m_chkGround.SetPos(m_btnTabRenderer.GetPos() + [ 0, 50 ]);
    m_chkMirror.SetPos(m_btnTabRenderer.GetPos() + [ 0, 70 ]);
    m_lstModels.SetPos(m_viewModel.GetPos() + [ m_viewModel.GetSize()[0], 0 ]);
    m_lstModels.SetSize([ 172, m_viewModel.GetSize()[1] ]);
    m_scrlModels.SetPos(m_lstModels.GetPos() + [ 172, 0 ]);
    m_scrlModels.SetLength(m_viewModel.GetSize()[1]);
    m_scrlModels.SetMax(m_lstModels.GetMaxVisibleItems());
    m_btnLoadModel.SetPos(m_lstModels.GetPos() + [ 0, m_lstModels.GetSize()[1] + 1 ]);
    m_btnSpawnProp.SetPos(m_btnLoadModel.GetPos() + [ 0, 30 ]);
    m_btnSetViewModel.SetPos(m_btnSpawnProp.GetPos() + [ 0, 30 ]);
    m_btnSpawnDoll.SetPos(m_btnSetViewModel.GetPos() + [ 0, 30 ]);
    m_btnFirstperson.SetPos(m_btnTabRenderer.GetPos() + [ 128, 30 ]);
    m_btnResetCam.SetPos(m_btnFirstperson.GetPos() + [ 0, 30 ]);
    m_lblSeqFrame.SetPos(m_btnTabRenderer.GetPos() + [ 0, 30 ]);
    m_btnSeqPrev.SetPos(m_btnTabRenderer.GetPos() + [ 0, 50 ]);
    m_btnSeqNext.SetPos(m_btnTabRenderer.GetPos() + [ 64, 50 ]);
}

void
vguiApp_ModelViewer::HideAll(void)
{
    m_chkBackground.Hide();
    m_chkGround.Hide();
    m_chkMirror.Hide();
    m_lblSeqFrame.Hide();
    m_btnSeqPrev.Hide();
    m_btnSeqNext.Hide();
    m_btnFirstperson.Hide();
    m_btnResetCam.Hide();
}

void
vguiApp_ModelViewer::ShowRenderer(void)
{
    vguiApp_ModelViewer::HideAll();
    m_chkBackground.Show();
    m_chkGround.Show();
    m_chkMirror.Show();
    m_btnFirstperson.Show();
    m_btnResetCam.Show();
}

void
vguiApp_ModelViewer::ShowSequence(void)
{
    vguiApp_ModelViewer::HideAll();
    m_lblSeqFrame.Show();
    m_btnSeqPrev.Show();
    m_btnSeqNext.Show();
}

void
vguiApp_ModelViewer::ShowBody(void)
{
    vguiApp_ModelViewer::HideAll();
}
void
vguiApp_ModelViewer::ShowTexture(void)
{
    vguiApp_ModelViewer::HideAll();
}

void
vguiApp_ModelViewer::ScrollUpdate (void)
{
    m_scrlModels.SetValue(m_lstModels.GetOffset());
}

void
vguiApp_ModelViewer::ListUpdate (void)
{
    m_lstModels.SetOffset(m_scrlModels.GetValue(), FALSE);
}

void
vguiApp_ModelViewer::LoadSelected (void)
{
    vguiApp_ModelViewer::SetModel(sprintf("%s%s", m_modelPath, m_lstModels.GetItem(m_lstModels.GetSelected())));
}

msg_result
vguiApp_ModelViewer::Message(string messageType, string messageData, vguiWidget sender)
{
    switch (messageType) {
    case "open":
        SetModel(messageData);
        return (true);
    default:
        return super::Message(messageType, messageData, sender);
    }
}

void
vguiApp_ModelViewer::LaunchKey(string keyName, string setValue)
{
    switch (keyName) {
    case "model_searchpath":
        m_modelSearchPath = setValue;
        break;
    case "model_path":
        m_modelPath = setValue;
        break;
    case "flymode":
        m_flyControls = stof(setValue);
        break;
    default:
        super::LaunchKey(keyName, setValue);
        break;
    }
}


void
vguiApp_ModelViewer::Launched(void)
{
    super::Launched();

    SetSize([ 550, 390 ]);
    SetMinSize([ 430, 256 ]);
    SetMaxSize([ 9999, 9999 ]);
    SetStyleMask(vguiWindowStyleDefault | vguiWindowResizeable);
    SetPos([ 172, 64 ]);
    CallOnResize(vguiApp_ModelViewer::Resize);

    m_picBackground = spawn(vguiRect);
    m_picBackground.SetPos([ 6, 32 ]);

    m_viewModel = spawn(vgui3DView);
    m_viewModel.SetDrawFuncWithDelegate(vguiApp_ModelViewer::Draw3DView, this);

    if (m_flyControls)
        m_viewModel.SetInputFuncWithDelegate(vguiApp_ModelViewer::Input3DView_FlyMode, this);
    else
        m_viewModel.SetInputFuncWithDelegate(vguiApp_ModelViewer::Input3DView, this);

    m_viewModel.SetPos([ 6, 32 ]);

    m_btnTabRenderer = spawn(vguiButton);
    m_btnTabRenderer.SetTitle("Renderer");
    m_btnTabRenderer.SetFunc(vguiApp_ModelViewer::ShowRenderer);
    m_btnTabSequence = spawn(vguiButton);
    m_btnTabSequence.SetTitle("Sequence");
    m_btnTabSequence.SetFunc(vguiApp_ModelViewer::ShowSequence);
    m_btnTabBody = spawn(vguiButton);
    m_btnTabBody.SetTitle("Body");
    m_btnTabBody.SetFunc(vguiApp_ModelViewer::ShowBody);
    m_btnTabTexture = spawn(vguiButton);
    m_btnTabTexture.SetTitle("Texture");
    m_btnTabTexture.SetFunc(vguiApp_ModelViewer::ShowTexture);

    m_chkBackground = spawn(vguiCheckbox);
    m_chkBackground.SetTitle("Background");
    m_chkBackground.SetValue(TRUE);
    m_chkGround = spawn(vguiCheckbox);
    m_chkGround.SetTitle("Ground");
    m_chkGround.SetValue(true);
    m_chkMirror = spawn(vguiCheckbox);
    m_chkMirror.SetTitle("Mirror on Ground");
    m_btnSpawnProp = spawn(vguiButton);
    m_btnSpawnProp.SetTitle("Spawn Prop");
    m_btnSpawnProp.SetFunc(vguiApp_ModelViewer::SpawnProp);
    m_btnSpawnProp.SetSize([192,24]);

    m_btnSpawnDoll = spawn(vguiButton);
    m_btnSpawnDoll.SetTitle("Spawn Doll");
    m_btnSpawnDoll.SetFunc(vguiApp_ModelViewer::SpawnDoll);
    m_btnSpawnDoll.SetSize([192,24]);

    m_btnFirstperson = spawn(vguiButton);
    m_btnFirstperson.SetTitle("FPS Cam");
    m_btnFirstperson.SetFunc(vguiApp_ModelViewer::Firstperson);
    m_btnResetCam = spawn(vguiButton);
    m_btnResetCam.SetTitle("Reset Cam");
    m_btnResetCam.SetFunc(vguiApp_ModelViewer::ResetCam);
    m_btnSetViewModel = spawn(vguiButton);
    m_btnSetViewModel.SetTitle("Set ViewModel");
    m_btnSetViewModel.SetFunc(vguiApp_ModelViewer::SetViewModel);
    m_btnSetViewModel.SetSize([192,24]);

    m_lblSeqFrame = spawn(vguiLabel);
    m_lblSeqFrame.SetTitle("Frame: 0");
    m_lblSeqFrame.SetSize([550,16]);
    m_btnSeqNext = spawn(vguiButton);
    m_btnSeqNext.SetTitle(">>");
    m_btnSeqNext.SetSize([48,24]);
    m_btnSeqNext.SetFunc(vguiApp_ModelViewer::SetFrameP);
    m_btnSeqPrev = spawn(vguiButton);
    m_btnSeqPrev.SetTitle("<<");
    m_btnSeqPrev.SetSize([48,24]);
    m_btnSeqPrev.SetFunc(vguiApp_ModelViewer::SetFrameM);

    searchhandle shModels = search_begin(m_modelSearchPath, SEARCH_NAMESORT | SEARCH_MULTISEARCH, TRUE);
    m_lstModels = spawn(vguiList);
    m_lstModels.SetItemCount(search_getsize(shModels));
    m_lstModels.CallOnScrollWithDelegate(vguiApp_ModelViewer::ScrollUpdate, this);
    m_lstModels.CallOnDoubleClickWithDelegate(vguiApp_ModelViewer::LoadSelected, this);

    for (int i = 0; i < search_getsize(shModels); i++) {
        string strAdd = search_getfilename(shModels, i);
        m_lstModels.AddItem(substring(strAdd , strlen(m_modelPath), -1));
    }
    search_end(shModels);

    m_scrlModels = spawn(vguiScrollBar);
    m_scrlModels.SetMin(0);
    m_scrlModels.SetStep(1);
    m_scrlModels.CallOnChangeWithDelegate(vguiApp_ModelViewer::ListUpdate, this);

    m_btnLoadModel = spawn(vguiButton);
    m_btnLoadModel.SetTitle("Load Selected");
    m_btnLoadModel.SetFunc(vguiApp_ModelViewer::LoadSelected);
    m_btnLoadModel.SetSize([192,24]);

    vguiApp_ModelViewer::Resize();
    vguiApp_ModelViewer::ShowRenderer();

    Add(m_picBackground);
    Add(m_viewModel);
    Add(m_btnTabRenderer);
    Add(m_btnTabSequence);
    //Add(m_btnTabBody);
    //Add(m_btnTabTexture);
    Add(m_chkBackground);
    Add(m_chkGround);
    Add(m_chkMirror);
    Add(m_lstModels);
    Add(m_lblSeqFrame);
    Add(m_btnSeqNext);
    Add(m_btnSeqPrev);
    Add(m_btnSpawnProp);
    //Add(m_btnSpawnDoll);
    Add(m_btnFirstperson);
    Add(m_btnSetViewModel);
    Add(m_btnResetCam);
    Add(m_btnLoadModel);
    Add(m_scrlModels);
}
