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

class
vguiTrUIMenu:vguiWidget
{
public:
	nonvirtual vguiTrUIMenu CreateFromMenuFile(vguiWidget parent, string filePath);
	nonvirtual void CloseAll(void);
	nonvirtual int InterpretLine(vguiWidget parent, int i, int lineNr, float wordsPerLine);
	nonvirtual void InterpretCommand(string commandString);

private:
	/* assetGlobalDef */
	string m_trGlobalCursor;
	string m_trGlobalGradientBar;
	float m_trGlobalFadeClamp;
	float m_trGlobalFadeCycle;
	float m_trGlobalFadeAmount;
	float m_trGlobalShadowX;
	float m_trGlobalShadowY;
	vector m_trGlobalShadowColor;
	float m_trGlobalShadowAlpha;
	font_s *m_trGlobalConsoleFont;
	font_s *m_trGlobalSmallFont;
	font_s *m_trGlobalFont;
	font_s *m_trGlobalBigFont;
	font_s *m_trGlobalExtraBigFont;
	font_s *m_trGlobalBoldFont;

	string lastWord;
	float incrementToken;
	bool inEvent;
	int braceDepth;
	string focusLevel;
};
