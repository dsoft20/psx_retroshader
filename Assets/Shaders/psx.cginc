uniform int _XPrecision = 160;
uniform int _YPrecision = 120;

struct psx_v2f
{
	fixed4 pos : SV_POSITION;
	float2 uv_MainTex : TEXCOORD0;
	half3 normal : NORMAL;
	half4 color : COLOR;
	float3 reflect : COLOR1;
	UNITY_FOG_COORDS(2)
};

struct psx_v2f_refl : psx_v2f
{
};

struct psx_appdata
{
	float4 vertex : POSITION;
	float3 normal : NORMAL;
	float4 texcoord : TEXCOORD0;
	fixed4 color : COLOR;
};

//returns vertex position snapped to the _XPrecision and _YPrecision
float4 pixelSnapping(float4 pos)
{
	float4 snapToPixel = UnityObjectToClipPos(pos);
	float4 vertex = snapToPixel;
	vertex.xyz = snapToPixel.xyz / snapToPixel.w;
	vertex.x = floor(_XPrecision * vertex.x) / _XPrecision;
	vertex.y = floor(_YPrecision * vertex.y) / _YPrecision;
	vertex.xyz *= snapToPixel.w;
	return vertex;
};

//applys affine texture mapping
float2 affineMapping(psx_appdata v, fixed4 snappedPos, float4 mainTex_ST, out half3 normal)
{
	float distance = length(mul(UNITY_MATRIX_MV, v.vertex));
	
	float2 uv = v.texcoord.xy * mainTex_ST.xy + mainTex_ST.zw;
	uv *= distance + (snappedPos.w*(UNITY_LIGHTMODEL_AMBIENT.a * 8)) / distance / 2;
	normal = distance + (snappedPos.w*(UNITY_LIGHTMODEL_AMBIENT.a * 8)) / distance / 2;
	
	return uv;
};

//calculates reflection vector
float3 calculateReflection(psx_appdata v)
{
	float3 viewDir = WorldSpaceViewDir(v.vertex);
	float3 worldN = mul((float3x3)unity_ObjectToWorld, v.normal * 1.0);
	return reflect(-viewDir, worldN);
}

half4 unlitLightning(psx_appdata v)
{
	return v.color;
}

half4 unlitAmbientLightning(psx_appdata v)
{
	return v.color * UNITY_LIGHTMODEL_AMBIENT;
}

half4 vertexLitLightning(psx_appdata v)
{
	return float4(ShadeVertexLightsFull(v.vertex, v.normal, 4, true), 1.0) * v.color;
}