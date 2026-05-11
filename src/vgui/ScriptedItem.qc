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

/** Trinity Menu File "itemDef"

This class represents objects that are parsed from "itemDef" entries
defined in the Quake III: Team Arena (2000) menu scripting language.

# See also

[menuDef](@ref vguiScriptedMenu)

*/
class
vguiScriptedItem:vguiWidget
{
public:
    void vguiScriptedItem(void);

    virtual void OnRemove(void);
    virtual void Draw(void);
    virtual bool Input(float, float, float, float);
    virtual void Reposition(void);
    virtual void ReloadVideoResources(void);

    nonvirtual void Draw3D(void);

    nonvirtual void OnMouseEntered(void);
    nonvirtual void OnMouseExited(void);
    nonvirtual void OnMouseDown(void);
    nonvirtual void OnMouseUp(void);
    nonvirtual void OnMaxChars(void);
    nonvirtual void AddText(string toAdd);
    nonvirtual void OpenURL(string urlString);

    nonvirtual void Reevaluate(void);

    /* the various type handlers */
    nonvirtual bool Button_Input(float, float, float, float);

    nonvirtual void RadioButton_Draw(void);
    nonvirtual bool RadioButton_Input(float, float, float, float);

    nonvirtual void CheckBox_Draw(void);
    nonvirtual bool CheckBox_Input(float, float, float, float);

    nonvirtual bool TextField_Input(float, float, float, float);

    nonvirtual void Combo_Draw(void);
    nonvirtual bool Combo_Input(float, float, float, float);

    nonvirtual void ListBox_Draw(void);
    nonvirtual bool ListBox_Input(float, float, float, float);

    nonvirtual bool NumericField_Input(float, float, float, float);

    nonvirtual void Slider_Draw(void);
    nonvirtual bool Slider_Input(float, float, float, float);

    nonvirtual void YesNo_Draw(void);
    nonvirtual bool YesNo_Input(float, float, float, float);

    nonvirtual bool Multi_Input(float, float, float, float);

    nonvirtual void Bind_Draw(void);
    nonvirtual bool Bind_Input(float, float, float, float);

    /* Type 32 */
    nonvirtual void WebView_Draw(void);
    nonvirtual bool WebView_Input(float, float, float, float);

    /* Type 33 */
    nonvirtual void InputBox_Draw(void);
    nonvirtual bool InputBox_Input(float, float, float, float);

private:
    string m_trItemName;
    string m_trItemText;
    int m_trItemType;
    int m_trItemStyle;
    bool m_trItemDecoration;
    bool m_trItemVisible;
    float m_trItemTextScale;
    int m_trItemTextStyle;
    int m_trItemTextFont;
    int m_trItemOwnerDraw;
    float m_trItemOwnerDrawValue;
    float m_trItemTextAlignX;
    float m_trItemTextAlignY;
    vector m_trItemFocusColor;
    float m_trItemFocusAlpha;
    vector m_trItemForeColor;
    float m_trItemForeAlpha;
    vector m_trItemBorderColor;
    float m_trItemBorderAlpha;
    vector m_trItemBackColor;
    float m_trItemBackAlpha;
    vguiScriptedView m_trGlobal;
    string m_trItemGroup;
    int m_trItemTextAlign;
    int m_trItemBorder;
    string m_trItemCvarStrList;
    string m_trItemCvarFloatList;
    int m_trItemListSel;
    string m_trItemCvar;
    string m_trItemBackground;

    string m_trItemActionBuffer;
    string m_trItemEnterBuffer;
    string m_trItemExitBuffer;
    string m_trItemMaxCharBuffer;

    /* cvar tests */
    string m_trItemCvarTest;
    string m_trItemEnableCvar;
    string m_trItemDisableCvar;
    string m_trItemShowCvar;
    string m_trItemHideCvar;

    /* 3D Model */
    string m_trItemModel;
    vector m_trItemModelOrigin;
    float m_trItemModelFOVX;
    float m_trItemModelFOVY;
    vector m_trItemModelRotation;
    vector m_trItemModelAngles;
    float m_trItemModelAnim;
    float m_trItemModelSkin;
    entity m_trItemModelDelegate;
    vector m_trItemModelAngularVelocity;
    vector m_trItemModelBob;
    entity m_trCamDelegate;
    vector m_trCamOrigin;
    vector m_trCamAngles;
    vector m_trCamAngularVelocity;

    /* text */
    int m_trItemMaxChars;

    /* video to reload */
    string m_trItemCinematic;

    /* feeders, valid for ITEM_TYPE_LISTBOX and more? */
    int m_trItemFeeder;
    int m_trItemElementWidth;
    int m_trItemElementHeight;
    int m_feederOffset;
    int m_feederSelected;

    /* webview */
    string m_webViewName;
};

enumflags
{
    TRITEM_VISIBLE,
    TRITEM_USABLE,
    TRITEM_HOVER,
    TRITEM_DOWN,
    TRITEM_LASTACTIVE,
    TRITEM_FOCUS,
};

