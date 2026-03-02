class
vguiFont
{
public:
    void vguiFont(void);
    nonvirtual vguiFont LoadFontFromFile(string);


    /* standard drawing */
/** Draw text on the screen at the desired position with a desired font.

@param vecOrigin is the absolute starting position.
@param strText is the text to be drawn.
@param fnt is the font to be used. */
nonvirtual void DrawText(vector vecOrigin, string strText);
/** Draw alpha-blended text on the screen at the desired position with a desired font.

@param vecOrigin is the absolute starting position.
@param strText is the text to be drawn.
@param a is the alpha value to blend with.
@param fnt is the font to be used. */
nonvirtual void DrawText_A(vector vecOrigin, string strText, float a);
/** Draw tinted text on the screen at the desired position with a desired font.

@param vecOrigin is the absolute starting position.
@param strText is the text to be drawn.
@param col is the normalized color value to tint the text with.
@param fnt is the font to be used. */
nonvirtual void DrawText_RGB(vector vecOrigin, string strText, vector col);
/** Draw tinted and alpha blended text on the screen at the desired position
with a desired font.

@param vecOrigin is the absolute starting position.
@param strText is the text to be drawn.
@param col is the normalized color value to tint the text with.
@param a is the alpha value to blend with.
@param fnt is the font to be used. */
nonvirtual void DrawText_RGBA(vector vecOrigin, string strText, vector col, float a);

/* right aligned variants */
/** Right-aligned variant of DrawText.
@sa DrawText */
nonvirtual void DrawRText(vector vecOrigin, string strText);
/** Right-aligned variant of DrawText_A.
@sa DrawText_A */
nonvirtual void DrawRText_A(vector vecOrigin, string strText, float a);
/** Right-aligned variant of DrawText_RGB.
@sa DrawText_RGB */
nonvirtual void DrawRText_RGB(vector vecOrigin, string strText, vector col);
/** Right-aligned variant of DrawText_RGBA.
@sa DrawText_RGBA */
nonvirtual void DrawRText_RGBA(vector vecOrigin, string strText, vector col, float a);

/** Draws a textfield with line wrapping.

@param vecOrigin is the absolute starting position.
@param vecSize is the total area in pixels that the field takes up on the screen.
@param strText is the text to be drawn onto the screen.
@param fnt is the font to be used for rendering the text.
@param iAlignFlags sets how the text may be aligned. */
nonvirtual void DrawField(vector vecOrigin, vector vecSize, string strText, alignflags_t iAlignFlags);

/** Draws a textfield with line wrapping at a custom text height.

@param vecOrigin is the absolute starting position.
@param vecSize is the total area in pixels that the field takes up on the screen.
@param iTextHeight is the desired text height in pixels.
@param strText is the text to be drawn onto the screen.
@param fnt is the font to be used for rendering the text.
@param iAlignFlags sets how the text may be aligned. */
nonvirtual void DrawFieldAtHeight(vector vecOrigin, vector vecSize, int iTextHeight, string strText, alignflags_t iAlignFlags);

/** Converts a normalized RGB color vector to a hex color string.

@param vecColor is the normalized input color. E.g. [1.0f, 0.0f, 0.0f]
@return is a hex color string. e.g. "^xF00" */
nonvirtual string RGBtoHex(vector vecColor);

/** @brief Returns the height of a specified font in pixels.
@param fnt is the font to be queried.
@return is the height of a font in pixels.
@sa StringWidth
*/
nonvirtual int GetHeight();

/** @brief Returns the width of a series of characters in pixels.

If you have a string with funstring color codes (e.g. ^1 or ^xF00) and want to make
sure those are not interpreted as visible characters, set the parameter hasColor
to true. Rendering may be more expensive this way, but you should generally cache the
result instead of querying it every frame anyway.

The return value is of type float, to be a drop-in replacement for the engine builtin
stringwidth().

@param strText is the text to get the length of.
@param hasColor hints if funstring color codes are present in the string.
@param fnt is the font used with the text in question. */
nonvirtual float StringWidth(string strText, bool hasColor);

/** @brief Get the internal font id.

The internal font id is only useful for when you want to assign 'drawfont'
yourself, or have some other use for it. Those id's are meant to be unique,
but may change between vid_reload or other cases where video memory is de-allocated.
Overall you should never need to use this, unless you know what you're doing or are
porting old code.

@param fnt is the font to be queried.
@return the internal 'drawfont' id of the specified font. */
nonvirtual float GetID();

nonvirtual void DrawTextScroll(vector vecOrigin, string strText, vector canvasSize);
nonvirtual void DrawTextScroll_A(vector vecOrigin, string strText, vector canvasSize, float a);
nonvirtual void DrawTextScroll_RGB(vector vecOrigin, string strText, vector canvasSize, vector rgb);
nonvirtual void DrawTextScroll_RGBA(vector vecOrigin, string strText, vector canvasSize, vector rgb, float a);


private:
	string m_filePath;

	int iID;	/**< Internal ID, will be passed to 'drawfont' before rendering text. */
	int iScaleX; /**< Suggested maximum width of a character in the font. */
	int iScaleY; /**< Maximum height of a chracter in the font. */
	vector vecColor; /**< Suggested default color of the font. */
	float flAlpha; /**< Suggested default alpha of the font. */
	int iFlags;	/**< Rendering flags that the font posesses. @sa drawflag_t */
	string hexColor;
};

