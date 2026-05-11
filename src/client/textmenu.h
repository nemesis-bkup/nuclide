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

var string g_textmenu = "";
var float g_textmenucheck = 0.0f; 

/** @defgroup textmenu Text Menu
    @brief Displays text-based menus, for use with a keyboard.
    @ingroup client

The text of the menu is defined inside `titles.txt`, powered by the same backend handling [Game Text](@ref text).

It is also used for things such as the waypoint editor. What the menu looks like can be seen here:

![Waypoint Editor powered by Text Menus](nuclide-way-flags.png)

# Console Commands

## textMenuOpen [TITLE]

Will display the text named **TITLE**.
If a file named `decls/textmenu/TITLE.decl` exists, it'll map the input codes to command entries named in the file.

Such a decl can look like this:

```
typeInfo commands
{
    "1" "say Hello World"
    "2" "play sound/enforcer/enfstop.wav"
    "3" "toggle r_showshaders"
    "5" "textMenuOpen MENUTEST2"
    "9" "textMenuClose"
}
```

## textMenuClose

When issued, will close/hide whatever text menu may have been open at this time.

@{

*/

class
ncTextMenuDict:ncDict
{
public:
    void ncTextMenuDict(void);
    
    nonvirtual void Input(int inputNum);
};

ncTextMenuDict g_textMenuDict;

/** Forcefully displays a given text menu. */
void Textmenu_Call(string);

/** Toggle the text menu, replacing it with the one specified if inactive. */
void Textmenu_Toggle(string);

/** Returns `true` or `false` depending on if a text menu is currently active. */
int Textmenu_IsActive(void);

/** Force the active text menu to be hidden. */
void Textmenu_Hide(void);

/** Called by Nuclide to pass numeric input values to the text menu. */
void Textmenu_Input(int);

/** Called by Nuclide to draw text menus. */
void Textmenu_Draw(void);

/** Called by `textMenuCreate` console command, argument equals the decl name. */
bool Textmenu_Open(string defName);

/** @} */ // end of client
