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

var vguiTrUISubMenu m_lastSubMenu;
var vguiTrUIItem m_lastItem;

void
vguiTrUIMenu::CloseAll(void)
{
	for (vguiTrUIMenu windowSearch = 0; (windowSearch = (vguiTrUIMenu)find(windowSearch, ::classname, "vguiTrUIMenu"));) {
		windowSearch.Hide();
	}
}

int
vguiTrUIMenu::InterpretLine(vguiWidget parent, int i, int lineNr, float wordsPerLine)
{
	string realWord = argv(i);
	string word = strtolower(realWord);
	string nextWord = argv(i+1);
	string macroLookUp = Constants_LookUp(strcat("$", nextWord), nextWord);

	incrementToken = 0;

	switch (word) {
	case "{":
		focusLevel = lastWord;

		/* anything outside braces defines the classname for the next def */
		if (lastWord == "assetglobaldef") {
			//printf("Created Menu %s\n", filePath);
		} else if (lastWord == "menudef") {
			m_lastSubMenu = spawn(vguiTrUISubMenu);
			m_lastSubMenu.m_trGlobal = this;
			parent.Add(m_lastSubMenu);
			//printf("Created menuDef for Menu\n");
		} else if (lastWord == "itemdef") {
			m_lastItem = spawn(vguiTrUIItem);
			m_lastItem.m_trGlobal = this;
			m_lastSubMenu.Add(m_lastItem);
			//printf("Created itemDef for MenuDef %s\n", m_lastSubMenu.m_trSubName);
		}

		braceDepth++;
		break;
	case "}":
		braceDepth--;
		
		if (focusLevel == "action") {
			printf("%s actions: %s\n", m_lastItem.m_trItemName, m_lastItem.m_trItemActionBuffer);
		}
		
		if (focusLevel == "mouseenter") {
			printf("%s mouseenter: %s\n", m_lastItem.m_trItemName, m_lastItem.m_trItemEnterBuffer);
		}
		
		if (focusLevel == "mouseexit") {
			printf("%s mouseexit: %s\n", m_lastItem.m_trItemName, m_lastItem.m_trItemExitBuffer);
		}

		focusLevel = "";
		break;
	default:
		if (word == "#include") {
			string includeFilePath = argv(i+1);
			filestream includeFile = fopen(includeFilePath, FILE_READ);
			string includeTempString;
			string lastIncludeWord = __NULL__;
			int includeLine = 1i;
			vguiTrUISubMenu oldSubMenu = m_lastSubMenu;
			vguiTrUISubMenu oldItem = m_lastItem;
			float includeWordsPerLine = 0;

			if (includeFile < 0) {
				ncError("Unable to read %S\n", includeFilePath);
			} else {
				/* line by line */
				while ((includeTempString = fgets(includeFile))) {
					string modifiedString = strreplace("}", " } ", includeTempString);
					includeTempString = strreplace("{", " { ", modifiedString);
					includeWordsPerLine = tokenize_console(includeTempString);

					for (float x = 0; x < includeWordsPerLine; x++) {
						float incrementCounter = InterpretLine(parent, x, includeLine, includeWordsPerLine);
						x += incrementCounter;
						includeWordsPerLine = tokenize_console(includeTempString);
					}
					includeLine++;
				}

				/* clean up */
				fclose(includeFile);
			}

			m_lastSubMenu = oldSubMenu;
			m_lastItem = oldItem;

			incrementToken++;
		} else if (word == "#define") {
			string macroName = argv(i+1);
			string macroValue = argv(i+2);
			
			for (int mtc = 3; mtc < wordsPerLine; mtc++) {
				macroValue = strcat(macroValue, " ", argv(i+mtc));
			}

			if (STRING_SET(macroValue)) {
				Constants_Add(macroName, macroValue);
			}
		} else if (focusLevel == "action") {
			m_lastItem.m_trItemActionBuffer = sprintf("%s%s ", m_lastItem.m_trItemActionBuffer, realWord);
		} else if (focusLevel == "mouseenter") {
			m_lastItem.m_trItemEnterBuffer = sprintf("%s%s ", m_lastItem.m_trItemEnterBuffer, realWord);
		} else if (focusLevel == "mouseexit") {
			m_lastItem.m_trItemExitBuffer = sprintf("%s%s ", m_lastItem.m_trItemExitBuffer, realWord);
		} else if (focusLevel == "assetglobaldef") {
			switch (word) {
			case "cursor":
				m_trGlobalCursor = macroLookUp;
				incrementToken++;
				break;
			case "gradientbar":
				incrementToken++;
				break;
			case "fadeclamp":
				incrementToken++;
				break;
			case "fadecycle":
				incrementToken++;
				break;
			case "fadeamount":
				incrementToken++;
				break;
			case "shadowx":
				incrementToken++;
				break;
			case "shadowy":
				incrementToken++;
				break;
			case "shadowcolor":
				incrementToken+=4;
				break;
			case "consolefont":
				incrementToken+=2;
				break;
			case "smallfont":
				incrementToken+=2;
				break;
			case "font":
				incrementToken+=2;
				break;
			case "bigfont":
				incrementToken+=2;
				break;
			case "extrabigfont":
				incrementToken+=2;
				break;
			case "boldfont":
				incrementToken+=2;
				break;
			default:
				ncError("assetGlobalDef: %i %S (LW: %S, NW: %S)", lineNr, argv(i), lastWord, argv(i+1));
			}
		} else if (focusLevel == "menudef") {
			switch (word) {
			case "name":
				m_lastSubMenu.m_trSubName = sprintf("%d_%s", num_for_edict(this), macroLookUp);
				incrementToken++;
				break;
			case "fullscreen":
				//m_lastSubMenu.m_trSubName = macroLookUp;
				//m_lastSubMenu.SetTitle(m_lastSubMenu.m_trSubName);
				incrementToken++;
				break;
			case "visible":
				m_lastSubMenu.m_bVisible = stof(macroLookUp);
				incrementToken++;
				break;
			case "rect":
				m_lastSubMenu.m_trSubRectMins[0] = stof(argv(i+1));
				m_lastSubMenu.m_trSubRectMins[1] = stof(argv(i+2));
				m_lastSubMenu.m_trSubRectMaxs[0] = stof(argv(i+3));
				m_lastSubMenu.m_trSubRectMaxs[1] = stof(argv(i+4));
				m_lastSubMenu.SetPos(m_lastSubMenu.m_trSubRectMins);
				m_lastSubMenu.SetSize(m_lastSubMenu.m_trSubRectMaxs);
				incrementToken+=4;
				break;
			case "bordercolor":
				m_lastSubMenu.m_trSubBorderColor[0] = stof(argv(i+1));
				m_lastSubMenu.m_trSubBorderColor[1] = stof(argv(i+2));
				m_lastSubMenu.m_trSubBorderColor[2] = stof(argv(i+3));
				m_lastSubMenu.m_trSubBorderAlpha = stof(argv(i+4));
				incrementToken+=4;
				break;
			case "backcolor":
				m_lastSubMenu.m_trSubBackColor[0] = stof(argv(i+1));
				m_lastSubMenu.m_trSubBackColor[1] = stof(argv(i+2));
				m_lastSubMenu.m_trSubBackColor[2] = stof(argv(i+3));
				m_lastSubMenu.m_trSubBackAlpha = stof(argv(i+4));
				incrementToken+=4;
				break;
			case "focuscolor":
				m_lastSubMenu.m_trSubFocusColor[0] = stof(argv(i+1));
				m_lastSubMenu.m_trSubFocusColor[1] = stof(argv(i+2));
				m_lastSubMenu.m_trSubFocusColor[2] = stof(argv(i+3));
				m_lastSubMenu.m_trSubFocusAlpha = stof(argv(i+4));
				incrementToken+=4;
				break;
			case "style":
				m_lastSubMenu.m_trSubStyle = stoi(macroLookUp);
				incrementToken++;
				break;
			case "border":
				m_lastSubMenu.m_trSubBorder = stoi(macroLookUp);
				incrementToken++;
				break;
			case "soundloop":
				m_lastSubMenu.m_trSubSoundLoop = macroLookUp;
				incrementToken++;
				break;
			case "popup":
			case "onopen":
			case "onclose":
			case "onesc":
			case "itemdef":
				break;
			default:
				ncError("menuDef: %i %S (LW: %S, NW: %S)", lineNr, argv(i), lastWord, argv(i+1));
			}
		} else if (focusLevel == "itemdef") {
			switch (word) {
			case "name":
				m_lastItem.m_trItemName = sprintf("%d_%s", num_for_edict(this), macroLookUp);
				incrementToken++;
				break;
			case "text":
				m_lastItem.m_trItemText = macroLookUp;
				incrementToken++;
				break;
			case "background":
				m_lastItem.m_trItemBackground = macroLookUp;
				incrementToken++;
				break;
			case "type":
				m_lastItem.m_trItemType = stoi(macroLookUp);
				incrementToken++;
				break;
			case "style":
				m_lastItem.m_trItemStyle = macroLookUp;
				incrementToken++;
				break;
			case "textstyle":
				m_lastItem.m_trItemTextStyle = stoi(macroLookUp);
				incrementToken++;
				break;
			case "decoration":
				m_lastItem.m_trItemDecoration = 1;
				break;
			case "visible":
				m_lastItem.m_bVisible = stof(macroLookUp);
				incrementToken++;
				break;
			case "forecolor":
				string foreR = argv(i+1);
				string foreG = argv(i+2);
				string foreB = argv(i+3);
				string foreA = argv(i+4);
				string macroforeR = Constants_LookUp(strcat("$", foreR), "");
				string macroforeG = Constants_LookUp(strcat("$", foreG), "");
				string macroforeB = Constants_LookUp(strcat("$", foreB), "");
				string macroforeA = Constants_LookUp(strcat("$", foreA), "");

				if (STRING_SET(macroforeR) && !STRING_SET(macroforeG)) {
					tokenize(macroforeR);
					foreR = argv(i+1);
					foreG = argv(i+2);
					foreB = argv(i+3);
					foreA = argv(i+4);
				}

				m_lastItem.m_trItemForeColor[0] = stof(foreR);
				m_lastItem.m_trItemForeColor[1] = stof(foreG);
				m_lastItem.m_trItemForeColor[2] = stof(foreB);
				m_lastItem.m_trItemForeAlpha = stof(foreA);

				incrementToken+=4;
				break;
			case "rect":
				string rectMinsX = argv(i+1);
				string rectMinsY = argv(i+2);
				string rectMaxsX = argv(i+3);
				string rectMaxsY = argv(i+4);
				string macroRectMinsX = Constants_LookUp(strcat("$", rectMinsX), "");
				string macroRectMinsY = Constants_LookUp(strcat("$", rectMinsY), "");
				string macroRectMaxsX = Constants_LookUp(strcat("$", rectMaxsX), "");
				string macroRectMaxsY = Constants_LookUp(strcat("$", rectMaxsY), "");

				if (STRING_SET(macroRectMinsX)) {
					m_lastItem.m_trItemRectMins[0] = stof(macroRectMinsX);
				} else {
					m_lastItem.m_trItemRectMins[0] = stof(rectMinsX);
				}
				if (STRING_SET(macroRectMinsY)) {
					m_lastItem.m_trItemRectMins[1] = stof(macroRectMinsY);
				} else {
					m_lastItem.m_trItemRectMins[1] = stof(rectMinsY);
				}
				if (STRING_SET(macroRectMaxsX)) {
					m_lastItem.m_trItemRectMaxs[0] = stof(macroRectMaxsX);
				} else {
					m_lastItem.m_trItemRectMaxs[0] = stof(rectMaxsX);
				}
				if (STRING_SET(macroRectMaxsY)) {
					m_lastItem.m_trItemRectMaxs[1] = stof(macroRectMaxsY);
				} else {
					m_lastItem.m_trItemRectMaxs[1] = stof(rectMaxsY);
				}

				m_lastItem.SetPos(m_lastItem.m_trItemRectMins);
				m_lastItem.SetSize(m_lastItem.m_trItemRectMaxs);
				incrementToken+=4;
				break;
			case "textfont":
				//m_lastItem.m_textfont = macroLookUp;
				incrementToken++;
				break;
			case "textscale":
				m_lastItem.m_trItemTextScale = stof(macroLookUp);
				incrementToken++;
				break;
			case "textalignx":
				m_lastItem.m_trItemTextAlignX = stof(macroLookUp);
				incrementToken++;
				break;
			case "textaligny":
				m_lastItem.m_trItemTextAlignY = stof(macroLookUp);
				incrementToken++;
				break;
			case "textstyle":
				m_lastItem.m_trItemTextStyle = stoi(macroLookUp);
				incrementToken++;
				break;
			case "ownerdraw":
				m_lastItem.m_trItemOwnerDraw = macroLookUp;
				incrementToken++;
				break;
			case "backcolor":
				m_lastItem.m_trItemBackColor[0] = stof(argv(i+1));
				m_lastItem.m_trItemBackColor[1] = stof(argv(i+2));
				m_lastItem.m_trItemBackColor[2] = stof(argv(i+3));
				m_lastItem.m_trItemBackAlpha = stof(argv(i+4));
				incrementToken+=4;
				break;
			case "bordercolor":
				m_lastItem.m_trItemBorderColor[0] = stof(argv(i+1));
				m_lastItem.m_trItemBorderColor[1] = stof(argv(i+2));
				m_lastItem.m_trItemBorderColor[2] = stof(argv(i+3));
				m_lastItem.m_trItemBorderAlpha = stof(argv(i+4));
				incrementToken+=4;
				break;
			case "group":
				m_lastItem.m_trItemGroup = macroLookUp;
				incrementToken++;
				break;
			case "textalign":
				m_lastItem.m_trItemTextAlign = macroLookUp;
				incrementToken++;
				break;
			case "border":
				m_lastItem.m_trItemBorder = macroLookUp;
				incrementToken++;
				break;
			case "cvartest":
				m_lastItem.m_trItemCvarTest = macroLookUp;
				incrementToken++;
				break;
			case "action":
			case "cvar":
			case "maxchars":
			case "showcvar":
			case "mouseenter":
			case "mouseexit":
				focusLevel = word;
				break;
			case "maxcharsgotonext":
				break;
			default:
				ncError("itemDef: %i: %S (LW: %S, NW: %S)", lineNr, argv(i), lastWord, argv(i+1));
			}
		}
	}

	lastWord = word;
	return (incrementToken);
}

vguiTrUIMenu
vguiTrUIMenu::CreateFromMenuFile(vguiWidget parent, string filePath)
{
	filestream defFile;
	string tempString = "";
	int lineNr = 1i;

	/* open file */
	defFile = fopen(filePath, FILE_READ);
	if (defFile < 0) {
		ncError("Unable to read %S\n", filePath);
		return (__NULL__);
	}

	vguiTrUIMenu newMenu = spawn(vguiTrUIMenu);

	/* line by line */
	while ((tempString = fgets(defFile))) {
		string modifiedString = strreplace("}", " } ", tempString);
		tempString = strreplace("{", " { ", modifiedString);
		float tokenCount = tokenize_console(tempString);

		for (float i = 0; i < tokenCount; i++) {
			float incrementCounter = (float)newMenu.InterpretLine(parent, i, lineNr, tokenCount);
			i += incrementCounter;
			tokenCount = tokenize_console(tempString);
		}
		lineNr++;
	}

	/* clean up */
	fclose(defFile);
	return (newMenu);
}
