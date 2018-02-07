//@author: vvvv group
//@help: Effect processing for skinned mesh.
//@tags: bone
//@credits: 

Texture2D texture2d <string uiname="Texture";>;
StructuredBuffer<float4x4> JointMatrices;

SamplerState linearSampler : IMMUTABLE
{
    Filter = MIN_MAG_MIP_LINEAR;
    AddressU = Clamp;
    AddressV = Clamp;
};
 
cbuffer cbPerDraw : register( b0 )
{
	float4x4 tVP : LAYERVIEWPROJECTION;	
};

cbuffer cbPerObj : register( b1 )
{
	float4x4 tW : WORLD;
	float4 cAmb <bool color=true;String uiname="Color";> = { 1.0f,1.0f,1.0f,1.0f };
};

struct VS_IN
{
	float3 PosO : POSITION;
	float3 Normal : NORMAL;
	float2 TexCd : TEXCOORD0;
	float4 BlendWeights	: BLENDWEIGHT;
	float4 BlendIndices	: BLENDINDICES;
};

struct vs2ps
{
    float4 PosWVP: SV_Position;
    float2 TexCd: TEXCOORD0;
};

vs2ps VS(VS_IN input)
{
    vs2ps output;
	
	float4 blendWeights = input.BlendWeights;
	float4 indices = input.BlendIndices;
	
	float4 pos = 0;

    for (int i = 0; i < 4; i++)
    {
        pos = pos + mul(float4(input.PosO.xyz,1), JointMatrices[indices[i]]) * blendWeights[i];
    }

    output.PosWVP  = mul(pos, mul(tW, tVP));
    output.TexCd = input.TexCd;
    return output;
}

float4 PS(vs2ps In): SV_Target
{
    float4 col = texture2d.Sample(linearSampler,In.TexCd.xy) * cAmb;
    return col;
}

technique10 Constant
{
	pass P0
	{
		SetVertexShader( CompileShader( vs_4_0, VS() ) );
		SetPixelShader( CompileShader( ps_4_0, PS() ) );
	}
}