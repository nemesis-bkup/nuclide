/** A desktop version of vguiTheme */
class
vguiDesktopTheme:vguiTheme
{
public:
	void vguiDesktopTheme(void);
	virtual bool IconsEnabled(void);
    virtual string GetDefaultThemeFile(void);
	nonvirtual void RefreshColorValues(void);
};

void
vguiDesktopTheme::vguiDesktopTheme(void)
{

}

string
vguiDesktopTheme::GetDefaultThemeFile(void)
{
	return ("scripts/desktop_style.txt");
}


void
vguiDesktopTheme::RefreshColorValues(void)
{
}

bool
vguiDesktopTheme::IconsEnabled(void)
{
	return (true);
}
