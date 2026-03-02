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

#define UI_DEVELOPER

#define KEY_UNKNOWN 		-1
#define KEY_GAME 			0
#define KEY_MENU 			2
#define KEY_MENU_GRABBED 	3

#define TARGET_MENU 	1
#define TARGET_CLIENT 	2


/** Draw library */
typedef struct
{
/** Displays a solid colored rectangle at the specified position with a specified size.

@param rectPos is the position at which the rectangle will be drawn.
@param rectSize is the size at which we draw the rectangle, in pixels.
@param rectRGB  is the color of the rectangle, in normalized RGB values. E.g. `[1.0f, 0.0f, 0.0f]` for red.
@param rectAlpha is the alpha channel of the rectangle. 0.0 is invisible, 1.0 is fully visible. */
	void Rect(vector rectPos, vector rectSize, vector rectRGB , float rectAlpha);
/** Displays a colored rectangle outline at the specified position with a specified size.

@param rectPos is the position at which the rectangle will be drawn.
@param rectSize is the size at which we draw the rectangle, in pixels.
@param outlineThickness is the thickness of the outline. In pixels.
@param rectRGB  is the color of the rectangle, in normalized RGB values. E.g. `[0.0f, 0.0f, 1.0f]` for blue.
@param rectAlpha is the alpha channel of the rectangle. 0.0 is invisible, 1.0 is fully visible. */
	void RectOutline(vector rectPos, vector rectSize, float outlineThickness, vector rectColor, float rectAlpha);
/** Displays a colored, rounded rectangle outline at the specified position with a specified size.

@param rectPos is the position at which the rounded rectangle will be drawn.
@param rectSize is the size at which we draw the rounded rectangle, in pixels.
@param rectRGB  is the color of the rounded rectangle, in normalized RGB values. E.g. `[0.0f, 0.0f, 1.0f]` for blue.
@param rectAlpha is the alpha channel of the rounded rectangle. 0.0 is invisible, 1.0 is fully visible. */
	void RoundedRectOutline(vector rectPos, vector rectSize, vector rectColor, float rectAlpha);

/** Displays a colored rounded box at the specified position with a specified size.

@param boxPos is the position at which the box will be drawn.
@param boxSize is the size at which we draw the box, in pixels.
@param boxColor  is the color of the box, in normalized RGB values. E.g. `[1.0f, 1.0f, 0.0f]` for yellow.
@param boxAlpha is the alpha channel of the box. 0.0 is invisible, 1.0 is fully visible. */
	void RoundedBox(vector boxPos, vector boxSize, vector boxColor, float boxAlpha);

/** Displays a line with a specified thickness and color.

@param lineThickness is the thickness of the line in pixels.
@param startPos is the 'starting' point of the line.
@param endPos  is the second, 'endpoint' of the line.
@param lineColor  is the color of the line, in normalized RGB values. E.g. `[0.0f, 1.0f, 0.0f]` for green.
@param lineAlpha is the alpha channel of the rectangle. 0.0 is invisible, 1.0 is fully visible. */
	void Line(float lineThickness, vector startPos, vector endPos, vector lineColor, float lineAlpha);
/** Draws an image from either the virtual file-system, or the materials.

@param imagePosis the position at which the pic will be drawn.
@param imageName is the path/name of the image. Can be a material as well. E.g. "gfx/foo.png" or "conback".
@param imageSize  is the size at which we draw the pic, in pixels.
@param imageColor  is the color/tint of the pic, in normalized RGB values. E.g. `[0.5f, 0.5f, 0.5f]` for gray/grey.
@param imageAlpha is the alpha channel of the rectangle. 0.0 is invisible, 1.0 is fully visible. */
	void Pic(vector imagePos, string imageName, vector imageSize, vector imageColor, float imageAlpha, float imageFlags);
/** Draws part of an image from either the virtual file-system, or the materials.

@param imagePosis the position at which the pic will be drawn.
@param imageName is the path/name of the image. Can be a material as well. E.g. "gfx/foo.png" or "conback".
@param displaySize  is the size at which we draw the pic, in pixels.
@param sourcePos  is the position at which we start cropping from (top-left corner), in normalized values
@param sourceSize  is the normalized
@param imageColor  is the color/tint of the pic, in normalized RGB values. E.g. `[0.5f, 0.5f, 0.5f]` for gray/grey.
@param imageAlpha is the alpha channel of the rectangle. 0.0 is invisible, 1.0 is fully visible. */
	void SubPic(vector imagePos, vector displaySize, string imageName, vector sourcePos, vector sourceSize, vector imageColor, float imageAlpha, float imageFlags);
/** Draw text on the screen at the desired position with a desired font.

@param vecOrigin is the absolute starting position.
@param strText is the text to be drawn.
@param fnt is the font to be used. */
	void Text(vector vecOrigin, string strText, font_s fnt);
/** Draw alpha-blended text on the screen at the desired position with a desired font.

@param vecOrigin is the absolute starting position.
@param strText is the text to be drawn.
@param a is the alpha value to blend with.
@param fnt is the font to be used. */
	void Text_A(vector vecOrigin, string strText, float a, font_s fnt);
/** Draw tinted text on the screen at the desired position with a desired font.

@param vecOrigin is the absolute starting position.
@param strText is the text to be drawn.
@param col is the normalized color value to tint the text with.
@param fnt is the font to be used. */
	void Text_RGB(vector vecOrigin, string strText, vector col, font_s fnt);
/** Draw tinted and alpha blended text on the screen at the desired position
with a desired font.

@param vecOrigin is the absolute starting position.
@param strText is the text to be drawn.
@param col is the normalized color value to tint the text with.
@param a is the alpha value to blend with.
@param fnt is the font to be used. */
	void Text_RGBA(vector vecOrigin, string strText, vector col, float a, font_s fnt);
/** Right-aligned variant of Text().
@sa Text */
	void RText(vector vecOrigin, string strText, font_s fnt);
/** Right-aligned variant of Text_A().
@sa Font_DrawText_A */
	void RText_A(vector vecOrigin, string strText, float a, font_s fnt);
/** Right-aligned variant of Text_RGB().
@sa Font_DrawText_RGB */
	void RText_RGB(vector vecOrigin, string strText, vector col, font_s fnt);
/** Right-aligned variant of Text_RGBA().
@sa Font_DrawText_RGBA */
	void RText_RGBA(vector vecOrigin, string strText, vector col, float a, font_s fnt);
/** Draws a textfield with line wrapping.

@param vecOrigin is the absolute starting position.
@param vecSize is the total area in pixels that the field takes up on the screen.
@param strText is the text to be drawn onto the screen.
@param fnt is the font to be used for rendering the text.
@param iAlignFlags sets how the text may be aligned. */
	void TextField(vector vecOrigin, vector vecSize, string strText, font_s fnt, alignflags_t iAlignFlags);
/** Draws a textfield with line wrapping at a custom text height.

@param vecOrigin is the absolute starting position.
@param vecSize is the total area in pixels that the field takes up on the screen.
@param iTextHeight is the desired text height in pixels.
@param strText is the text to be drawn onto the screen.
@param fnt is the font to be used for rendering the text.
@param iAlignFlags sets how the text may be aligned. */
	void TextFieldAtHeight(vector vecOrigin, vector vecSize, int iTextHeight, string strText, font_s fnt, alignflags_t iAlignFlags);

	/** Draws an opaque, rectangular radar that is centered around the current player, or the player that is being spectated. */
	void RadarRect(vector vecOrigin, vector vecSize);
} drawAPI_t;
var drawAPI_t draw;/**< Access drawAPI_t functions using this variable. */

