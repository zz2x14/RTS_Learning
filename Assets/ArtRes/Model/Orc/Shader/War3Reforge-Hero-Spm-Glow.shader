// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "E3D/War3R-Hero/Actor-CST-N-Spm-Glow"
{
	Properties
	{
		_Cutoff( "Mask Clip Value", Float ) = 0.5
		_MainTex("MainTex", 2D) = "white" {}
		[HDR]_MainColor("MainColor", Color) = (1,1,1,1)
		_ReColor("ReColor", Color) = (1,1,1,1)
		_ASmoothInstensity("A-Smooth-Instensity", Range( 0 , 1)) = 0.5
		_BSmoothInstensity("B-Smooth-Instensity", Range( 0 , 1)) = 0.5
		_SmoothOffset("Smooth-Offset", Range( 0 , 1)) = 0.5
		_BumpsMap("BumpMap", 2D) = "bump" {}
		[Toggle(_ONLYNORMAL_ON)] _OnlyNormal("OnlyNormal", Float) = 0
		[Toggle(_NONENORMAL_ON)] _NoneNormal("NoneNormal", Float) = 0
		_SpecularMap("SpecularMap", 2D) = "white" {}
		_AMetallicInstensity("A-Metallic-Instensity", Range( 0 , 1)) = 1
		_BMetallicInstensity("B-Metallic-Instensity", Range( 0 , 1)) = 1
		_GlowMap("GlowMap", 2D) = "white" {}
		[HDR]_GlowColor("GlowColor", Color) = (1,1,1,0)
		_GlowIntensity("GlowIntensity", Range( 0.5 , 5)) = 1
		_GlowSpeed("Glow-Speed", Range( 0.1 , 2)) = 0.8
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "TransparentCutout"  "Queue" = "AlphaTest+0" "IsEmissive" = "true"  }
		Cull Back
		CGINCLUDE
		#include "UnityPBSLighting.cginc"
		#include "UnityShaderVariables.cginc"
		#include "Lighting.cginc"
		#pragma target 3.0
		#pragma shader_feature _ONLYNORMAL_ON
		#pragma shader_feature _NONENORMAL_ON
		#ifdef UNITY_PASS_SHADOWCASTER
			#undef INTERNAL_DATA
			#undef WorldReflectionVector
			#undef WorldNormalVector
			#define INTERNAL_DATA half3 internalSurfaceTtoW0; half3 internalSurfaceTtoW1; half3 internalSurfaceTtoW2;
			#define WorldReflectionVector(data,normal) reflect (data.worldRefl, half3(dot(data.internalSurfaceTtoW0,normal), dot(data.internalSurfaceTtoW1,normal), dot(data.internalSurfaceTtoW2,normal)))
			#define WorldNormalVector(data,normal) half3(dot(data.internalSurfaceTtoW0,normal), dot(data.internalSurfaceTtoW1,normal), dot(data.internalSurfaceTtoW2,normal))
		#endif
		struct Input
		{
			float2 uv_texcoord;
			float3 worldNormal;
			INTERNAL_DATA
		};

		struct SurfaceOutputCustomLightingCustom
		{
			half3 Albedo;
			half3 Normal;
			half3 Emission;
			half Metallic;
			half Smoothness;
			half Occlusion;
			half Alpha;
			Input SurfInput;
			UnityGIInput GIData;
		};

		uniform float4 _GlowColor;
		uniform sampler2D _GlowMap;
		uniform float4 _GlowMap_ST;
		uniform float _GlowIntensity;
		uniform float _GlowSpeed;
		uniform sampler2D _MainTex;
		uniform float4 _MainTex_ST;
		uniform float4 _MainColor;
		uniform float4 _ReColor;
		uniform sampler2D _SpecularMap;
		uniform float4 _SpecularMap_ST;
		uniform sampler2D _BumpsMap;
		uniform float4 _BumpsMap_ST;
		uniform float _AMetallicInstensity;
		uniform float _BMetallicInstensity;
		uniform float _SmoothOffset;
		uniform float _ASmoothInstensity;
		uniform float _BSmoothInstensity;
		uniform float _Cutoff = 0.5;

		inline half4 LightingStandardCustomLighting( inout SurfaceOutputCustomLightingCustom s, half3 viewDir, UnityGI gi )
		{
			UnityGIInput data = s.GIData;
			Input i = s.SurfInput;
			half4 c = 0;
			float2 uv_MainTex = i.uv_texcoord * _MainTex_ST.xy + _MainTex_ST.zw;
			float4 tex2DNode1 = tex2D( _MainTex, uv_MainTex );
			float Alpha168 = tex2DNode1.a;
			SurfaceOutputStandard s2 = (SurfaceOutputStandard ) 0;
			float2 uv_SpecularMap = i.uv_texcoord * _SpecularMap_ST.xy + _SpecularMap_ST.zw;
			float4 tex2DNode71 = tex2D( _SpecularMap, uv_SpecularMap );
			float ReColorMask189 = tex2DNode71.a;
			float4 lerpResult197 = lerp( ( _MainColor * tex2DNode1 ) , ( tex2DNode1 * _ReColor ) , ReColorMask189);
			float4 color41 = IsGammaSpace() ? float4(0.5073529,0.5073529,0.5073529,0) : float4(0.2209101,0.2209101,0.2209101,0);
			#ifdef _ONLYNORMAL_ON
				float4 staticSwitch40 = color41;
			#else
				float4 staticSwitch40 = lerpResult197;
			#endif
			float4 Albedo173 = staticSwitch40;
			s2.Albedo = Albedo173.rgb;
			float2 uv_BumpsMap = i.uv_texcoord * _BumpsMap_ST.xy + _BumpsMap_ST.zw;
			float3 tex2DNode6 = UnpackNormal( tex2D( _BumpsMap, uv_BumpsMap ) );
			float3 appendResult222 = (float3(tex2DNode6.r , tex2DNode6.g , tex2DNode6.b));
			float4 color44 = IsGammaSpace() ? float4(0,0,1,0) : float4(0,0,1,0);
			#ifdef _NONENORMAL_ON
				float4 staticSwitch43 = color44;
			#else
				float4 staticSwitch43 = float4( appendResult222 , 0.0 );
			#endif
			float4 Normal175 = staticSwitch43;
			s2.Normal = WorldNormalVector( i , Normal175.rgb );
			s2.Emission = float3( 0,0,0 );
			float lerpResult202 = lerp( ( _AMetallicInstensity * tex2DNode71.b ) , ( _BMetallicInstensity * tex2DNode71.b ) , ReColorMask189);
			float Matel177 = saturate( lerpResult202 );
			s2.Metallic = Matel177;
			float lerpResult188 = lerp( ( ( ( ( 1.0 - tex2DNode71.g ) + _SmoothOffset ) + 0.0 ) * _ASmoothInstensity ) , ( ( ReColorMask189 * ( ( ( 1.0 - tex2DNode71.g ) + _SmoothOffset ) + tex2DNode71.r ) ) * _BSmoothInstensity ) , ReColorMask189);
			float Smooth181 = saturate( lerpResult188 );
			s2.Smoothness = Smooth181;
			float AO215 = tex2DNode71.r;
			s2.Occlusion = AO215;

			data.light = gi.light;

			UnityGI gi2 = gi;
			#ifdef UNITY_PASS_FORWARDBASE
			Unity_GlossyEnvironmentData g2 = UnityGlossyEnvironmentSetup( s2.Smoothness, data.worldViewDir, s2.Normal, float3(0,0,0));
			gi2 = UnityGlobalIllumination( data, s2.Occlusion, s2.Normal, g2 );
			#endif

			float3 surfResult2 = LightingStandard ( s2, viewDir, gi2 ).rgb;
			surfResult2 += s2.Emission;

			#ifdef UNITY_PASS_FORWARDADD//2
			surfResult2 -= s2.Emission;
			#endif//2
			float4 color206 = IsGammaSpace() ? float4(1.5,1.5,1.5,0) : float4(2.440062,2.440062,2.440062,0);
			float3 clampResult205 = clamp( surfResult2 , float3( 0,0,0 ) , color206.rgb );
			c.rgb = clampResult205;
			c.a = 1;
			clip( Alpha168 - _Cutoff );
			return c;
		}

		inline void LightingStandardCustomLighting_GI( inout SurfaceOutputCustomLightingCustom s, UnityGIInput data, inout UnityGI gi )
		{
			s.GIData = data;
		}

		void surf( Input i , inout SurfaceOutputCustomLightingCustom o )
		{
			o.SurfInput = i;
			o.Normal = float3(0,0,1);
			float2 uv_GlowMap = i.uv_texcoord * _GlowMap_ST.xy + _GlowMap_ST.zw;
			float mulTime226 = _Time.y * _GlowSpeed;
			float4 Glow210 = ( _GlowColor * tex2D( _GlowMap, uv_GlowMap ) * _GlowIntensity * (1.4 + (sin( ( ( 2.0 * UNITY_PI ) * mulTime226 ) ) - 0.0) * (1.9 - 1.4) / (1.0 - 0.0)) );
			o.Emission = Glow210.rgb;
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf StandardCustomLighting keepalpha fullforwardshadows 

		ENDCG
		Pass
		{
			Name "ShadowCaster"
			Tags{ "LightMode" = "ShadowCaster" }
			ZWrite On
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 3.0
			#pragma multi_compile_shadowcaster
			#pragma multi_compile UNITY_PASS_SHADOWCASTER
			#pragma skip_variants FOG_LINEAR FOG_EXP FOG_EXP2
			#include "HLSLSupport.cginc"
			#if ( SHADER_API_D3D11 || SHADER_API_GLCORE || SHADER_API_GLES3 || SHADER_API_METAL || SHADER_API_VULKAN )
				#define CAN_SKIP_VPOS
			#endif
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "UnityPBSLighting.cginc"
			struct v2f
			{
				V2F_SHADOW_CASTER;
				float2 customPack1 : TEXCOORD1;
				float4 tSpace0 : TEXCOORD2;
				float4 tSpace1 : TEXCOORD3;
				float4 tSpace2 : TEXCOORD4;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};
			v2f vert( appdata_full v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID( v );
				UNITY_INITIALIZE_OUTPUT( v2f, o );
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO( o );
				UNITY_TRANSFER_INSTANCE_ID( v, o );
				Input customInputData;
				float3 worldPos = mul( unity_ObjectToWorld, v.vertex ).xyz;
				half3 worldNormal = UnityObjectToWorldNormal( v.normal );
				half3 worldTangent = UnityObjectToWorldDir( v.tangent.xyz );
				half tangentSign = v.tangent.w * unity_WorldTransformParams.w;
				half3 worldBinormal = cross( worldNormal, worldTangent ) * tangentSign;
				o.tSpace0 = float4( worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x );
				o.tSpace1 = float4( worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y );
				o.tSpace2 = float4( worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z );
				o.customPack1.xy = customInputData.uv_texcoord;
				o.customPack1.xy = v.texcoord;
				TRANSFER_SHADOW_CASTER_NORMALOFFSET( o )
				return o;
			}
			half4 frag( v2f IN
			#if !defined( CAN_SKIP_VPOS )
			, UNITY_VPOS_TYPE vpos : VPOS
			#endif
			) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID( IN );
				Input surfIN;
				UNITY_INITIALIZE_OUTPUT( Input, surfIN );
				surfIN.uv_texcoord = IN.customPack1.xy;
				float3 worldPos = float3( IN.tSpace0.w, IN.tSpace1.w, IN.tSpace2.w );
				half3 worldViewDir = normalize( UnityWorldSpaceViewDir( worldPos ) );
				surfIN.worldNormal = float3( IN.tSpace0.z, IN.tSpace1.z, IN.tSpace2.z );
				surfIN.internalSurfaceTtoW0 = IN.tSpace0.xyz;
				surfIN.internalSurfaceTtoW1 = IN.tSpace1.xyz;
				surfIN.internalSurfaceTtoW2 = IN.tSpace2.xyz;
				SurfaceOutputCustomLightingCustom o;
				UNITY_INITIALIZE_OUTPUT( SurfaceOutputCustomLightingCustom, o )
				surf( surfIN, o );
				UnityGI gi;
				UNITY_INITIALIZE_OUTPUT( UnityGI, gi );
				o.Alpha = LightingStandardCustomLighting( o, worldViewDir, gi ).a;
				#if defined( CAN_SKIP_VPOS )
				float2 vpos = IN.pos;
				#endif
				SHADOW_CASTER_FRAGMENT( IN )
			}
			ENDCG
		}
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=17101
371;336;1304;605;-1973.533;-1726.27;1.3;True;True
Node;AmplifyShaderEditor.CommentaryNode;141;1242.784,-31.69993;Inherit;False;2547.941;755.7902;Specular;19;181;166;188;187;158;190;186;156;163;185;183;189;184;71;207;208;213;215;217;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SamplerNode;71;1260.905,81.8771;Inherit;True;Property;_SpecularMap;SpecularMap;10;0;Create;True;0;0;False;0;None;623054268a718a1498dcacb6ed8040ed;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.OneMinusNode;217;1695.299,245.5153;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;208;1497.37,428.3572;Inherit;False;Property;_SmoothOffset;Smooth-Offset;6;0;Create;True;0;0;False;0;0.5;0.76;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;207;1835.672,342.0667;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RelayNode;184;2004.151,341.8246;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;198;1839.427,-1346.941;Inherit;False;1967.032;739.1594;Comment;11;173;41;40;194;195;196;1;168;197;171;23;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;189;2165.234,112.9635;Inherit;False;ReColorMask;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;183;2175.671,192.866;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;220;2313.624,-559.8542;Inherit;False;1477.828;508.3019;Metall;8;199;77;204;78;218;202;203;177;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;137;2413.063,1383.607;Inherit;False;1851.674;1118.557;Glow;11;234;226;229;233;224;230;210;73;209;72;223;;1,1,1,1;0;0
Node;AmplifyShaderEditor.ColorNode;196;1922.909,-868.941;Float;False;Property;_ReColor;ReColor;3;0;Create;True;0;0;False;0;1,1,1,1;1,1,1,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;185;2448.453,138.3703;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;204;2369.545,-505.327;Float;False;Property;_AMetallicInstensity;A-Metallic-Instensity;11;0;Create;True;0;0;False;0;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;234;2506.592,2153.302;Inherit;False;Property;_GlowSpeed;Glow-Speed;16;0;Create;True;0;0;False;0;0.8;0.8;0.1;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;163;2173.336,426.4874;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;186;2412.41,349.7436;Inherit;False;Property;_BSmoothInstensity;B-Smooth-Instensity;5;0;Create;True;0;0;False;0;0.5;0.304;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;23;1960.599,-1226.772;Float;False;Property;_MainColor;MainColor;2;1;[HDR];Create;True;0;0;False;0;1,1,1,1;1,1,1,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;191;2631.7,734.8965;Inherit;False;1357.922;603.4506;Normal;5;6;175;43;44;222;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SamplerNode;1;1876.427,-1058.538;Inherit;True;Property;_MainTex;MainTex;1;0;Create;True;0;0;False;0;None;f9e80e2f75738b04fbb6f5cf75cbd9cf;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;156;2408.706,528.0613;Inherit;False;Property;_ASmoothInstensity;A-Smooth-Instensity;4;0;Create;True;0;0;False;0;0.5;0.56;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;77;2363.624,-373.6716;Float;False;Property;_BMetallicInstensity;B-Metallic-Instensity;12;0;Create;True;0;0;False;0;1;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RelayNode;199;2443.25,-281.665;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;195;2267.632,-1058.705;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;194;2655.738,-986.1346;Inherit;True;189;ReColorMask;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;6;2716.552,969.4436;Inherit;True;Property;_BumpsMap;BumpMap;7;0;Create;False;0;0;False;0;None;3c18ac67121637d469fd33126e83cb28;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;171;2266.942,-1222.062;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;218;2725.974,-509.8542;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;78;2728.285,-304.5522;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;158;2746.89,423.4925;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;190;2747.044,8.263485;Inherit;False;189;ReColorMask;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;187;2748.832,139.4174;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;226;2857.214,2160.262;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.PiNode;229;2859.709,2048.013;Inherit;False;1;0;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;188;3088.14,267.9699;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;197;2965.857,-1152.843;Inherit;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;44;3210.764,785.9982;Float;False;Constant;_Color1;Color 1;6;0;Create;True;0;0;False;0;0,0,1,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;230;3058.391,2098.732;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;222;3062.033,999.859;Inherit;True;FLOAT3;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ColorNode;41;2963.381,-919.2047;Float;False;Constant;_Color0;Color 0;3;0;Create;True;0;0;False;0;0.5073529,0.5073529,0.5073529,0;0.4191176,0.4191176,0.4191176,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;202;3099.785,-465.6464;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;166;3339.306,268.2221;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SinOpNode;224;3222.214,2096.263;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;43;3465.984,854.5419;Float;False;Property;_NoneNormal;NoneNormal;9;0;Create;True;0;0;False;0;0;0;0;True;;Toggle;2;Key0;Key1;Create;False;9;1;COLOR;0,0,0,0;False;0;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;4;COLOR;0,0,0,0;False;5;COLOR;0,0,0,0;False;6;COLOR;0,0,0,0;False;7;COLOR;0,0,0,0;False;8;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.StaticSwitch;40;3259.431,-1049.067;Float;False;Property;_OnlyNormal;OnlyNormal;8;0;Create;True;0;0;False;0;0;0;0;True;;Toggle;2;Key0;Key1;Create;False;9;1;COLOR;0,0,0,0;False;0;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;4;COLOR;0,0,0,0;False;5;COLOR;0,0,0,0;False;6;COLOR;0,0,0,0;False;7;COLOR;0,0,0,0;False;8;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;203;3339.76,-464.4753;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;209;3233.767,1518.701;Inherit;False;Property;_GlowColor;GlowColor;14;1;[HDR];Create;True;0;0;False;0;1,1,1,0;1.507,1.507,1.507,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;215;1678.335,2.82329;Inherit;False;AO;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;181;3551.532,264.9425;Inherit;False;Smooth;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;72;3232.886,1736.283;Inherit;True;Property;_GlowMap;GlowMap;13;0;Create;True;0;0;False;0;None;55f939fc85e1c8a41b66f798dd42aab5;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;173;3517.306,-1049.871;Inherit;False;Albedo;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.TFHCRemapNode;233;3470.484,2096.856;Inherit;True;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;1.4;False;4;FLOAT;1.9;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;219;4095.973,-247.6125;Inherit;False;1218.238;740.8817;PBR-Combine;13;216;174;176;182;178;206;2;205;211;214;201;169;61;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;177;3548.452,-467.6639;Inherit;False;Matel;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;223;3226.581,1929.47;Inherit;False;Property;_GlowIntensity;GlowIntensity;15;0;Create;True;0;0;False;0;1;1;0.5;5;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;175;3743.164,869.9642;Inherit;False;Normal;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;216;4160.349,378.2691;Inherit;False;215;AO;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;182;4145.973,292.3601;Inherit;False;181;Smooth;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;178;4149.372,149.9805;Inherit;False;177;Matel;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;73;3807.611,1590.895;Inherit;True;4;4;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;176;4152.069,76.09892;Inherit;False;175;Normal;1;0;OBJECT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;174;4154.703,5.729163;Inherit;False;173;Albedo;1;0;OBJECT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;168;2266.606,-898.3544;Inherit;False;Alpha;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;210;4037.267,1579.068;Inherit;False;Glow;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.CustomStandardSurface;2;4388.052,84.69734;Inherit;False;Metallic;Tangent;6;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,1;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ColorNode;206;4398.88,273.3026;Inherit;False;Constant;_Color2;Color 2;14;1;[HDR];Create;True;0;0;False;0;1.5,1.5,1.5,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;201;4150.266,215.0679;Inherit;False;Constant;_Float0;Float 0;13;0;Create;True;0;0;False;0;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;211;4813.488,-156.2115;Inherit;False;210;Glow;1;0;OBJECT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;213;1928.968,61.06805;Inherit;False;Final;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;205;4812.88,82.30263;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;1,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;169;4816.842,-22.54662;Inherit;False;168;Alpha;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;214;4835.844,238.771;Inherit;False;213;Final;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;61;5051.211,-197.6125;Float;False;True;2;ASEMaterialInspector;0;0;CustomLighting;E3D/War3R-Hero/Actor-CST-N-Spm-Glow;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Masked;0.5;True;True;0;False;TransparentCutout;;AlphaTest;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;0;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;217;0;71;2
WireConnection;207;0;217;0
WireConnection;207;1;208;0
WireConnection;184;0;207;0
WireConnection;189;0;71;4
WireConnection;183;0;184;0
WireConnection;183;1;71;1
WireConnection;185;0;189;0
WireConnection;185;1;183;0
WireConnection;163;0;184;0
WireConnection;199;0;71;3
WireConnection;195;0;1;0
WireConnection;195;1;196;0
WireConnection;171;0;23;0
WireConnection;171;1;1;0
WireConnection;218;0;204;0
WireConnection;218;1;199;0
WireConnection;78;0;77;0
WireConnection;78;1;199;0
WireConnection;158;0;163;0
WireConnection;158;1;156;0
WireConnection;187;0;185;0
WireConnection;187;1;186;0
WireConnection;226;0;234;0
WireConnection;188;0;158;0
WireConnection;188;1;187;0
WireConnection;188;2;190;0
WireConnection;197;0;171;0
WireConnection;197;1;195;0
WireConnection;197;2;194;0
WireConnection;230;0;229;0
WireConnection;230;1;226;0
WireConnection;222;0;6;1
WireConnection;222;1;6;2
WireConnection;222;2;6;3
WireConnection;202;0;218;0
WireConnection;202;1;78;0
WireConnection;202;2;190;0
WireConnection;166;0;188;0
WireConnection;224;0;230;0
WireConnection;43;1;222;0
WireConnection;43;0;44;0
WireConnection;40;1;197;0
WireConnection;40;0;41;0
WireConnection;203;0;202;0
WireConnection;215;0;71;1
WireConnection;181;0;166;0
WireConnection;173;0;40;0
WireConnection;233;0;224;0
WireConnection;177;0;203;0
WireConnection;175;0;43;0
WireConnection;73;0;209;0
WireConnection;73;1;72;0
WireConnection;73;2;223;0
WireConnection;73;3;233;0
WireConnection;168;0;1;4
WireConnection;210;0;73;0
WireConnection;2;0;174;0
WireConnection;2;1;176;0
WireConnection;2;3;178;0
WireConnection;2;4;182;0
WireConnection;2;5;216;0
WireConnection;213;0;71;3
WireConnection;205;0;2;0
WireConnection;205;2;206;0
WireConnection;61;2;211;0
WireConnection;61;10;169;0
WireConnection;61;13;205;0
ASEEND*/
//CHKSM=C317012B51B52CA25B7F8ED7559917CDF28C1434