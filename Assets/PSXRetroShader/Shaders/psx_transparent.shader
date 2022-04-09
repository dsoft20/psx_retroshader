Shader "psx/psx-transparent" {
	Properties{
		[KeywordEnum(VertexLit, UnlitAmbient, Unlit)] _Lightning ("Lighting mode", Float) = 0
		_Color("Color", Color) = (1, 1, 1, 1)
		_MainTex("Base (RGB)", 2D) = "white" {}
		_Cube("Reflection map", CUBE) = "" {}
		_ReflectionPower("Reflection power", Range(0, 1)) = 0
		[KeywordEnum(Add, Mult)] _Reflection ("Reflection mode", Float) = 0
	}
	SubShader{
		Tags{ "Queue" = "Transparent" "RenderType" = "Transparent" }
		LOD 200
		Blend SrcAlpha OneMinusSrcAlpha

		Pass{
			Lighting On
			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_fog
			#pragma shader_feature _LIGHTNING_VERTEXLIT _LIGHTNING_UNLITAMBIENT _LIGHTNING_UNLIT
			#pragma shader_feature _REFLECTION_ADD _REFLECTION_MULT
			#include "UnityCG.cginc"
			#include "psx.cginc"

			float4 _MainTex_ST;
			half4 _Color;
			sampler2D _MainTex;
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

				UNITY_APPLY_FOG(IN.fogCoord, c);
				return c;
			}
			ENDCG
		}
	}
}