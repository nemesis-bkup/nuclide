/*
 * Copyright (c) 2023-2025 Vera Visions LLC.
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

/* For vguiTheme, we want to allow everyone some basic overrides to handle most of the drawing
tasks. However, this is matter that will slowly expand to encompass more features.
If you plan on doing something really 'out there' that you can't do within this Theme framework,
I encourage you to just maintain your own objects with overridden draw functions for best
forward compatibility.

Why does this exist? Because the support for VGUI type elements needs variable appearances
and we can't rely on ifdefs to do the bulk of the work, that's why. The official inspiration
also referred to as TrackerUI has changed many times in appearance and we'd like to offer
means of handling any such styles.
*/

font_s g_fntDefault;
font_s g_fntTitle;
font_s g_fntSubTitle;
font_s g_fntMenuButton;

var vector UI_MAINCOLOR;

/** State of the widget we're going to draw. */
typedef enum
{
    VGUI_STATE_NORMAL,      /** The widget is in normal operation. */
    VGUI_STATE_ACTIVE,      /** The widget is active. */
    VGUI_STATE_HOVER,       /** The mouse or another pointing device is hovering over the widget. */
    VGUI_STATE_FOCUSED,     /** The widget is focused. */
    VGUI_STATE_DISABLED,    /** The widget is disabled. */
    VGUI_STATE_CHECKED      /** The widget is pressed or enabled. */
} VGUIDrawState_t;

/** Style of the border to be drawn within the vguiTheme. */
typedef enum
{
    VGUI_BORDER_LINE,       /**< Thin line border. */
    VGUI_BORDER_INSET,      /**< Inset border, used for control elements. */
    VGUI_BORDER_OUTSET,     /**< Outset border, often used for windows. */
    //VGUI_BORDER_DOTTED,
    //VGUI_BORDER_DASHED,
    //VGUI_BORDER_RIDGE,
    //VGUI_BORDER_GROOVE
    VGUI_BORDER_NONE        /**< No border */
} VGUIBorderStyle_t;

/** Abstract class than can be set/overriden to customize to final appearance of GUI widgets */
class
vguiTheme
{
public:
    virtual void vguiTheme(void);

    virtual void Init(void);

    virtual string GetDefaultThemeFile(void);

    /** Draw a border at the specified position, size and VGUIBorderStyle_t. */
    virtual void DrawBorder(vector, vector, VGUIBorderStyle_t, vguiColor);
    /** Draws control text onto a widget. */
    virtual void DrawControlText(vector, string, float, vector, VGUIDrawState_t, font_s);
    /** Draws control text onto a widget. */
    virtual void DrawControlTextWithIcon(vector, string, float, string, vector, vector, vector, VGUIDrawState_t, font_s);
    /** Draw a control item background at the specified position, size and VGUIDrawState_t. */
    virtual void DrawControlBackground(vector, vector, VGUIDrawState_t);
    /** Draw a text field background at the specified position, size and VGUIDrawState_t. */
    virtual void DrawTextBackground(vector, vector, VGUIDrawState_t);
    /** Draw a text field background at the specified position, size and VGUIDrawState_t. */
    virtual void DrawListBackground(vector, vector, VGUIDrawState_t);
    /** Draw a window background at the specified position, size and VGUIDrawState_t. */
    virtual void DrawWindowBackground(vector, vector, VGUIDrawState_t);
    /** Draw a window background at the specified position, size and VGUIDrawState_t. */
    virtual void DrawWindowTitle(vector, vector, string, string, font_s, VGUIDrawState_t);
    /** Draw a button body at the specified position, size and VGUIDrawState_t. */
    virtual void DrawButton(vector, vector, VGUIDrawState_t);
    /** Draw a scroller at the specified position, size and VGUIDrawState_t. */
    virtual void DrawScroller(vector, vector, VGUIDrawState_t);
    /** Draw a scrollbar at the specified position, size and VGUIDrawState_t. */
    virtual void DrawScrollbar(vector, vector, VGUIDrawState_t);
    /** Draw a progress indicator at the specified position, size and VGUIDrawState_t. */
    virtual void DrawProgressIndicator(vector, vector, float, VGUIDrawState_t);
    /** Draws generic text onto a widget. */
    virtual void DrawText(vector, string, vector, font_s);
    /** Draws generic text onto a widget. */
    virtual void DrawHighlightText(vector, string, vector, font_s);
    /** Draw a window body. */
    virtual void DrawWindow(vector, vector, VGUIDrawState_t);
    /** Draw a window body. */
    virtual void DrawWindowBorder(vector, vector, VGUIDrawState_t);
    /** Draw window text. */
    virtual void DrawLabel(vector atPos, string withText, int labelFlags, int sizeOverride, vector boundSize, VGUIDrawState_t drawStyle);
    virtual void DrawHighlight(vector atPos, vector withSize, VGUIDrawState_t drawStyle);
    /** Draw a menu bar body. */
    virtual void DrawMenuBar(vector, vector, VGUIDrawState_t);

    /** Draw a control item background at the specified position, size and VGUIDrawState_t. */
    virtual void DrawRadioButton(vector, string, vector, VGUIDrawState_t);

    /** Returns whether icons are currently enabled. */
    virtual bool IconsEnabled(void);

    /** Plays a UI sound, subject to sound theme guidelines */
    virtual void PlaySound(string shortName);

private:
    vguiColor m_controlBackgroundColor;
    vguiColor m_windowBackgroundColor;
    vguiColor m_textBackgroundColor;
    vguiColor m_controlTextColor;
    vguiColor m_textColor;
    vguiColor m_windowBorderColor;
    vguiColor m_lightColor;
    vguiColor m_shadowColor;
    vguiColor m_hoverColor;
    vguiColor m_fillColor;
    vguiColor m_highlightTextColor;
    vguiColor m_activeTitleColor;
    vguiColor m_inactiveTitleColor;
    vguiColor m_activeTitleTextColor;
    vguiColor m_inactiveTitleTextColor;
    vguiColor m_gradientActiveTitleColor;
    vguiColor m_gradientInactiveTitleColor;
    bool m_noIcons;
    bool m_roundedCorners;
};

