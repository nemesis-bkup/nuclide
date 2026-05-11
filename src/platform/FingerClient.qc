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

typedef enum
{
    GOPHER_ITEM_TEXT,
} gopherItem_t;

tcpinfo_t tcp_fingerNet;
var bool g_fingerNet_connected;

void
Finger_RequestPlan(string targetString)
{
    tokenizebyseparator(targetString, "@");
    string targetUser = argv(0);
    string targetAddress = argv(1);

    if (!STRING_SET(targetUser)) {
        ncError("User not specified.");
        return;
    }

    if (!STRING_SET(targetAddress)) {
        ncError("Address not specified.");
        return;
    }

    int i = TCP_Connect(&tcp_fingerNet, sprintf("tcp://%s:79/", targetAddress));

    if (i < 0) {
        printf("Unable to connect to the finger service.\n");
        g_fingerNet_connected = false;
    } else {
        g_fingerNet_connected = true;
        TCP_Send(&tcp_fingerNet, sprintf("%s\r\n", targetUser));
    }
}

__weak void
FingerCallback_PlanLine(string planLine)
{
}

void
Finger_Frame(void)
{
    if (g_fingerNet_connected == false) {
        return;
    }

    TCP_Frame(&tcp_fingerNet);

    string returnString =  strreplace("\r", "", TCP_Receive(&tcp_fingerNet));

    if (TCP_GetState(&tcp_fingerNet) != STATE_CONNECTED) {
        return;
    }

    if (returnString == __NULL__) {
        return;
    }

    FingerCallback_PlanLine(returnString);
    localcmd(sprintf("addFingerLine %S\n", returnString));
    ncLog(returnString);
}