enum
{
    ITEM_TYPE_TEXT = 0,
    ITEM_TYPE_BUTTON,
    ITEM_TYPE_RADIOBUTTON,
    ITEM_TYPE_CHECKBOX,
    ITEM_TYPE_EDITFIELD,
    ITEM_TYPE_COMBO,
    ITEM_TYPE_LISTBOX,
    ITEM_TYPE_MODEL,
    ITEM_TYPE_OWNERDRAW,
    ITEM_TYPE_NUMERICFIELD,
    ITEM_TYPE_SLIDER,
    ITEM_TYPE_YESNO,
    ITEM_TYPE_MULTI,
    ITEM_TYPE_BIND,
    ITEM_TYPE_NUCLIDE_START=31,
    ITEM_TYPE_WEBVIEW,
    ITEM_TYPE_INPUTBOX,
    ITEM_TYPE_VIDEO,
    ITEM_TYPE_PICTURE,
};

#ifdef MENU
__variant MenuGame_OwnerDrawValueForType(entity clientSlot, int ownerDraw, int typeValue);
bool MenuGame_OwnerDrawItemRect(entity clientSlot, vguiScriptedItem drawItem, int ownerDraw, int drawType);
bool MenuGame_OwnerDrawMenuRect(entity clientSlot, vguiScriptedMenu drawMenu);

#define Game_OwnerDrawValueForType MenuGame_OwnerDrawValueForType
#define Game_OwnerDrawItemRect MenuGame_OwnerDrawItemRect
#define Game_OwnerDrawMenuRect MenuGame_OwnerDrawMenuRect
#endif

#ifdef CLIENT
__variant ClientGame_OwnerDrawValueForType(ncPlayer clientSlot, int ownerDraw, int typeValue);
bool ClientGame_OwnerDrawItemRect(ncPlayer clientSlot, vguiScriptedItem drawItem, int ownerDraw, int drawType);
bool ClientGame_OwnerDrawMenuRect(ncPlayer clientSlot, vguiScriptedMenu drawMenu);

__variant HUD_OwnerDrawValueForType(int ownerDraw, int typeValue);
bool HUD_OwnerDrawItemRect(vector pos, vector size, int ownerDraw, int drawType);

#define Game_OwnerDrawValueForType ClientGame_OwnerDrawValueForType
#define Game_OwnerDrawItemRect ClientGame_OwnerDrawItemRect
#define Game_OwnerDrawMenuRect ClientGame_OwnerDrawMenuRect
#endif

void
vguiScriptedItem::vguiScriptedItem(void)
{
    m_trItemName = __NULL__;
    m_trItemText = __NULL__;
    m_trItemType = 0;
    m_trItemStyle = 0;
    m_trItemDecoration = false;
    m_vecSize = g_vec_null;
    m_trItemTextScale = 0.0f;
    m_trItemTextStyle = 0i;
    m_trItemOwnerDraw = __NULL__;
    m_trGlobal = __NULL__;
    m_trItemTextAlignX = 0;
    m_trItemTextFont = 0;
    m_trItemTextAlignY = 0;
    m_trItemFocusColor = g_vec_null;
    m_trItemFocusAlpha = 0;
    m_trItemForeColor = g_vec_null;
    m_trItemForeAlpha = 0;
    m_trItemBorderColor = g_vec_null;
    m_trItemBorderAlpha = 0;
    m_trItemBackColor = g_vec_null;
    m_trItemBackAlpha = 0;
    m_trItemGroup = 0;
    m_trItemTextAlign = 0;
    m_trItemBorder = 0;
    m_trItemCvar = g_string_null;
    m_trItemCvarTest = 0;
    m_trItemCvarStrList = g_string_null;
    m_trItemBackground = g_string_null;
    m_trItemActionBuffer = __NULL__;
    m_trItemEnterBuffer = __NULL__;
    m_trItemExitBuffer = __NULL__;
    m_trItemMaxCharBuffer = __NULL__;
    m_trItemOwnerDrawValue = 0.0f;

    m_trItemModel = g_string_null;
    m_trItemModelOrigin = g_vec_null;
    m_trItemModelFOVX = g_float_null;
    m_trItemModelFOVY = g_float_null;
    m_trItemModelRotation = g_vec_null;
    m_trItemModelAngles = g_vec_null;
    m_trItemModelAnim = g_float_null;
    m_trItemModelSkin = g_float_null;
    m_trItemMaxChars = 0;
    m_trItemModelDelegate = g_entity_null;
    m_trCamAngularVelocity = g_vec_null;
    m_trCamDelegate = g_entity_null;
    m_trItemListSel = 0i;
    m_trItemCinematic = g_string_null;
    m_trItemElementWidth = 0i;
    m_trItemElementHeight = 0i;
    m_trItemFeeder = 0i;
}

void
vguiScriptedItem::ReloadVideoResources(void)
{
    if (STRING_SET(m_trItemCinematic)) {
        shaderforname(m_trItemCinematic, sprintf("{\n\t{\n\t\tvideomap %s\n\t}\n}", m_trItemCinematic));
    }
    if (STRING_SET(m_webViewName)) {
        gecko_navigate(m_webViewName, "about:blank");
        gecko_destroy(m_webViewName);
        m_webViewName = __NULL__;
    }
}

void
vguiScriptedItem::Reposition(void)
{
}