void
vguiFont::vguiFont(void)
{
    m_filePath = __NULL__;
}

vguiFont
vguiFont::LoadFontFromFile(string strFile)
{
    for (vguiFont fontEnum = 0; (fontEnum = (vguiFont)find(fontEnum, ::classname, "vguiFont"));) {
        if (fontEnum.m_filePath == strFile) {
            return (fontEnum);
        }
    }

    vguiFont newFont = spawn(vguiFont);
    newFont.m_filePath = strFile;
	string strTemp = "";
	string strFontPath = "";
	string strRenderSize = "";

	filestream fileFont = fopen(strFile, FILE_READ);
	newFont.iID = 0;
	newFont.iScaleX = newFont.iScaleY = 12;
	newFont.vecColor = [1,1,1];
	newFont.hexColor = "^xFFF";
	newFont.flAlpha = 1.0f;
	newFont.iFlags = 0;

	if (fileFont >= 0) {
		int argc;
		while ((strTemp = fgets(fileFont))) {
			float segments;
			argc = tokenize_console(strTemp);

			if (argc != 2)
				continue;

			switch (argv(0)) {
			case "color":
				newFont.vecColor = stov(argv(1)) / 255;
				newFont.hexColor = RGBtoHex(newFont.vecColor);
				break;
			case "alpha":
				newFont.flAlpha = stof(argv(1)) / 255;
				break;
			case "size_x":
				newFont.iScaleX = (int)stof(argv(1));
				break;
			case "size_y":
				newFont.iScaleY = (int)stof(argv(1));
				break;
			case "size":
				if ((autocvar(font_ttfOnly, 0) == 0) && (autocvar(font_bitmapOnly, 0) == 0)) {
					newFont.iScaleY = newFont.iScaleX = (int)stof(argv(1));
				}
				break;
			case "size_ttf":
				if (autocvar(font_ttfOnly, 0) == 1) {
					segments = tokenize(argv(1));

					if (segments == 2) {
						newFont.iScaleX = (int)stof(argv(0));
						newFont.iScaleY = (int)stof(argv(1));
					} else if (segments == 1) {
						newFont.iScaleY = newFont.iScaleX = (int)stof(argv(0));
					}
				}
				break;
			case "size_bitmap":
				if (autocvar(font_bitmapOnly, 0) == 1) {
					segments = tokenize(argv(1));

					if (segments == 2) {
						newFont.iScaleX = (int)stof(argv(0));
						newFont.iScaleY = (int)stof(argv(1));
					} else if (segments == 1) {
						newFont.iScaleY = newFont.iScaleX = (int)stof(argv(0));
					}
				}
				break;
			case "path":
				if ((autocvar(font_ttfOnly, 0) == 0) && (autocvar(font_bitmapOnly, 0) == 0)) {
					strFontPath = argv(1);
				}
				break;
			case "path_ttf":
				if (autocvar(font_ttfOnly, 0) == 1) {
					strFontPath = argv(1);
				}
				break;
			case "path_bitmap":
				if (autocvar(font_bitmapOnly, 0) == 1) {
					strFontPath = argv(1);
				}
				break;
			case "rendersize":
				strRenderSize = argv(1);
				break;
			case "flags":
				newFont.iFlags = (int)stof(argv(1));
				break;
			case "additive":
				if (stof(argv(1)) == 1)
					newFont.iFlags = DRAWFLAG_ADDITIVE;
				break;
			default:
				break;
			}
		}
		fclose(fileFont);
	} else {
		ncError("Missing file %s", strFile);
	}

	if (!newFont.iScaleX || !newFont.iScaleY) {
		ncError("Invalid size defined for %s", strFile);
		newFont.iScaleX = 12i;
		newFont.iScaleY = 12i;
	}

	ncLogAlways("...precached font %S (%i x %i)", strFile, newFont.iScaleX, newFont.iScaleY);

	if (strRenderSize != "") {
		newFont.iID = (int)loadfont("", strFontPath, strRenderSize, -1, 0, 0);
	} else
		newFont.iID = (int)loadfont("", strFontPath, ftos((float)newFont.iScaleY), -1, 0, 0);

#if 0
	/* this is the console font, so make sure we use it */
	if (strFile == "fonts/consoleFont.font") {
		string r = ftos(newFont.vecColor[0]);
		string g = ftos(newFont.vecColor[1]);
		string b = ftos(newFont.vecColor[2]);
		cvar_set("con_textfont", strcat(strFontPath, "?col=", r, ",", g, ",", b));

		/* just to be extra sure */
		if (newFont.iScaleY > 0i) {
			string size = ftos((float)newFont.iScaleY);
			cvar_set("con_textsize", strcat("-", size));
		}
	}
#endif
	return (newFont);
}


float
vguiFont::GetID(void)
{
	return (float)iID;
}