void
vguiTheme::vguiTheme(void)
{
    Init();
}
    vector controlTextColor;
    vector textColor;
    vector mainColor;
    vector foregroundColor;
    float mainAlpha;
    vector highColor;
    vector lowColor;
    vector borderColor;
    float borderAlpha;
    vector fillColor;
    vector hoverColor;
    float hoverAlpha;
    float fillAlpha;
    vector textBackgroundColor;
    float textBackgroundAlpha;
    vector highlightTextColor;
    float highlightTextAlpha;
    float controlBackgroundAlpha;

    vector activeTitleColor;
    vector inactiveTitleColor;
    vector gradientActiveTitleColor;
    vector gradientInactiveTitleColor;
    vector activeTitleTextColor;
    vector inactiveTitleTextColor;


void
vguiTheme::StyleKey(string keyName, string setValue)
{
    switch (keyName) {
    case "SHADOW_COLOR":
        lowColor = stov(setValue) / 255;
        break;
    case "HILIGHT_COLOR":
        highColor = stov(setValue) / 255;
        break;
    case "BORDER_ALPHA":
        borderAlpha = stof(setValue) / 255;
        break;
    case "HOVER_COLOR":
        hoverColor = stov(setValue) / 255;
        break;
    case "HOVER_ALPHA":
        hoverAlpha = stof(setValue) / 255;
        break;
    case "BG_ALPHA":
    case "ALPHA":
        mainAlpha = stof(setValue) / 255;
        break;
    case "ROUNDED":
        m_roundedCorners = (bool)stof(setValue);
        break;
    case "NOICONS":
        m_noIcons = (bool)stof(setValue);
        break;

    case "BORDER_COLOR":
    case "ActiveBorder":
        borderColor = stov(setValue) / 255;
        break;

    case "Background":
        break;
    case "ActiveTitle":
        activeTitleColor = stov(setValue) / 255;
        break;
    case "AppWorkspace":
        break;
    case "ButtonFace":
        controlBackgroundAlpha = 1.0f;
    case "BG_COLOR":
    case "COLOR":
        mainColor = stov(setValue) / 255;
        activeTitleColor = mainColor;
        inactiveTitleColor = mainColor;
        gradientActiveTitleColor = mainColor;
        gradientInactiveTitleColor = mainColor;
        break;
    case "ButtonDkShadow":
        break;
    case "ButtonHilight":
        break;
    case "ButtonLight":
        break;
    case "ButtonShadow":
        break;
    case "CONTROL_COLOR":
    case "ButtonText":
        controlTextColor = stov(setValue) / 255;
        break;
    case "GradientActiveTitle":
        gradientActiveTitleColor = stov(setValue) / 255;
        break;
    case "GradientInactiveTitle":
        gradientInactiveTitleColor = stov(setValue) / 255;
        break;
    case "GrayText":
        break;
    case "FILL_COLOR":
    case "Hilight":
        fillColor = stov(setValue) / 255;
        break;
    case "HilightText":
        break;
    case "InactiveBorder":
        break;
    case "InactiveTitle":
        inactiveTitleColor = stov(setValue) / 255;
        break;
    case "InactiveTitleText":
        inactiveTitleTextColor = stov(setValue) / 255;
        break;
    case "InfoText":
        break;
    case "InfoWindow":
        break;
    case "Menu":
        break;
    case "MenuText":
        break;
    case "Scrollbar":
        break;
    case "Window":
        textBackgroundColor = (stov(setValue) / 255);
        break;
    case "WindowFrame":
        break;
    case "FG_COLOR":
    case "WindowText":
        textColor = controlTextColor = (stov(setValue) / 255);
        break;
    case "TitleText":
        activeTitleTextColor = stov(setValue) / 255;
        break;
    }
}

