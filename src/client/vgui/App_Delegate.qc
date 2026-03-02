/*
 * Copyright (c) 2016-2022 Vera Visions LLC.
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

#ifdef CLIENT
/* this works, but did not prove to be very effective due to the limited number of multiprogs
 * we seem to be able to run on the client. */
class
vguiApp_Delegate:vguiWindow
{
	void vguiApp_Delegate(void);

	virtual int MainFunction(void);
	nonvirtual int RunApplicationFromProgs(string progsPath);
	nonvirtual void PR_Exec(string commandString);
	nonvirtual float LoadUIFromFile(string fileName);

private:
	string m_appProgsPath;
	float m_appProgsID;
	entity m_appUI;
	entity m_appUiChain;
};

vguiApp_Delegate g_runApplicationFromProgs;

void
vguiApp_Delegate::vguiApp_Delegate(void)
{
	m_appProgsPath = g_string_null;
	m_appProgsID = 0;
}

void
vguiApp_Delegate::PR_Exec(string commandString)
{
	void(void) MainFunction = externvalue(m_appProgsID, commandString);
	MainFunction();
}

int
vguiApp_Delegate::MainFunction(void)
{
	return (0);
}

float
vguiApp_Delegate::LoadUIFromFile(string fileName)
{
	g_runApplicationFromProgs.m_appUiChain = spawn(vguiWindow);
	vguiWidget uiChain = (vguiWindow)g_runApplicationFromProgs.m_appUiChain;
	uiChain.m_iFlags = 1;
	g_runApplicationFromProgs.m_appUI = vguiScriptedView::CreateFromMenuFile(g_runApplicationFromProgs.m_appUiChain, fileName);
	g_runApplicationFromProgs.m_appUI.owner = this;
	uiChain.Add(g_runApplicationFromProgs.m_appUI);
	return num_for_edict(g_runApplicationFromProgs.m_appUI);
}

int
vguiApp_Delegate::RunApplicationFromProgs(string progsPath)
{
	int returnValue = 0;

	if (!STRING_SET(progsPath)) {
		return 0;
	}

	vguiApp_Delegate newApplication = spawn(vguiApp_Delegate);
	newApplication.m_appProgsID = addprogs(progsPath);

	if (newApplication.m_appProgsID > 0) {
		newApplication.MainFunction = externvalue(newApplication.m_appProgsID, "main");
		externset(newApplication.m_appProgsID, LoadUIFromFile, "loadui");
		g_runApplicationFromProgs = newApplication;

		if (newApplication.MainFunction) {
			returnValue = newApplication.MainFunction();
		}

		if (!g_runApplicationFromProgs.m_appUI) {
			remove(newApplication);
		} else {
			vguiWidget findDesktop = (vguiWidget)find(world, ::classname, "vguiDesktop");

			if (findDesktop) {
				findDesktop.Add(newApplication.m_appUiChain);
				vguiWindow theWindow = (vguiWindow)newApplication.m_appUiChain;
				theWindow.SetPos([16,32]);
			} else {
				printf("Couldn't find desktop\n");
			}
		}

		g_runApplicationFromProgs = 0;
	}

	return (returnValue);
}
#endif
