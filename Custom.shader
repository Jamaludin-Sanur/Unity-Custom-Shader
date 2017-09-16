Shader "__Costum_Shader__/Custom"
{
    Properties
    {
    	[Header(Diffuse)]
    	_Color ("Color", color) = (1., 1., 1., 1.)				// Color
        _MainTex ("Texture", 2D) = "white" {}						// Texture

        [Header(Specular)]
        _SpecColor ("Specular color", color) = (1., 1., 1., 1.)		// Specular Color
        _Shininess ("Shininess", Range(0, 10)) = 0.				// Shininess

        [Header(Ambient)]
        _AmbColor ("Color", color) = (1., 1., 1., 1.)				// Ambient Color
        _Ambient ("Intensity", Range(0., 1.)) = 0.1					// Ambient Intensity

        [Header(Reflection)]
        [Toggle] _REFLECTION("Enable (Probe must exist)", Float) = 0	// Reflection 
 
        [Header(Lightmap)]
        _LightMapTex ("Texture", 2D) = "gray" {}				// Light Map
        _LightMapColor ("Tint Color", color) = (1., 1., 1., 1.)	// Light Map Color
        _LightMapVal ("Intensity", Range(0, 10)) = 0.					// Light Map Intensity

        [Header(Mouse Event)]
        _HoverTex ("Mouse Hover Texture", 2D) = "white" {}	// Texture applied at mouse hover
        _ClickTex ("Mouse Click Texture", 2D) = "white" {}	// Texture applied at mouse click
		[HideInInspector] _LerpValue ("Transition", Range(0,1)) = 0			// Transition used at mouse hover

    }
 
    SubShader
    {
        Pass
        {
            Tags { "RenderType"="Opaque" "Queue"="Geometry" "LightMode"="ForwardBase" }
 
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
 			#pragma multi_compile _REFLECTION_OFF _REFLECTION_ON

            #include "UnityCG.cginc"
 
            struct v2f {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
                fixed4 light : COLOR0;
                float3 coord: NORMAL;
            };
 
            fixed4 _LightColor0;
           
            // Diffuse
            fixed4 _Color;

            //Specular
            fixed _Shininess;
            fixed4 _SpecColor;
           
            //Ambient
            fixed _Ambient;
            fixed4 _AmbColor;

            // Texture
            sampler2D _MainTex;
            sampler2D _MainTex_ST;
            sampler2D _HoverTex;
            sampler2D _HoverTex_ST;
            sampler2D _ClickTex;
            sampler2D _ClickTex_ST;

            // Transition value
            float _LerpValue;


            v2f vert(appdata_base v)
            {
                v2f o;
                // World position
                float4 worldPos = mul(unity_ObjectToWorld, v.vertex);
 
                // Clip position
                o.pos = mul(UNITY_MATRIX_VP, worldPos);
 
                // Light direction
                float3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
 
                // Normal in World Space
                float3 worldNormal = normalize(mul(v.normal, (float3x3)unity_WorldToObject));
 
                // Camera direction
                float3 viewDir = normalize(_WorldSpaceCameraPos.xyz - worldPos.xyz);
 
                // Calculate ambient lighting
                fixed4 amb = _Ambient * _AmbColor;
 
                // Calculate diffuse lighting
                fixed4 NdotL = max(0., dot(worldNormal, lightDir) * _LightColor0);
                fixed4 dif = NdotL * _LightColor0 * _Color;
                o.light = dif + amb;
 
                // Calculate specular 
                float3 refl = reflect(-lightDir, worldNormal);
                float RdotV = max(0., dot(refl, viewDir));
                fixed4 spec = RdotV* _Shininess * _LightColor0 * ceil(NdotL) * _SpecColor;
               	o.light += spec;

               	o.coord = v.normal;
                o.uv = v.texcoord;
 
                return o;
            }
 
            // Lightmap
            sampler2D _LightMapTex;
            sampler2D _LightMapTex_ST;
            fixed4 _LightMapColor;
            fixed _LightMapVal;
 
            fixed4 frag(v2f i) : SV_Target
            {
                fixed4 c = tex2D(_MainTex, i.uv);

               	// Change texture overtime based on _LerpValue
				// _LerpValue will change by mouse event from other component
				c += lerp( tex2D(_MainTex, i.uv), tex2D(_HoverTex, i.uv), _LerpValue);

                c.rgb *= i.light;
 
                // Calculate lightmap
                fixed4 emi = tex2D(_LightMapTex, i.uv).r * _LightMapColor * _LightMapVal;
                c.rgb += emi.rgb;

                // Calculate reflection
                #if _REFLECTION_ON
                	float3 coords = normalize(i.coord);
	                float4 finalColor = 1.0;
	                float4 val = UNITY_SAMPLE_TEXCUBE(unity_SpecCube0, coords);
	                finalColor.xyz = DecodeHDR(val, unity_SpecCube0_HDR);
	                finalColor.w = 1.0;              
	                c.rgb += finalColor;
				#endif



                return c;
            }
 
            ENDCG
        }
    }
}
