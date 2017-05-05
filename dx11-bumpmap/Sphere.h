#pragma once
#include "pch.h"

//------------------------------------------------------------------------------
class Sphere
{
public:
	Sphere(_In_ ID3D11Device* device);

	void __cdecl Draw(
		_In_ ID3D11DeviceContext* deviceContext,
		_In_ DirectX::IEffect* effect,
		_In_ ID3D11InputLayout* inputLayout) const;

	void __cdecl CreateInputLayout(
		_In_ ID3D11Device* device,
		_In_ DirectX::IEffect* effect,
		_Outptr_ ID3D11InputLayout** pInputLayout) const;

private:
	Microsoft::WRL::ComPtr<ID3D11Buffer> m_VB;
	Microsoft::WRL::ComPtr<ID3D11Buffer> m_IB;
	DirectX::CommonStates m_states;
};

//------------------------------------------------------------------------------