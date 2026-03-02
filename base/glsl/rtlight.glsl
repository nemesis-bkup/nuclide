//======= Copyright (c) 2015-2024 Vera Visions LLC. All rights reserved. =======
//
// Purpose:
//
// Any surface lit by a dynamic/real-time light is touched with this shader.
//==============================================================================

!!ver 100 150

!!permu BUMP
!!permu FRAMEBLEND
!!permu SKELETAL
!!permu UPPERLOWER
!!permu FOG
!!permu REFLECTCUBEMASK
!!permu SPECULAR

!!cvarf r_glsl_offsetmapping_scale
!!cvardf r_glsl_pcf
!!cvardf r_glsl_fresnel
!!cvardf r_bumptest

!!samps diffuse shadowmap projectionmap
!!samps =BUMP normalmap
!!samps =REFLECTCUBEMASK reflectcube
!!samps =UPPERLOWER upper lower
!!samps =SPECULAR specular
!!samps =FAKESHADOWS shadowmap
!!samps =PCF shadowmap
!!samps =CUBE projectionmap

#ifdef SPECULAR
#define PBR
#endif

#include "sys/defs.h"

varying vec2 tcbase;
varying vec3 lightvector;

#ifdef VERTEXCOLOURS
varying vec4 vc;
#endif

#ifdef SPECULAR
varying vec3 eyevector;
varying mat3 invsurface;
#endif

#if defined(PCF) || defined(CUBE) || defined(SPOT) || defined(ORTHO)
varying vec4 vtexprojcoord;
#endif

#ifdef VERTEX_SHADER
	#include "sys/skeletal.h"
	void main ()
	{
		vec3 n, s, t, w;
		gl_Position = skeletaltransform_wnst(w,n,s,t);
		tcbase = v_texcoord;	//pass the texture coords straight through

    #ifdef ORTHO
        vec3 lightminusvertex = -l_lightdirection;
        lightvector.x = dot(lightminusvertex, s.xyz);
        lightvector.y = dot(lightminusvertex, t.xyz);
        lightvector.z = dot(lightminusvertex, n.xyz);
    #else
        vec3 lightminusvertex = l_lightposition - w.xyz;
        #ifdef NOBUMP
            //the only important thing is distance
            lightvector = lightminusvertex;
        #else
            //the light direction relative to the surface normal, for bumpmapping.
            lightvector.x = dot(lightminusvertex, s.xyz);
            lightvector.y = dot(lightminusvertex, t.xyz);
            lightvector.z = dot(lightminusvertex, n.xyz);
        #endif
    #endif

	#ifdef VERTEXCOLOURS
		vc = v_colour;
	#endif

	#ifdef SPECULAR
		vec3 eyeminusvertex = e_eyepos - w.xyz;
		eyevector.x = dot(eyeminusvertex, s.xyz);
		eyevector.y = dot(eyeminusvertex, t.xyz);
		eyevector.z = dot(eyeminusvertex, n.xyz);
		invsurface[0] = v_svector;
		invsurface[1] = v_tvector;
		invsurface[2] = v_normal;
	#endif

	#if defined(PCF) || defined(SPOT) || defined(CUBE) || defined(ORTHO)
		//for texture projections/shadowmapping on dlights
		vtexprojcoord = (l_cubematrix*vec4(w.xyz, 1.0));
	#endif
	}
#endif