void
vguiFont::DrawText(vector vecOrigin, string strText)
{
	drawfont = (float)iID;
	drawstring(vecOrigin, strText, [iScaleX, iScaleY], vecColor, flAlpha, (float)iFlags);
	drawfont = 0;
}

void
vguiFont::DrawTextScroll(vector vecOrigin, string strText, vector canvasSize)
{
	DrawTextScroll_RGBA(vecOrigin , strText, canvasSize, [1,1,1], 1.0f);
}

void
vguiFont::DrawTextScroll_A(vector vecOrigin, string strText, vector canvasSize, float a)
{
	DrawTextScroll_RGBA(vecOrigin , strText, canvasSize, [1,1,1], a);
}

void
vguiFont::DrawTextScroll_RGB(vector vecOrigin, string strText, vector canvasSize, vector rgb)
{
	DrawTextScroll_RGBA(vecOrigin , strText, canvasSize, rgb, 1.0f);
}

void
vguiFont::DrawTextScroll_RGBA(vector vecOrigin, string strText, vector canvasSize, vector rgb, float a)
{
	float width = StringWidth(strText, true);
	static float offset = 0;

	if (width > canvasSize[0]) {
		offset -= frametime * 30;
		if (offset < -width)
			offset = width;
	}

	drawsetcliparea(vecOrigin[0], vecOrigin[1], canvasSize[0], canvasSize[1]);
	DrawText(vecOrigin + [offset, 0], strText);

	if (offset < 0)
		DrawText(vecOrigin + [width + offset, 0], strText);
	else if (offset > 0)
		DrawText(vecOrigin + [offset - width, 0], strText);

	drawresetcliparea();
}

void
vguiFont::DrawText_A(vector vecOrigin, string strText, float a)
{
	drawfont = (float)iID;
	drawstring(vecOrigin, strText, [iScaleX, iScaleY], vecColor, a, (float)iFlags);
	drawfont = 0;
}

void
vguiFont::DrawText_RGB(vector vecOrigin, string strText, vector rgb)
{
	drawfont = (float)iID;
	drawstring(vecOrigin, strText, [iScaleX, iScaleY], rgb, flAlpha, (float)iFlags);
	drawfont = 0;
}

void
vguiFont::DrawText_RGBA(vector vecOrigin, string strText, vector rgb, float a)
{
	drawfont = (float)iID;
	drawstring(vecOrigin, strText, [iScaleX, iScaleY], rgb, a, (float)iFlags);
	drawfont = 0;
}

void
vguiFont::DrawRText(vector vecOrigin, string strText)
{
	vecOrigin[0] -= StringWidth(strText, TRUE);
	DrawText(vecOrigin, strText);
}

void
vguiFont::DrawRText_A(vector vecOrigin, string strText, float a)
{
	vecOrigin[0] -= StringWidth(strText, TRUE);
	DrawText_A(vecOrigin, strText, a);
}

void
vguiFont::DrawRText_RGB(vector vecOrigin, string strText, vector rgb)
{
	vecOrigin[0] -= StringWidth(strText, TRUE);
	DrawText_RGB(vecOrigin, strText, rgb);
}

void
vguiFont::DrawRText_RGBA(vector vecOrigin, string strText, vector rgb, float a)
{
	vecOrigin[0] -= StringWidth(strText, TRUE);
	DrawText_RGBA(vecOrigin, strText, rgb, a);
}

void
vguiFont::DrawField(vector vecOrigin, vector vecSize, string strText, alignflags_t iAlignFlags)
{
	drawfont = (float)iID;
	drawfontscale[0] = (float)iScaleX / 8;
	drawfontscale[1] = (float)iScaleY / 8;
	drawtextfield(vecOrigin, vecSize, (float)iAlignFlags, strcat(hexColor, strText));
	drawfont = 0;
	drawfontscale = [1,1,0];
}

void
vguiFont::DrawFieldAtHeight(vector vecOrigin, vector vecSize, int iTextHeight, string strText, alignflags_t iAlignFlags)
{
	drawfont = (float)iID;
	drawfontscale[0] = (float)iTextHeight / 8;
	drawfontscale[1] = (float)iTextHeight / 8;
	drawtextfield(vecOrigin, vecSize, (float)iAlignFlags, strcat(hexColor, strText));
	drawfont = 0;
	drawfontscale = [1,1,0];
}

string
vguiFont::RGBtoHex(vector vecColor)
{
	static string numtohex(float x) {
		x = rint(x * 15);
		if (x <= 9)
			return ftos(x);
		else {
			x -= 10;
			return sprintf("%c", 'A' + x);
		}

	}

	return sprintf("^x%s%s%s", numtohex(vecColor[0]), numtohex(vecColor[1]), numtohex(vecColor[2]));
}

int
vguiFont::GetHeight(void)
{
	return (float)iScaleY;
}

float
vguiFont::StringWidth(string strText, bool hasColor)
{
	float w;
	drawfont = (float)iID;
	w = stringwidth(strText, (float)hasColor, [iScaleX, iScaleY]);
	drawfont = 0;
	drawfontscale = [1,1,0];
	return w;
}
