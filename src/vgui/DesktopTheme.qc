/** A desktop version of vguiTheme */
class
vguiDesktopTheme:vguiTheme
{
public:
	void vguiDesktopTheme(void);
	virtual bool IconsEnabled(void);

	nonvirtual void RefreshColorValues(void);
};

void
vguiDesktopTheme::vguiDesktopTheme(void)
{

}

void
vguiDesktopTheme::RefreshColorValues(void)
{
	m_controlBackgroundColor.SetColorWithAlpha([0.75, 0.75, 0.75], 1.0f);
	m_windowBackgroundColor.SetColorWithAlpha([0.75, 0.75, 0.75], 1.0f);
	m_textBackgroundColor.SetColor([1,1,1]);
	m_textColor.SetColor([0,0,0]);
	m_windowBorderColor.SetColor([0,0,0]);
	m_hilightColor.SetColorWithAlpha([1,1,1], 0.5f);
	m_shadowColor.SetColorWithAlpha([0,0,0], 0.5f);
	m_hoverColor.SetColorWithAlpha([1,1,1], 0.0f);
}

bool
vguiDesktopTheme::IconsEnabled(void)
{
	return (true);
}
