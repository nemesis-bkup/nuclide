/*
 * Copyright (c) 2016-2026 Vera Visions LLC.
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

typedef enum
{
    PLAYERMODEL_NAME,
    PLAYERMODEL_PATH,
    PLAYERMODEL_SKINSUPPORT,
    PLAYERMODEL_TOPBOTTOMCOLOR,
} playerModelInfo_t;

class
ncPlayerModelLibrary
{
    nonvirtual void Init(void);
    nonvirtual void Shutdown(void);
    nonvirtual void Reload(void);
    nonvirtual void ReloadSkins(void);
    nonvirtual void ReloadSprays(void);

    nonvirtual __variant GetInfo(int, playerModelInfo_t);
    nonvirtual string ModelPathForName(string playerModelName);
    nonvirtual int Count(void);

    nonvirtual int SkinCount(void);
    nonvirtual string SkinName(int);

    nonvirtual int SprayCount(void);
    nonvirtual string SprayName(int);
};
