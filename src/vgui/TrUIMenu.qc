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

font_s g_trConsoleFont;
font_s g_trSmallFont;
font_s g_trFont;
font_s g_trBigFont;
font_s g_trExtraBigFont;
font_s g_trBoldFont;

var vguiTrUISubMenu m_lastSubMenu;
var vguiTrUIItem m_lastItem;

void
vguiTrUIMenu::CloseAll(void)
{
	for (vguiTrUIMenu windowSearch = 0; (windowSearch = (vguiTrUIMenu)find(windowSearch, ::classname, "vguiTrUIMenu"));) {
		windowSearch.Hide();
	}
}

void
vguiTrUIMenu::InterpretCommand(vguiWidget originWidget, string commandString)
{

	int commandWords = tokenize_console(commandString);
	string firstWord = argv(0);
	string secondWord = argv(1);
	string thirdWord = argv(2);
	string targetLookUp = sprintf("%d_%s", num_for_edict(this), secondWord);
		printf("%s %s\n", firstWord, secondWord);

	if (!STRING_SET(firstWord)) {
		return;
	}

	switch (firstWord) {
	case "exec":
		localcmd(sprintf("%s\n", substring(commandString, 5, -1)));
		break;
	case "uiscript":
		break;
	case "fireOutput":
		vguiTrUIItem itemEnt = (vguiTrUIItem)originWidget;
		localcmd(sprintf("cmd ui_input %d FireOutput %s\n", this.owner.m_serverSideNum, secondWord));
		printf(sprintf("cmd ui_input %d FireOutput %s\n", this.owner.m_serverSideNum, secondWord));
		break;
	case "activateOnText":
		vguiTrUIItem itemEnt = (vguiTrUIItem)originWidget;
		localcmd(sprintf("cmd ui_input %d ActivateOnTextMatch %S\n", this.owner.m_serverSideNum, itemEnt.m_trItemText));
		break;
	case "settext":
		for (vguiTrUIItem windowSearch = 0; (windowSearch = (vguiTrUIItem)find(windowSearch, ::classname, "vguiTrUIItem"));) {
			if (targetLookUp == windowSearch.m_trItemName || targetLookUp == windowSearch.m_trItemGroup) {
				windowSearch.m_trItemText = thirdWord;
			}
		}
		break;
	case "addtext":
		for (vguiTrUIItem windowSearch = 0; (windowSearch = (vguiTrUIItem)find(windowSearch, ::classname, "vguiTrUIItem"));) {
			if (targetLookUp == windowSearch.m_trItemName || targetLookUp == windowSearch.m_trItemGroup) {
				windowSearch.AddText(thirdWord);
			}
		}
		break;
	case "setbackground":
		for (vguiTrUIItem windowSearch = 0; (windowSearch = (vguiTrUIItem)find(windowSearch, ::classname, "vguiTrUIItem"));) {
			if (targetLookUp == windowSearch.m_trItemName || targetLookUp == windowSearch.m_trItemGroup) {
				precache_pic(thirdWord);
				windowSearch.m_trItemBackground = thirdWord;
			}
		}
		break;
	case "setitemcolor":
		for (vguiTrUIItem windowSearch = 0; (windowSearch = (vguiTrUIItem)find(windowSearch, ::classname, "vguiTrUIItem"));) {
			if (targetLookUp == windowSearch.m_trItemName || targetLookUp == windowSearch.m_trItemGroup) {
				switch (thirdWord) {
				case "forecolor":
					windowSearch.m_trItemForeColor[0] = stof(argv(3));
					windowSearch.m_trItemForeColor[1] = stof(argv(4));
					windowSearch.m_trItemForeColor[2] = stof(argv(5));
					windowSearch.m_trItemForeAlpha = stof(argv(6));
					break;
				case "backcolor":
					windowSearch.m_trItemBackColor[0] = stof(argv(3));
					windowSearch.m_trItemBackColor[1] = stof(argv(4));
					windowSearch.m_trItemBackColor[2] = stof(argv(5));
					windowSearch.m_trItemBackAlpha = stof(argv(6));
				case "bordercolor":
					windowSearch.m_trItemBorderColor[0] = stof(argv(3));
					windowSearch.m_trItemBorderColor[1] = stof(argv(4));
					windowSearch.m_trItemBorderColor[2] = stof(argv(5));
					windowSearch.m_trItemBorderAlpha = stof(argv(6));
					break;
				}
			}
		}
		break;
	case "addframe":
		float framesToAdd = stof(thirdWord);

		for (vguiTrUIItem windowSearch = 0; (windowSearch = (vguiTrUIItem)find(windowSearch, ::classname, "vguiTrUIItem"));) {
			if (targetLookUp == windowSearch.m_trItemName || targetLookUp == windowSearch.m_trItemGroup) {
				windowSearch.m_trItemModelDelegate.frame += framesToAdd;
			}
		}
		break;
	case "removeframe":
		float framesToAdd = stof(thirdWord);

		for (vguiTrUIItem windowSearch = 0; (windowSearch = (vguiTrUIItem)find(windowSearch, ::classname, "vguiTrUIItem"));) {
			if (targetLookUp == windowSearch.m_trItemName || targetLookUp == windowSearch.m_trItemGroup) {
				windowSearch.m_trItemModelDelegate.frame -= framesToAdd;
			}
		}
		break;
	case "setmodel":
		for (vguiTrUIItem windowSearch = 0; (windowSearch = (vguiTrUIItem)find(windowSearch, ::classname, "vguiTrUIItem"));) {
			if (targetLookUp == windowSearch.m_trItemName || targetLookUp == windowSearch.m_trItemGroup) {
				windowSearch.m_trItemModel = thirdWord;
				setmodel(windowSearch.m_trItemModelDelegate, thirdWord);
			}
		}
		break;
	case "play":
		localcmd("play sound/common/wpn_select.wav\n");
		break;
	case "open":
		string fileToOpen = substring(commandString, 5, -1);

		if (STRING_SET(fileToOpen))
			localcmd(sprintf("trMenuOpen ui/%s.menu\n", substring(commandString, 5, -1)));
		break;
	case "show":
		for (vguiTrUIItem windowSearch = 0; (windowSearch = (vguiTrUIItem)find(windowSearch, ::classname, "vguiTrUIItem"));) {
			if (targetLookUp == windowSearch.m_trItemName || targetLookUp == windowSearch.m_trItemGroup)
				windowSearch.Show();
		}
		for (vguiTrUISubMenu windowSearch = 0; (windowSearch = (vguiTrUISubMenu)find(windowSearch, ::classname, "vguiTrUISubMenu"));) {
			if (targetLookUp == windowSearch.m_trSubName)
				windowSearch.Show();
		}
		break;
	case "close":
	case "hide":
		for (vguiTrUIItem windowSearch = 0; (windowSearch = (vguiTrUIItem)find(windowSearch, ::classname, "vguiTrUIItem"));) {
			if (targetLookUp == windowSearch.m_trItemName || targetLookUp == windowSearch.m_trItemGroup)
				windowSearch.Hide();
		}
		for (vguiTrUISubMenu windowSearch = 0; (windowSearch = (vguiTrUISubMenu)find(windowSearch, ::classname, "vguiTrUISubMenu"));) {
			if (targetLookUp == windowSearch.m_trSubName)
				windowSearch.Hide();
		}
		break;
	default:
		printf("InterpretCommand: %s\n", commandString);
	}
}

