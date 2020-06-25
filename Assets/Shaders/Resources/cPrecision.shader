// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Hidden/cPrecision"
{
	Properties
	{
		_MainTex("Texture", 2D) = "white" {}
		_Colors("Color precision", Float) = 0
		_Palette("Palette", 2D) = "white" {}
	}
		SubShader
	{
		// No culling or depth
		Cull Off ZWrite Off ZTest Always

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
			};

			v2f vert(appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				return o;
			}

			sampler2D _MainTex;
			sampler2D _Palette;
			float _usePalette;
			float _Colors;

			fixed4 frag(v2f i) : SV_Target
			{
				fixed4 col = tex2D(_MainTex , i.uv);
				col *= _Colors;
				col = floor(col);
				col /= _Colors;
				if (_usePalette == 1) col = tex2D(_Palette, float2((col.r + col.g + col.b) / 3, i.uv.y));
				return col;
			}
			ENDCG
		}
	}
}
