//************************************************//
//   Implemented by Alice                         //
//   Fragment shader for spot and point lights    //
//												  //
//   Includes blinn/phong illumination, normal    //
//   mapping, attenuation factor and bone         //
//   transformations for animation                //
//************************************************//

#version 400

in vec3 ex_Normal;
in vec3 ex_VertPos;
in vec3 ex_LightDir;
in vec3 ex_LightDir2;
in vec3 ex_LightDir3;
in vec3 ex_LightDir4;
in vec2 ex_UV;
in vec3 halfVec;
in vec3 halfVec2;
in vec3 halfVec3;
in vec3 halfVec4;

in vec4 cols;

//spotlight
in vec3 spotDir;

uniform sampler2D texture0;
uniform sampler2D texNorm;

uniform int type;
uniform int caught;
uniform int found;

out vec4 out_Colour;   //colour for the pixel

void main(void)
{
	float shininess;
	vec4 texColour;

	//Calculate lighting

	vec4 light_ambient;
	if(caught==0)  light_ambient = vec4(0.2, 0.2, 0.2, 1.0);
	else light_ambient = vec4(1.0, 0.2, 0.2, 1.0); //make spotlight red if caught

	vec4 light_diffuse = vec4(1.0, 1.0, 1.0, 1.0);
	vec4 light_specular = vec4(1.0, 1.0, 1.0, 1.0); //1.0

	vec4 material_ambient;
	vec4 material_diffuse;
	vec4 material_specular;
	if(type == 2){
		if(found == 0){ 
			material_ambient = vec4(0.8, 0.8, 0.0, 1.0);
			material_diffuse = vec4(0.7, 0.7, 0.2, 1.0);
			material_specular = vec4(1.0, 1.0, 1.0, 1.0);
		}
		else{ 
			material_ambient = vec4(0.1, 0.1, 0.1, 1.0);
			material_diffuse = vec4(0.8, 0.8, 0.8, 1.0);
			material_specular = vec4(0.3, 0.3, 0.3, 1.0);
		}
	}
	else{
		material_ambient = vec4(0.8, 0.8, 0.8, 1.0); //0.1
		material_diffuse = vec4(0.8, 0.8, 0.8, 1.0); //0.8, 0.5, 0.8
		material_specular = vec4(0.3, 0.3, 0.3, 1.0); //1.0
	 }
	
	vec4 ambientProduct = light_ambient * material_ambient;
	vec4 diffuseProduct = light_diffuse * material_diffuse;
	vec4 specularProduct = light_specular * material_specular;

	float constAtt = 1.0;
    float linAtt = 0.22;
    float quadAtt = 0.20; 
	float LdotN, HdotN, spec, att, dist;
	vec4 Illumination;
	vec3 L;
	
	//lighting is slightly different for level, character and item types	
	if(type==0){
		shininess = 10.0;
		texColour = vec4(0.2, 0.2, 0.2, 1.0);
		//texColour = texture2D(texture0, ex_UV);
	}
	else if(type==1 || type==2){
		shininess = 40.0;
		texColour = texture2D(texture0, ex_UV);
	}
	
	 // sample the normal map and covert from 0:1 range to -1:1 range
	vec3 mapped_Normals = normalize(texture2D(texNorm, ex_UV).rgb * 2.0 - 1.0);
	vec3 newNormal = normalize(mapped_Normals); //normal mapped normals

	if(type==0 || type==2){
		newNormal = ex_Normal;
	}

	float cutOff = 0.05;

	//first light - spot light
	dist = length(ex_LightDir);
	att = max(0.0, 1.0 - dot(ex_LightDir, ex_LightDir));
	L = normalize(ex_LightDir);
	LdotN = max(dot(L, newNormal), 0.0);
	HdotN = max(dot(halfVec, newNormal), 0.0);
	spec = pow(HdotN, shininess);
	float spotFactor = dot(-L, spotDir);

	if(spotFactor > cutOff){
		Illumination = att * ambientProduct;
		Illumination += att * diffuseProduct * LdotN;
		Illumination += att * specularProduct * spec;
		Illumination = Illumination * (1.0 - (1.0 - spotFactor) * 1.0 / (1.0 - cutOff));
	}
	else{
		Illumination = vec4(0.0, 0.0, 0.0, 1.0);
	}

	vec4 col1 = Illumination*8;
	out_Colour = (col1 * texColour);
		
	light_ambient = vec4(0.2, 0.2, 0.2, 1.0);
	ambientProduct = light_ambient * material_ambient;
	light_specular = vec4(0.0, 0.0, 0.0, 1.0); 
	specularProduct = light_specular * material_specular;
	
	//second light
	dist = length(ex_LightDir2);
	att = max(0.0, 1.0 - dot(ex_LightDir2, ex_LightDir2));
	L = normalize(ex_LightDir2);
	Illumination = att * ambientProduct;
	LdotN = max(dot(L, newNormal), 0.0);
	HdotN = max(dot(halfVec2, newNormal), 0.0);
	spec = pow(HdotN, shininess);

	Illumination += att * diffuseProduct * LdotN;
	Illumination += att * specularProduct * spec;

	vec4 col2 = Illumination;
	out_Colour += (col2 * texColour);

	out_Colour.a = 1.0; //ensure it's opaque

	//out_Colour = texture2D(texture, ex_UV); //just textures, no lighting effect
	//out_Colour = col1 + col2 + col3 + col4; //just light, no textures
	//out_Colour = cols; //just bone transformations

}


