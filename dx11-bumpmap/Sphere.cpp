#include "pch.h"
#include "Sphere.h"

using namespace DirectX;

//------------------------------------------------------------------------------
namespace
{
#include "assets/dgslsphere.inc"
}

//------------------------------------------------------------------------------
Sphere::Sphere(ID3D11Device* device)
    : m_states(device)
{
  {
    D3D11_BUFFER_DESC desc = {0};
    desc.ByteWidth         = sizeof(g_sphereVB);
    desc.Usage             = D3D11_USAGE_DEFAULT;
    desc.BindFlags         = D3D11_BIND_VERTEX_BUFFER;

    D3D11_SUBRESOURCE_DATA initData = {0};
    initData.pSysMem                = g_sphereVB;
    device->CreateBuffer(&desc, &initData, m_VB.ReleaseAndGetAddressOf());
  }

  {
    D3D11_BUFFER_DESC desc = {0};
    desc.ByteWidth         = sizeof(g_sphereIB);
    desc.Usage             = D3D11_USAGE_DEFAULT;
    desc.BindFlags         = D3D11_BIND_INDEX_BUFFER;

    D3D11_SUBRESOURCE_DATA initData = {0};
    initData.pSysMem                = g_sphereIB;
    device->CreateBuffer(&desc, &initData, m_IB.ReleaseAndGetAddressOf());
  }
}

//------------------------------------------------------------------------------
void
Sphere::Draw(
  ID3D11DeviceContext* deviceContext,
  DirectX::IEffect* effect,
  ID3D11InputLayout* inputLayout) const
{
  assert(deviceContext != 0);
  assert(effect != 0);

  if (!inputLayout)
  {
    return;
  }

  effect->Apply(deviceContext);

  auto sampler = m_states.LinearWrap();
  deviceContext->PSSetSamplers(0, 1, &sampler);
  deviceContext->RSSetState(m_states.CullClockwise());
  deviceContext->IASetIndexBuffer(m_IB.Get(), DXGI_FORMAT_R16_UINT, 0);
  deviceContext->IASetInputLayout(inputLayout);

  UINT stride = sizeof(VertexPositionNormalTangentColorTexture);
  UINT offset = 0;
  deviceContext->IASetVertexBuffers(
    0, 1, m_VB.GetAddressOf(), &stride, &offset);

  deviceContext->IASetPrimitiveTopology(D3D11_PRIMITIVE_TOPOLOGY_TRIANGLELIST);
  deviceContext->DrawIndexed(_countof(g_sphereIB), 0, 0);
}

//------------------------------------------------------------------------------
void
Sphere::CreateInputLayout(
  ID3D11Device* device, IEffect* effect, ID3D11InputLayout** pInputLayout) const
{
  void const* shaderByteCode;
  size_t byteCodeLength;
  effect->GetVertexShaderBytecode(&shaderByteCode, &byteCodeLength);

  if (byteCodeLength == 0)
  {
    return;
  }

  device->CreateInputLayout(
    VertexPositionNormalTangentColorTexture::InputElements,
    VertexPositionNormalTangentColorTexture::InputElementCount,
    shaderByteCode,
    byteCodeLength,
    pInputLayout);
}

//------------------------------------------------------------------------------