void
vguiTheme::PlaySound(string shortName)
{
    localcmd(sprintf("play sound/ui/%s.ogg\n", shortName));
}


string
vguiTheme::GetDefaultThemeFile(void)
{
#ifdef CLIENT
    return ("scripts/client_style.txt");
#else
    return ("scripts/menu_style.txt");
#endif
}

void
vguiTheme::Init(void)
{
    string strTemp = "";
    string strUIFile = GetDefaultThemeFile();
    filestream fileUI = fopen(strUIFile, FILE_READ);

    if (fileUI < 0) {
        strUIFile = "scripts/ui_style.txt";
        fileUI = fopen(strUIFile, FILE_READ);
    }

    mainColor = [68,68,68] / 255;
    foregroundColor = [255,255,255] / 255;
    mainAlpha = 1.0f;
    m_roundedCorners = false;
    m_noIcons = false;
    highColor = [255,255,255] / 255;
    lowColor = [0,0,0] / 255;
    borderColor = [255,255,255] / 255;
    borderAlpha = 0 / 255;
    fillColor = [68,68,255] / 255;
    fillAlpha = 0.75f;
    hoverColor = [255,255,255] / 255;
    hoverAlpha = 0;
    controlTextColor = [255,255,255] / 255;
    controlBackgroundAlpha = 0.0f;
    textColor = [255,255,255] / 255;
    textBackgroundColor = [0.25, 0.25, 0.25];
    textBackgroundAlpha = 1.0f;
    highlightTextColor = [1,1,1];
    highlightTextAlpha = 1.0f;
    activeTitleColor = [68,68,68] / 255;
    inactiveTitleColor = [68,68,68] / 255;
    gradientActiveTitleColor = [68,68,68] / 255;
    gradientInactiveTitleColor  = [68,68,68] / 255;
    activeTitleTextColor = [1,1,1];
    inactiveTitleTextColor = [1,1,1];

    if (fileUI >= 0) {
        while ((strTemp = fgets(fileUI))) {
            if (tokenizebyseparator(strTemp, "=") == 2) {
                StyleKey(argv(0), argv(1));
            }
        }
        fclose(fileUI);
    } else {
        ncError("Cannot load UI file %s!", strUIFile);
    }

    Font_Load("fonts/ui.font", g_fntDefault);
    Font_Load("fonts/title.font", g_fntTitle);
    Font_Load("fonts/subtitle.font", g_fntSubTitle);
    Font_Load("fonts/menu_button.font", g_fntMenuButton);

    if (g_fntMenuButton.iID == 0) {
        g_fntMenuButton = g_fntDefault;
    }

    if (g_fntSubTitle.iID == 0) {
        g_fntSubTitle = g_fntDefault;
    }

    if (g_fntTitle.iID == 0) {
        g_fntTitle = g_fntDefault;
    }

    m_controlBackgroundColor = spawn(vguiColor);
    m_controlBackgroundColor. SetColorWithAlpha(mainColor, controlBackgroundAlpha);

    m_windowBackgroundColor = spawn(vguiColor);
    m_windowBackgroundColor.SetColorWithAlpha(mainColor, mainAlpha);

    m_textBackgroundColor = spawn(vguiColor);
    m_textBackgroundColor.SetColorWithAlpha(textBackgroundColor, textBackgroundAlpha);

    m_controlTextColor = spawn(vguiColor);
    m_controlTextColor.SetColor(controlTextColor);

    m_textColor = spawn(vguiColor);
    m_textColor.SetColor(textColor);

    m_windowBorderColor = spawn(vguiColor);
    m_windowBorderColor.SetColor(borderColor);

    m_lightColor = spawn(vguiColor);
    m_lightColor.SetColorWithAlpha(highColor, 0.5f);

    m_shadowColor = spawn(vguiColor);
    m_shadowColor.SetColorWithAlpha(lowColor, 0.5f);

    m_hoverColor = spawn(vguiColor);
    m_hoverColor.SetColorWithAlpha(hoverColor, hoverAlpha);

    m_fillColor = spawn(vguiColor);
    m_fillColor.SetColorWithAlpha(fillColor, fillAlpha);

    m_highlightTextColor = spawn(vguiColor);
    m_highlightTextColor.SetColorWithAlpha(highlightTextColor, highlightTextAlpha);

    m_activeTitleColor = spawn(vguiColor);
    m_activeTitleColor.SetColor(activeTitleColor);

    m_inactiveTitleColor = spawn(vguiColor);
    m_inactiveTitleColor.SetColor(inactiveTitleColor);

    m_gradientActiveTitleColor = spawn(vguiColor);
    m_gradientActiveTitleColor.SetColor(gradientActiveTitleColor);

    m_gradientInactiveTitleColor = spawn(vguiColor);
    m_gradientInactiveTitleColor.SetColor(gradientInactiveTitleColor);

    m_activeTitleTextColor = spawn(vguiColor);
    m_activeTitleTextColor.SetColor(activeTitleTextColor);

    m_inactiveTitleTextColor = spawn(vguiColor);
    m_inactiveTitleTextColor.SetColor(inactiveTitleTextColor);


}

