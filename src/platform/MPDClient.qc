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

tcpinfo_t tcp_mpdConnection;
var bool g_mpd_connected;

var string autocvar_mpd_host = "127.0.0.1";
var int autocvar_mpd_port = 6600i;
var float autocvar_mpd_timeOut;
var string autocvar_mpd_password;

void
ncMPDController::Connect(void)
{
	if (!STRING_SET(autocvar_mpd_host)) {
		ncError("MPD host not specified.");
		return;
	}

	if (!autocvar_mpd_port) {
		ncError("MPD port not specified.");
		return;
	}

	int i = TCP_Connect(&tcp_mpdConnection, sprintf("tcp://%s:%i/", autocvar_mpd_host, autocvar_mpd_port));

	if (i < 0) {
		printf("Unable to connect to the MPD service.\n");
		g_mpd_connected = false;
	} else {
		g_mpd_connected = true;
		TCP_Send(&tcp_mpdConnection, sprintf("%s\r\n", "currentsong"));
	}
}

void
ncMPDController::Command_Next(void)
{
	TCP_Send(&tcp_mpdConnection, sprintf("%s\r\n", "next"));
	TCP_Send(&tcp_mpdConnection, sprintf("%s\r\n", "currentsong"));
}

void
ncMPDController::Command_Previous(void)
{
	TCP_Send(&tcp_mpdConnection, sprintf("%s\r\n", "previous"));
	TCP_Send(&tcp_mpdConnection, sprintf("%s\r\n", "currentsong"));
}

void
ncMPDController::Command_Pause(void)
{
	TCP_Send(&tcp_mpdConnection, sprintf("%s\r\n", "pause"));
	TCP_Send(&tcp_mpdConnection, sprintf("%s\r\n", "currentsong"));
}

void
ncMPDController::Command_Stop(void)
{
	TCP_Send(&tcp_mpdConnection, sprintf("%s\r\n", "stop"));
	TCP_Send(&tcp_mpdConnection, sprintf("%s\r\n", "currentsong"));
}

void
ncMPDController::Command_Play(void)
{
	TCP_Send(&tcp_mpdConnection, sprintf("%s\r\n", "play"));
	TCP_Send(&tcp_mpdConnection, sprintf("%s\r\n", "currentsong"));
}

void
ncMPDController::Command_SetShuffle(bool enabled)
{
	TCP_Send(&tcp_mpdConnection, sprintf("%s %d\r\n", "random", enabled));
}

void
ncMPDController::Command_SetRepeat(bool enabled)
{
	TCP_Send(&tcp_mpdConnection, sprintf("%s %d\r\n", "repeat", enabled));
}

void
ncMPDController::Command_SetSingle(bool enabled)
{
	TCP_Send(&tcp_mpdConnection, sprintf("%s %d\r\n", "single", enabled));
}

void
ncMPDController::Frame(void)
{
	if (g_mpd_connected == false) {
		return;
	}

	TCP_Frame(&tcp_mpdConnection);

	string returnString =  strreplace("\r", "", TCP_Receive(&tcp_mpdConnection));

	if (TCP_GetState(&tcp_mpdConnection) != STATE_CONNECTED) {
		return;
	}

	if (!STRING_SET(returnString)) {
		return;
	}

	if (returnString == "OK") {
		TCP_Send(&tcp_mpdConnection, sprintf("%s\r\n", "status"));
		return;
	}

	tokenizebyseparator(returnString, "\t");
	string component = argv(0);
	tokenizebyseparator(component, ":");

	switch (argv(0)) {
	case "Title":
		localcmd(sprintf("set ui_mpd_songTitle %S\n", substring(argv(1), 1, -1)));
		break;
	case "Artist":
		localcmd(sprintf("set ui_mpd_songArtist %S\n", substring(argv(1), 1, -1)));
		break;
	case "Date":
		localcmd(sprintf("set ui_mpd_songDate %S\n", substring(argv(1), 1, -1)));
		break;
	case "Track":
		localcmd(sprintf("set ui_mpd_songTrack %S\n", substring(argv(1), 1, -1)));
		break;
	case "Disc":
		localcmd(sprintf("set ui_mpd_songDisc %S\n", substring(argv(1), 1, -1)));
		break;
	case "Genre":
		localcmd(sprintf("set ui_mpd_songGenre %S\n", substring(argv(1), 1, -1)));
		break;
	case "Album":
		localcmd(sprintf("set ui_mpd_songAlbum %S\n", substring(argv(1), 1, -1)));
		break;
	case "state":
		localcmd(sprintf("set ui_mpd_state %S\n", substring(argv(1), 1, -1)));
		break;
	case "bitrate":
		localcmd(sprintf("set ui_mpd_songRate %S\n", substring(argv(1), 1, -1)));
		break;
	case "audio":
		localcmd(sprintf("set ui_mpd_songFreq %S\n", substring(argv(1), 1, -1)));
		break;
	case "elapsed":
		localcmd(sprintf("set ui_mpd_elapsed %S\n", substring(argv(1), 1, -1)));
		break;
	case "duration":
		localcmd(sprintf("set ui_mpd_duration %S\n", substring(argv(1), 1, -1)));
		break;
	case "repeat":
		localcmd(sprintf("set ui_mpd_repeat %S\n", substring(argv(1), 1, -1)));
		break;
	case "random":
		localcmd(sprintf("set ui_mpd_random %S\n", substring(argv(1), 1, -1)));
		break;
	case "single":
		localcmd(sprintf("set ui_mpd_single %S\n", substring(argv(1), 1, -1)));
		break;
	default:
		//printf(sprintf("%S %S\n", argv(0), substring(argv(1), 1, -1)));
	}
}

void
ncMPDController::Shutdown(void)
{
	TCP_Disconnect(&tcp_mpdConnection);
}
