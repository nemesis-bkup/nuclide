/*
 * Copyright (c) 2026 Vera Visions LLC.
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

/** Container class that'll deal with handling colors via a variety of different means. */


/** VGUI Widget: Color Container

@ingroup vgui
*/
class vguiColor
{
public:
    void vguiColor(void);

    nonvirtual void SetColor(vector);
    nonvirtual void SetColorWithAlpha(vector, float);
    nonvirtual vector GetColor(void);
    nonvirtual float GetAlpha(void);
    nonvirtual string GetFunStringColor(void);

private:
    vector m_colorValue;
    float m_alphaValue;
};

void
vguiColor::vguiColor(void)
{
    m_colorValue = [0.0f, 0.0f, 0.0f];
    m_alphaValue = 1.0f;
}

void
vguiColor::SetColor(vector value)
{
    m_colorValue = value;
}

void
vguiColor::SetColorWithAlpha(vector color, float alpha)
{
    m_colorValue = color;
    m_alphaValue = alpha;
}

vector
vguiColor::GetColor(void)
{
    return m_colorValue;
}

float
vguiColor::GetAlpha(void)
{
    return m_alphaValue;
}

string
vguiColor::GetFunStringColor(void)
{
    return Font_RGBtoHex(m_colorValue);
}
