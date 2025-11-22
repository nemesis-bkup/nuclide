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


void
ncAddonManager::Shutdown(void)
{
	for (ncAddonDelegate addonEnum = __NULL__; (addonEnum = AddonManager_NextAddon(addonEnum));) {
		addonEnum.Close();
	}
}

bool
ncAddonManager::ConsoleCommand(ncPlayer a, string b)
{
	for (ncAddonDelegate addonEnum = __NULL__; (addonEnum = AddonManager_NextAddon(addonEnum));) {
		addonEnum.ConsoleCommand(a, b);
	}
}

bool
ncAddonManager::ClientCommand(ncClient a, string b)
{
	for (ncAddonDelegate addonEnum = __NULL__; (addonEnum = AddonManager_NextAddon(addonEnum));) {
		addonEnum.ClientCommand(a, b);
	}
}

void
ncAddonManager::PlayerConnect(ncPlayer a)
{
	for (ncAddonDelegate addonEnum = __NULL__; (addonEnum = AddonManager_NextAddon(addonEnum));) {
		addonEnum.PlayerConnect(a);
	}
}

void
ncAddonManager::PlayerDisconnect(ncPlayer a)
{
	for (ncAddonDelegate addonEnum = __NULL__; (addonEnum = AddonManager_NextAddon(addonEnum));) {
		addonEnum.PlayerDisconnect(a);
	}
}

void
ncAddonManager::PlayerSpawn(ncPlayer a)
{
	for (ncAddonDelegate addonEnum = __NULL__; (addonEnum = AddonManager_NextAddon(addonEnum));) {
		addonEnum.PlayerSpawn(a);
	}
}

void
ncAddonManager::PlayerDeath(ncPlayer a, ncEntity b, ncEntity c, string d)
{
	for (ncAddonDelegate addonEnum = __NULL__; (addonEnum = AddonManager_NextAddon(addonEnum));) {
		addonEnum.PlayerDeath(a, b, c, d);
	}
}

void
ncAddonManager::NPCDeath(ncActor a, ncEntity b, ncEntity c)
{
	for (ncAddonDelegate addonEnum = __NULL__; (addonEnum = AddonManager_NextAddon(addonEnum));) {
		addonEnum.NPCDeath(a, b, c);
	}
}


void
ncAddonManager::LoadDefaultAddons(void)
{
	string defaultAddons = cvars.GetString("g_addons");
	int defaultCount = tokenize(defaultAddons);

	for (int i = 0; i < tokenize(defaultAddons); i++) {
		string addonName = argv(i);
		string addonPath = strcat("plugins/", addonName, ".dat");
		ncAddonDelegate addonEnum = addonEnum.CreateFromProgs(addonName, addprogs(addonPath));

		if (addonEnum == __NULL__) {
			ncError("Failed to load named addon %S", addonName);
		}

		addonEnum.Load();
		addonEnum.ServerActivate();
	}
}