void
vguiScriptedItem::OpenURL(string urlPath)
{
    Show();

    if (m_trItemType == ITEM_TYPE_TEXT) {
        m_trItemText = localize(urlPath);
        ncLogAlways("Setting text to %S", urlPath);
    } else if (m_trItemType == ITEM_TYPE_WEBVIEW) {
        if (STRING_SET(urlPath)) {
            gecko_navigate(m_webViewName, urlPath);
        } else {
            gecko_navigate(m_webViewName, "about:blank");
        }
        ncLogAlways("Setting webview to %S", urlPath);
    } else if (m_trItemType == ITEM_TYPE_VIDEO) {
        string newUrl;

        if (substring(urlPath, 0, 5) == "http:") {
            newUrl = strcat("avs:", urlPath);
        } else if (substring(urlPath, 0, 6) == "https:") {
            newUrl = strcat("avs:", urlPath);
        } else if (substring(urlPath, 0, 5) == "rtmp:") {
            newUrl = strcat("avs:", urlPath);
        } else {
            newUrl = urlPath;
        }

        m_trItemCinematic = newUrl;
        shaderforname(m_trItemCinematic, sprintf("{\n\t{\n\t\tvideomap %s\n\t}\n}", m_trItemCinematic));
        ncLogAlways("Setting video to %S", newUrl);
    }  else if (m_trItemType == ITEM_TYPE_PICTURE) {
        m_trItemBackground = urlPath;
        shaderforname(m_trItemBackground, sprintf("{\n\t{\n\t\tclampmap %s\n\t}\n}", m_trItemBackground));
        ncLogAlways("Setting picture to %S", urlPath);
    } else if (m_trItemType == ITEM_TYPE_MODEL) {
        m_trItemModel = urlPath;
        setmodel(m_trItemModelDelegate, m_trItemModel);
    }
}

void
vguiScriptedItem::AddText(string toAdd)
{
    float stringLength = strlen(m_trItemText);

    if (m_trItemMaxChars > 0)
    if (stringLength >= m_trItemMaxChars) {
        m_trItemText = "";
        return;
    }

    m_trItemText = strcat(m_trItemText, toAdd);
    stringLength = strlen(m_trItemText);

    /* check if we've hit max chars */
    if (stringLength >= m_trItemMaxChars) {
        OnMaxChars();
        return;
    }
}

void
vguiScriptedItem::OnMaxChars(void)
{
    int commandCount;

    for (int i = 0; i < (commandCount = tokenizebyseparator(m_trItemMaxCharBuffer, ";", "\n")); i++) {
        string commandString = argv(i);

        if (STRING_SET(commandString)) {
            m_trGlobal.InterpretCommand(this, commandString);
        }
    }
}

void
vguiScriptedItem::OnMouseEntered(void)
{
    int commandCount;

    for (int i = 0; i < (commandCount = tokenizebyseparator(m_trItemEnterBuffer, ";", "\n")); i++) {
        string commandString = argv(i);

        if (STRING_SET(commandString)) {
            m_trGlobal.InterpretCommand(this, commandString);
        }
    }
}

void
vguiScriptedItem::OnMouseExited(void)
{
    int commandCount;

    for (int i = 0; i < (commandCount = tokenizebyseparator(m_trItemExitBuffer, ";", "\n")); i++) {
        string commandString = argv(i);

        if (STRING_SET(commandString)) {
            m_trGlobal.InterpretCommand(this, commandString);
        }
    }
}

void
vguiScriptedItem::OnMouseDown(void)
{
}

void
vguiScriptedItem::OnMouseUp(void)
{
    int commandCount;

    for (int i = 0; i < (commandCount = tokenizebyseparator(m_trItemActionBuffer, ";", "\n")); i++) {
        string commandString = argv(i);

        if (STRING_SET(commandString)) {
            m_trGlobal.InterpretCommand(this, commandString);
        }
    }
}

