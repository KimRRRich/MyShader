//Blinn-Phone光照模型
Shader "MyShader/myShader"
{
    Properties
    {
        _Diffuse("环境光颜色",Color)=(1,1,1,1)
        _MainTex("图片纹理",2D)="white"{}
        _BumpMap("法相纹理",2D)="bump"{}
        _SpecularColor("镜面光颜色",Color)=(1,1,1,1)
        _Specular("镜面反射系数",Range(0,1.5))=0.5

    }

    SubShader
    {
        pass
        {
            Tags{ "RenderType" = "Opaque" }

            CGPROGRAM
            #include "Lighting.cginc"
            #pragma vertex vert
            #pragma fragment frag
            fixed4 _Diffuse;
            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _BumpMap;
            float _Specular;
            fixed4 _SpecularColor;

            struct v2f
            {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 lightDir : TEXCOORD1;

            };

            v2f vert(appdata_tan v)
            {
                v2f o;
                o.pos=UnityObjectToClipPos(v.vertex);
                TANGENT_SPACE_ROTATION;
                o.lightDir=mul(rotation,ObjSpaceLightDir(v.vertex));
                o.uv=TRANSFORM_TEX(v.texcoord,_MainTex);
                return o;

            }

            fixed4 frag(v2f i):SV_TARGET
            {
                
                float3 tangentNormal=UnpackNormal(tex2D(_BumpMap,i.uv));
                float3 tangentLight = normalize(i.lightDir);
                fixed4 Texcolor = tex2D(_MainTex, i.uv);
                //获取环境光颜色
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
                //获取漫反射光颜色
                fixed3 diffuse = _Diffuse.rgb * Texcolor.rgb * max(0, dot(tangentNormal, tangentLight));
                //获取镜面反射光颜色
                fixed3 reflectDir=normalize(reflect(-tangentLight,tangentNormal));
                fixed3 viewDir=normalize(UnityWorldSpaceViewDir(i.pos));
                fixed3 halfDir=normalize(tangentLight+viewDir);
                fixed3 specular=_Specular*_SpecularColor*pow(max(0,dot(tangentNormal,halfDir)),16);


                return fixed4(ambient + diffuse + specular, 1);
            }




            ENDCG

        }
    }
    
    Fallback "Diffuse"
}