int
vguiTrUIMenu::InterpretLine(vguiWidget parent, int i, int lineNr, float wordsPerLine)
{
	string realWord = argv(i);
	string word = strtolower(realWord);
	string nextWord = argv(i+1);
	string macroLookUp = Constants_LookUp(strcat("$", nextWord), nextWord);
	string thirdWord = argv(i+3);

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
		} else if (focusLevel == "maxcharshit") {
			m_lastItem.m_trItemMaxCharBuffer = sprintf("%s%s ", m_lastItem.m_trItemMaxCharBuffer, realWord);
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
				Font_Load(realWord, g_trConsoleFont);
				m_trGlobalConsoleFont = &g_trConsoleFont;
				incrementToken += STRING_SET(thirdWord) ? 2 : 1;
				break;
			case "smallfont":
				Font_Load(realWord, g_trSmallFont);
				m_trGlobalSmallFont = &g_trSmallFont;
				incrementToken += STRING_SET(thirdWord) ? 2 : 1;
				break;
			case "font":
				Font_Load(macroLookUp, g_trFont);
				m_trGlobalFont = &g_trFont;
				incrementToken += STRING_SET(thirdWord) ? 2 : 1;
				break;
			case "bigfont":
				Font_Load(realWord, g_trBigFont);
				m_trGlobalBigFont = &g_trBigFont;
				incrementToken += STRING_SET(thirdWord) ? 2 : 1;
				break;
			case "extrabigfont":
				Font_Load(realWord, g_trExtraBigFont);
				m_trGlobalExtraBigFont = &g_trExtraBigFont;
				incrementToken += STRING_SET(thirdWord) ? 2 : 1;
				break;
			case "boldfont":
				Font_Load(realWord, g_trBoldFont);
				m_trGlobalBoldFont = &g_trBoldFont;
				incrementToken += STRING_SET(thirdWord) ? 2 : 1;
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
				m_lastItem.m_trItemOwnerDraw = stoi(macroLookUp);
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
				m_lastItem.m_trItemGroup = sprintf("%d_%s", num_for_edict(this), macroLookUp);
				incrementToken++;
				break;
			case "textalign":
				m_lastItem.m_trItemTextAlign = stoi(macroLookUp);
				incrementToken++;
				break;
			case "border":
				m_lastItem.m_trItemBorder = stoi(macroLookUp);
				incrementToken++;
				break;
			case "cvartest":
				m_lastItem.m_trItemCvarTest = macroLookUp;
				incrementToken++;
				break;
			case "maxchars":
				m_lastItem.m_trItemMaxChars = stoi(macroLookUp);
				incrementToken++;
				break;
			case "action":
			case "cvar":
			case "showcvar":
			case "mouseenter":
			case "mouseexit":
			case "maxcharshit":
				focusLevel = word;
				break;
			case "maxcharsgotonext":
				break;

			case "asset_model":
				m_lastItem.m_trItemModel = macroLookUp;
				incrementToken++;
				break;
			case "model_origin":
				m_lastItem.m_trItemModelOrigin[0] = stof(argv(i+1));
				m_lastItem.m_trItemModelOrigin[1] = stof(argv(i+2));
				m_lastItem.m_trItemModelOrigin[2] = stof(argv(i+3));
				incrementToken+=3;
				break;
			case "model_fov":
				m_lastItem.m_trItemModelFOVX =
				m_lastItem.m_trItemModelFOVY = stof(macroLookUp);
				incrementToken++;
				break;
			case "model_fovx":
				m_lastItem.m_trItemModelFOVX = stof(macroLookUp);
				incrementToken++;
				break;
			case "model_fovy":
				m_lastItem.m_trItemModelFOVY = stof(macroLookUp);
				incrementToken++;
				break;
			case "model_rotation":
				m_lastItem.m_trItemModelRotation[0] = stof(argv(i+1));
				m_lastItem.m_trItemModelRotation[1] = stof(argv(i+2));
				m_lastItem.m_trItemModelRotation[2] = stof(argv(i+3));
				incrementToken+=3;
				break;
			case "model_angle":
				m_lastItem.m_trItemModelAngles[1] = stof(macroLookUp);
				incrementToken++;
				break;
			case "model_angles":
				m_lastItem.m_trItemModelAngles[0] = stof(argv(i+1));
				m_lastItem.m_trItemModelAngles[1] = stof(argv(i+2));
				m_lastItem.m_trItemModelAngles[2] = stof(argv(i+3));
				incrementToken+=3;
				break;
			case "model_animplay":
				m_lastItem.m_trItemModelAnim = stof(macroLookUp);
				incrementToken++;
				break;
			case "model_avelocity":
				m_lastItem.m_trItemModelAngularVelocity[0] = stof(argv(i+1));
				m_lastItem.m_trItemModelAngularVelocity[1] = stof(argv(i+2));
				m_lastItem.m_trItemModelAngularVelocity[2] = stof(argv(i+3));
				incrementToken+=3;
				break;
			case "camera_origin":
				m_lastItem.m_trCamOrigin[0] = stof(argv(i+1));
				m_lastItem.m_trCamOrigin[1] = stof(argv(i+2));
				m_lastItem.m_trCamOrigin[2] = stof(argv(i+3));
				incrementToken+=3;
				break;
			case "camera_angles":
				m_lastItem.m_trCamAngles[0] = stof(argv(i+1));
				m_lastItem.m_trCamAngles[1] = stof(argv(i+2));
				m_lastItem.m_trCamAngles[2] = stof(argv(i+3));
				incrementToken+=3;
				break;
			case "camera_avelocity":
				m_lastItem.m_trCamAngularVelocity[0] = stof(argv(i+1));
				m_lastItem.m_trCamAngularVelocity[1] = stof(argv(i+2));
				m_lastItem.m_trCamAngularVelocity[2] = stof(argv(i+3));
				incrementToken+=3;
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