.float skin;
void
vguiScriptedItem::Draw3D(void)
{
    vector pos = m_parent.m_vecOrigin + m_vecOrigin;
    vector size = m_vecSize;

    if (!m_trItemModelDelegate) {
        m_trItemModelDelegate = spawn();
        setmodel(m_trItemModelDelegate, m_trItemModel);
        setorigin(m_trItemModelDelegate, m_trItemModelOrigin);
        m_trItemModelDelegate.angles = m_trItemModelAngles;
        m_trItemModelDelegate.frame = m_trItemModelAnim;
        m_trItemModelDelegate.skin = m_trItemModelSkin;
        m_trItemModelDelegate.movetype = MOVETYPE_FLY;
        m_trItemModelDelegate.solid = SOLID_NOT;
        m_trItemModelDelegate.avelocity = m_trItemModelAngularVelocity;

        m_trCamDelegate = spawn();
        m_trCamDelegate.movetype = MOVETYPE_FLY;
        m_trCamDelegate.solid = SOLID_NOT;
        m_trCamDelegate.angles = m_trCamAngles;
        m_trCamDelegate.avelocity = m_trCamAngularVelocity;
        m_trCamDelegate.origin = m_trCamOrigin;
        m_trItemModelDelegate.frame1time += clframetime;

    }

    clearscene();
    setproperty(VF_VIEWPORT, pos, size);
    setproperty(VF_AFOV, m_trItemModelFOVX);
    setproperty(VF_ORIGIN, m_trCamDelegate.origin);
    setproperty(VF_ANGLES, m_trCamDelegate.angles);

#ifndef MENU
    setproperty(VF_DRAWWORLD, false);
#endif

    /* sanity checks */
    if (m_trItemModelDelegate.frame < 0) {
        m_trItemModelDelegate.frame = 0;
    }

    vector oldAngles = m_trItemModelDelegate.angles;

#ifdef CLIENT
    if (m_trItemModelBob[0] > 0) {
        m_trItemModelDelegate.angles[0] = lerp(m_trItemModelDelegate.angles[0],  g_modelSpinPitch, m_trItemModelBob[0]);
    }

    if (m_trItemModelBob[1] > 0) {
        m_trItemModelDelegate.angles[1] = lerp(m_trItemModelDelegate.angles[0],  g_modelSpinAngle, m_trItemModelBob[1]);
    }

    if (m_trItemModelBob[2] > 0) {
        m_trItemModelDelegate.angles[2] = lerp(m_trItemModelDelegate.angles[0],  g_modelSpinRoll, m_trItemModelBob[2]);
    }
#endif

    addentity(m_trItemModelDelegate);
    m_trItemModelDelegate.frame1time = time;

    renderscene();
    m_trItemModelDelegate.angles = oldAngles;
}

var bool autocvar_trMenu_debugItems = false;

void
vguiScriptedItem::Draw(void)
{
    vector pos;
    vector textPos;
    vector size;
    int textAlignFlags = 0;
    vguiFont textFont;
    entity targetEntity;

#ifdef CLIENT
    targetEntity = (ncPlayer)pSeat->m_ePlayer;
#endif

    pos = GetAbsPos();
    size = m_vecSize;

    Reevaluate();

    if (HasFlag(TRITEM_VISIBLE) == false) {
        return;
    }

    switch (m_trItemType) {
        case ITEM_TYPE_PICTURE:
            if (STRING_SET(m_trItemBackground)) {
                draw.Pic(pos, m_trItemBackground, size, [1,1,1], 1.0, 0);
            }
            break;
        case ITEM_TYPE_LISTBOX:
            ListBox_Draw();
            break;
        case ITEM_TYPE_WEBVIEW:
            WebView_Draw();
            return;
            break;
        case ITEM_TYPE_INPUTBOX:
            InputBox_Draw();
            return;
            break;
    }

    bool hudResult = false;

#ifdef CLIENT
    hudResult = HUD_OwnerDrawItemRect(pos, size, m_trItemOwnerDraw, m_trItemType);
#endif

    if (hudResult == false) {
        hudResult = Game_OwnerDrawItemRect(targetEntity, this, m_trItemOwnerDraw, m_trItemType);

        if (hudResult == true) {
            return;
        }
    } else if (hudResult == true) {
        return;
    }

    switch (m_trItemTextFont) {
    case 1:
        textFont = m_trGlobal.m_trGlobalBigFont;
        break;
    case 2:
        textFont = m_trGlobal.m_trGlobalExtraBigFont;
        break;
    case 3:
        textFont = m_trGlobal.m_trGlobalSmallFont;
        break;
    case 4:
        textFont = m_trGlobal.m_trGlobalBoldFont;
        break;
    case 5:
        textFont = m_trGlobal.m_trGlobalConsoleFont;
        break;
    default:
        textFont = m_trGlobal.m_trGlobalFont;
        break;
    }

    switch (m_trItemTextAlign) {
    case 1: /* center  */
        int textWidth = textFont.StringWidth(m_trItemText, true);
        int textHeight = textFont.GetHeight();
        textPos = pos + [0, 0];
        textPos[0] += m_trItemTextAlignX - (size[0]/2);
        textPos[1] += m_trItemTextAlignY - (size[1]/2);
        textAlignFlags = AF_CENTER;
        break;
    case 2: /* right  */
        textPos = pos - [m_trItemTextAlignX, m_trItemTextAlignY];
        textAlignFlags = AF_RIGHT;
        break;
    case 3: /* center again? */
        textPos = pos + [m_trItemTextAlignX, m_trItemTextAlignY];
        textAlignFlags = AF_CENTER;
        break;
    default:
    case 0: /* left  */
        textPos = pos + [m_trItemTextAlignX, m_trItemTextAlignY];
        textAlignFlags = AF_LEFT;
        break;
    }

    if (STRING_SET(m_trItemCinematic)) {
        draw.Pic(pos, m_trItemCinematic, size, [1,1,1], 1.0, 0);
    }

    if (STRING_SET(m_trItemBackground)) {
        if (m_trItemType == 3 || m_trItemStyle == 3) {
            draw.Pic(pos, m_trItemBackground, size, [1,1,1], 1.0, 0);
        } else {
            draw.Pic(pos, m_trItemBackground, size, m_trItemBackColor, m_trItemBackAlpha, 0);
        }
    } else {
        draw.Rect(pos, size, m_trItemBackColor, m_trItemBackAlpha);
    }

    /* model stuff goes here */
    if (STRING_SET(m_trItemModel)) {
        Draw3D();
    }

    if (m_trItemBorder > 0) {
        draw.RectOutline(pos, size, 1.0f, m_trItemBorderColor, m_trItemBorderAlpha);
    }

    if (HasFlag(TRITEM_HOVER)) {
        drawfill(pos, size, m_trItemFocusColor, m_trItemFocusAlpha);
    }

    if (STRING_SET(m_trItemText) || m_trItemOwnerDraw) {
        string foreColor = Font_RGBtoHex(m_trItemForeColor);
        string destText;

#ifdef CLIENT
        destText = HUD_OwnerDrawValueForType(targetEntity, m_trItemOwnerDraw, m_trItemType);
#endif

        if (destText == __NULL__) {
            destText = Game_OwnerDrawValueForType(targetEntity, m_trItemOwnerDraw, m_trItemType);

            if (destText == __NULL__) {
                destText = m_trItemText;

                if (m_trItemType == ITEM_TYPE_EDITFIELD) {
                    destText = cvar_string(m_trItemCvar);
                }
            }
        }

        /* button */
        if (m_trItemType == 1 && HasFlag(TRITEM_HOVER)) {
            textFont.DrawField(textPos, size, destText, textAlignFlags);
        } else {
            textFont.DrawField(textPos, size, strcat(foreColor, destText), textAlignFlags);
        }
    }
}

