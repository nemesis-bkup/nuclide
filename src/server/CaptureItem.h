/*
 * Copyright (c) 2023-2025 Vera Visions LLC.
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

/** Item Capture Manager.

While not an item itself, it cares about managing
goal/capture items within a game.

An instance of ncCaptureItem will give an item, receive items (capturing)
and assign score points.

It can be configured to look like a flag, will give a (separate) inventory item
that is unique to the map and can be captured at other ncCapturePoint instances or ncCaptureItem instances.
*/
class ncCaptureItem:ncRenderableEntity
{
public:
	void ncCaptureItem(void);

	virtual void Precache(void);
	virtual void Respawn(void);
	virtual void Touch(entity);
	virtual void SpawnKey(string, string);
	nonvirtual void Captured(float teamNumber);
	nonvirtual void WatchPlayer(void);
	nonvirtual void Return(void);

private:
	string m_desiredItem;
	string m_goalItem;
	string m_requiresItem;
	int m_playerScore;
	int m_teamScore;
	float m_goalNo;
	ncPlayer m_watchPlayer;
	string m_outputOnCapture;
	string m_outputOnTake;
	string m_outputOnReturn;
};
