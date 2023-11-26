Shader "Unlit/NewUnlitShader"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_MainTex2 ("Texture", 2D) = "white" {}
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 100

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			// make fog work
			#pragma multi_compile_fog
			
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
				float2 uv2 : TEXCOORD1;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float2 uv2: TEXCOORD1;
				UNITY_FOG_COORDS(1)
				float4 vertex : SV_POSITION;
			};

			sampler2D _MainTex;
			sampler2D _MainTex2;
			float4 _MainTex_ST;
			float4 _MainTex2_ST;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				o.uv2 = TRANSFORM_TEX(v.uv, _MainTex2);
				UNITY_TRANSFER_FOG(o,o.vertex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				// sample the texture
				fixed4 col = tex2D(_MainTex, i.uv);
				// apply fog
				UNITY_APPLY_FOG(i.fogCoord, col);
				float me = tex2D(_MainTex, i.uv).x;
				
				
				/*
				float heightmapsize = 1024.0;
				float n = tex2D(_MainTex, float2(i.uv.x, i.uv.y + 1.0f/heightmapsize)).x;
				float s = tex2D(_MainTex, float2(i.uv.x, i.uv.y - 1.0f/heightmapsize)).x;
				float e = tex2D(_MainTex, float2(i.uv.x + 1.0f/heightmapsize, i.uv.y )).x;
				float w = tex2D(_MainTex, float2(i.uv.x - 1.0f/heightmapsize, i.uv.y )).x;

				float3 normalOffset = float3((n-me) - (s-me),(e-me)-(w-me),0) * 20 ;

				normalOffset.b = 1;

				*/

				float xnormal =  (ddx(me)*1) * 0.5+0.5;
				float ynormal =  (ddy(me)*1) * 0.5+0.5;
				float3 createdNormal = float3(xnormal,ynormal,1);
				createdNormal = createdNormal *2-1;
				fixed4 colortex = tex2D(_MainTex2, i.uv2 + createdNormal.xy*0.5);


				
				return colortex;

				//return float4 (normalOffset * 0.5+0.5,1);
				
			}
			ENDCG
		}
	}
}