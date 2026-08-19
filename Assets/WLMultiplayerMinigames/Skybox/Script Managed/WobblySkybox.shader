// Made with Amplify Shader Editor v1.9.8
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "lstwo/ScriptControlledWobblySkybox"
{
	Properties
	{
		[SingleLineTexture]_CloudTexture("CloudTexture", CUBE) = "white" {}
		[SingleLineTexture]_WobblySunandMoon("WobblySunandMoon", CUBE) = "white" {}
		_CloudBottomGradient("CloudBottomGradient", Range( 0 , 1)) = 0.533
		_CloudOpacity("CloudOpacity", Range( 0 , 1)) = 0.555
		_CloudRotationSpeed("CloudRotationSpeed", Range( 0 , 5)) = 0.01
		_Tint("Tint", Color) = (0,0,0,0)
		_Color0("Color 0", Color) = (0,0,0,0)
		_StarsVisibility("StarsVisibility", Float) = 0
		_FogFill("FogFill", Float) = 0
		_TimeOfDay("TimeOfDay", Float) = 0

	}
	
	SubShader
	{
		
		
		Tags { "RenderType"="Opaque" }
	LOD 100

		CGINCLUDE
		#pragma target 3.0
		ENDCG
		Blend Off
		AlphaToMask Off
		Cull Back
		ColorMask RGBA
		ZWrite Off
		ZTest LEqual
		Offset 0 , 0
		
		
		
		Pass
		{
			Name "Unlit"

			CGPROGRAM

			#define ASE_VERSION 19800


			#ifndef UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX
			//only defining to not throw compilation error over Unity 5.5
			#define UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input)
			#endif
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_instancing
			#include "UnityCG.cginc"
			#include "UnityShaderVariables.cginc"


			struct appdata
			{
				float4 vertex : POSITION;
				float4 color : COLOR;
				float4 ase_texcoord : TEXCOORD0;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};
			
			struct v2f
			{
				float4 vertex : SV_POSITION;
				#ifdef ASE_NEEDS_FRAG_WORLD_POSITION
				float3 worldPos : TEXCOORD0;
				#endif
				float4 ase_texcoord1 : TEXCOORD1;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			uniform float _StarsVisibility;
			uniform float4 _Tint;
			uniform samplerCUBE _WobblySunandMoon;
			uniform float _TimeOfDay;
			uniform samplerCUBE _CloudTexture;
			uniform float _CloudRotationSpeed;
			uniform float _CloudOpacity;
			uniform float4 _Color0;
			uniform float _CloudBottomGradient;
			uniform float _FogFill;
			float3 mod3D289( float3 x ) { return x - floor( x / 289.0 ) * 289.0; }
			float4 mod3D289( float4 x ) { return x - floor( x / 289.0 ) * 289.0; }
			float4 permute( float4 x ) { return mod3D289( ( x * 34.0 + 1.0 ) * x ); }
			float4 taylorInvSqrt( float4 r ) { return 1.79284291400159 - r * 0.85373472095314; }
			float snoise( float3 v )
			{
				const float2 C = float2( 1.0 / 6.0, 1.0 / 3.0 );
				float3 i = floor( v + dot( v, C.yyy ) );
				float3 x0 = v - i + dot( i, C.xxx );
				float3 g = step( x0.yzx, x0.xyz );
				float3 l = 1.0 - g;
				float3 i1 = min( g.xyz, l.zxy );
				float3 i2 = max( g.xyz, l.zxy );
				float3 x1 = x0 - i1 + C.xxx;
				float3 x2 = x0 - i2 + C.yyy;
				float3 x3 = x0 - 0.5;
				i = mod3D289( i);
				float4 p = permute( permute( permute( i.z + float4( 0.0, i1.z, i2.z, 1.0 ) ) + i.y + float4( 0.0, i1.y, i2.y, 1.0 ) ) + i.x + float4( 0.0, i1.x, i2.x, 1.0 ) );
				float4 j = p - 49.0 * floor( p / 49.0 );  // mod(p,7*7)
				float4 x_ = floor( j / 7.0 );
				float4 y_ = floor( j - 7.0 * x_ );  // mod(j,N)
				float4 x = ( x_ * 2.0 + 0.5 ) / 7.0 - 1.0;
				float4 y = ( y_ * 2.0 + 0.5 ) / 7.0 - 1.0;
				float4 h = 1.0 - abs( x ) - abs( y );
				float4 b0 = float4( x.xy, y.xy );
				float4 b1 = float4( x.zw, y.zw );
				float4 s0 = floor( b0 ) * 2.0 + 1.0;
				float4 s1 = floor( b1 ) * 2.0 + 1.0;
				float4 sh = -step( h, 0.0 );
				float4 a0 = b0.xzyw + s0.xzyw * sh.xxyy;
				float4 a1 = b1.xzyw + s1.xzyw * sh.zzww;
				float3 g0 = float3( a0.xy, h.x );
				float3 g1 = float3( a0.zw, h.y );
				float3 g2 = float3( a1.xy, h.z );
				float3 g3 = float3( a1.zw, h.w );
				float4 norm = taylorInvSqrt( float4( dot( g0, g0 ), dot( g1, g1 ), dot( g2, g2 ), dot( g3, g3 ) ) );
				g0 *= norm.x;
				g1 *= norm.y;
				g2 *= norm.z;
				g3 *= norm.w;
				float4 m = max( 0.6 - float4( dot( x0, x0 ), dot( x1, x1 ), dot( x2, x2 ), dot( x3, x3 ) ), 0.0 );
				m = m* m;
				m = m* m;
				float4 px = float4( dot( x0, g0 ), dot( x1, g1 ), dot( x2, g2 ), dot( x3, g3 ) );
				return 42.0 * dot( m, px);
			}
			
			float3 RotateAroundAxis( float3 center, float3 original, float3 u, float angle )
			{
				original -= center;
				float C = cos( angle );
				float S = sin( angle );
				float t = 1 - C;
				float m00 = t * u.x * u.x + C;
				float m01 = t * u.x * u.y - S * u.z;
				float m02 = t * u.x * u.z + S * u.y;
				float m10 = t * u.x * u.y + S * u.z;
				float m11 = t * u.y * u.y + C;
				float m12 = t * u.y * u.z - S * u.x;
				float m20 = t * u.x * u.z - S * u.y;
				float m21 = t * u.y * u.z + S * u.x;
				float m22 = t * u.z * u.z + C;
				float3x3 finalMatrix = float3x3( m00, m01, m02, m10, m11, m12, m20, m21, m22 );
				return mul( finalMatrix, original ) + center;
			}
			
			struct Gradient
			{
				int type;
				int colorsLength;
				int alphasLength;
				float4 colors[8];
				float2 alphas[8];
			};
			
			Gradient NewGradient(int type, int colorsLength, int alphasLength, 
			float4 colors0, float4 colors1, float4 colors2, float4 colors3, float4 colors4, float4 colors5, float4 colors6, float4 colors7,
			float2 alphas0, float2 alphas1, float2 alphas2, float2 alphas3, float2 alphas4, float2 alphas5, float2 alphas6, float2 alphas7)
			{
				Gradient g;
				g.type = type;
				g.colorsLength = colorsLength;
				g.alphasLength = alphasLength;
				g.colors[ 0 ] = colors0;
				g.colors[ 1 ] = colors1;
				g.colors[ 2 ] = colors2;
				g.colors[ 3 ] = colors3;
				g.colors[ 4 ] = colors4;
				g.colors[ 5 ] = colors5;
				g.colors[ 6 ] = colors6;
				g.colors[ 7 ] = colors7;
				g.alphas[ 0 ] = alphas0;
				g.alphas[ 1 ] = alphas1;
				g.alphas[ 2 ] = alphas2;
				g.alphas[ 3 ] = alphas3;
				g.alphas[ 4 ] = alphas4;
				g.alphas[ 5 ] = alphas5;
				g.alphas[ 6 ] = alphas6;
				g.alphas[ 7 ] = alphas7;
				return g;
			}
			
			float4 SampleGradient( Gradient gradient, float time )
			{
				float3 color = gradient.colors[0].rgb;
				UNITY_UNROLL
				for (int c = 1; c < 8; c++)
				{
				float colorPos = saturate((time - gradient.colors[c-1].w) / ( 0.00001 + (gradient.colors[c].w - gradient.colors[c-1].w)) * step(c, (float)gradient.colorsLength-1));
				color = lerp(color, gradient.colors[c].rgb, lerp(colorPos, step(0.01, colorPos), gradient.type));
				}
				#ifndef UNITY_COLORSPACE_GAMMA
				color = half3(GammaToLinearSpaceExact(color.r), GammaToLinearSpaceExact(color.g), GammaToLinearSpaceExact(color.b));
				#endif
				float alpha = gradient.alphas[0].x;
				UNITY_UNROLL
				for (int a = 1; a < 8; a++)
				{
				float alphaPos = saturate((time - gradient.alphas[a-1].y) / ( 0.00001 + (gradient.alphas[a].y - gradient.alphas[a-1].y)) * step(a, (float)gradient.alphasLength-1));
				alpha = lerp(alpha, gradient.alphas[a].x, lerp(alphaPos, step(0.01, alphaPos), gradient.type));
				}
				return float4(color, alpha);
			}
			

			
			v2f vert ( appdata v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
				UNITY_TRANSFER_INSTANCE_ID(v, o);

				o.ase_texcoord1.xyz = v.ase_texcoord.xyz;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord1.w = 0;
				float3 vertexValue = float3(0, 0, 0);
				#if ASE_ABSOLUTE_VERTEX_POS
				vertexValue = v.vertex.xyz;
				#endif
				vertexValue = vertexValue;
				#if ASE_ABSOLUTE_VERTEX_POS
				v.vertex.xyz = vertexValue;
				#else
				v.vertex.xyz += vertexValue;
				#endif
				o.vertex = UnityObjectToClipPos(v.vertex);

				#ifdef ASE_NEEDS_FRAG_WORLD_POSITION
				o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
				#endif
				return o;
			}
			
			fixed4 frag (v2f i ) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID(i);
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i);
				fixed4 finalColor;
				#ifdef ASE_NEEDS_FRAG_WORLD_POSITION
				float3 WorldPosition = i.worldPos;
				#endif
				float3 texCoord85 = i.ase_texcoord1.xyz;
				texCoord85.xy = i.ase_texcoord1.xyz.xy * float2( 1,1 ) + float2( 0,0 );
				float simplePerlin3D84 = snoise( texCoord85*40.0 );
				simplePerlin3D84 = simplePerlin3D84*0.5 + 0.5;
				float3 texCoord96 = i.ase_texcoord1.xyz;
				texCoord96.xy = i.ase_texcoord1.xyz.xy * float2( 1,1 ) + float2( 0,0 );
				float simplePerlin3D98 = snoise( texCoord96*55.0 );
				simplePerlin3D98 = simplePerlin3D98*0.5 + 0.5;
				float3 texCoord174 = i.ase_texcoord1.xyz;
				texCoord174.xy = i.ase_texcoord1.xyz.xy * float2( 1,1 ) + float2( 0,0 );
				float3 rotatedValue175 = RotateAroundAxis( float3( 0,0,0 ), texCoord174, float3( 1,0,0 ), ( ( ( _TimeOfDay + 180.0 ) / 360.0 ) * 6.28319 ) );
				float4 texCUBENode74 = texCUBE( _WobblySunandMoon, rotatedValue175 );
				float4 lerpResult81 = lerp( ( ( ( step( simplePerlin3D84 , 0.035 ) + ( step( simplePerlin3D98 , 0.05 ) * 0.1 ) ) * _StarsVisibility ) + _Tint ) , float4( texCUBENode74.rgb , 0.0 ) , texCUBENode74.a);
				float mulTime54 = _Time.y * _CloudRotationSpeed;
				float3 texCoord65 = i.ase_texcoord1.xyz;
				texCoord65.xy = i.ase_texcoord1.xyz.xy * float2( 1,1 ) + float2( 0,0 );
				float3 rotatedValue72 = RotateAroundAxis( float3( 0,0,0 ), texCoord65, float3(0,1,0), mulTime54 );
				float4 texCUBENode2 = texCUBE( _CloudTexture, rotatedValue72 );
				Gradient gradient47 = NewGradient( 0, 2, 2, float4( 1, 1, 1, 0 ), float4( 1, 1, 1, 1 ), 0, 0, 0, 0, 0, 0, float2( 1, 0 ), float2( 0.4823529, 1 ), 0, 0, 0, 0, 0, 0 );
				float2 texCoord45 = i.ase_texcoord1.xyz.xy * float2( 1,1 ) + float2( 0,0 );
				float4 lerpResult34 = lerp( lerpResult81 , float4( texCUBENode2.rgb , 0.0 ) , ( texCUBENode2.a * _CloudOpacity * SampleGradient( gradient47, texCoord45.y ).a ));
				Gradient gradient20 = NewGradient( 0, 2, 2, float4( 1, 1, 1, 0 ), float4( 1, 1, 1, 1 ), 0, 0, 0, 0, 0, 0, float2( 1, 0 ), float2( 0, 0.01499962 ), 0, 0, 0, 0, 0, 0 );
				float2 texCoord25 = i.ase_texcoord1.xyz.xy * float2( 1,1 ) + ( float2( 0,1 ) * ( ( _CloudBottomGradient * 2 ) - (float)1 ) );
				float4 temp_output_2_0_g2 = SampleGradient( gradient20, texCoord25.y );
				float4 lerpResult115 = lerp( _Color0 , float4( (temp_output_2_0_g2).rgb , 0.0 ) , 0.2);
				float4 lerpResult4 = lerp( lerpResult34 , lerpResult115 , ( (temp_output_2_0_g2).a * _FogFill ));
				
				
				finalColor = lerpResult4;
				return finalColor;
			}
			ENDCG
		}
	}
	CustomEditor "ASEMaterialInspector"
	
	Fallback Off
}
/*ASEBEGIN
Version=19800
Node;AmplifyShaderEditor.TextureCoordinatesNode;96;-3792,-1040;Inherit;False;0;-1;3;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;97;-3728,-864;Inherit;False;Constant;_Float1;Float 1;8;0;Create;True;0;0;0;False;0;False;55;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.IntNode;40;-2640,944;Inherit;False;Constant;_Int0;Int 0;4;0;Create;True;0;0;0;False;0;False;2;0;False;0;1;INT;0
Node;AmplifyShaderEditor.RangedFloatNode;23;-2768,864;Inherit;False;Property;_CloudBottomGradient;CloudBottomGradient;2;0;Create;True;0;0;0;False;0;False;0.533;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;95;-3520,-816;Inherit;False;Constant;_Float3;Float 3;8;0;Create;True;0;0;0;False;0;False;0.05;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;98;-3552,-928;Inherit;False;Simplex3D;True;False;2;0;FLOAT3;0,0,0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;85;-3616,-1264;Inherit;False;0;-1;3;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;86;-3552,-1088;Inherit;False;Constant;_Float2;Float 2;8;0;Create;True;0;0;0;False;0;False;40;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;39;-2480,848;Inherit;False;2;2;0;FLOAT;0;False;1;INT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.IntNode;42;-2480,944;Inherit;False;Constant;_Int1;Int 1;4;0;Create;True;0;0;0;False;0;False;1;0;False;0;1;INT;0
Node;AmplifyShaderEditor.RangedFloatNode;176;-2736,-1440;Inherit;False;Property;_TimeOfDay;TimeOfDay;12;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;94;-3312,-896;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;101;-3248,-672;Inherit;False;Constant;_Float6;Float 6;8;0;Create;True;0;0;0;False;0;False;0.1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;93;-3344,-1040;Inherit;False;Constant;_Float4;Float 4;8;0;Create;True;0;0;0;False;0;False;0.035;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;84;-3376,-1168;Inherit;False;Simplex3D;True;False;2;0;FLOAT3;0,0,0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;41;-2320,848;Inherit;False;2;0;FLOAT;0;False;1;INT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;38;-2320,720;Inherit;False;Constant;_Vector0;Vector 0;4;0;Create;True;0;0;0;False;0;False;0,1;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleAddOpNode;180;-2560,-1440;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;180;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;100;-3072,-816;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;92;-3104,-1152;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;55;-2352,-320;Inherit;False;Property;_CloudRotationSpeed;CloudRotationSpeed;4;0;Create;True;0;0;0;False;0;False;0.01;0;0;5;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;37;-2160,768;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;179;-2448,-1440;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;360;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;54;-2016,-320;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;65;-2048,-224;Inherit;False;0;-1;3;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector3Node;73;-2016,-512;Inherit;False;Constant;_Vector1;Vector 1;6;0;Create;True;0;0;0;False;0;False;0,1,0;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleAddOpNode;99;-2864,-1024;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;25;-2016,736;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GradientNode;20;-2016,656;Inherit;False;0;2;2;1,1,1,0;1,1,1,1;1,0;0,0.01499962;0;1;OBJECT;0
Node;AmplifyShaderEditor.RangedFloatNode;139;-2768,-656;Inherit;False;Property;_StarsVisibility;StarsVisibility;8;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;174;-2400,-1312;Inherit;False;0;-1;3;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;178;-2336,-1440;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;6.28319;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;45;-1808,-16;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GradientNode;47;-1808,-96;Inherit;False;0;2;2;1,1,1,0;1,1,1,1;1,0;0.4823529,1;0;1;OBJECT;0
Node;AmplifyShaderEditor.RotateAboutAxisNode;72;-1760,-352;Inherit;False;False;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;126;-2448,-848;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GradientSampleNode;24;-1792,720;Inherit;True;2;0;OBJECT;;False;1;FLOAT;0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;138;-1760,-640;Inherit;False;Property;_Tint;Tint;6;0;Create;True;0;0;0;False;0;False;0,0,0,0;0,0,0,0;True;True;0;6;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT3;5
Node;AmplifyShaderEditor.RotateAboutAxisNode;175;-2096,-1424;Inherit;False;False;4;0;FLOAT3;1,0,0;False;1;FLOAT;0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GradientSampleNode;46;-1504,-64;Inherit;True;2;0;OBJECT;;False;1;FLOAT;0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;113;-1504,-784;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;74;-1488,-1360;Inherit;True;Property;_WobblySunandMoon;WobblySunandMoon;1;1;[SingleLineTexture];Create;True;0;0;0;False;0;False;-1;1594da2ce7e78274da30391daa337cee;1594da2ce7e78274da30391daa337cee;True;0;False;white;Auto;False;Object;-1;Auto;Cube;8;0;SAMPLERCUBE;;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;3;FLOAT3;0,0,0;False;4;FLOAT3;0,0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;6;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT3;5
Node;AmplifyShaderEditor.SamplerNode;2;-1472,-368;Inherit;True;Property;_CloudTexture;CloudTexture;0;1;[SingleLineTexture];Create;True;0;0;0;False;0;False;-1;8d5e8a1df9a71064a9aee8ba34531fb8;8d5e8a1df9a71064a9aee8ba34531fb8;True;0;False;white;Auto;False;Object;-1;Auto;Cube;8;0;SAMPLERCUBE;;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;3;FLOAT3;0,0,0;False;4;FLOAT3;0,0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;6;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT3;5
Node;AmplifyShaderEditor.RangedFloatNode;44;-1472,-176;Inherit;False;Property;_CloudOpacity;CloudOpacity;3;0;Create;True;0;0;0;False;0;False;0.555;0.47;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;18;-1408,560;Inherit;False;Alpha Split;-1;;2;07dab7960105b86429ac8eebd729ed6d;0;1;2;COLOR;0,0,0,0;False;2;FLOAT3;0;FLOAT;6
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;43;-1152,-224;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;81;-1136,-656;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.WireNode;137;-1168,496;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;51;-1104,528;Inherit;False;Constant;_Float0;Float 0;6;0;Create;True;0;0;0;False;0;False;0.2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;140;-960,720;Inherit;False;Property;_FogFill;FogFill;9;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;142;-1298.082,248.3753;Inherit;False;Property;_Color0;Color 0;7;0;Create;True;0;0;0;False;0;False;0,0,0,0;0,0,0,0;True;True;0;6;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT3;5
Node;AmplifyShaderEditor.LerpOp;34;-960,-384;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;115;-912,384;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;141;-635.8345,623.1492;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector3Node;161;-3408,-3104;Inherit;False;Property;_LightRotation;LightRotation;11;0;Create;True;0;0;0;False;0;False;0,0,0;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleDivideOpNode;170;-3136,-3072;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;360,360,360;False;1;FLOAT3;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;162;-2736,-3184;Inherit;False;0;-1;3;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.BreakToComponentsNode;173;-2816,-2960;Inherit;False;FLOAT3;1;0;FLOAT3;0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.RotateAboutAxisNode;166;-2432,-3072;Inherit;False;False;4;0;FLOAT3;1,0,0;False;1;FLOAT;0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RotateAboutAxisNode;167;-2080,-3008;Inherit;False;False;4;0;FLOAT3;0,1,0;False;1;FLOAT;0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RotateAboutAxisNode;168;-1712,-2880;Inherit;False;False;4;0;FLOAT3;0,0,1;False;1;FLOAT;0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;107;-4256,-1840;Inherit;False;rotation;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;4;-512,16;Inherit;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;108;-3184,288;Inherit;False;107;rotation;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GradientNode;102;-3216,192;Inherit;False;0;8;2;0.2376736,0.283674,0.4622642,0;0.3176471,0.2862745,0.4901961,0.03376821;0.3173849,0.2846209,0.490566,0.4363622;0.6415094,0.4527597,0.4145603,0.4970626;0.5669469,0.4862745,0.6039216,0.5316091;0.4579031,0.6847942,0.9245283,0.5896086;0.4588235,0.6862745,0.9254902,0.8882429;0.2392157,0.282353,0.4627451,1;1,0;1,1;0;1;OBJECT;0
Node;AmplifyShaderEditor.GradientSampleNode;104;-2976,240;Inherit;True;2;0;OBJECT;;False;1;FLOAT;0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;128;-4000,-144;Inherit;False;107;rotation;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;132;-3920,-16;Inherit;False;Constant;_Float8;Float 8;6;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GradientNode;125;-3808,-272;Inherit;False;0;7;2;0.5019608,0.5019608,0.5019608,0;1,1,1,0.03376821;1,1,1,0.4363622;0,0,0,0.5298696;0,0,0,0.5896086;0,0,0,0.9376669;0.5,0.5,0.5,1;1,0;1,1;0;1;OBJECT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;131;-3744,-128;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GradientSampleNode;127;-3536,-256;Inherit;True;2;0;OBJECT;;False;1;FLOAT;0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;75;-5840,-2176;Inherit;False;Property;_RotationSpeed;RotationSpeed;5;0;Create;True;0;0;0;False;0;False;0.01666667;0;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;82;-5552,-2144;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;76;-5392,-2144;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.IntNode;106;-4992,-2032;Inherit;False;Constant;_Int2;Int 2;8;0;Create;True;0;0;0;False;0;False;1;0;False;0;1;INT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;133;-5136,-2112;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleRemainderNode;105;-4848,-2144;Inherit;False;2;0;FLOAT;0;False;1;INT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;160;-2880,-2544;Inherit;False;Property;_Rotation;Rotation;10;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;77;-2720,-2400;Inherit;False;0;-1;3;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector3Node;78;-2688,-2688;Inherit;False;Constant;_Vector2;Vector 2;6;0;Create;True;0;0;0;False;0;False;1,0,0;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;122;-2688,-2512;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;159;-2608,-2112;Inherit;False;0;-1;3;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;152;-2384,-2112;Inherit;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;1;False;1;FLOAT4;0
Node;AmplifyShaderEditor.Matrix4X4Node;143;-2544,-1952;Inherit;False;Global;SkyboxLightLocalToWorldMatrix;SkyboxLightLocalToWorldMatrix;11;0;Create;True;0;0;0;False;0;False;1,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1;0;1;FLOAT4x4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;153;-2192,-2048;Inherit;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT4x4;1,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1;False;1;FLOAT4;0
Node;AmplifyShaderEditor.FunctionNode;157;-3120,-2144;Inherit;False;Normal Face;-1;;3;f4725843c667a994e8a7e4987db394b2;2,88,0,86,1;0;1;FLOAT3;30
Node;AmplifyShaderEditor.WorldNormalVector;144;-2848,-2224;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.GetLocalVarNode;121;-3152,-2688;Inherit;False;107;rotation;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;158;-1808,-2416;Inherit;False;0;-1;3;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RotateAboutAxisNode;79;-2432,-2528;Inherit;False;False;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;124;-2912,-2448;Inherit;False;Constant;_Float7;Float 7;6;0;Create;True;0;0;0;False;0;False;6.28319;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;169;-3264,-2928;Inherit;False;Constant;_Float9;Float 7;6;0;Create;True;0;0;0;False;0;False;6.28319;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;172;-3008,-3008;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;0;48,-16;Float;False;True;-1;3;ASEMaterialInspector;100;5;lstwo/ScriptControlledWobblySkybox;0770190933193b94aaa3065e307002fa;True;Unlit;0;0;Unlit;2;False;True;0;1;False;;0;False;;0;1;False;;0;False;;True;0;False;;0;False;;False;False;False;False;False;False;False;False;False;True;0;False;;True;True;0;False;;True;True;True;True;True;True;0;False;;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;True;True;2;False;;True;3;False;;True;True;0;False;;0;False;;True;1;RenderType=Opaque=RenderType;True;2;False;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;0;;0;0;Standard;1;Vertex Position,InvertActionOnDeselection;1;0;0;1;True;False;;False;0
WireConnection;98;0;96;0
WireConnection;98;1;97;0
WireConnection;39;0;23;0
WireConnection;39;1;40;0
WireConnection;94;0;98;0
WireConnection;94;1;95;0
WireConnection;84;0;85;0
WireConnection;84;1;86;0
WireConnection;41;0;39;0
WireConnection;41;1;42;0
WireConnection;180;0;176;0
WireConnection;100;0;94;0
WireConnection;100;1;101;0
WireConnection;92;0;84;0
WireConnection;92;1;93;0
WireConnection;37;0;38;0
WireConnection;37;1;41;0
WireConnection;179;0;180;0
WireConnection;54;0;55;0
WireConnection;99;0;92;0
WireConnection;99;1;100;0
WireConnection;25;1;37;0
WireConnection;178;0;179;0
WireConnection;72;0;73;0
WireConnection;72;1;54;0
WireConnection;72;3;65;0
WireConnection;126;0;99;0
WireConnection;126;1;139;0
WireConnection;24;0;20;0
WireConnection;24;1;25;2
WireConnection;175;1;178;0
WireConnection;175;3;174;0
WireConnection;46;0;47;0
WireConnection;46;1;45;2
WireConnection;113;0;126;0
WireConnection;113;1;138;0
WireConnection;74;1;175;0
WireConnection;2;1;72;0
WireConnection;18;2;24;0
WireConnection;43;0;2;4
WireConnection;43;1;44;0
WireConnection;43;2;46;4
WireConnection;81;0;113;0
WireConnection;81;1;74;5
WireConnection;81;2;74;4
WireConnection;137;0;18;0
WireConnection;34;0;81;0
WireConnection;34;1;2;5
WireConnection;34;2;43;0
WireConnection;115;0;142;0
WireConnection;115;1;137;0
WireConnection;115;2;51;0
WireConnection;141;0;18;6
WireConnection;141;1;140;0
WireConnection;170;0;161;0
WireConnection;173;0;172;0
WireConnection;166;1;173;0
WireConnection;166;3;162;0
WireConnection;167;1;173;1
WireConnection;167;3;166;0
WireConnection;168;1;173;2
WireConnection;168;3;167;0
WireConnection;107;0;105;0
WireConnection;4;0;34;0
WireConnection;4;1;115;0
WireConnection;4;2;141;0
WireConnection;104;0;102;0
WireConnection;104;1;108;0
WireConnection;131;0;128;0
WireConnection;131;1;132;0
WireConnection;127;0;125;0
WireConnection;127;1;131;0
WireConnection;82;0;75;0
WireConnection;76;0;82;0
WireConnection;133;0;76;0
WireConnection;105;0;133;0
WireConnection;105;1;106;0
WireConnection;122;0;160;0
WireConnection;122;1;124;0
WireConnection;152;0;159;1
WireConnection;152;1;159;2
WireConnection;152;2;159;3
WireConnection;153;0;152;0
WireConnection;153;1;143;0
WireConnection;144;0;157;30
WireConnection;79;0;78;0
WireConnection;79;1;122;0
WireConnection;79;3;77;0
WireConnection;172;0;170;0
WireConnection;172;1;169;0
WireConnection;0;0;4;0
ASEEND*/
//CHKSM=867A11A45227BC1B08258F58C91CC81CA24D1EDB