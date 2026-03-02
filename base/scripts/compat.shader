nature/water_canals03_beneath
{
	qer_editorImage "liquid/water2.tga"
	sort banner
	qer_trans 0.8
	surfaceParm trans
	surfaceParm water
	surfaceParm nodlight
	surfaceParm nolightmap
	cull none
	diffusemap "liquid/water2.ktx"
	normalmap "liquid/water1_n.tga"

	{
		program water_high
		map $reflection
		map $refraction
	}
}

tools/toolsskybox
{
	qer_editorImage "textures/common/skyportal.tga"
	surfaceParm noimpact
	surfaceParm nolightmap
	surfaceParm sky
	surfaceParm nodlight
	nomipmaps
	skyParms - 512 -
}

tools/toolsnodraw
{
	qer_editorImage "textures/common/nodraw.tga"
	qer_trans 0.50
	surfaceParm nodraw
	surfaceParm nonsolid
	surfaceParm trans
	surfaceParm nomarks
	surfaceParm nolightmap
	nomipmaps
}

tools/toolsclip
{
	qer_editorImage "textures/common/clip.tga"
	surfaceParm nodraw
	surfaceParm trans
	surfaceParm nolightmap
	nomipmaps
}
