/*-----------------------------------------

Copyright (c) 2018 suraimu752

This source is released under the MIT License, see under URL.
https://github.com/suraimu752/Unity-Shader/blob/master/MIT_License.txt

-----------------------------------------*/

Shader "Custom/Meishi"
{
	Properties
	{
		_Size("Size", range(0.001, 1)) = 0.001
		_Seed("Random Seed", float) = 0
		_Color("Color", Color) = (0, 0, 0, 1)
	}
	SubShader
	{
		Tags { "RenderType"="Transparent" "Queue"="Transparent" "IgnoreProjector"="True" }
		LOD 100
		Cull Off
		ZWrite Off
		Blend SrcAlpha OneMinusSrcAlpha

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma geometry geom
			#pragma fragment frag
			
			#include "UnityCG.cginc"

			float _Seed;

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct g2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
			};

			float rand(float2 co) {
				return frac(sin(dot(co+_Seed, float2(12.9898, 78.233))) * 43758.5453);
			}

			#define PI 3.1415926535897932384626433832795
			
			appdata vert (appdata v)
			{
				appdata o;
				float r0 = rand(v.uv+0)*2-1, r1 = rand(v.uv+1)*2-1, r2 = rand(v.uv+2)*2-1;

				r0 *= 60, r2 *= 60;

				float th1 = 2*PI*r1;
				float3 vert = float3(r0, sin(th1)*6-3, r2);

				if(v.uv.x < 0.9) o.vertex = mul(UNITY_MATRIX_M, float4(vert, 1));
				else o.vertex = mul(UNITY_MATRIX_M, float4(0, -100, 0, 1));
				o.uv = v.uv;
				return o;
			}

			float _Size;
			float4 _Color;

			[maxvertexcount(4)]
			void geom(triangle appdata input[3], inout TriangleStream<g2f> stream) {

				[unroll]
				for (int i=0;i<3;i++){
					appdata v = input[i];
					g2f o;
					float4 vert = mul(UNITY_MATRIX_V, v.vertex);

					o.uv = float2(-1, -1);
					o.vertex = mul(UNITY_MATRIX_P, vert + float4(o.uv, 0, 0) * _Size);
					stream.Append(o);
					
					o.uv = float2(1, -1);
					o.vertex = mul(UNITY_MATRIX_P, vert + float4(o.uv, 0, 0) * _Size);
					stream.Append(o);

					o.uv = float2(-1, 1);
					o.vertex = mul(UNITY_MATRIX_P, vert + float4(o.uv, 0, 0) * _Size);
					stream.Append(o);

					o.uv = float2(1, 1);
					o.vertex = mul(UNITY_MATRIX_P, vert + float4(o.uv, 0, 0) * _Size);
					stream.Append(o);

					stream.RestartStrip();
				}
			}
			
			fixed4 frag (g2f i) : SV_Target
			{
				float d = length(i.uv);

				fixed4 col;
				//col.rgb = float3(66./255, 164./255, 244./255)*1.5;
				col = _Color*1.5;
				col.a = clamp(1. - d*d, 0., 1.)*1.2;
				if(col.a > 1){
					col.rgb *= col.a;
					col.a = 1;
				}
				return col;
			}
			ENDCG
		}
	}
}
