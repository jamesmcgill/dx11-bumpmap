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
// Per-vertex data used as input to the vertex shader.
//------------------------------------------------------------------------------
struct VertexShaderInput
{
  float3 pos : SV_Position;
  float3 normal : NORMAL;
  float4 tangent : TANGENT;
  float4 color : COLOR;
  float2 texCoord : TEXCOORD0;
};

//------------------------------------------------------------------------------
// Per-pixel color data passed through the pixel shader.
//------------------------------------------------------------------------------
struct PixelShaderInput
{
  float4 pos : SV_POSITION;
  float2 texCoord : TEXCOORD0;
  float3 normal : NORMAL;
  float3 light : TEXCOORD1;
  float3 eyeRay : TEXCOORD2;
};

//------------------------------------------------------------------------------
// Simple shader to do vertex processing on the GPU.
//------------------------------------------------------------------------------
PixelShaderInput
main(VertexShaderInput input)
{
  PixelShaderInput output;
  float4 pos    = float4(input.pos, 1.0f);
  float4 normal = float4(input.normal, 0.0f);

  // Transform the vertex position into projected space.
  float4 worldPos = mul(pos, model);
  pos             = mul(worldPos, view);
  pos             = mul(pos, projection);
  output.pos      = pos;

  // Matrix from world space to tangent space
  float4 biTangentAxis = float4(cross(input.tangent.xyz, input.normal), 0.0f);
  float3x3 worldToTangentSpace;
  worldToTangentSpace[0] = mul(input.tangent, model).xyz;
  worldToTangentSpace[1] = mul(biTangentAxis, model).xyz;
  worldToTangentSpace[2] = mul(normal, model).xyz;

  output.texCoord = input.texCoord;

  // transform the normal
  output.normal = mul(normal, model).xyz;

  // for specular light
  output.light  = mul(worldToTangentSpace, lightDir.xyz);
  output.eyeRay = mul(worldToTangentSpace, (eyePos - worldPos).xyz);

  return output;
}

//------------------------------------------------------------------------------
