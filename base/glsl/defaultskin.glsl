//======= Copyright (c) 2015-2021 Vera Visions LLC. All rights reserved. =======
//
// Purpose:
//
// Skinned objects, aka rigged objects are handled here.
// Skeletal operations are performed on the GPU (hopefully) and we don't care
// about lightmaps, but query the engine for a dir + ambient term which may
// come from the lightgrid or not exist at all. At that point it should be
// the rtlight shader doing the major work though.
//==============================================================================

!!ver 100 150

!!permu FOG
!!permu BUMP
!!permu DELUXE
!!permu SPECULAR
!!permu FULLBRIGHT
!!permu FAKESHADOWS
!!permu OFFSETMAPPING
!!permu SKELETAL
!!permu UPPERLOWER

!!samps diffuse
!!samps =BUMP normalmap
!!samps =SPECULAR specular reflectcube
!!samps =FULLBRIGHT fullbright
!!samps =UPPERLOWER upper lower
!!samps =FAKESHADOWS shadowmap

!!permu FAKESHADOWS
!!cvardf r_glsl_pcf
!!cvardf r_skipDiffuse
!!cvardf r_fullbright
!!samps =FAKESHADOWS shadowmap

!!cvarf r_glsl_offsetmapping_scale
!!cvardf gl_specular

#ifndef FRESNEL
#define FRESNEL gl_specular
#endif


#ifndef LIGHT_DIR_MULTIPLIER
#define LIGHT_DIR_MULTIPLIER 1.0f
#endif

#ifndef LIGHT_MULTIPLIER
#define LIGHT_MULTIPLIER 1.0f
#endif

#include "sys/defs.h"

// always required
varying vec2 tc;
varying vec3 lightvector;
varying vec3 light;
varying vec3 light_dir;

// from this point forth, if we check for SPECULAR this means we're in PBR territory
#ifdef BUMP
varying vec3 eyevector;
varying mat3 invsurface;
#define PBR
#endif

// r_shadows 2
#ifdef FAKESHADOWS
	varying vec4 vtexprojcoord;
#endif

// our basic vertex shader
#ifdef VERTEX_SHADER
	#include "sys/skeletal.h"

	float lambert( vec3 normal, vec3 dir ) {
		return dot( normal, dir );
	}
	float halflambert( vec3 normal, vec3 dir ) {
		return ( dot( normal, dir ) * 0.5 ) + 0.5;
	}

	void main ()
	{
		vec3 n, s, t, w;
		gl_Position = skeletaltransform_wnst(w,n,s,t);

	#ifdef PBR
		vec3 eyeminusvertex = e_eyepos - w.xyz;
		eyevector.x = dot(eyeminusvertex, s.xyz);
		eyevector.y = dot(eyeminusvertex, t.xyz);
		eyevector.z = dot(eyeminusvertex, n.xyz);
		invsurface[0] = s;
		invsurface[1] = t;
		invsurface[2] = n;
	#endif

    #ifdef PBR
		light = (e_light_ambient + ((e_light_mul * lambert(n, e_light_dir)) * LIGHT_DIR_MULTIPLIER)) * LIGHT_MULTIPLIER;
    #else
		light = (e_light_ambient + ((e_light_mul * lambert(n, e_light_dir))));
    #endif

		tc = v_texcoord;
		lightvector.x = dot(e_light_dir, s.xyz);
		lightvector.y = dot(e_light_dir, t.xyz);
		lightvector.z = dot(e_light_dir, n.xyz);

		light_dir = e_light_dir;

	#ifdef FAKESHADOWS
		vtexprojcoord = (l_cubematrix*vec4(v_position.xyz, 1.0));
	#endif
	}
#endif

