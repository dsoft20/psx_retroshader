// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "psx/reflective/unlit-Mult" {
	Properties{
		_MainTex("Base (RGB)", 2D) = "white" {}
	_Cube("Cubemap", CUBE) = "" {}
	}
		SubShader{
		Tags{ "RenderType" = "Opaque" }
		LOD 200

		Pass{
		Lighting On
		CGPROGRAM

#pragma vertex vert
#pragma fragment frag
#include "UnityCG.cginc"

	struct v2f
	{
		fixed4 pos : SV_POSITION;
		half4 color : COLOR0;
		half4 colorFog : COLOR1;
		float2 uv_MainTex : TEXCOORD0;
		half3 normal : TEXCOORD1;
		float3 reflect : COLOR2;
	};

	float4 _MainTex_ST;
	uniform half4 unity_FogStart;
	uniform half4 unity_FogEnd;

	v2f vert(appdata_full v)
	{
		v2f o;

		//Vertex snapping
		float4 snapToPixel = UnityObjectToClipPos(v.vertex);
		float4 vertex = snapToPixel;
		vertex.xyz = snapToPixel.xyz / snapToPixel.w;
		vertex.x = floor(160 * vertex.x) / 160;
		vertex.y = floor(120 * vertex.y) / 120;
		vertex.xyz *= snapToPixel.w;
		o.pos = vertex;

		//Reflection
		float3 viewDir = WorldSpaceViewDir(v.vertex);
		float3 worldN = mul((float3x3)unity_ObjectToWorld, v.normal * 1.0);
		o.reflect = reflect(-viewDir, worldN);

		//Vertex lighting 
		o.color = v.color*UNITY_LIGHTMODEL_AMBIENT;;

		float distance = length(mul(UNITY_MATRIX_MV,v.vertex));

		//Affine Texture Mapping
		float4 affinePos = vertex;//vertex;				
		o.uv_MainTex = TRANSFORM_TEX(v.texcoord, _MainTex);
		o.uv_MainTex *= distance + (vertex.w*(UNITY_LIGHTMODEL_AMBIENT.a * 8)) / distance / 2;
		o.normal = distance + (vertex.w*(UNITY_LIGHTMODEL_AMBIENT.a * 8)) / distance / 2;

		//Affine texturing for cubemap
		o.reflect *= o.normal;

		//Fog
		float4 fogColor = unity_FogColor;

		float fogDensity = (unity_FogEnd - distance) / (unity_FogEnd - unity_FogStart);
		o.normal.g = fogDensity;
		o.normal.b = 1;

		o.colorFog = fogColor;
		o.colorFog.a = clamp(fogDensity,0,1);

		//Cut out polygons
		if (distance > unity_FogStart.z + unity_FogColor.a * 255)
		{
			o.pos.w = 0;
		}


		return o;
	}

	sampler2D _MainTex;
	samplerCUBE _Cube;

	float4 frag(v2f IN) : COLOR
	{
		half4 c = tex2D(_MainTex, IN.uv_MainTex / IN.normal.r)*IN.color;
		c *= texCUBE(_Cube, IN.reflect);
		half4 color = c*(IN.colorFog.a);
		color.rgb += IN.colorFog.rgb*(1 - IN.colorFog.a);
		return color;
	}
		ENDCG
	}
	}
}