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

/** Dictionary for mail records.

Messages, generally meant for the player. Can be collected
throughout the game, or potentially even be written by
the player themselves. Sky is the limit.

# KEYS

- "date" : Date at which the message was recorded.
- "to" : Localized string of the target recipient.
- "from" : Localized string of the sender.
- "subject" : Subject of the message.
- "text" : Message contained within.

@ingroup decl
@ingroup electronics
*/
class
ncMailDict:ncDict
{
public:
    void ncMailDict(void);

private:
    string m_mailDate;
    string m_mailTo;
    string m_mailFrom;
    string m_mailSubject;
    string m_mailText;
};
