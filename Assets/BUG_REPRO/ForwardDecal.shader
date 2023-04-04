Shader "Unlit/ForwardDecal"
{
    Properties {}
    SubShader
    {
        Tags
        {
            "RenderType" = "Opaque"
            "IgnoreProjector" = "True"
            "RenderPipeline" = "UniversalPipeline"
        }
        LOD 100

        Pass
        {
            Name "Forward"
            
            ZTest Always
            ZWrite Off
            Cull Front

            HLSLPROGRAM
            #pragma target 3.0

            // -------------------------------------
            // Unity defined keywords
            #pragma multi_compile_fog
            #pragma multi_compile_instancing
            #pragma multi_compile _ DOTS_INSTANCING_ON

            #pragma vertex Vertex
            #pragma fragment Fragment

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareDepthTexture.hlsl"

            struct Attributes
            {
                float4 positionOS : POSITION;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float2 uv : TEXCOORD0;
                float4 projection : TEXCOORD1;
                float3 viewDirection : TEXCOORD2;
                UNITY_VERTEX_INPUT_INSTANCE_ID
                UNITY_VERTEX_OUTPUT_STEREO
            };

            Varyings Vertex(Attributes input)
            {
                Varyings output = (Varyings)0;

                float3 positionWS = TransformObjectToWorld(input.positionOS.xyz);
                output.positionCS = TransformWorldToHClip(positionWS);
                output.uv = input.positionOS.xz + 0.5;
                output.viewDirection = TransformWorldToView(positionWS) * float3(-1, -1, 1);
                output.projection = ComputeScreenPos(output.positionCS);

                return output;
            }

            float2 DecalUV(Varyings input, out float originalDepth)
            {
                input.viewDirection = input.viewDirection * (_ProjectionParams.z / input.viewDirection.z);
                float2 grabUV = input.projection.xy / input.projection.w;
                // read depth and reconstruct world position
                originalDepth = SampleSceneDepth(grabUV);
                float depth = Linear01Depth(originalDepth, _ZBufferParams);

                float4 vpos = float4(input.viewDirection * depth, 1);
                float3 wpos = mul(unity_CameraToWorld, vpos).xyz;
                float3 opos = mul(unity_WorldToObject, float4(wpos, 1)).xyz;

                clip(0.5 - abs(opos.xyz));
                return opos.xz + 0.5;
            }

            half4 Fragment(Varyings input, out float depth : SV_Depth) : SV_Target
            {
                DecalUV(input, depth);
                return half4(1, 0, 0, 1);
            }
            ENDHLSL
        }
    }
}