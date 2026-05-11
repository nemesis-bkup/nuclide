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

models/flag_white
{
	surfaceprop metal
	diffusemap models/flag.tga
	normalmap detail_pbr/metal_local.tga
	specularmap detail_pbr/metal_mra.tga

	{
		program defaultskin
	}
}


models/flag_blue
{
	surfaceprop metal
	diffusemap models/flag.tga
	normalmap detail_pbr/metal_local.tga
	specularmap detail_pbr/metal_mra.tga

	{
		program defaultwall#TINT_R=0#TINT_G=0#TINT_B=0.5
	}
}


models/flag_red
{
	surfaceprop metal
	diffusemap models/flag.tga
	normalmap detail_pbr/metal_local.tga
	specularmap detail_pbr/metal_mra.tga

	{
		program defaultwall#TINT_R=0.5#TINT_G=0#TINT_B=0
	}
}

models/flag_green
{
	surfaceprop metal
	diffusemap models/flag.tga
	normalmap detail_pbr/metal_local.tga
	specularmap detail_pbr/metal_mra.tga

	{
		program defaultskin
	}
}

models/flag_yellow
{
	surfaceprop metal
	diffusemap models/flag.tga
	normalmap detail_pbr/metal_local.tga
	specularmap detail_pbr/metal_mra.tga

	{
		program defaultskin
	}
}

models/cross_small
{
    fte_transmissionfactor 4.0
	surfaceprop metal
	diffusemap detail_pbr/metal.tga
	normalmap detail_pbr/metal_local.tga
	transmissionmap lights/green.tga
	specularmap detail_pbr/metal_mra.tga

	{
		program defaultwall#TINT_R=0#TINT_G=1#TINT_B=0
	}
}

models/cross_medium
{
    fte_transmissionfactor 4.0
	surfaceprop metal
	diffusemap detail_pbr/metal.tga
	normalmap detail_pbr/metal_local.tga
	transmissionmap lights/yellow.tga
	specularmap detail_pbr/metal_mra.tga

	{
		program defaultwall#TINT_R=1#TINT_G=1#TINT_B=0
	}
}

models/cross_large
{
    fte_transmissionfactor 4.0
	surfaceprop metal
	diffusemap detail_pbr/metal.tga
	transmissionmap lights/orange.tga
	normalmap detail_pbr/metal_local.tga
	specularmap detail_pbr/metal_mra.tga

	{
		program defaultwall#TINT_R=1#TINT_G=0.5#TINT_B=0
	}
}

models/cross_mega
{
    fte_transmissionfactor 4.0
	surfaceprop metal
	diffusemap detail_pbr/metal.tga
	transmissionmap lights/blue.tga
	normalmap detail_pbr/metal_local.tga
	specularmap detail_pbr/metal_mra.tga

	{
		program defaultwall#TINT_R=0.5#TINT_G=0.5#TINT_B=1
	}
}

models/sphere
{
    {
        map sfx/metal_env_b.tga
        tcGen environment
        blendFunc add
        rgbGen wave sin .1 .2 1 .5
    }
        {
        map sfx/metal_env.tga
        tcGen environment
        blendFunc add
        rgbGen const (0.25 0.25 0.25)
    }
}