void
vguiScriptedItem::Reevaluate(void)
{
    if (!STRING_SET(m_trItemCvarTest)) {
        FlagAdd(TRITEM_USABLE);
        FlagAdd(TRITEM_VISIBLE);
        return;
    }

    if (STRING_SET(m_trItemEnableCvar)) {
        for (int i = 0; (i < (int)tokenizebyseparator(m_trItemEnableCvar, ",")); i++) {
            if (cvar_string(m_trItemCvarTest) == argv(i)) {
                FlagAdd(TRITEM_USABLE);
            }
        }
    }

    if (STRING_SET(m_trItemDisableCvar)) {
        for (int i = 0; (i < (int)tokenizebyseparator(m_trItemDisableCvar, ",")); i++) {
            if (cvar_string(m_trItemCvarTest) == argv(i)) {
                FlagRemove(TRITEM_USABLE);
            }
        }
    }

    if (STRING_SET(m_trItemShowCvar)) {
        for (int i = 0; (i < (int)tokenizebyseparator(m_trItemShowCvar, ",")); i++) {
            if (cvar_string(m_trItemCvarTest) == argv(i)) {
                FlagAdd(TRITEM_VISIBLE);
            }
        }
    }

    if (STRING_SET(m_trItemHideCvar)) {
        for (int i = 0; (i < (int)tokenizebyseparator(m_trItemHideCvar, ",")); i++) {
            if (cvar_string(m_trItemCvarTest) == argv(i)) {
                FlagRemove(TRITEM_VISIBLE);
            }
        }
    }
}

bool
vguiScriptedItem::TextField_Input(float flEVType, float flKey, float flChar, float flDevID)
{
    bool ret = false;

    switch (flKey) {
    case K_MOUSE1 :
        if (flEVType == IE_KEYDOWN) {
            if (HasFlag(TRITEM_HOVER)) {
                FlagAdd(TRITEM_DOWN);
                ret = true;
            }
        } else {
            if (HasFlag(TRITEM_DOWN) && HasFlag(TRITEM_HOVER)) {
                FlagAdd(TRITEM_FOCUS);
                ret = true;
            } else {
                FlagRemove(TRITEM_FOCUS);
            }
            m_iFlags -= (m_iFlags & TRITEM_DOWN);
        }
        break;
    case K_BACKSPACE:
            if (flEVType == IE_KEYDOWN)
                if (HasFlag(TRITEM_FOCUS))
                    m_trItemText = substring(m_trItemText, 0, strlen(m_trItemText) - 1);
        break;
    case K_ENTER:
        //if (tmpvguiTextBox1) {
            //tmpvguiTextBox1();
        //}
        break;
    default:
        if (HasFlag(TRITEM_DOWN))
            ret = true;
        else if (HasFlag(TRITEM_FOCUS)) {
            if ((flChar >= 32 && flChar <= 125)) {
                if (flEVType == IE_KEYDOWN) {
                    m_trItemText = sprintf("%s%s", m_trItemText, chr2str(flChar));

                    if (STRING_SET(m_trItemCvar)) {
                        cvar_set(m_trItemCvar, m_trItemText);
                    }
                }
                ret = true;
            }
            if ((flKey >= 32 && flKey <= 125)) {
                ret = true;
            }
        }
    }

    return (ret);
}

bool
vguiScriptedItem::Button_Input(float flEVType, float flKey, float flChar, float flDevID)
{
    float ret = false;

    if (flEVType == IE_KEYDOWN) {
        if (flKey == K_MOUSE1) {
            FlagRemove(TRITEM_LASTACTIVE);

            if (HasFlag(TRITEM_HOVER)) {
                OnMouseDown();

                FlagAdd(TRITEM_DOWN);
                FlagAdd(TRITEM_LASTACTIVE);
                ret = true;
            }
        }
    } else if (flEVType == IE_KEYUP) {
        if (flKey == K_MOUSE1) {
            if (HasFlag(TRITEM_DOWN) && HasFlag(TRITEM_HOVER)) {
                OnMouseUp();
                ret = true;
            }
            FlagRemove(TRITEM_DOWN);
        }
    }

    return (ret);
}

