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
	float3 light : TEXCOORD1;
	float3 eyeRay: TEXCOORD2;
};

//------------------------------------------------------------------------------
// Textures and Samplers
//------------------------------------------------------------------------------
Texture2D ColorMap : register(t0);
SamplerState Sampler : register(s0);
Texture2D NormalMap : register(t1);

//------------------------------------------------------------------------------
// A pass-through function for the (interpolated) color data. 
//------------------------------------------------------------------------------
float4 main(PixelShaderInput input) : SV_TARGET
{
	float4 texColor = ColorMap.Sample(Sampler, input.texCoord);
	float3 normal = ((2 * NormalMap.Sample(Sampler, input.texCoord)) - 1.0).xyz;

	float3 lightRay = normalize(-input.light.xyz);
	float3 viewDir = normalize(input.eyeRay);

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