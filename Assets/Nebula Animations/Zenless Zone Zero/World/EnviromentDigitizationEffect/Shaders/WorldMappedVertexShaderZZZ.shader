// Made with Amplify Shader Editor v1.9.5.1
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Nebula Animations/ZZZ/WorldMappedVertexShaderZZZ"
{
	Properties
	{
		_Cutoff( "Mask Clip Value", Float ) = 0.5
		[HDR]_Color0("Color 0", Color) = (0.6981132,0.6981132,0.6981132,0)
		[HDR]_Color1("Color 1", Color) = (0.6981132,0.6981132,0.6981132,0)
		[HDR]_Color2("Color 2", Color) = (0.6981132,0.6981132,0.6981132,0)
		[HDR][NoScaleOffset][SingleLineTexture]_NoiseTex("NoiseTex", 2D) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Transparent"  "Queue" = "Transparent+0" }
		Cull Off
		CGPROGRAM
		#pragma target 3.0
		#pragma surface outlineSurf Outline nofog alpha:premul  keepalpha noshadow noambient novertexlights nolightmap nodynlightmap nodirlightmap nometa noforwardadd vertex:outlineVertexDataFunc 
		
		#include "UnityShaderVariables.cginc"
		
		
		
		struct Input
		{
			float3 worldPos;
			float3 worldNormal;
			INTERNAL_DATA
		};
		uniform float4 _Color0;
		uniform sampler2D _NoiseTex;
		uniform float4 _Color1;
		uniform float4 _Color2;
		
inline float4 TriplanarSampling43( sampler2D topTexMap, float3 worldPos, float3 worldNormal, float falloff, float2 tiling, float3 normalScale, float3 index )
{
	float3 projNormal = ( pow( abs( worldNormal ), falloff ) );
	projNormal /= ( projNormal.x + projNormal.y + projNormal.z ) + 0.00001;
	float3 nsign = sign( worldNormal );
	half4 xNorm; half4 yNorm; half4 zNorm;
	xNorm = tex2D( topTexMap, tiling * worldPos.zy * float2(  nsign.x, 1.0 ) );
	yNorm = tex2D( topTexMap, tiling * worldPos.xz * float2(  nsign.y, 1.0 ) );
	zNorm = tex2D( topTexMap, tiling * worldPos.xy * float2( -nsign.z, 1.0 ) );
	return xNorm * projNormal.x + yNorm * projNormal.y + zNorm * projNormal.z;
}


inline float4 TriplanarSampling45( sampler2D topTexMap, float3 worldPos, float3 worldNormal, float falloff, float2 tiling, float3 normalScale, float3 index )
{
	float3 projNormal = ( pow( abs( worldNormal ), falloff ) );
	projNormal /= ( projNormal.x + projNormal.y + projNormal.z ) + 0.00001;
	float3 nsign = sign( worldNormal );
	half4 xNorm; half4 yNorm; half4 zNorm;
	xNorm = tex2D( topTexMap, tiling * worldPos.zy * float2(  nsign.x, 1.0 ) );
	yNorm = tex2D( topTexMap, tiling * worldPos.xz * float2(  nsign.y, 1.0 ) );
	zNorm = tex2D( topTexMap, tiling * worldPos.xy * float2( -nsign.z, 1.0 ) );
	return xNorm * projNormal.x + yNorm * projNormal.y + zNorm * projNormal.z;
}


inline float4 TriplanarSampling46( sampler2D topTexMap, float3 worldPos, float3 worldNormal, float falloff, float2 tiling, float3 normalScale, float3 index )
{
	float3 projNormal = ( pow( abs( worldNormal ), falloff ) );
	projNormal /= ( projNormal.x + projNormal.y + projNormal.z ) + 0.00001;
	float3 nsign = sign( worldNormal );
	half4 xNorm; half4 yNorm; half4 zNorm;
	xNorm = tex2D( topTexMap, tiling * worldPos.zy * float2(  nsign.x, 1.0 ) );
	yNorm = tex2D( topTexMap, tiling * worldPos.xz * float2(  nsign.y, 1.0 ) );
	zNorm = tex2D( topTexMap, tiling * worldPos.xy * float2( -nsign.z, 1.0 ) );
	return xNorm * projNormal.x + yNorm * projNormal.y + zNorm * projNormal.z;
}


float2 voronoihash24( float2 p )
{
	
	p = float2( dot( p, float2( 127.1, 311.7 ) ), dot( p, float2( 269.5, 183.3 ) ) );
	return frac( sin( p ) *43758.5453);
}


float voronoi24( float2 v, float time, inout float2 id, inout float2 mr, float smoothness, inout float2 smoothId )
{
	float2 n = floor( v );
	float2 f = frac( v );
	float F1 = 8.0;
	float F2 = 8.0; float2 mg = 0;
	for ( int j = -2; j <= 2; j++ )
	{
		for ( int i = -2; i <= 2; i++ )
	 	{
	 		float2 g = float2( i, j );
	 		float2 o = voronoihash24( n + g );
			o = ( sin( time + o * 6.2831 ) * 0.5 + 0.5 ); float2 r = f - g - o;
			float d = 0.5 * dot( r, r );
	 //		if( d<F1 ) {
	 //			F2 = F1;
	 			float h = smoothstep(0.0, 1.0, 0.5 + 0.5 * (F1 - d) / smoothness); F1 = lerp(F1, d, h) - smoothness * h * (1.0 - h);mg = g; mr = r; id = o;
	 //		} else if( d<F2 ) {
	 //			F2 = d;
	
	 //		}
	 	}
	}
	return F1;
}


		void outlineVertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			float3 ase_vertex3Pos = v.vertex.xyz;
			float3 break173 = ase_vertex3Pos;
			float mulTime130 = _Time.y * 0.5;
			float time24 = mulTime130;
			float2 voronoiSmoothId24 = 0;
			float voronoiSmooth24 = 0.15;
			float3 ase_worldPos = mul( unity_ObjectToWorld, v.vertex );
			float2 appendResult2 = (float2(ase_worldPos.x , ase_worldPos.z));
			float2 panner5 = ( 2.0 * _Time.y * float2( 1.5,1.5 ) + ( appendResult2 * 2.5 ));
			float2 coords24 = panner5 * 0.1;
			float2 id24 = 0;
			float2 uv24 = 0;
			float voroi24 = voronoi24( coords24, time24, id24, uv24, voronoiSmooth24, voronoiSmoothId24 );
			float saferPower26 = abs( voroi24 );
			float temp_output_26_0 = pow( saferPower26 , 1.5 );
			float temp_output_27_0 = saturate( temp_output_26_0 );
			float temp_output_140_0 = ( temp_output_27_0 * 0.1 );
			float3 appendResult11 = (float3(( break173.x * temp_output_140_0 ) , saturate( ( break173.y * ( temp_output_27_0 * 0.25 ) ) ) , ( break173.z * temp_output_140_0 )));
			float3 outlineVar = appendResult11;
			v.vertex.xyz += outlineVar;
		}
		inline half4 LightingOutline( SurfaceOutput s, half3 lightDir, half atten ) { return half4 ( 0,0,0, s.Alpha); }
		void outlineSurf( Input i, inout SurfaceOutput o )
		{
			float3 ase_worldPos = i.worldPos;
			float3 ase_worldNormal = WorldNormalVector( i, float3( 0, 0, 1 ) );
			float mulTime152 = _Time.y * 0.2;
			float3 temp_output_154_0 = ( ase_worldPos * 1.0 );
			float2 panner87 = ( mulTime152 * float2( -0.7,0.5 ) + temp_output_154_0.xy);
			float temp_output_155_0 = ( ase_worldPos.z * 1.0 );
			float2 temp_cast_1 = (temp_output_155_0).xx;
			float2 panner104 = ( mulTime152 * float2( 0.7,1 ) + temp_cast_1);
			float3 appendResult106 = (float3(panner87 , panner104.x));
			float4 triplanar43 = TriplanarSampling43( _NoiseTex, ( appendResult106 * 0.1 ), ase_worldNormal, 1.0, float2( 1,1 ), 1.0, 0 );
			float2 panner112 = ( mulTime152 * float2( 1.2,1 ) + temp_output_154_0.xy);
			float2 temp_cast_3 = (temp_output_155_0).xx;
			float2 panner111 = ( mulTime152 * float2( 0.8,0 ) + temp_cast_3);
			float3 appendResult110 = (float3(panner112 , panner111.x));
			float4 triplanar45 = TriplanarSampling45( _NoiseTex, ( appendResult110 * 0.15 ), ase_worldNormal, 1.0, float2( 1,1 ), 1.0, 0 );
			float2 panner116 = ( mulTime152 * float2( 0.65,1 ) + temp_output_154_0.xy);
			float2 temp_cast_5 = (temp_output_155_0).xx;
			float2 panner117 = ( mulTime152 * float2( -1.2,1 ) + temp_cast_5);
			float3 appendResult114 = (float3(panner116 , panner117.x));
			float4 triplanar46 = TriplanarSampling46( _NoiseTex, ( appendResult114 * 0.12 ), ase_worldNormal, 1.0, float2( 1,1 ), 1.0, 0 );
			float3 saferPower167 = abs( ( ( _Color0.rgb * triplanar43.x ) + ( _Color1.rgb * triplanar45.x ) + ( _Color2.rgb * triplanar46.x ) ) );
			float mulTime130 = _Time.y * 0.5;
			float time24 = mulTime130;
			float2 voronoiSmoothId24 = 0;
			float voronoiSmooth24 = 0.15;
			float2 appendResult2 = (float2(ase_worldPos.x , ase_worldPos.z));
			float2 panner5 = ( 2.0 * _Time.y * float2( 1.5,1.5 ) + ( appendResult2 * 2.5 ));
			float2 coords24 = panner5 * 0.1;
			float2 id24 = 0;
			float2 uv24 = 0;
			float voroi24 = voronoi24( coords24, time24, id24, uv24, voronoiSmooth24, voronoiSmoothId24 );
			float saferPower26 = abs( voroi24 );
			float temp_output_26_0 = pow( saferPower26 , 1.5 );
			float saferPower13 = abs( ( saturate( temp_output_26_0 ) * 4.0 ) );
			float3 ase_worldViewDir = normalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			float3 ase_normWorldNormal = normalize( ase_worldNormal );
			float fresnelNdotV143 = dot( ase_normWorldNormal, ase_worldViewDir );
			float fresnelNode143 = ( 0.0 + 1.0 * pow( max( 1.0 - fresnelNdotV143 , 0.0001 ), 1.0 ) );
			float temp_output_146_0 = ( saturate( pow( saferPower13 , 5.0 ) ) * saturate( fresnelNode143 ) );
			o.Emission = saturate( ( pow( saferPower167 , 1.5 ) * temp_output_146_0 ) );
			o.Alpha = temp_output_146_0;
			o.Normal = float3(0,0,-1);
		}
		ENDCG
		

		Tags{ "RenderType" = "TransparentCutout"  "Queue" = "AlphaTest+0" "IgnoreProjector" = "True" }
		Cull Off
		CGPROGRAM
		#pragma target 4.6
		#pragma surface surf Unlit keepalpha noshadow vertex:vertexDataFunc 
		struct Input
		{
			half filler;
		};

		uniform float _Cutoff = 0.5;

		void vertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			v.vertex.xyz += 0;
			v.vertex.w = 1;
		}

		inline half4 LightingUnlit( SurfaceOutput s, half3 lightDir, half atten )
		{
			return half4 ( 0, 0, 0, s.Alpha );
		}

		void surf( Input i , inout SurfaceOutput o )
		{
			o.Alpha = 1;
			clip( 0.0 - _Cutoff );
		}

		ENDCG
	}
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=19501
Node;AmplifyShaderEditor.WorldPosInputsNode;138;-2608,800;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;151;-2976,-384;Inherit;False;Constant;_Float1;Float 1;5;0;Create;True;0;0;0;False;0;False;0.2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.WorldPosInputsNode;47;-3120,-112;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.DynamicAppendNode;2;-2400,848;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;135;-2352,976;Inherit;False;Constant;_Float2;Float 2;5;0;Create;True;0;0;0;False;0;False;2.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;168;-3031.954,240.2;Inherit;False;Constant;_Float0;Float 0;5;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;152;-2816,-384;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;155;-2891.545,-16.24951;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;134;-2128,848;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PannerNode;104;-2528,-304;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0.7,1;False;1;FLOAT;0.5;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PannerNode;111;-2544,-16;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0.8,0;False;1;FLOAT;0.15;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PannerNode;117;-2544,272;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;-1.2,1;False;1;FLOAT;0.5;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;154;-2896,-128;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;25;-1904,1056;Inherit;False;Constant;_Float3;Float 3;3;0;Create;True;0;0;0;False;0;False;0.15;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.PannerNode;5;-1936,848;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;1.5,1.5;False;1;FLOAT;2;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleTimeNode;130;-1936,976;Inherit;False;1;0;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.BreakToComponentsNode;105;-2352,-304;Inherit;False;FLOAT2;1;0;FLOAT2;0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.BreakToComponentsNode;113;-2368,-16;Inherit;False;FLOAT2;1;0;FLOAT2;0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.BreakToComponentsNode;115;-2368,272;Inherit;False;FLOAT2;1;0;FLOAT2;0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.PannerNode;112;-2544,-144;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;1.2,1;False;1;FLOAT;0.5;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PannerNode;87;-2528,-432;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;-0.7,0.5;False;1;FLOAT;0.2;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PannerNode;116;-2544,144;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0.65,1;False;1;FLOAT;0.15;False;1;FLOAT2;0
Node;AmplifyShaderEditor.VoronoiNode;24;-1696,848;Inherit;True;1;0;1;0;1;False;1;False;True;False;4;0;FLOAT2;0,0;False;1;FLOAT;0;False;2;FLOAT;0.1;False;3;FLOAT;0;False;3;FLOAT;0;FLOAT2;1;FLOAT2;2
Node;AmplifyShaderEditor.DynamicAppendNode;106;-2192,-384;Inherit;False;FLOAT3;4;0;FLOAT2;0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DynamicAppendNode;110;-2208,-96;Inherit;False;FLOAT3;4;0;FLOAT2;0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DynamicAppendNode;114;-2208,192;Inherit;False;FLOAT3;4;0;FLOAT2;0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;120;-2192,-256;Inherit;False;Constant;_Float4;Float 4;5;0;Create;True;0;0;0;False;0;False;0.1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;123;-2192,16;Inherit;False;Constant;_Float5;Float 4;5;0;Create;True;0;0;0;False;0;False;0.15;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;124;-2192,320;Inherit;False;Constant;_Float6;Float 4;5;0;Create;True;0;0;0;False;0;False;0.12;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;26;-1360,848;Inherit;True;True;2;0;FLOAT;0;False;1;FLOAT;1.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;119;-1952,-384;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;121;-1968,-80;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;122;-1952,224;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SaturateNode;139;-1040,848;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TexturePropertyNode;44;-1888,-752;Inherit;True;Property;_NoiseTex;NoiseTex;4;3;[HDR];[NoScaleOffset];[SingleLineTexture];Create;True;0;0;0;False;0;False;None;d784f59ee712e19439a06c5dc1bec580;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.TriplanarNode;43;-1584,-736;Inherit;True;Spherical;World;False;Top Texture 0;_TopTexture0;white;-1;None;Mid Texture 0;_MidTexture0;white;-1;None;Bot Texture 0;_BotTexture0;white;-1;None;Triplanar Sampler;Tangent;10;0;SAMPLER2D;;False;5;FLOAT;1;False;1;SAMPLER2D;;False;6;FLOAT;0;False;2;SAMPLER2D;;False;7;FLOAT;0;False;9;FLOAT3;0,0,0;False;8;FLOAT;1;False;3;FLOAT2;1,1;False;4;FLOAT;1;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TriplanarNode;45;-1600,-208;Inherit;True;Spherical;World;False;Top Texture 1;_TopTexture1;white;-1;None;Mid Texture 1;_MidTexture1;white;-1;None;Bot Texture 1;_BotTexture1;white;-1;None;Triplanar Sampler;Tangent;10;0;SAMPLER2D;;False;5;FLOAT;1;False;1;SAMPLER2D;;False;6;FLOAT;0;False;2;SAMPLER2D;;False;7;FLOAT;0;False;9;FLOAT3;0,0,0;False;8;FLOAT;1;False;3;FLOAT2;1,1;False;4;FLOAT;1;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TriplanarNode;46;-1568,240;Inherit;True;Spherical;World;False;Top Texture 2;_TopTexture2;white;-1;None;Mid Texture 2;_MidTexture2;white;-1;None;Bot Texture 2;_BotTexture2;white;-1;None;Triplanar Sampler;Tangent;10;0;SAMPLER2D;;False;5;FLOAT;1;False;1;SAMPLER2D;;False;6;FLOAT;0;False;2;SAMPLER2D;;False;7;FLOAT;0;False;9;FLOAT3;0,0,0;False;8;FLOAT;1;False;3;FLOAT2;1,1;False;4;FLOAT;1;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;15;-832,848;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;4;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;21;-1504,-944;Inherit;False;Property;_Color0;Color 0;1;1;[HDR];Create;True;0;0;0;False;0;False;0.6981132,0.6981132,0.6981132,0;2.996078,0.3278432,0.2996079,0;True;True;0;6;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT3;5
Node;AmplifyShaderEditor.ColorNode;37;-1472,-432;Inherit;False;Property;_Color1;Color 1;2;1;[HDR];Create;True;0;0;0;False;0;False;0.6981132,0.6981132,0.6981132,0;0.497255,2.996078,0.2996079,0;True;True;0;6;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT3;5
Node;AmplifyShaderEditor.ColorNode;40;-1456,16;Inherit;False;Property;_Color2;Color 2;3;1;[HDR];Create;True;0;0;0;False;0;False;0.6981132,0.6981132,0.6981132,0;0.4000001,0.4000001,4,0;True;True;0;6;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT3;5
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;31;-1200,-784;Inherit;True;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;42;-1168,64;Inherit;True;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;36;-1168,-304;Inherit;True;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.FresnelNode;143;-736,1136;Inherit;True;Standard;WorldNormal;ViewDir;True;True;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.PosVertexDataNode;177;-1104,336;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SaturateNode;27;-1024,720;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;13;-640,848;Inherit;True;True;2;0;FLOAT;0;False;1;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;32;-768,-240;Inherit;True;3;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SaturateNode;16;-384,848;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;144;-416,1136;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.BreakToComponentsNode;173;-704,336;Inherit;False;FLOAT3;1;0;FLOAT3;0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;148;-816,704;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.25;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;146;-192,848;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;167;-464,128;Inherit;False;True;2;0;FLOAT3;0,0,0;False;1;FLOAT;1.5;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;10;-480,496;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;140;-816,576;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;23;-64,304;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SaturateNode;147;-320,496;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;127;-480,384;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;128;-480,592;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;125;96,304;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DynamicAppendNode;11;-144,496;Inherit;False;FLOAT3;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WorldPosInputsNode;171;-1104,480;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;172;-864,336;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ObjectScaleNode;153;-3120,48;Inherit;False;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;169;513.0452,172.3538;Inherit;False;Constant;_Float7;Float 7;5;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.OutlineNode;3;272,304;Inherit;False;2;True;AlphaPremultiplied;0;0;Off;True;True;True;True;0;False;;3;0;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;736,32;Float;False;True;-1;6;ASEMaterialInspector;0;0;Unlit;Nebula Animations/ZZZ/WorldMappedVertexShaderZZZ;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;False;False;False;False;Off;2;False;;1;False;;False;0;False;;0;False;;False;0;Masked;0.5;True;False;0;False;TransparentCutout;;AlphaTest;All;12;all;True;True;True;True;0;False;;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;0;1;2;5;False;0.5;False;0;1;False;;10;False;;0;0;False;;0;False;;0;False;;0;False;;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;True;Relative;0;;0;-1;-1;-1;0;False;0;0;False;;-1;0;False;;0;0;0;False;0.1;False;;0;False;;False;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;16;FLOAT4;0,0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;2;0;138;1
WireConnection;2;1;138;3
WireConnection;152;0;151;0
WireConnection;155;0;47;3
WireConnection;155;1;168;0
WireConnection;134;0;2;0
WireConnection;134;1;135;0
WireConnection;104;0;155;0
WireConnection;104;1;152;0
WireConnection;111;0;155;0
WireConnection;111;1;152;0
WireConnection;117;0;155;0
WireConnection;117;1;152;0
WireConnection;154;0;47;0
WireConnection;154;1;168;0
WireConnection;5;0;134;0
WireConnection;105;0;104;0
WireConnection;113;0;111;0
WireConnection;115;0;117;0
WireConnection;112;0;154;0
WireConnection;112;1;152;0
WireConnection;87;0;154;0
WireConnection;87;1;152;0
WireConnection;116;0;154;0
WireConnection;116;1;152;0
WireConnection;24;0;5;0
WireConnection;24;1;130;0
WireConnection;24;3;25;0
WireConnection;106;0;87;0
WireConnection;106;2;105;0
WireConnection;110;0;112;0
WireConnection;110;2;113;0
WireConnection;114;0;116;0
WireConnection;114;2;115;0
WireConnection;26;0;24;0
WireConnection;119;0;106;0
WireConnection;119;1;120;0
WireConnection;121;0;110;0
WireConnection;121;1;123;0
WireConnection;122;0;114;0
WireConnection;122;1;124;0
WireConnection;139;0;26;0
WireConnection;43;0;44;0
WireConnection;43;9;119;0
WireConnection;45;0;44;0
WireConnection;45;9;121;0
WireConnection;46;0;44;0
WireConnection;46;9;122;0
WireConnection;15;0;139;0
WireConnection;31;0;21;5
WireConnection;31;1;43;1
WireConnection;42;0;40;5
WireConnection;42;1;46;1
WireConnection;36;0;37;5
WireConnection;36;1;45;1
WireConnection;27;0;26;0
WireConnection;13;0;15;0
WireConnection;32;0;31;0
WireConnection;32;1;36;0
WireConnection;32;2;42;0
WireConnection;16;0;13;0
WireConnection;144;0;143;0
WireConnection;173;0;177;0
WireConnection;148;0;27;0
WireConnection;146;0;16;0
WireConnection;146;1;144;0
WireConnection;167;0;32;0
WireConnection;10;0;173;1
WireConnection;10;1;148;0
WireConnection;140;0;27;0
WireConnection;23;0;167;0
WireConnection;23;1;146;0
WireConnection;147;0;10;0
WireConnection;127;0;173;0
WireConnection;127;1;140;0
WireConnection;128;0;173;2
WireConnection;128;1;140;0
WireConnection;125;0;23;0
WireConnection;11;0;127;0
WireConnection;11;1;147;0
WireConnection;11;2;128;0
WireConnection;172;0;177;0
WireConnection;172;1;171;0
WireConnection;3;0;125;0
WireConnection;3;2;146;0
WireConnection;3;1;11;0
WireConnection;0;10;169;0
WireConnection;0;11;3;0
ASEEND*/
//CHKSM=F807D2EB0FC9A6E094F77FBE1A5E4BF59F30910E