#ifdef FRAGMENT_SHADER
	vec3 LightingFuncShlick(vec3 N, vec3 V, vec3 L, float roughness, vec3 Cdiff, vec3 F0)
	{
		vec3 H = normalize(V+L);
		float NL = clamp(dot(N,L), 0.001, 1.0);
		float LH = clamp(dot(L,H), 0.0, 1.0);
		float NH = clamp(dot(N,H), 0.0, 1.0);
		float NV = clamp(abs(dot(N,V)), 0.001, 1.0);
		float VH = clamp(dot(V,H), 0.0, 1.0);
		float PI = 3.14159f;

		//Fresnel term
		//the fresnel models glancing light.
		//(Schlick)
		vec3 F = F0 + (1.0-F0)*pow(1.0-VH, 5.0);

		//Schlick
		float k = roughness*0.79788456080286535587989211986876;
		float G = (LH/(LH*(1.0-k)+k)) * (NH/(NH*(1.0-k)+k));

		//microfacet distribution
		float a = roughness*roughness;
		a *= a;
		float t = (NH*NH*(a-1.0)+1.0);

		float D = a/(PI*t*t);

		if (r_glsl_fresnel == 1)
			return vec3(F);
		if (r_glsl_fresnel == 2)
			return vec3(G);
		if (r_glsl_fresnel == 3)
			return vec3(D);

		return ((1.0-F)*(Cdiff/PI) +
			(F*G*D)/(4.0*NL*NV)) * NL;
	}

	#include "sys/fog.h"
	#include "sys/pcf.h"

	#ifdef PBR
	#include "sys/pbr.h"
	#endif

	#ifdef OFFSETMAPPING
	#include "sys/offsetmapping.h"
	#endif

	void main ()
	{
		gl_FragColor = vec4(1.0, 1.0, 1.0, 1.0);

	#ifdef OFFSETMAPPING
		vec2 tcoffsetmap = offsetmap(s_normalmap, tcbase, eyevector);
		#define tcbase tcoffsetmap
	#endif

		vec4 albedo_f = texture2D(s_diffuse, tcbase);

		#ifdef SPECULAR
		vec3 spec_f = texture2D(s_specular, tcbase).rgb;
		#else
		vec3 spec_f = vec3(1.0, 0.0, 1.0);
        #endif

	#ifdef BUMP
		vec3 normal_f = normalize(texture2D(s_normalmap, tcbase).rgb - 0.5);
		normal_f.g *= -1.0f;
	#else
		vec3 normal_f = vec3(0.0,0.0,1.0);
	#endif

	#ifdef SKELETAL
        normal_f = vec3(0.0,0.0,1.0) - 0.5;
	#endif

	#ifdef ORTHO
		float colorscale = 1.0;
	#else
		float colorscale = max(1.0 - (dot(lightvector, lightvector)/(l_lightradius*l_lightradius)), 0.0);
	#endif

	#ifdef PCF
		/* filter the light by the shadowmap. logically a boolean, but we allow fractions for softer shadows */
		colorscale *= ShadowmapFilter(s_shadowmap, vtexprojcoord);
	#endif

	#ifdef SPOT
		/* filter the colour by the spotlight. discard anything behind the light so we don't get a mirror image */
		if (vtexprojcoord.w < 0.0) discard;
		vec2 spot = ((vtexprojcoord.st)/vtexprojcoord.w);
		colorscale*=1.0-(dot(spot,spot));
	#endif

		if (colorscale > 0.0)
		{
			vec3 out_f;

		#ifdef FLAT
			albedo_f = vec4(FLAT, FLAT, FLAT, 1.0);
		#else
			#ifdef VERTEXCOLOURS
				albedo_f.rgb *= albedo_f.a;
			#endif
		#endif

		#ifdef UPPER
			vec4 uc = texture2D(s_upper, tcbase);
			albedo_f.rgb += uc.rgb*e_uppercolour*uc.a;
		#endif

		#ifdef LOWER
			vec4 lc = texture2D(s_lower, tcbase);
			albedo_f.rgb += lc.rgb*e_lowercolour*lc.a;
		#endif

            float metalness_f = 1.0 - spec_f.r;
            float roughness_f = spec_f.g;
            float ao = spec_f.b;


	#ifndef BUMP
            metalness_f = 0.0;
	#endif

			vec3 nl = normalize(lightvector);
			out_f = albedo_f.rgb * (l_lightcolourscale.x + l_lightcolourscale.y * max(dot(normal_f.rgb, nl), 0.0));

			const vec3 dielectricSpecular = vec3(0.04, 0.04, 0.04);
			const vec3 black = vec3(0.0, 0.0, 0.0);
			vec3 F0 = mix(dielectricSpecular, albedo_f.rgb, metalness_f);
			albedo_f.rgb = mix(albedo_f.rgb * (1.0 - dielectricSpecular.r), black, metalness_f);

			out_f = DoPBR(normal_f.rgb, normalize(eyevector), normalize(lightvector), roughness_f, albedo_f.rgb, F0, l_lightcolourscale);

			vec3 cube_c = reflect(-eyevector, normal_f.rgb);
			cube_c = cube_c.x*invsurface[0] + cube_c.y*invsurface[1] + cube_c.z*invsurface[2];
			cube_c = vec4(m_model * vec4(cube_c.xyz,0.0)).xyz;

        #ifndef REFLECTCUBEMASK
			out_f.rgb = out_f.rgb + (vec3(metalness_f,metalness_f,metalness_f) * vec3(0.0,0.0,0.0));
        #else
			out_f.rgb = out_f.rgb + (vec3(metalness_f,metalness_f,metalness_f) * (textureCube(s_reflectcube, cube_c).rgb * ao));
        #endif

		#ifdef CUBE
			/* filter the colour by the cubemap projection */
			out_f *= textureCube(s_projectionmap, vtexprojcoord.xyz).rgb;
		#endif

		#ifdef PROJECTION
			/* 2d projection, not used */
			out_f *= texture2d(s_projectionmap, shadowcoord);
		#endif

		#ifdef VERTEXCOLOURS
			out_f *= vc.rgb * vc.a;
		#endif

			gl_FragColor.rgb = fog3additive(out_f * colorscale * l_lightcolour);
		} else {
			gl_FragColor.rgb = vec3(0.0, 0.0, 0.0);
		}
	}
#endif
