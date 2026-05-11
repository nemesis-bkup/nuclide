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

var vguiScriptedMenu m_lastSubMenu;
var vguiScriptedItem m_lastItem;

.float skin;

void
vguiScriptedView::CloseAll(void)
{
    for (vguiScriptedView windowSearch = 0; (windowSearch = (vguiScriptedView)find(windowSearch, ::classname, "vguiScriptedView"));) {
        windowSearch.Hide();
    }
}

void
vguiScriptedView::Reposition(void)
{
}

void
vguiScriptedView::UIScript_Command(string commandString)
{
    switch (commandString) {
    case "quit":
        localcmd("quit\n");
        break;
    case "leave":
        localcmd("disconnect\n");
        break;
    case "closeingame":
        localcmd("togglemenu\n");
        break;
    case "loadcontrols":
        break;
    case "playmovie":
        break;
    default:
        ncWarning("%s not known", commandString);
    }
}

void
vguiScriptedView::InterpretCommand(vguiWidget originWidget, string commandString)
{

    int commandWords = tokenize_console(commandString);
    string firstWord = argv(0);
    string secondWord = argv(1);
    string thirdWord = argv(2);
    string targetLookUp = sprintf("%d_%s", num_for_edict(this), secondWord);
    //printf("%s %s\n", firstWord, secondWord);

    if (!STRING_SET(firstWord)) {
        return;
    }

    switch (strtolower(firstWord)) {
    case "exec":
        string subString = substring(commandString, 5, -1);
        ncLog("executing console command %S", subString);
        localcmd(sprintf("%s\n", subString));
        break;
#if 0
    /* too ambitious for now */
    case "pr_exec":
        if (this.owner) {
            if (this.owner.classname == "vguiDesktopAppDelegate") {
                vguiDesktopAppDelegate appDelegate = (vguiDesktopAppDelegate)this.owner;
                appDelegate.PR_Exec(substring(commandString, 5, -1));
            }
        }
        break;
#endif
    case "uiscript":
        UIScript_Command(secondWord);
        break;
    case "fireoutput":
        vguiScriptedItem itemEnt = (vguiScriptedItem)originWidget;
        ncLog("firing output %S on entity %d owning UI", secondWord, this.owner.m_serverSideNum);
        localcmd(sprintf("cmd ui_input %d FireOutput %s\n", this.owner.m_serverSideNum, secondWord));
        //printf(sprintf("cmd ui_input %d FireOutput %s\n", this.owner.m_serverSideNum, secondWord));
        break;
    case "fireoutput_model_frame":
        vguiScriptedItem itemEnt = (vguiScriptedItem)originWidget;

        ncLog("firing output %S on entity %d owning UI with current framegroup id as data", secondWord, this.owner.m_serverSideNum);

        for (vguiScriptedItem itemSearch = 0; (itemSearch = (vguiScriptedItem)find(itemSearch, ::classname, "vguiScriptedItem"));) {
            /* found the named model */
            if (targetLookUp == itemSearch.m_trItemName) {
                localcmd(sprintf("cmd ui_input %d FireOutput %d\n", this.owner.m_serverSideNum, itemSearch.m_trItemModelDelegate.frame+1));
                printf(sprintf("cmd ui_input %d FireOutput %d\n", this.owner.m_serverSideNum, itemSearch.m_trItemModelDelegate.frame+1));
                break;
            }
        }
        break;
    case "fireoutput_model_skin":
        vguiScriptedItem itemEnt = (vguiScriptedItem)originWidget;

        ncLog("firing output %S on entity %d owning UI with current skin id as data", secondWord, this.owner.m_serverSideNum);

        for (vguiScriptedItem itemSearch = 0; (itemSearch = (vguiScriptedItem)find(itemSearch, ::classname, "vguiScriptedItem"));) {
            /* found the named model */
            if (targetLookUp == itemSearch.m_trItemName) {
                localcmd(sprintf("cmd ui_input %d FireOutput %d\n", this.owner.m_serverSideNum, itemSearch.m_trItemModelDelegate.skin+1));
                printf(sprintf("cmd ui_input %d FireOutput %d\n", this.owner.m_serverSideNum, itemSearch.m_trItemModelDelegate.skin+1));
                break;
            }
        }
        break;
    case "activateontext":
        vguiScriptedItem itemEnt = (vguiScriptedItem)originWidget;
        ncLog("if %S is a valid match on entity %d, activate targets", itemEnt.m_trItemText, this.owner.m_serverSideNum);
        localcmd(sprintf("cmd ui_input %d ActivateOnTextMatch %S\n", this.owner.m_serverSideNum, itemEnt.m_trItemText));
        break;
    case "settext":
        ncLog("text of %S changed to %S", targetLookUp, thirdWord);

        for (vguiScriptedItem windowSearch = 0; (windowSearch = (vguiScriptedItem)find(windowSearch, ::classname, "vguiScriptedItem"));) {
            if (targetLookUp == windowSearch.m_trItemName || targetLookUp == windowSearch.m_trItemGroup) {
                windowSearch.m_trItemText = thirdWord;
            }
        }
        break;
    case "addtext":
        ncLog("text of %S gets %S appended", targetLookUp, thirdWord);

        for (vguiScriptedItem windowSearch = 0; (windowSearch = (vguiScriptedItem)find(windowSearch, ::classname, "vguiScriptedItem"));) {
            if (targetLookUp == windowSearch.m_trItemName || targetLookUp == windowSearch.m_trItemGroup) {
                windowSearch.AddText(thirdWord);
            }
        }
        break;
    case "beginreceive":
        string shareItemGroup = sprintf("%d_%s", num_for_edict(this), "sharedItem");

        /* hide anything else currently playing media. */
        for (vguiScriptedItem windowSearch = 0; (windowSearch = (vguiScriptedItem)find(windowSearch, ::classname, "vguiScriptedItem"));) {
            if (targetLookUp == windowSearch.m_trItemName) {
                //windowSearch.OpenURL(thirdWord);
            } else if (windowSearch.m_trItemGroup == shareItemGroup) {
                windowSearch.OpenURL("");
                windowSearch.Hide();
            }
        }
        break;
    case "receive":
        string shareItemGroup = sprintf("%d_%s", num_for_edict(this), "sharedItem");

        /* this needs to mirror beginshare, but in reverse */
        for (vguiScriptedItem windowSearch = 0; (windowSearch = (vguiScriptedItem)find(windowSearch, ::classname, "vguiScriptedItem"));) {
            if (targetLookUp == windowSearch.m_trItemName) {
                windowSearch.OpenURL(thirdWord);
            } else if (windowSearch.m_trItemGroup == shareItemGroup) {
                //windowSearch.OpenURL("");
                //windowSearch.Hide();
            }
        }
        break;
    case "media_navigate":
        ncLog("media of %S becomes %S", targetLookUp, thirdWord);

        for (vguiScriptedItem windowSearch = 0; (windowSearch = (vguiScriptedItem)find(windowSearch, ::classname, "vguiScriptedItem"));) {
            if (targetLookUp == windowSearch.m_trItemName || targetLookUp == windowSearch.m_trItemGroup) {
                gecko_navigate(windowSearch.m_webViewName, thirdWord);
            }
        }
        break;
    case "setbackground":
        ncLog("background of %S becomes %S", targetLookUp, thirdWord);

        for (vguiScriptedItem windowSearch = 0; (windowSearch = (vguiScriptedItem)find(windowSearch, ::classname, "vguiScriptedItem"));) {
            if (targetLookUp == windowSearch.m_trItemName || targetLookUp == windowSearch.m_trItemGroup) {
                precache_pic(thirdWord);
                windowSearch.m_trItemBackground = thirdWord;
            }
        }
        break;
    case "setcolor":
    case "setitemcolor":
        for (vguiScriptedItem windowSearch = 0; (windowSearch = (vguiScriptedItem)find(windowSearch, ::classname, "vguiScriptedItem"));) {
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
    case "skinincrement":
        float maxSkin = stof(thirdWord);

        for (vguiScriptedItem windowSearch = 0; (windowSearch = (vguiScriptedItem)find(windowSearch, ::classname, "vguiScriptedItem"));) {
            if (targetLookUp == windowSearch.m_trItemName || targetLookUp == windowSearch.m_trItemGroup) {
                windowSearch.m_trItemModelDelegate.skin++;

                if (windowSearch.m_trItemModelDelegate.skin > maxSkin) {
                    windowSearch.m_trItemModelDelegate.skin = maxSkin;
                }
            }
        }
        break;
    case "skindecrement":
        float minSkin = stof(thirdWord);

        for (vguiScriptedItem windowSearch = 0; (windowSearch = (vguiScriptedItem)find(windowSearch, ::classname, "vguiScriptedItem"));) {
            if (targetLookUp == windowSearch.m_trItemName || targetLookUp == windowSearch.m_trItemGroup) {
                windowSearch.m_trItemModelDelegate.skin--;

                if (windowSearch.m_trItemModelDelegate.skin < minSkin) {
                    windowSearch.m_trItemModelDelegate.skin = minSkin;
                }
            }
        }
        break;
    case "addframe":
        float framesToAdd = stof(thirdWord);

        for (vguiScriptedItem windowSearch = 0; (windowSearch = (vguiScriptedItem)find(windowSearch, ::classname, "vguiScriptedItem"));) {
            if (targetLookUp == windowSearch.m_trItemName || targetLookUp == windowSearch.m_trItemGroup) {
                windowSearch.m_trItemModelDelegate.frame += framesToAdd;
            }
        }
        break;
    case "removeframe":
        float framesToAdd = stof(thirdWord);

        for (vguiScriptedItem windowSearch = 0; (windowSearch = (vguiScriptedItem)find(windowSearch, ::classname, "vguiScriptedItem"));) {
            if (targetLookUp == windowSearch.m_trItemName || targetLookUp == windowSearch.m_trItemGroup) {
                windowSearch.m_trItemModelDelegate.frame -= framesToAdd;
            }
        }
        break;
    case "setmodel":
        for (vguiScriptedItem windowSearch = 0; (windowSearch = (vguiScriptedItem)find(windowSearch, ::classname, "vguiScriptedItem"));) {
            if (targetLookUp == windowSearch.m_trItemName || targetLookUp == windowSearch.m_trItemGroup) {
                windowSearch.m_trItemModel = thirdWord;
                setmodel(windowSearch.m_trItemModelDelegate, thirdWord);
            }
        }
        break;
    case "clingleft":
        /* moves the named item left to the element on which this action happens. when optional values are specified it'll adjust the offset */
        for (vguiScriptedItem windowSearch = 0; (windowSearch = (vguiScriptedItem)find(windowSearch, ::classname, "vguiScriptedItem"));) {
            if (targetLookUp == windowSearch.m_trItemName || targetLookUp == windowSearch.m_trItemGroup) {
                //windowSearch.m_trItemTRItemRectMins[0] = originWidget.m_trItemTRItemRectMins[0] + stof(argv(3)) - windowSearch.m_trItemTRItemRectMaxs[0];
                //windowSearch.m_trItemTRItemRectMins[1] = originWidget.m_trItemTRItemRectMins[1] + stof(argv(4)) - windowSearch.m_trItemTRItemRectMaxs[1];
            }
        }
        break;
    case "clingright":
        /* moves the named item right to the element on which this action happens. when optional values are specified it'll adjust the offset */
        for (vguiScriptedItem windowSearch = 0; (windowSearch = (vguiScriptedItem)find(windowSearch, ::classname, "vguiScriptedItem"));) {
            if (targetLookUp == windowSearch.m_trItemName || targetLookUp == windowSearch.m_trItemGroup) {
                //windowSearch.m_trItemTRItemRectMins[0] = originWidget.m_trItemTRItemRectMins[0] + stof(argv(3)) + originWidget.m_trItemTRItemRectMaxs[0];
                //windowSearch.m_trItemTRItemRectMins[1] = originWidget.m_trItemTRItemRectMins[1] + stof(argv(4)) + originWidget.m_trItemTRItemRectMaxs[1];
            }
        }
        break;

    case "transition":
        float endX = stof(argv(6));
        float endY = stof(argv(7));
        float endW = stof(argv(8));
        float endH = stof(argv(9));

        ncLog("transition of %S to %d,%d %dx%d", targetLookUp, endX, endY, endW, endH);

        /* moves the named item right to the element on which this action happens. when optional values are specified it'll adjust the offset */
        for (vguiScriptedItem windowSearch = 0; (windowSearch = (vguiScriptedItem)find(windowSearch, ::classname, "vguiScriptedItem"));) {
            if (targetLookUp == windowSearch.m_trItemName || targetLookUp == windowSearch.m_trItemGroup) {
                windowSearch.m_vecOrigin[0] = endX;
                windowSearch.m_vecOrigin[1] = endY;
                windowSearch.m_vecSize[0] = endW;
                windowSearch.m_vecSize[1] = endH;
            }
        }

        /* moves the named item right to the element on which this action happens. when optional values are specified it'll adjust the offset */
        for (vguiScriptedMenu windowSearch = 0; (windowSearch = (vguiScriptedMenu)find(windowSearch, ::classname, "vguiScriptedMenu"));) {
            if (targetLookUp == windowSearch.m_trSubName) {
                windowSearch.m_vecOrigin[0] = endX;
                windowSearch.m_vecOrigin[1] = endY;
                windowSearch.m_vecSize[0] = endW;
                windowSearch.m_vecSize[1] = endH;
            }
        }
        break;
    case "play":
        localcmd("play sound/common/wpn_select.wav\n");
        break;

    case "playlooped":
        localcmd(sprintf("music %s\n", secondWord));
        break;

    case "file":
        string fileToOpen = secondWord;
#ifdef CLIENT
        if (STRING_SET(fileToOpen))
            localcmd(sprintf("trMenuOpen ui/%s.menu\n", secondWord));
#else
        if (STRING_SET(fileToOpen))
            m_parent.Add(vguiScriptedView::CreateFromMenuFile(m_parent, strcat("ui/", fileToOpen, ".menu")));
#endif
    case "open":
        ncLog("open menu %S", targetLookUp);

        for (vguiScriptedMenu windowSearch = 0; (windowSearch = (vguiScriptedMenu)find(windowSearch, ::classname, "vguiScriptedMenu"));) {
            if (targetLookUp == windowSearch.m_trSubName)
                windowSearch.Show();
        }

        break;
    case "fadein":
    case "show":
        ncLog("show menu %S", targetLookUp);

        for (vguiScriptedItem windowSearch = 0; (windowSearch = (vguiScriptedItem)find(windowSearch, ::classname, "vguiScriptedItem"));) {
            if (targetLookUp == windowSearch.m_trItemName || targetLookUp == windowSearch.m_trItemGroup)
                windowSearch.Show();
        }
        for (vguiScriptedMenu windowSearch = 0; (windowSearch = (vguiScriptedMenu)find(windowSearch, ::classname, "vguiScriptedMenu"));) {
            if (targetLookUp == windowSearch.m_trSubName)
                windowSearch.Show();
        }
        break;
    case "fadeout":
    case "close":
    case "hide":
        ncLog("hide menu %S", targetLookUp);

        for (vguiScriptedItem windowSearch = 0; (windowSearch = (vguiScriptedItem)find(windowSearch, ::classname, "vguiScriptedItem"));) {
            if (targetLookUp == windowSearch.m_trItemName || targetLookUp == windowSearch.m_trItemGroup)
                windowSearch.Hide();
        }
        for (vguiScriptedMenu windowSearch = 0; (windowSearch = (vguiScriptedMenu)find(windowSearch, ::classname, "vguiScriptedMenu"));) {
            if (targetLookUp == windowSearch.m_trSubName)
                windowSearch.Hide();
        }
        break;
    default:
        printf("InterpretCommand: %s\n", commandString);
    }
}

int
vguiScriptedView::InterpretLine(vguiWidget parent, int i, int lineNr, float wordsPerLine)
{
    string realWord = argv(i);
    string word = strtolower(realWord);
    string nextWord = argv(i+1);
    string macroLookUp;
    string secondWord = argv(i+2);
    string thirdWord = argv(i+3);

    if (substring(nextWord, 0, 1) == "@")
        macroLookUp = localize(strcat("#", substring(nextWord, 1, -1)));
    else
        macroLookUp = localize(ncConstantManager::LookUp(strcat("$", nextWord), nextWord));

    incrementToken = 0;

    switch (word) {
    case "{":
        focusLevel = lastWord;

        /* anything outside braces defines the classname for the next def */
        if (lastWord == "assetglobaldef") {
            //printf("Created Menu %s\n", filePath);
        } else if (lastWord == "menudef") {
            m_lastSubMenu = spawn(vguiScriptedMenu);
            m_lastSubMenu.m_trGlobal = this;
            m_lastSubMenu.m_bVisible = false;
            parent.Add(m_lastSubMenu);
            //printf("Created menuDef for Menu\n");
        } else if (lastWord == "itemdef") {
            m_lastItem = spawn(vguiScriptedItem);
            m_lastItem.m_trGlobal = this;

            if (m_lastSubMenu)
            m_lastSubMenu.Add(m_lastItem);
            //printf("Created itemDef for MenuDef %s\n", m_lastSubMenu.m_trSubName);
        }

        braceDepth++;
        break;
    case "}":
        braceDepth--;

        if (focusLevel == "action") {
            //printf("%s actions: %s\n", m_lastItem.m_trItemName, m_lastItem.m_trItemActionBuffer);
        }

        if (focusLevel == "mouseenter") {
            //printf("%s mouseenter: %s\n", m_lastItem.m_trItemName, m_lastItem.m_trItemEnterBuffer);
        }

        if (focusLevel == "mouseexit") {
            //printf("%s mouseexit: %s\n", m_lastItem.m_trItemName, m_lastItem.m_trItemExitBuffer);
        }

        focusLevel = "";
        break;
    default:
        if (word == "#include" || word == "loadmenu") {
            string includeFilePath = word == "loadmenu" ? argv(i+2) : argv(i+1);
            filestream includeFile = fopen(includeFilePath, FILE_READ);
            string includeTempString;
            string lastIncludeWord = __NULL__;
            int includeLine = 1i;
            vguiScriptedMenu oldSubMenu = m_lastSubMenu;
            vguiScriptedMenu oldItem = m_lastItem;
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
                ncConstantManager::Add(macroName, macroValue);
            }


        } else if (focusLevel == "action") {
            m_lastItem.m_trItemActionBuffer = sprintf("%s%s ", m_lastItem.m_trItemActionBuffer, realWord);
        } else if (focusLevel == "mouseenter") {
            m_lastItem.m_trItemEnterBuffer = sprintf("%s%s ", m_lastItem.m_trItemEnterBuffer, realWord);
        } else if (focusLevel == "mouseexit") {
            m_lastItem.m_trItemExitBuffer = sprintf("%s%s ", m_lastItem.m_trItemExitBuffer, realWord);
        } else if (focusLevel == "maxcharshit") {
            m_lastItem.m_trItemMaxCharBuffer = sprintf("%s%s ", m_lastItem.m_trItemMaxCharBuffer, realWord);
        } else if (focusLevel == "cvarstrlist") {
            m_lastItem.m_trItemCvarStrList = sprintf("%s%s ", m_lastItem.m_trItemCvarStrList, realWord);
        } else if (focusLevel == "cvarstrlist") {
            m_lastItem.m_trItemCvarFloatList = sprintf("%s%s ", m_lastItem.m_trItemCvarFloatList, realWord);
        } else if (focusLevel == "enablecvar") {
            m_lastItem.m_trItemEnableCvar = sprintf("%s%s ", m_lastItem.m_trItemEnableCvar, realWord);
        } else if (focusLevel == "disablecvar") {
            m_lastItem.m_trItemDisableCvar = sprintf("%s%s ", m_lastItem.m_trItemDisableCvar, realWord);
        } else if (focusLevel == "showcvar") {
            m_lastItem.m_trItemShowCvar = sprintf("%s%s ", m_lastItem.m_trItemShowCvar, realWord);
        } else if (focusLevel == "hidecvar") {
            m_lastItem.m_trItemHideCvar = sprintf("%s%s ", m_lastItem.m_trItemHideCvar, realWord);
        } else if (focusLevel == "onesc") {
            if (m_lastSubMenu)
            m_lastSubMenu.m_trSubOnESC = sprintf("%s%s ", m_lastSubMenu.m_trSubOnESC, realWord);
        } else if (focusLevel == "onopen") {
            if (m_lastSubMenu)
            m_lastSubMenu.m_trSubOnOpen = sprintf("%s%s ", m_lastSubMenu.m_trSubOnOpen, realWord);
        } else if (focusLevel == "onclose") {
            if (m_lastSubMenu)
            m_lastSubMenu.m_trSubOnClose = sprintf("%s%s ", m_lastSubMenu.m_trSubOnClose, realWord);
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
                m_trGlobalConsoleFont = vguiFont::LoadFontFromFile(strcat(macroLookUp, ".font"));
                incrementToken += STRING_SET(secondWord) ? 2 : 1;
                break;
            case "smallfont":
                m_trGlobalSmallFont = vguiFont::LoadFontFromFile(strcat(macroLookUp, ".font"));
                incrementToken += STRING_SET(secondWord) ? 2 : 1;
                break;
            case "font":
                m_trGlobalFont = vguiFont::LoadFontFromFile(strcat(macroLookUp, ".font"));
                incrementToken += STRING_SET(secondWord) ? 2 : 1;
                break;
            case "bigfont":
                m_trGlobalBigFont = vguiFont::LoadFontFromFile(strcat(macroLookUp, ".font"));
                incrementToken += STRING_SET(secondWord) ? 2 : 1;
                break;
            case "extrabigfont":
                m_trGlobalExtraBigFont = vguiFont::LoadFontFromFile(strcat(macroLookUp, ".font"));
                incrementToken += STRING_SET(secondWord) ? 2 : 1;
                break;
            case "boldfont":
                m_trGlobalBoldFont = vguiFont::LoadFontFromFile(strcat(macroLookUp, ".font"));
                incrementToken += STRING_SET(secondWord) ? 2 : 1;
                break;
            default:
                ncError("assetGlobalDef: %i %S (LW: %S, NW: %S)", lineNr, argv(i), lastWord, argv(i+1));
            }
        } else if (focusLevel == "menudef") {
            switch (word) {
            case "name":
                m_lastSubMenu.m_trSubName = sprintf("%d_%s", num_for_edict(this), macroLookUp);

                if (macroLookUp == "main") {
                    m_lastSubMenu.m_bVisible = true;
                }
                incrementToken++;
                break;
            case "fullscreen":
                m_lastSubMenu.m_trSubFullScreen = stof(macroLookUp);
                incrementToken++;
                break;
            case "visible":
                m_lastSubMenu.m_bVisible = stof(macroLookUp);
                incrementToken++;
                break;
            case "rect":
                m_lastSubMenu.m_vecOrigin[0] = stof(argv(i+1));
                m_lastSubMenu.m_vecOrigin[1] = stof(argv(i+2));
                m_lastSubMenu.m_vecSize[0] = stof(argv(i+3));
                m_lastSubMenu.m_vecSize[1] = stof(argv(i+4));
                m_lastSubMenu.SetPos(m_lastSubMenu.m_vecOrigin);
                m_lastSubMenu.SetSize(m_lastSubMenu.m_vecSize);
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
            case "bordersize":
            case "border":
                m_lastSubMenu.m_trSubBorder = stoi(macroLookUp);
                incrementToken++;
                break;
            case "soundloop":
                m_lastSubMenu.m_trSubSoundLoop = macroLookUp;
                incrementToken++;
                break;
            case "background":
                m_lastSubMenu.m_trSubBackground = macroLookUp;
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
                precache_pic(macroLookUp);
                incrementToken++;
                break;
            case "type":
                m_lastItem.m_trItemType = stoi(macroLookUp);
                incrementToken++;
                break;
            case "style":
                m_lastItem.m_trItemStyle = stoi(macroLookUp);
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
            case "cvar":
                m_lastItem.m_trItemCvar = macroLookUp;
                incrementToken++;
                break;
            case "forecolor":
                string foreR = argv(i+1);
                string foreG = argv(i+2);
                string foreB = argv(i+3);
                string foreA = argv(i+4);
                string macroforeR = ncConstantManager::LookUp(strcat("$", foreR), "");
                string macroforeG = ncConstantManager::LookUp(strcat("$", foreG), "");
                string macroforeB = ncConstantManager::LookUp(strcat("$", foreB), "");
                string macroforeA = ncConstantManager::LookUp(strcat("$", foreA), "");

                if (STRING_SET(macroforeR) && !STRING_SET(macroforeG)) {
                    tokenize(macroforeR);
                    foreR = argv(i+0);
                    foreG = argv(i+1);
                    foreB = argv(i+2);
                    foreA = argv(i+3);
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
                string macroRectMinsX = ncConstantManager::LookUp(strcat("$", rectMinsX), "");
                string macroRectMinsY = ncConstantManager::LookUp(strcat("$", rectMinsY), "");
                string macroRectMaxsX = ncConstantManager::LookUp(strcat("$", rectMaxsX), "");
                string macroRectMaxsY = ncConstantManager::LookUp(strcat("$", rectMaxsY), "");

                if (STRING_SET(macroRectMinsX)) {
                    m_lastItem.m_vecOrigin[0] = stof(macroRectMinsX);
                } else {
                    m_lastItem.m_vecOrigin[0] = stof(rectMinsX);
                }
                if (STRING_SET(macroRectMinsY)) {
                    m_lastItem.m_vecOrigin[1] = stof(macroRectMinsY);
                } else {
                    m_lastItem.m_vecOrigin[1] = stof(rectMinsY);
                }
                if (STRING_SET(macroRectMaxsX)) {
                    m_lastItem.m_vecSize[0] = stof(macroRectMaxsX);
                } else {
                    m_lastItem.m_vecSize[0] = stof(rectMaxsX);
                }
                if (STRING_SET(macroRectMaxsY)) {
                    m_lastItem.m_vecSize[1] = stof(macroRectMaxsY);
                } else {
                    m_lastItem.m_vecSize[1] = stof(rectMaxsY);
                }

                m_lastItem.SetPos(m_lastItem.m_vecOrigin);
                m_lastItem.SetSize(m_lastItem.m_vecSize);
                incrementToken+=4;
                break;
            case "textfont":
                m_lastItem.m_trItemTextFont = stof(macroLookUp);
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
                m_lastItem.m_trItemType = ITEM_TYPE_OWNERDRAW;
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
            case "feeder":
                m_lastItem.m_trItemFeeder = stoi(macroLookUp);
                incrementToken++;
                break;
            case "elementheight":
                m_lastItem.m_trItemElementHeight = stoi(macroLookUp);
                incrementToken++;
                break;
            case "elementwidth":
                m_lastItem.m_trItemElementWidth = stoi(macroLookUp);
                incrementToken++;
                break;
            case "cvarstrlist":
            case "cvarfloatlist":
            case "action":
            case "cvar":
            case "showcvar":
            case "hidecvar":
            case "enablecvar":
            case "disablecvar":
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
            case "model_skin":
                m_lastItem.m_trItemModelSkin = stof(macroLookUp);
                incrementToken++;
                break;
            case "model_animplay":
                m_lastItem.m_trItemModelAnim = stof(macroLookUp);
                incrementToken++;
                break;
            case "model_bob":
                m_lastItem.m_trItemModelBob[0] = stof(argv(i+1));
                m_lastItem.m_trItemModelBob[1] = stof(argv(i+2));
                m_lastItem.m_trItemModelBob[2] = stof(argv(i+3));
                incrementToken+=3;
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
            case "cinematic":
                m_lastItem.m_trItemCinematic = macroLookUp;
                shaderforname(macroLookUp, sprintf("{\n\t{\n\t\tvideomap video/%s\n\t}\n}", macroLookUp));
                incrementToken++;
                break;
            default:
                ncError("itemDef: %i: %S (LW: %S, NW: %S)", lineNr, argv(i), lastWord, argv(i+1));
            }
        }
    }

    lastWord = word;
    return (incrementToken);
}

