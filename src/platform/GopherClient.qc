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

typedef enum
{
    GOPHER_ITEM_TEXT,
} gopherItem_t;

tcpinfo_t tcp_gopherNet;
var bool g_gopherNet_connected;
var bool g_gopherNet_textmode;
var int g_gopherNet_textID;

void
Gopher_RequestIndex(string targetAddress)
{
    int i = TCP_Connect(&tcp_gopherNet, "tcp://gopher.floodgap.com:70/");

    if (i < 0) {
        printf("Unable to connect to the gopher service.\n");
        g_gopherNet_connected = false;
    } else {
        g_gopherNet_connected = true;
        g_gopherNet_textmode = false;
        TCP_Send(&tcp_gopherNet, "\r\n");
    }
}
void
Gopher_QueryItem(string targetHost, string targetPort, string selectorString, string queryString)
{
    if (g_gopherNet_connected == true) {
        TCP_Disconnect(&tcp_gopherNet);
    }

    int i = TCP_Connect(&tcp_gopherNet, sprintf("tcp://%s:%s/", targetHost, targetPort));

    if (i < 0) {
        printf("Unable to connect to the gopher service.\n");
        g_gopherNet_connected = false;
    } else {
        g_gopherNet_connected = true;
        g_gopherNet_textmode = false;
        TCP_Send(&tcp_gopherNet, sprintf("%s\t%s\r\n", selectorString, queryString));
    }
}
void
Gopher_RequestText(string targetHost, string targetPort, string selectorString, string queryString)
{
    if (g_gopherNet_connected == true) {
        TCP_Disconnect(&tcp_gopherNet);
    }

    int i = TCP_Connect(&tcp_gopherNet, sprintf("tcp://%s:%s/", targetHost, targetPort));

    if (i < 0) {
        printf("Unable to connect to the gopher service.\n");
        g_gopherNet_connected = false;
    } else {
        g_gopherNet_connected = true;
        g_gopherNet_textmode = true;
        g_gopherNet_textID++;
        TCP_Send(&tcp_gopherNet, sprintf("%s\t%s\r\n", selectorString, queryString));
    }
}

void
Gopher_Frame(void)
{
    if (g_gopherNet_connected == false) {
        return;
    }

    TCP_Frame(&tcp_gopherNet);

    string returnString =  strreplace("\r", "", TCP_Receive(&tcp_gopherNet));

    if (TCP_GetState(&tcp_gopherNet) != STATE_CONNECTED) {
        return;
    }

    if (returnString == __NULL__) {
        return;
    }

    string typeNum = substring(returnString, 0, 1);
    tokenizebyseparator(returnString, "\t");
    string titleString =  substring(argv(0), 1, -1);
    string selectorString =  argv(1);
    string targetHost =  argv(2);
    string targetPort =  argv(3);

    if (targetHost == "error.host") {
        targetHost = tcp_gopherNet.m_host;
        targetPort = tcp_gopherNet.m_port;
    }

    switch (typeNum) {
    case ".":
        TCP_Disconnect(&tcp_gopherNet);
        g_gopherNet_connected = false;
        g_gopherNet_textmode = false;
        break;
#if 0
    case "i":
        //printf("%s\n", titleString);
        break;
    case "0": /* text file */
        //printf("%s %s\n", imageToConsole("gfx/icon16/page_white_text", ICN_SIZE, selectorString), titleString);
        break;
    case "1": /* dir entry */
        //printf("%s %s\n", imageToConsole("gfx/icon16/folder", ICN_SIZE, selectorString), titleString);
        break;
    case "5": /* binary file */
        //printf("%s %s\n", imageToConsole("gfx/icon16/application", ICN_SIZE, selectorString), titleString);
        break;
    case "9": /* binary file */
        //printf("%s %s\n", imageToConsole("gfx/icon16/application", ICN_SIZE, selectorString), titleString);
        break;
    case "+": /* remote copy */
        //printf("%s %s\n", imageToConsole("gfx/icon16/copy", ICN_SIZE, selectorString), titleString);
        break;
    case "g": /* gif */
        //printf("%s %s\n", imageToConsole("gfx/icon16/film", ICN_SIZE, selectorString), titleString);
        break;
    case "I": /* image */
        //printf("%s %s\n", imageToConsole("gfx/icon16/monitor", ICN_SIZE, selectorString), titleString);
        break;
#endif
    default:
        break;
    }

    if (g_gopherNet_textmode == false)
        localcmd(sprintf("addGopherLine %S %S %S %S %S\n", typeNum, titleString, selectorString, targetHost, targetPort));
    else
        localcmd(sprintf("addGopherText %i %S\n", g_gopherNet_textID, returnString));
}


__weak void
GopherCallback_MessageReceived(gopherItem_t itemType, string titleString, string furtherData)
{
}