bool
vguiTheme::IconsEnabled(void)
{
    return (m_noIcons == false) ? (true) : (false);
}

void
vguiTheme::DrawBorder(vector atPos, vector withSize, VGUIBorderStyle_t borderStyle, vguiColor color)
{
    switch (borderStyle) {
    case VGUI_BORDER_INSET:
        //drawfill(atPos + [1, 1], withSize + [-2, -2], [0,0,0], 0.25f);
        drawfill(atPos + [0, withSize[1] - 1], [withSize[0], 1], m_lightColor.GetColor(), m_lightColor.GetAlpha());
        drawfill(atPos, [withSize[0], 1], m_shadowColor.GetColor(), m_shadowColor.GetAlpha());
        drawfill(atPos + [0, 1], [1, withSize[1] - 2], m_shadowColor.GetColor(), m_shadowColor.GetAlpha());
        drawfill(atPos + [withSize[0] - 1, 1], [1, withSize[1] - 2], m_lightColor.GetColor(), m_lightColor.GetAlpha());
        break;
    case VGUI_BORDER_OUTSET:
        drawfill(atPos + [0, withSize[1] - 1], [withSize[0], 1], m_shadowColor.GetColor(), 0.5f);
        drawfill(atPos, [withSize[0], 1], m_lightColor.GetColor(), 0.5f);
        drawfill(atPos + [0, 1], [1, withSize[1] - 2], m_lightColor.GetColor(), 0.5f);
        drawfill(atPos + [withSize[0] - 1, 1], [1, withSize[1] - 2], m_shadowColor.GetColor(), 0.5f);
        break;
    case VGUI_BORDER_LINE:
        drawfill(atPos + [0, withSize[1] - 1], [withSize[0], 1], color.GetColor(), color.GetAlpha());
        drawfill(atPos, [withSize[0], 1], color.GetColor(), color.GetAlpha());
        drawfill(atPos + [0, 1], [1, withSize[1] - 2], color.GetColor(), color.GetAlpha());
        drawfill(atPos + [withSize[0] - 1, 1], [1, withSize[1] - 2], color.GetColor(), color.GetAlpha());
        break;
    default:
    case VGUI_BORDER_NONE:
        break;
    }
}

void
vguiTheme::DrawControlBackground(vector atPos, vector withSize, VGUIDrawState_t drawStyle)
{
    if (drawStyle == VGUI_STATE_DISABLED) {
        drawfill(atPos, withSize, m_controlBackgroundColor.GetColor(), m_controlBackgroundColor.GetAlpha());
    } else {
        drawfill(atPos, withSize, m_controlBackgroundColor.GetColor(), m_controlBackgroundColor.GetAlpha());
    }
}

