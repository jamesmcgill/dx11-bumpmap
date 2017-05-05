cbuffer StaticBuffer : register(b0)
{
	float4 modelColor;
	float4 ambientIC;
	float4 diffuseIC;
	float4 specularIC;
	float4 lightDir;
};

//------------------------------------------------------------------------------
cbuffer DynamicBuffer : register(b1)
{
	matrix model;
	matrix view;
	matrix projection;
	matrix worldInverseTranspose;
	float4 eyePos;
};

//------------------------------------------------------------------------------
// Per-pixel color data passed through the pixel shader.
//------------------------------------------------------------------------------
struct PixelShaderInput
{
	float4 pos : SV_POSITION;
	float2 texCoord: TEXCOORD0;
	float3 normal : NORMAL;
	float3 eyeRay: TEXCOORD2;
};

//------------------------------------------------------------------------------
// Textures and Samplers
//------------------------------------------------------------------------------
Texture2D ColorMap : register(t0);
SamplerState ColorMapSampler : register(s0);

//------------------------------------------------------------------------------
// A pass-through function for the (interpolated) color data. 
//------------------------------------------------------------------------------
float4 main(PixelShaderInput input) : SV_TARGET
{
	float4 texColor = ColorMap.Sample(ColorMapSampler, input.texCoord);

	float3 lightRay = normalize(-lightDir.xyz);
	float3 viewDir = normalize(input.eyeRay);

	float3 normal = normalize(input.normal);
	float cosLight = dot(normal, lightRay);
	float diffuse = saturate(cosLight);

	// R = 2(n.l)n -l
	float3 reflect = normalize(2 * cosLight * normal - lightRay);

	// Spec = R.V
	float specular = 
		pow(
		saturate(dot(reflect, viewDir))
		, 32);

	float4 color = (0.2 * texColor) + (diffuse * texColor);
	color.w = 1.0;
	return color + (specular * specularIC);
}

//------------------------------------------------------------------------------