vguiScriptedView
vguiScriptedView::CreateFromBase64(vguiWidget parent, string base64String)
{
    filestream defFile;

    /* open file */
    defFile = fopen("tmp.menu", FILE_WRITE);

    if (defFile < 0) {
        return (__NULL__);
    }

    int byteCount;
    fputs(defFile, base64decode(base64String, byteCount));
    fclose(defFile);
    return CreateFromMenuFile(parent, "tmp.menu");
}


vguiScriptedView
vguiScriptedView::CreateFromMenuFile(vguiWidget parent, string filePath)
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

    vguiScriptedView newMenu = spawn(vguiScriptedView);

    /* line by line */
    while ((tempString = fgets(defFile))) {
        string modifiedString = strreplace("}", " } ", tempString);
        tempString = strreplace("{", " { ", modifiedString);
        float tokenCount = tokenize_console(tempString);

        for (float i = 0; i < tokenCount; i++) {
            float incrementCounter = (float)newMenu.InterpretLine(newMenu, i, lineNr, tokenCount);
            i += incrementCounter;
            tokenCount = tokenize_console(tempString);
        }
        lineNr++;
    }

    /* trigger the menus that are open at launch... */
    vguiScriptedMenu wNext = parent;
    do {
        if (wNext && wNext.classname == "vguiScriptedMenu") {
            vguiScriptedMenu subMenu = (vguiScriptedMenu)wNext;

            if (subMenu.m_bVisible) {
                subMenu.OnOpen();
            }
        }

        wNext = wNext.m_next;
    } while (wNext);

    /* clean up */
    fclose(defFile);
    return (newMenu);
}