void
vguiTheme::DrawRadioButton(vector atPos, string withText, vector withSize, VGUIDrawState_t drawStyle)
{
    DrawControlBackground(atPos, withSize, drawStyle);

    if (drawStyle == VGUI_STATE_CHECKED) {
        DrawBorder(atPos, withSize, VGUI_BORDER_INSET, __NULL__);
    }

    if (drawStyle == VGUI_STATE_ACTIVE) {
        drawpic(atPos, "gfx/icon16/bullet_white", [16,16], [1,1,1], 1.0f, 0);
    } else {
        drawpic(atPos, "gfx/icon16/bullet_black", [16,16], [1,1,1], 1.0f, 0);
    }

    if (withText) {
        DrawText(atPos + [24, 3], withText, withSize, g_fntDefault);
    }
}


void
vguiTheme::DrawCheckBox(vector atPos, string withText, vector withSize, VGUIDrawState_t drawStyle)
{
    DrawControlBackground(atPos, withSize, VGUI_STATE_ACTIVE);

    if (drawStyle == VGUI_STATE_ACTIVE) {
        DrawBorder(atPos, withSize, VGUI_BORDER_INSET, __NULL__);
    }

    if (drawStyle == VGUI_STATE_CHECKED) {
        drawpic(atPos, "gfx/icon16/bullet_toggle_plus", [16,16], [1,1,1], 1.0f, 0);
    } else {
        drawpic(atPos, "gfx/icon16/bullet_black", [16,16], [1,1,1], 1.0f, 0);
    }

    if (withText) {
        DrawText(atPos + [24, 3], withText, withSize, g_fntDefault);
    }
}

void
vguiTheme::DrawSlider(vector atPos, string withText, string withIcon, vector withSize, VGUIDrawState_t drawStyle)
{
    if (STRING_SET(withText)) {
        DrawText(atPos, withText, withSize, g_fntDefault);
    }

    DrawBorder(atPos + [0, (withSize[1]/2) - 2], [withSize[0], 4], VGUI_BORDER_INSET, m_shadowColor);
}

void
vguiTheme::DrawControlText(vector atPos, string withText, float keyEquivalent, vector boundSize, VGUIDrawState_t drawStyle, font_s textFont)
{
    float textPadding = 8;

    /* size check is a quick hack for small buttons */
    if (keyEquivalent >= 0 && (boundSize[1] > 128)) {
        float length;
        string keyText = keynumtostring(keyEquivalent);

        length = Font_StringWidth(keyText, FALSE, textFont);
        textPadding += length + 8;
        DrawText(atPos + [8, 6], keyText, boundSize, textFont);
    }

    if (STRING_SET(withText)) {
        DrawText(atPos + [textPadding, 6], withText, boundSize, textFont);
    }
    //drawsetcliparea(atPos[0], atPos[1], boundSize[0], boundSize[1]);
    //drawfill(atPos, boundSize, [1,1,1], 0.5f);
    //drawresetcliparea();
}

void
vguiTheme::DrawControlTextWithIcon(vector atPos, string withText, float keyEquivalent, string iconPath, vector iconColor, vector iconSize, vector boundSize, VGUIDrawState_t drawStyle, font_s textFont)
{
    float textPadding = 8;

    /* size check is a quick hack for small buttons */
    if (keyEquivalent >= 0 && boundSize[0] > 32) {
        float length;
        string keyText = keynumtostring(keyEquivalent);

        length = Font_StringWidth(keyText, false, textFont);
        textPadding += length + 8;
        DrawText(atPos + [8, 6], keyText, boundSize, textFont);
    }

    if ((STRING_SET(iconPath) && IconsEnabled()) || (!STRING_SET(withText) && STRING_SET(iconPath))) {
        if (drawStyle == VGUI_STATE_CHECKED) {
            drawpic(atPos + [3,3], iconPath, iconSize, iconColor * 0.25, 1.0f, 0);
        } else {
            drawpic(atPos + [3,3], iconPath, iconSize, iconColor, 1.0f, 0);
        }

        textPadding += iconSize[0] + 3;
    }

    if (STRING_SET(withText)) {
        DrawText(atPos + [textPadding, 6], withText, boundSize, textFont);
    }
    //drawsetcliparea(atPos[0], atPos[1], boundSize[0], boundSize[1]);
    //drawfill(atPos, boundSize, [1,1,1], 0.5f);
    //drawresetcliparea();
}

