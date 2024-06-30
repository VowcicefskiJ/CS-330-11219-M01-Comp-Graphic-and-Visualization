#version 330 core

struct Material 
{
    vec3 diffuseColor;
    vec3 specularColor;
    float shininess;
}; 

struct LightSource 
{
    vec3 position;	
    vec3 diffuseColor;
    vec3 specularColor;
    float focalStrength;
    float specularIntensity;
};

#define TOTAL_LIGHTS 2

in vec3 fragmentPosition;
in vec3 fragmentVertexNormal;
in vec2 fragmentTextureCoordinate;

out vec4 outFragmentColor;

uniform bool bUseTexture;
uniform bool bUseLighting;
uniform vec4 objectColor;
uniform sampler2D objectTexture;
uniform vec3 viewPosition;
uniform vec2 UVscale;
uniform LightSource lightSources[TOTAL_LIGHTS];
uniform Material material;
uniform vec3 globalAmbientColor;
    
vec3 CalcLightSource(LightSource light, vec3 lightNormal, vec3 vertexPosition, vec3 viewDirection);

void main()
{
    vec3 phongResult = vec3(0.0f);
    if(bUseLighting)
    {
        vec3 lightNormal = normalize(fragmentVertexNormal);
        vec3 viewDirection = normalize(viewPosition - fragmentPosition);

        for(int i = 0; i < TOTAL_LIGHTS; i++)
        {
            phongResult += CalcLightSource(lightSources[i], lightNormal, fragmentPosition, viewDirection); 
        }
    }

    vec3 resultColor;
    if(bUseTexture)
    {
        vec4 textureColor = texture(objectTexture, fragmentTextureCoordinate * UVscale);
        resultColor = phongResult * textureColor.xyz;
    }
    else
    {
        resultColor = phongResult * objectColor.xyz;
    }
    
    outFragmentColor = vec4(resultColor, 1.0);
}

vec3 CalcLightSource(LightSource light, vec3 lightNormal, vec3 vertexPosition, vec3 viewDirection)
{
    vec3 ambient = globalAmbientColor * material.diffuseColor;
    vec3 lightDirection = normalize(light.position - vertexPosition); 
    float impact = max(dot(lightNormal, lightDirection), 0.0);
    vec3 diffuse = impact * light.diffuseColor * material.diffuseColor;

    vec3 reflectDir = reflect(-lightDirection, lightNormal);
    float specularComponent = pow(max(dot(viewDirection, reflectDir), 0.0), material.shininess);
    vec3 specular = light.specularIntensity * specularComponent * light.specularColor * material.specularColor;
  
    return ambient + diffuse + specular;
}