#ifdef FRAGMENT_SHADER
	#include "sys/fog.h"

	#ifdef FAKESHADOWS
	#include "sys/pcf.h"
	#endif

	#ifdef OFFSETMAPPING
	#include "sys/offsetmapping.h"
	#endif

	float LightingFuncGGX(vec3 N, vec3 V, vec3 L, float roughness, float F0)
	{
		float alpha = roughness*roughness;

		vec3 H = normalize(V+L);

		float dotNL = clamp(dot(N,L), 0.0, 1.0);
		float dotLH = clamp(dot(L,H), 0.0, 1.0);
		float dotNH = clamp(dot(N,H), 0.0, 1.0);

		float F, D, vis;

		// D
		float alphaSqr = alpha*alpha;
		float pi = 3.14159f;
		float denom = dotNH * dotNH *(alphaSqr-1.0) + 1.0f;
		D = alphaSqr/(pi * denom * denom);

		// F
		float dotLH5 = pow(1.0f-dotLH,5.0);
		F = F0 + (1.0-F0)*(dotLH5);

		// V
		float k = alpha/2.0f;
		float k2 = k*k;
		float invK2 = 1.0f-k2;
		vis = 1.0/(dotLH*dotLH*invK2 + k2);

		float specular = dotNL * D * F * vis;
		return specular;
	}

	vec3 hsv2rgb(float h, float s, float v)
	{
		int i;
		float f,p,q,t;
		vec3 col = vec3(0,0,0);

		h = max(0.0, min(360.0, h));
		s = max(0.0, min(100.0, s));
		v = max(0.0, min(100.0, v));

		s /= float(100.0);
		v /= float(100.0);

		if (s == 0.0) {
			col.x = col.y = col.z = floor(v * 255.0);
			return col / float(255.0);
		}

		h /= float(60.0);
		i = int(floor(h));
		f = h - float(i);
		p = v * (1.0 - s);
		q = v * (1.0 - s * f);
		t = v * (1.0 - s * (1.0 - f));

		switch (i) {
		case 0:
			col[0] = floor(255.0*v);
			col[1] = floor(255.0*t);
			col[2] = floor(255.0*p);
			break;
		case 1:
			col[0] = floor(255.0*q);
			col[1] = floor(255.0*v);
			col[2] = floor(255.0*p);
			break;
		case 2:
			col[0] = floor(255.0*p);
			col[1] = floor(255.0*v);
			col[2] = floor(255.0*t);
			break;
		case 3:
			col[0] = floor(255.0*p);
			col[1] = floor(255.0*q);
			col[2] = floor(255.0*v);
			break;
		case 4:
			col[0] = floor(255.0*t);
			col[1] = floor(255.0*p);
			col[2] = floor(255.0*v);
			break;
		default:
			col[0] = floor(255.0*v);
			col[1] = floor(255.0*p);
			col[2] = floor(255.0*q);
		}
		return col / float(255.0);
	}

	void main ()
	{
	#ifdef OFFSETMAPPING
		vec2 tcoffsetmap = offsetmap(s_normalmap, tc, eyevector);
		#define tc tcoffsetmap
	#endif

		vec4 albedo_f = texture2D(s_diffuse, tc);

    #if r_skipDiffuse==1
        albedo_f.rgb = vec3(1.0,1.0,1.0);
    #endif

	#if defined(MASK)
	#if defined(MASKLT)
		if (albedo_f.a < MASK)
			discard;
	#else
		if (albedo_f.a >= MASK)
			discard;
	#endif
		albedo_f.a = 1.0;	//alpha blending AND alpha testing usually looks stupid, plus it screws up our fog.
	#endif

	#ifdef BUMP
		vec3 normal_f = normalize(texture2D(s_normalmap, tc).rgb - 0.5);
		normal_f.g *= -1.0f;
    #endif

	#ifdef UPPER
		vec4 uc = texture2D(s_upper, tc);

		if (e_colourident.z == 2.0) {
			vec3 topcolor = hsv2rgb(float(e_colourident.x) * 360.0, 100.0, 100.0);
			albedo_f.rgb += uc.rgb*topcolor*uc.a;
		} else {
			albedo_f.rgb += uc.rgb*e_uppercolour*uc.a;
		}
	#endif

	#ifdef LOWER
		vec4 lc = texture2D(s_lower, tc);

		if (e_colourident.z == 2.0) {
			vec3 bottomcolor = hsv2rgb(float(e_colourident.y) * 360.0, 100.0, 100.0);
			albedo_f.rgb += lc.rgb*bottomcolor*lc.a;
		} else {
			albedo_f.rgb += lc.rgb*e_lowercolour*lc.a;
		}
	#endif

		if (e_colourident.z != 2.0) {
            albedo_f.rgb *= e_colourident.rgb;
        }

	#ifdef BUMP

        #ifdef SPECULAR
            float metalness_f = 1.0 - texture2D(s_specular, tc).r;
            float roughness_f = texture2D(s_specular, tc).g;
            float ao = texture2D(s_specular, tc).b;
        #else
            float metalness_f = 0.0;
            float roughness_f = 0.0;
            float ao = 1.0;
        #endif

		/* coords */
		vec3 cube_c;

		/* calculate cubemap texcoords */
		cube_c = reflect(-normalize(eyevector), normal_f.rgb);
		cube_c = cube_c.x * invsurface[0] + cube_c.y * invsurface[1] + cube_c.z * invsurface[2];
		cube_c = (m_model * vec4(cube_c.xyz, 0.0)).xyz;

		/* do PBR reflection using cubemap */
		gl_FragColor = albedo_f + (metalness_f * (textureCube(s_reflectcube, cube_c) * ao));

		/* do PBR specular using our handy function */
		gl_FragColor += (LightingFuncGGX(normal_f, normalize(eyevector), normalize(lightvector), roughness_f, 0.5) * gl_FragColor);
	#else
		gl_FragColor = albedo_f;
	#endif

	#if r_fullbright==0
		/* this isn't necessary if we're not doing lightgrid terms */
    #ifdef BUMP
		gl_FragColor.rgb *= (light * e_lmscale.rgb * dot(normal_f,  normalize(light_dir)));
    #else
		gl_FragColor.rgb *= light * e_lmscale.rgb;
    #endif
    #endif

	#ifdef FULLBRIGHT
		vec4 fb = texture2D(s_fullbright, tc);
		gl_FragColor.rgb += fb.rgb * fb.a * e_glowmod.rgb;
	#endif

		/* and let the engine add fog on top */
		gl_FragColor = fog4(gl_FragColor);
	}
#endif