void
vguiTheme::DrawTextBackground(vector atPos, vector withSize, VGUIDrawState_t drawStyle)
{
    drawfill(atPos, withSize, m_textBackgroundColor.GetColor(), m_textBackgroundColor.GetAlpha());
    drawfill(atPos, [withSize[0], 1], [0,0,0], 0.5f);
    drawfill(atPos + [0, withSize[1] - 1], [withSize[0], 1], [1,1,1], 0.5f);
    drawfill(atPos + [0, 1], [1, withSize[1] - 2], [0,0,0], 0.5f);
    drawfill(atPos + [withSize[0] - 1, 1], [1, withSize[1] - 2], [1,1,1], 0.5f);
}

void
vguiTheme::DrawListBackground(vector atPos, vector withSize, VGUIDrawState_t drawStyle)
{
    DrawTextBackground( atPos,  withSize,  drawStyle);
}


void
vguiTheme::DrawHighlight(vector atPos, vector withSize, VGUIDrawState_t drawStyle)
{
    drawfill(atPos, withSize, m_fillColor.GetColor(), m_fillColor.GetAlpha());
}

void
vguiTheme::DrawWindowBackground(vector atPos, vector withSize, VGUIDrawState_t drawStyle)
{
    drawfill(atPos, withSize, m_windowBackgroundColor.GetColor(), m_windowBackgroundColor.GetAlpha());
}

void
vguiTheme::DrawMenuBar(vector atPos, vector withSize, VGUIDrawState_t drawStyle)
{
    /* draw the panel */
    drawfill(atPos, [withSize[0], 28], m_controlBackgroundColor.GetColor(), 1.0f, 0);
    drawfill(atPos + [0,26], [withSize[0], 1], m_controlBackgroundColor.GetColor() * 0.5, 1.0f, 0);
    drawfill(atPos + [0,27], [withSize[0], 1], m_controlBackgroundColor.GetColor() * 0.1, 1.0f, 0);
}

void
vguiTheme::DrawButton(vector atPos, vector withSize, VGUIDrawState_t drawStyle)
{
    DrawControlBackground(atPos, withSize, drawStyle);

    if (drawStyle == VGUI_STATE_DISABLED) {
        drawfill(atPos + [0, withSize[1] - 1], [withSize[0], 1], m_lightColor.GetColor(), m_lightColor.GetAlpha() * 0.5f);
        drawfill(atPos, [withSize[0], 1], m_shadowColor.GetColor(), m_shadowColor.GetAlpha() * 0.5f);
        drawfill(atPos + [0, 1], [1, withSize[1] - 2], m_shadowColor.GetColor(), m_shadowColor.GetAlpha() * 0.5f);
        drawfill(atPos + [withSize[0] - 1, 1], [1, withSize[1] - 2], m_lightColor.GetColor(), m_lightColor.GetAlpha() * 0.5f);
    } else if (drawStyle == VGUI_STATE_ACTIVE) {
        drawfill(atPos + [0, withSize[1] - 1], [withSize[0], 1], m_lightColor.GetColor(), m_lightColor.GetAlpha());
        drawfill(atPos, [withSize[0], 1], m_shadowColor.GetColor(), m_shadowColor.GetAlpha());
        drawfill(atPos + [0, 1], [1, withSize[1] - 2], m_shadowColor.GetColor(), m_shadowColor.GetAlpha());
        drawfill(atPos + [withSize[0] - 1, 1], [1, withSize[1] - 2], m_lightColor.GetColor(), m_lightColor.GetAlpha());
    } else {
        drawfill(atPos + [0, withSize[1] - 1], [withSize[0], 1], m_shadowColor.GetColor(), m_shadowColor.GetAlpha());
        drawfill(atPos, [withSize[0], 1], m_lightColor.GetColor(), m_lightColor.GetAlpha());
        drawfill(atPos + [0, 1], [1, withSize[1] - 2], m_lightColor.GetColor(), m_lightColor.GetAlpha());
        drawfill(atPos + [withSize[0] - 1, 1], [1, withSize[1] - 2], m_shadowColor.GetColor(), m_shadowColor.GetAlpha());
    }

    if (drawStyle == VGUI_STATE_HOVER) {
        drawfill(atPos, withSize, m_hoverColor.GetColor(), m_hoverColor.GetAlpha());
    }
}

void
vguiTheme::DrawScroller(vector atPos, vector withSize, VGUIDrawState_t drawStyle)
{
    DrawControlBackground(atPos, withSize, drawStyle);

    drawfill(atPos + [0, withSize[1] - 1], [withSize[0], 1], m_shadowColor.GetColor(), m_shadowColor.GetAlpha());
    drawfill(atPos, [withSize[0], 1], m_lightColor.GetColor(), m_lightColor.GetAlpha());
    drawfill(atPos + [0, 1], [1, withSize[1] - 2], m_lightColor.GetColor(), m_lightColor.GetAlpha());
    drawfill(atPos + [withSize[0] - 1, 1], [1, withSize[1] - 2], m_shadowColor.GetColor(), m_shadowColor.GetAlpha());
}