void
vguiScriptedItem::RadioButton_Draw(void)
{
    return (false);
}

bool
vguiScriptedItem::RadioButton_Input(float, float, float, float)
{
    return (false);
}

void
vguiScriptedItem::CheckBox_Draw(void)
{
    return (false);
}

bool
vguiScriptedItem::CheckBox_Input(float flEVType, float flKey, float flChar, float flDevID)
{
    float ret = false;

    if (flEVType == IE_KEYDOWN) {
        if (flKey == K_MOUSE1) {
            FlagRemove(TRITEM_LASTACTIVE);

            if (HasFlag(TRITEM_HOVER)) {
                //OnMouseDown();

                FlagAdd(TRITEM_DOWN);
                FlagAdd(TRITEM_LASTACTIVE);
                ret = true;
            }
        }
    } else if (flEVType == IE_KEYUP) {
        if (flKey == K_MOUSE1) {
            if (HasFlag(TRITEM_DOWN) && HasFlag(TRITEM_HOVER)) {
                //OnMouseUp();

                if (STRING_SET(m_trItemCvar)) {
                    if (cvar(m_trItemCvar) == 1) {
                        m_trItemText = "NO";
                        cvar_set(m_trItemCvar, "0");
                    } else {
                        m_trItemText = "YES";
                        cvar_set(m_trItemCvar, "1");
                    }
                } else {
                    m_trItemText = "NO CVAR";
                }

                ret = true;
            }
            FlagRemove(TRITEM_DOWN);
        }
    }

    return (ret);
}

void
vguiScriptedItem::Combo_Draw(void)
{
    return (false);
}

bool
vguiScriptedItem::Combo_Input(float, float, float, float)
{
    return (false);
}

typedef enum
{
    FEEDER_HEADS = 0,
    FEEDER_MAPS,
    FEEDER_SERVERS,
    FEEDER_CLANS,
    FEEDER_ALLMAPS,
    FEEDER_REDTEAM_LIST,
    FEEDER_BLUETEAM_LIST,
    FEEDER_PLAYER_LIST,
    FEEDER_TEAM_LIST,
    FEEDER_MODS,
    FEEDER_DEMOS,
    FEEDER_SCOREBOARD,
    FEEDER_Q3HEADS,
    FEEDER_SERVERSTATUS,
    FEEDER_FINDPLAYER,
    FEEDER_CINEMATICS,
} feedertypes_t;


void
vguiScriptedItem::OnRemove(void)
{
    if (STRING_SET(m_webViewName)) {
        gecko_navigate(m_webViewName, "about:blank");
        gecko_destroy(m_webViewName);
        m_webViewName = __NULL__;
    }
}


void
vguiScriptedItem::ListBox_Draw(void)
{
    vector pos;
    vector size;
    int textAlignFlags;
    int maxVisible = floor(m_vecSize[1] / m_trItemElementHeight);

    pos = m_parent.m_parent.m_vecOrigin + m_parent.m_vecOrigin + m_vecOrigin;
    size = m_vecSize;

    switch (m_trItemTextAlign) {
    case 1: /* center  */
        textAlignFlags = AF_CENTER;
        break;
    case 2: /* right  */
        textAlignFlags = AF_RIGHT;
        break;
    case 3: /* center again? */
        textAlignFlags = AF_CENTER;
        break;
    default:
    case 0: /* left  */
        textAlignFlags = AF_LEFT;
        break;
    }


    for (int i = m_feederOffset; i < m_feederOffset + maxVisible; i++) {
        string itemText = Feeder_StringAtIndex(i, 0, m_trItemFeeder);

        if (m_feederSelected != i) {
            Font_DrawField(pos, [m_trItemElementWidth, m_trItemElementHeight], itemText, g_fntDefault, textAlignFlags);
        } else {
            Font_DrawField(pos, [m_trItemElementWidth, m_trItemElementHeight], strcat("^2", itemText), g_fntDefault, textAlignFlags);
        }
        pos[1] += m_trItemElementHeight;
    }

    return (false);
}

bool
vguiScriptedItem::ListBox_Input(float flEVType, float flKey, float flChar, float flDevID)
{
    int maxVisible = floor(m_vecSize[1] / m_trItemElementHeight);
    int startHeight = m_parent.m_vecOrigin[1] + m_vecOrigin[1];
    int selectedEntry = floor((g_vecMousePos[1] - startHeight) / m_trItemElementHeight);
    m_feederSelected = m_feederOffset + selectedEntry;
    /* printf("maxVisible: %i; selectedEntry: %i; feederSelected: %i\n", maxVisible, selectedEntry, m_feederSelected); */

    if (flEVType == IE_KEYDOWN) {
        if (flKey == K_MWHEELUP) {
            m_feederOffset--;

            if (m_feederOffset < 0) {
                m_feederOffset = 0;
            }
        } else if (flKey == K_MWHEELDOWN) {
            m_feederOffset++;
        }
    }

    /* send the selected id off to the rest of the menu system */
    switch (m_trItemFeeder) {
    case FEEDER_ALLMAPS:
        g_ui_map_create_preview = m_feederSelected;
        break;
    case FEEDER_MAPS:
        break;
    case FEEDER_SERVERS:
        break;
#ifdef MENU
    case FEEDER_MODS:
        break;
#endif
    default:
        break;
    }

    return HasFlag(TRITEM_HOVER);
}

