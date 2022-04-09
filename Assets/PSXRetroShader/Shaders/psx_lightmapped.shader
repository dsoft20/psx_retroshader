Shader "psx/psx-lightmapped" {
	Properties{
		[KeywordEnum(VertexLit, UnlitAmbient, Unlit)] _Lightning ("Lighting mode", Float) = 0
		_Color("Color", Color) = (1, 1, 1, 1)
		_MainTex("Base (RGB)", 2D) = "white" {}
		_Cube("Reflection map", CUBE) = "" {}
		_ReflectionPower("Reflection power", Range(0, 1)) = 0
		[KeywordEnum(Add, Mult)] _Reflection ("Reflection mode", Float) = 0
	}
	SubShader{
		Tags{ "RenderType" = "Opaque" }
		LOD 200

		Pass{
			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_fog
			#pragma multi_compile __ LIGHTMAP_ON
			#pragma shader_feature _LIGHTNING_VERTEXLIT _LIGHTNING_UNLITAMBIENT _LIGHTNING_UNLIT
			#pragma shader_feature _REFLECTION_ADD _REFLECTION_MULT
			#include "UnityCG.cginc"
			#include "psx.cginc"

			float4 _MainTex_ST;
			sampler2D _MainTex;
			half4 _Color;
			samplerCUBE _Cube;
			half _ReflectionPower;

			psx_v2f vert(psx_appdata v)
			{
				psx_v2f o;
				UNITY_INITIALIZE_OUTPUT(psx_v2f, o);

				//Vertex snapping
				o.pos = pixelSnapping(v.vertex);

				//lighting 
				#if _LIGHTNING_VERTEXLIT
				o.color = vertexLitLightning(v);
				#elif _LIGHTNING_UNLITAMBIENT
				o.color = unlitAmbientLightning(v);
				#else
				o.color = unlitLightning(v);
				#endif

				//Affine texture mapping
				o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);

				//Reflection
				o.reflect = calculateReflection(v);

				//Lightmapping
				#if LIGHTMAP_ON
				o.uv1 = v.texcoord1.xy * unity_LightmapST.xy + unity_LightmapST.zw;
				#endif

				UNITY_TRANSFER_FOG(o, o.pos);

				return o;
			}

			float4 frag(psx_v2f IN) : COLOR
			{
				half4 c = tex2D(_MainTex, IN.uv) * IN.color * _Color;

				#if _REFLECTION_ADD
				c += texCUBE(_Cube, IN.reflect) * _ReflectionPower;
				#else
				c = lerp(c, c * texCUBE(_Cube, IN.reflect), _ReflectionPower);
				#endif

				#if LIGHTMAP_ON
				c.rgb *= DecodeLightmap(UNITY_SAMPLE_TEX2D(unity_Lightmap, IN.uv1));
				#endif

				UNITY_APPLY_FOG(IN.fogCoord, c);
				return c;
			}
			ENDCG
		}
	}

	Fallback "Diffuse"
}