void
vguiTheme::DrawScrollbar(vector atPos, vector withSize, VGUIDrawState_t drawStyle)
{
    DrawTextBackground(atPos, withSize, drawStyle);
}

void
vguiTheme::DrawProgressIndicator(vector atPos, vector withSize, float progressValue, VGUIDrawState_t drawStyle)
{
    drawfill(atPos + [0, withSize[1] - 1], [withSize[0], 1], m_lightColor.GetColor(), m_lightColor.GetAlpha());
    drawfill(atPos, [withSize[0], 1], m_shadowColor.GetColor(), m_shadowColor.GetAlpha());
    drawfill(atPos + [0, 1], [1, withSize[1] - 2], m_shadowColor.GetColor(), m_shadowColor.GetAlpha());
    drawfill(atPos + [withSize[0] - 1, 1], [1, withSize[1] - 2], m_lightColor.GetColor(), m_lightColor.GetAlpha());

    vector drawPos = [4,4];
    float max = floor(((withSize[0] - 8) * progressValue) / 12);

    for (float i = 0; i < max; i++ ) {
        drawfill(atPos + drawPos, [8, 16], m_fillColor.GetColor(), 1.0f);
        drawPos[0] += 12;
    }
}

void
vguiTheme::DrawText(vector atPos, string withText, vector boundSize, font_s textFont)
{
    //drawsetcliparea(atPos[0], atPos[1], boundSize[0], boundSize[1]);
    //drawfill(atPos, boundSize, [1,1,1], 0.5f);
    Font_DrawText_RGBA(atPos+[2,1], withText, m_shadowColor.GetColor(), 0.15f,textFont);
    Font_DrawText_RGB(atPos, withText, m_textColor.GetColor(), textFont);
    //drawresetcliparea();
}

void
vguiTheme::DrawHighlightText(vector atPos, string withText, vector boundSize, font_s textFont)
{
    //drawsetcliparea(atPos[0], atPos[1], boundSize[0], boundSize[1]);
    //drawfill(atPos, boundSize, [1,1,1], 0.5f);
    Font_DrawText_RGB(atPos, withText, m_highlightTextColor.GetColor(), textFont);
    //drawresetcliparea();
}


void
vguiTheme::DrawLabel(vector atPos, string withText, int labelFlags, int sizeOverride, vector boundSize, VGUIDrawState_t drawStyle)
{
    if (0) {
        if (!sizeOverride)
            Font_DrawField(atPos + [2,1], boundSize, strcat("^xAAA", withText), g_fntDefault, labelFlags);
        else
            Font_DrawFieldAtHeight(atPos + [2,1], boundSize, sizeOverride, strcat("^xAAA", withText), g_fntDefault, labelFlags);
    }

    if (!sizeOverride)
        Font_DrawField(atPos, boundSize, strcat(m_textColor.GetFunStringColor(), withText), g_fntDefault, labelFlags);
    else
        Font_DrawFieldAtHeight(atPos, boundSize, sizeOverride, strcat(m_textColor.GetFunStringColor(), withText), g_fntDefault, labelFlags);
}

void
vguiTheme::DrawWindow(vector atPos, vector withSize, VGUIDrawState_t drawStyle)
{
    static void
    DRB(vector pos, vector size, vector rgb, float a)
    {
        drawpic(pos, "gfx/ui/m_topleft.tga", [16,16], rgb, a, 0);
        drawpic(pos + [size[0] - 16, 0], "gfx/ui/m_topright.tga", [16,16], rgb, a, 0);
        drawpic(pos + [0, size[1] - 16], "gfx/ui/m_bottomleft.tga", [16,16], rgb, a, 0);
        drawpic(pos + [size[0] - 16, size[1] - 16], "gfx/ui/m_bottomright.tga", [16,16], rgb, a, 0);

        if (size_x > 32) {
            drawpic(pos + [16, 0], "gfx/ui/m_top.tga", [size[0] - 32, 16], rgb, a, 0);
            drawpic(pos + [16, size[1] - 16], "gfx/ui/m_bottom.tga", [size[0] - 32, 16], rgb, a, 0);
        }

        if (size_y > 32) {
            drawpic(pos + [0, 16], "gfx/ui/m_left.tga", [16, size[1] - 32], rgb, a, 0);
            drawpic(pos + [size[0] - 16, 16], "gfx/ui/m_right.tga", [16, size[1] - 32], rgb, a, 0);
            drawpic(pos + [16, 16], "gfx/ui/m_mid.tga", [size[0] - 32, size[1] - 32], rgb, a, 0);
        }
    }

    if (m_roundedCorners == true) {
        DRB(atPos, withSize, m_windowBackgroundColor.GetColor(), m_windowBackgroundColor.GetAlpha());
    } else {
        DrawWindowBackground(atPos, withSize, drawStyle);
    }
}