bool
vguiScriptedItem::NumericField_Input(float flEVType, float flKey, float flChar, float flDevID)
{
    bool ret = false;

    switch (flKey) {
    case K_MOUSE1 :
        if (flEVType == IE_KEYDOWN) {
            if (HasFlag(TRITEM_HOVER)) {
                FlagAdd(TRITEM_DOWN);
                ret = true;
            }
        } else {
            if (HasFlag(TRITEM_DOWN) && HasFlag(TRITEM_HOVER)) {
                FlagAdd(TRITEM_FOCUS);
                ret = true;
            } else {
                FlagRemove(TRITEM_FOCUS);
            }
            m_iFlags -= (m_iFlags & TRITEM_DOWN);
        }
        break;
    case K_BACKSPACE:
            if (flEVType == IE_KEYDOWN)
                if (HasFlag(TRITEM_FOCUS))
                    m_trItemText = substring(m_trItemText, 0, strlen(m_trItemText) - 1);
        break;
    case K_ENTER:
        //if (tmpvguiTextBox1) {
            //tmpvguiTextBox1();
        //}
        break;
    default:
        if (HasFlag(TRITEM_DOWN))
            ret = true;
        else if (HasFlag(TRITEM_FOCUS)) {
            if ((flChar >= 48 && flChar <= 57)) {
                if (flEVType == IE_KEYDOWN) {
                    m_trItemText = sprintf("%s%s", m_trItemText, chr2str(flChar));

                    if (STRING_SET(m_trItemCvar)) {
                        cvar_set(m_trItemCvar, m_trItemText);
                    }
                }
                ret = true;
            }
            if ((flKey >= 32 && flKey <= 125)) {
                ret = true;
            }
        }
    }

    return (ret);
}


void
vguiScriptedItem::Slider_Draw(void)
{
    return (false);
}

bool
vguiScriptedItem::Slider_Input(float, float, float, float)
{
    return (false);
}


void
vguiScriptedItem::YesNo_Draw(void)
{
}

bool
vguiScriptedItem::YesNo_Input(float, float, float, float)
{
    return (false);
}

void
vguiScriptedItem::Multi_Rotate(void)
{
    int tokenCount = 0i;
    int maxArgs = 0i;

    if (STRING_SET(m_trItemCvarStrList)) {
        tokenCount = (int)tokenizebyseparator(m_trItemCvarStrList, ",");
        //printf("%i %S\n", tokenCount, m_trItemCvarStrList);
    } else if (STRING_SET(m_trItemCvarFloatList))  {
        tokenCount = (int)tokenizebyseparator(m_trItemCvarFloatList, ",");
        //printf("%i %S\n", tokenCount, m_trItemCvarFloatList);
    }

    m_trItemListSel++;
    maxArgs = (m_trItemListSel * 2);

    if (maxArgs >= tokenCount) {
        m_trItemListSel = 0;
        maxArgs = 0;
    }

    //printf("%i %i %s\n", m_trItemListSel, maxArgs, argv(maxArgs));
    m_trItemText = strtrim(argv(maxArgs));

    if (STRING_SET(m_trItemCvar)) {
        cvar_set(m_trItemCvar, strtrim(argv(maxArgs + 1)));
    }
}

bool
vguiScriptedItem::Multi_Input(float flEVType, float flKey, float flChar, float flDevID)
{
    float ret = false;

    if (flEVType == IE_KEYDOWN) {
        if (flKey == K_MOUSE1) {
            FlagRemove(TRITEM_LASTACTIVE);

            if (HasFlag(TRITEM_HOVER)) {
                OnMouseDown();

                FlagAdd(TRITEM_DOWN);
                FlagAdd(TRITEM_LASTACTIVE);
                ret = true;
            }
        }
    } else if (flEVType == IE_KEYUP) {
        if (flKey == K_MOUSE1) {
            if (HasFlag(TRITEM_DOWN) && HasFlag(TRITEM_HOVER)) {
                Multi_Rotate(); /* the only additio nfrom button... */
                OnMouseUp();
                ret = true;
            }
            FlagRemove(TRITEM_DOWN);
        }
    }

    return (ret);
}

void
vguiScriptedItem::Bind_Draw(void)
{
    return (false);
}

bool
vguiScriptedItem::Bind_Input(float, float, float, float)
{
    return (false);
}

void
vguiScriptedItem::WebView_Draw(void)
{
    if (!STRING_SET(m_webViewName)) {
        m_webViewName = sprintf("vguiWebView%d", num_for_edict(this));
        gecko_create(m_webViewName, "http:");
        gecko_navigate(m_webViewName, m_trItemText);
        return;
    }

    gecko_resize(m_webViewName, m_vecSize[0], m_vecSize[1]);
    draw.Pic(m_parent.m_vecOrigin + m_vecOrigin, m_webViewName, m_vecSize, [1,1,1], 1.0f, DRAWFLAG_NORMAL);
    return;
}

