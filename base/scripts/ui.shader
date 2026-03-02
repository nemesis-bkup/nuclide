vtvDOG
{
	{
		map gfx/vtv_dog.tga
		blendFunc blend
	}
}

xserver
{
	{
		videomap x11
	}
}

static
{
	{
		videomap video/static.roq
	}
}


static_additive
{
	{
		videomap video/static.roq
		blendFunc add
	}
}

levelshotdetail
{
	{
		map textures/detail/concrete.tga
		blendFunc filter
	}
}