void
vguiTheme::DrawWindowBorder(vector atPos, vector withSize, VGUIDrawState_t drawStyle)
{

    static void
    DRB2(vector pos, vector size, vector rgb, float a)
    {
        drawpic(pos, "gfx/ui/m_linetopleft.tga", [16,16], rgb, a, 0);
        drawpic(pos + [size[0] - 16, 0], "gfx/ui/m_linetopright.tga", [16,16], rgb, a, 0);
        drawpic(pos + [0, size[1] - 16], "gfx/ui/m_linebottomleft.tga", [16,16], rgb, a, 0);
        drawpic(pos + [size[0] - 16, size[1] - 16], "gfx/ui/m_linebottomright.tga", [16,16], rgb, a, 0);

        if (size_x > 32) {
            drawpic(pos + [16, 0], "gfx/ui/m_linetop.tga", [size[0] - 32, 16], rgb, a, 0);
            drawpic(pos + [16, size[1] - 16], "gfx/ui/m_linebottom.tga", [size[0] - 32, 16], rgb, a, 0);
        }

        if (size_y > 32) {
            drawpic(pos + [0, 16], "gfx/ui/m_lineleft.tga", [16, size[1] - 32], rgb, a, 0);
            drawpic(pos + [size[0] - 16, 16], "gfx/ui/m_lineright.tga", [16, size[1] - 32], rgb, a, 0);
            drawpic(pos + [16, 16], "gfx/ui/m_linemid.tga", [size[0] - 32, size[1] - 32], rgb, a, 0);
        }
    }

    if (m_roundedCorners == true) {
        if (m_windowBorderColor.GetAlpha() > 0.0f) {
            DRB2(atPos, withSize, m_windowBorderColor.GetColor(), m_windowBorderColor.GetAlpha());
        }
    } else {
        DrawBorder(atPos, withSize, VGUI_BORDER_OUTSET, m_windowBorderColor);
    }
}


void
vguiTheme::DrawWindowTitle(vector atPos, vector withSize, string titleText, string withIcon, font_s textFont, VGUIDrawState_t drawStyle)
{
    if (m_roundedCorners == false) {
    if (drawStyle != VGUI_STATE_ACTIVE) {
        drawfill(atPos, [withSize[0], 28], m_inactiveTitleColor.GetColor(), 1.0f, 0);
        drawpic(atPos, "gfx/icon16/hgradient", [withSize[0], 28], m_gradientInactiveTitleColor.GetColor(), 1.0f, 0);
    } else {
        drawfill(atPos, [withSize[0], 28], m_activeTitleColor.GetColor(), 1.0f, 0);
        drawpic(atPos, "gfx/icon16/hgradient", [withSize[0], 28], m_gradientActiveTitleColor.GetColor(), 1.0f, 0);
    }
    }

    if (STRING_SET(titleText)) {
        if (STRING_SET(withIcon) && IconsEnabled()) {
            DrawText(atPos + [26, 8], titleText, withSize, textFont);

            if (m_roundedCorners == false) {
                if (drawStyle != VGUI_STATE_ACTIVE) {
                    Font_DrawText_RGB(atPos + [26, 8], titleText, m_inactiveTitleTextColor.GetColor(), textFont);
                } else {
                    Font_DrawText_RGB(atPos + [26, 8], titleText, m_activeTitleTextColor.GetColor(), textFont);
                }
            } else {
                if (drawStyle != VGUI_STATE_ACTIVE) {
                    Font_DrawText_RGB(atPos + [26, 8], titleText, m_textColor.GetColor(), textFont);
                } else {
                    Font_DrawText_RGB(atPos + [26, 8], titleText, m_textColor.GetColor(), textFont);
                }
            }

            drawpic(atPos + [4, 4], withIcon, [16,16], [1,1,1], 1.0f, 0);
        } else {
            DrawText(atPos + [8, 8], titleText, withSize, textFont);
        }
    }
}