bool
vguiScriptedItem::WebView_Input(float flEVType, float flKey, float flChar, float flDevID)
{
    bool ret = false;
    vguiRootWindow rootWin = (vguiRootWindow)GetRootWindow();
    vector mousePos = rootWin.GetMousePos();
    vector absPos = GetAbsPos();
    bool mouseHover = false;

    if (HasFlag(TRITEM_HOVER)) {
        mouseHover = true;
    }

    if (IsEnabled() == false) {
        return (false);
    }

    if (mouseHover) {
        vector relativeMousePos;
        relativeMousePos[0] = (mousePos[0] - (absPos[0])) / GetWidth();
        relativeMousePos[1] = (mousePos[1] - (absPos[1])) / GetHeight();
        ret = true;

        if (relativeMousePos[0] > 1.0f) {
            relativeMousePos[0] = 1.0f;
        }
        if (relativeMousePos[1] > 1.0f) {
            relativeMousePos[1] = 1.0f;
        }
        if (relativeMousePos[0] < 0.0f) {
            relativeMousePos[0] = 0.0f;
        }
        if (relativeMousePos[1] < 0.0f) {
            relativeMousePos[1] = 1.0f;
        }

        gecko_mousemove(m_webViewName, relativeMousePos[0], relativeMousePos[1]);
    }

    if (mouseHover == true) {
        gecko_navigate(m_webViewName, "cmd:focus");
    } else if (mouseHover == false) {
        gecko_navigate(m_webViewName, "cmd:unfocus");
    }

    if (mouseHover) {
        switch (flEVType) {
        case IE_KEYDOWN:
        case IE_KEYUP:
            gecko_keyevent(m_webViewName, flKey, flEVType, flChar);
            break;
        default:
            return (ret);
        }
    }

    return (ret);
}

void
vguiScriptedItem::InputBox_Draw(void)
{
    Font_DrawText([8,8], "Input Zone", g_fntDefault);
    return;
}

bool
vguiScriptedItem::InputBox_Input(float flEVType, float flKey, float flChar, float flDevID)
{
    /* forward events to the connected device */
    if (HasFlag(TRITEM_HOVER)) {
        return (true);
    }


    return (false);
}

bool
vguiScriptedItem::Input(float flEVType, float flKey, float flChar, float flDevID)
{
    vguiRootWindow rootWin = (vguiRootWindow)GetRootWindow();
    vector mousePos = rootWin.GetMousePos();
    vector absPos = GetAbsPos();

    if (m_trItemDecoration) {
        return (false);
    }

    Reevaluate();

    if (HasFlag(TRITEM_USABLE) == false) {
        return (false);
    }

    bool mouseHover = false;

    if (MouseAbove()) {
        mouseHover = true;
    }

    if (mouseHover == true && HasFlag(TRITEM_HOVER) == false) {
        FlagAdd(TRITEM_HOVER);
        OnMouseEntered();
    } else if (HasFlag(TRITEM_HOVER) && mouseHover == false) {
        FlagRemove(TRITEM_HOVER);
        OnMouseExited();
    }

    switch (m_trItemType) {
    case ITEM_TYPE_TEXT:
        return false;
    case ITEM_TYPE_BUTTON:
        return Button_Input(flEVType, flKey, flChar, flDevID);
    case ITEM_TYPE_RADIOBUTTON:
        return RadioButton_Input(flEVType, flKey, flChar, flDevID);
    case ITEM_TYPE_CHECKBOX:
        return CheckBox_Input(flEVType, flKey, flChar, flDevID);
    case ITEM_TYPE_EDITFIELD:
        return TextField_Input(flEVType, flKey, flChar, flDevID);
    case ITEM_TYPE_COMBO:
        return Combo_Input(flEVType, flKey, flChar, flDevID);
    case ITEM_TYPE_LISTBOX:
        return ListBox_Input(flEVType, flKey, flChar, flDevID);
    case ITEM_TYPE_MODEL:
        return false;
    case ITEM_TYPE_OWNERDRAW:
        return false; /* ownerdraw */
    case ITEM_TYPE_NUMERICFIELD:
        return NumericField_Input(flEVType, flKey, flChar, flDevID);
    case ITEM_TYPE_SLIDER:
        return Slider_Input(flEVType, flKey, flChar, flDevID);
    case ITEM_TYPE_YESNO:
        return YesNo_Input(flEVType, flKey, flChar, flDevID);
    case ITEM_TYPE_MULTI:
        return Multi_Input(flEVType, flKey, flChar, flDevID);
    case ITEM_TYPE_BIND:
        return Bind_Input(flEVType, flKey, flChar, flDevID);
    case ITEM_TYPE_WEBVIEW:
        return WebView_Input(flEVType, flKey, flChar, flDevID);
    case ITEM_TYPE_INPUTBOX:
        return InputBox_Input(flEVType, flKey, flChar, flDevID);
    }

    return (false);
}
