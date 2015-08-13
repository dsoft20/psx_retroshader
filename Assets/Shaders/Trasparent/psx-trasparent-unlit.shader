Shader "psx/trasparent/unlit" {
	Properties {
		_MainTex ("Base (RGB)", 2D) = "white" {}
	} 
	SubShader {
		Tags { "Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent"  "DisableBatching"="True"}
	//	ZWrite Off
		Blend SrcAlpha OneMinusSrcAlpha  
        //AlphaTest Less .01 
        Cull Off
		LOD 200	    
		     
		Pass { 
		Lighting On
			CGPROGRAM
			  

				#pragma vertex vert
				#pragma fragment frag
				#include "UnityCG.cginc"
			
				struct v2f 
				{
					fixed4 pos : SV_POSITION;
					float4 color : COLOR0;
					float4 colorFog : COLOR1;
					float2 uv_MainTex : TEXCOORD0;
					float3 normal : NORMAL;
				};
			
				float4 _MainTex_ST;
				uniform half4 unity_FogStart;
				uniform half4 unity_FogEnd;

				v2f vert(appdata_full v) 
				{
					v2f o;		

					//Vertex snapping
					float4 snapToPixel = mul(UNITY_MATRIX_MVP,v.vertex);
					float4 vertex =  snapToPixel;
					vertex.xyz = snapToPixel.xyz/snapToPixel.w;
					vertex.x = round(160*vertex.x)/160;
					vertex.y = round(120*vertex.y)/120;
					vertex.xyz*=snapToPixel.w;
					o.pos = vertex;

					float distance =length(mul (UNITY_MATRIX_MV,v.vertex));
						
					//Vertex color				
					o.color = v.color;
									
					//Affine Texture Mapping
					float4 affinePos = vertex;//vertex;				
					o.uv_MainTex = TRANSFORM_TEX(v.texcoord, _MainTex);
					o.uv_MainTex *= distance + (vertex.w*(UNITY_LIGHTMODEL_AMBIENT.a * 8)) / distance / 2;
					o.normal = distance + (vertex.w*(UNITY_LIGHTMODEL_AMBIENT.a * 8)) / distance / 2;

					//Fog
					float4 fogColor = unity_FogColor;
							
					float fogDensity = (unity_FogEnd-distance)/(unity_FogEnd-unity_FogStart);					
					o.normal.g = fogDensity;
					o.normal.b = 1;
					o.colorFog = fogColor;
					o.colorFog.a = clamp(fogDensity,0,1);

					//Cut out polygons
					if (distance >= unity_FogStart.z + unity_FogColor.a * 255)
					{
						o.pos.w = 0;
					}

					return o; 
				}
			
				sampler2D _MainTex;
			
				float4 frag(v2f IN) : COLOR 
				{
					fixed4 c = tex2D (_MainTex, IN.uv_MainTex/IN.normal.r)*IN.color;				
					float4 color = c*(IN.colorFog.a);
					color.rgb += IN.colorFog.rgb*(1-IN.colorFog.a);					
					return color;
				}
			ENDCG
		}
	}
}