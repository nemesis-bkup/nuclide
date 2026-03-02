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
    RENDERER_RESOLUTION,
    RENDERER_DISPLAYMODE,
    RENDERER_ASPECTRATIO,
    RENDERER_API
} rendererInfo_t;

class
ncRenderingManager
{
    nonvirtual void Init(void);
    nonvirtual void Shutdown(void);

    nonvirtual __variant GetInfo(int, rendererInfo_t);
    nonvirtual int Count(rendererInfo_t);

    nonvirtual __variant GetCurrent(rendererInfo_t);
};
