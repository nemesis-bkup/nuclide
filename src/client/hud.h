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

void HUD_Init(void);
void HUD_Draw(void);
void HUD_DrawSpectator(void);
void HUD_SendStat(string, string);
float HUD_ClientInputFrame(float);
bool HUD_ConsoleCommand(string);
void HUD_Obituary(string, string, string, string);

void HUDProgs_Init(void);
void HUDProgs_Draw(void);
void HUDProgs_DrawSpectator(void);
void HUDProgs_DrawIntermission(void);
void HUDProgs_SendStat(string, string);
float HUDProgs_ClientInputFrame(float);
bool HUDProgs_ConsoleCommand(string);
void HUDProgs_Obituary(string, string, string, string);
void HUD_DrawScriptedView(vector, vector);
