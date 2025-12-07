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

/** Trinity Menu File (ui/.menu files) handler

# Overview

This class handles the creation of  interfaces (Menus, HUDs, in-world interactive displays) using
external, plain text scripts.

# Console Commands

## trMenuOpen \[path to .menu file\]

Opens a named menu.

## trMenuClose \[name of menu\]

Closes a named menu. Only affects menus opened with trMenuOpen.
When a name is not specified, it's going to close all of the ones
that are currently open, including hidden windows.

# History

The original implementation of this script syntax can be found in
Quake III: Team Arena (2000), it was shortly after overhauled in the game
Return to Castle Wolfenstein (2001), adding the ability to
use custom fonts and more.

It then went on to appear primarily in the Call of Duty series, where the syntax itself
received almost no modifications from its RtCW origins.

We are currently sticking to a minimal subset of the original implementations
(more will be added over time) but also are allowing people to override rendering of items and menus
in both the [Client Game](@ref CSQC) and the [HudC](@ref hudC) progs.

This way you can write lean, specialized code routines for custom
items without having to sub-class. This way the client-game can provide
items for use in a game, and a custom HudC progs can then-again override them.

This should allow for sturdy re-use of elements, built on a proven
track-record in many best-selling games.

While we've evaluated other ways of defining interface resources, many
were incomplete in comparison and would have meant gluing different
systems together.

# Trivia

Doom 3 has a slightly more advanced variant, in that it also has means of handling state.
The syntax in that implementation has also changed in ways that make it
incompatible with our implementation.

Since we can allocate console variables on the fly, we already have means of
storing our own state. Currently exploring options.

# See also

[Q3TA Menu reference by PhaethonH](https://web.archive.org/web/20050308150534/http://www.linux.ucla.edu/~phaethon/q3tamenu/q3tamenu.txt)
*/
class
vguiTrUIMenu:vguiWidget
{
public:
	nonvirtual vguiTrUIMenu CreateFromMenuFile(vguiWidget parent, string filePath);
	nonvirtual void CloseAll(void);
	nonvirtual int InterpretLine(vguiWidget parent, int i, int lineNr, float wordsPerLine);
	nonvirtual void InterpretCommand(vguiWidget originWidget, string commandString);

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

.float m_serverSideNum;
