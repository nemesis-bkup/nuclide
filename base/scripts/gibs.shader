glassgibs
{
	surfaceprop glass
	surfaceparm trans
	surfaceparm alphashadow
	surfaceparm nolightmap
	diffusemap detail_pbr/default.tga
	normalmap detail_pbr/glass_local.tga
	specularmap detail_pbr/glass_mra.tga

	{
		program defaultskin
	}
}

woodgibs
{
	surfaceprop wood
	diffusemap detail_pbr/wood.tga
	normalmap detail_pbr/wood_local.tga
	specularmap detail_pbr/wood_mra.tga

	{
		program defaultskin
	}
}

metalgibs
{
	surfaceprop metal
	diffusemap detail_pbr/metal.tga
	normalmap detail_pbr/metal_local.tga
	specularmap detail_pbr/metal_mra.tga

	{
		program defaultskin
	}
}

rockgibs
{
	surfaceprop dirt
	diffusemap detail_pbr/dirt.tga
	normalmap detail_pbr/dirt_local.tga
	specularmap detail_pbr/dirt_mra.tga

	{
		program defaultskin
	}
}

cindergibs
{
	surfaceprop dirt
	diffusemap detail_pbr/concrete.tga
	normalmap detail_pbr/concrete_local.tga
	specularmap detail_pbr/concrete_mra.tga

	{
		program defaultskin
	}
}
