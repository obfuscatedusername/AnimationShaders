//************************************************//
//   Implemented by Alice                         //
//   Vertex shader for spot and point lights      //
//												  //
//   Includes blinn/phong illumination, normal    //
//   mapping, attenuation factor and bone         //
//   transformations for animation                //
//************************************************//

#version 400


layout (location = 0) in vec3 vertexPos;
layout (location = 1) in vec3 vertexNorm;
layout (location = 2) in vec2 vertexUV;
layout (location = 3) in ivec4 BoneIDs; //the bones affecting a particular vertex
layout (location = 4) in vec4 Weights; //the weighting of how much a bone affects a vertex

const int MAX_BONES = 100;
uniform mat4 boneTransforms[MAX_BONES]; //contains all the bone transformations (only 4 of them needed per vertex)

uniform mat4 ModelView;
uniform mat4 Projection;
uniform mat4 View;
uniform mat3 NormalMatrix;

uniform vec3 lightPosWorld;
uniform vec3 spotLightDir;
uniform int type;

out vec3 ex_Normal;
out vec3 ex_VertPos;
out vec3 ex_LightDir;
out vec3 ex_LightDir2;
out vec3 ex_LightDir3;
out vec3 ex_LightDir4;
out vec2 ex_UV;
out vec3 halfVec;
out vec3 halfVec2;
out vec3 halfVec3;
out vec3 halfVec4;

out vec4 cols; //to test the bone transfom matrices

//spotlight
out vec3 spotDir;



void main(void)
{	
	cols = vec4(0.0, 1.0, 0.0, 1.0);	

	//if type = 0, multiply vertex pos and normals by bone trans
	if(type==0){
		//combine the bone transformations of the 4 bones affecting the vertex
		//sometimes it's less than 4 bones which means you add on 0
		mat4 BoneTransform = boneTransforms[BoneIDs[0]] * Weights[0];
		BoneTransform += boneTransforms[BoneIDs[1]] * Weights[1];
		BoneTransform += boneTransforms[BoneIDs[2]] * Weights[2];
		BoneTransform += boneTransforms[BoneIDs[3]] * Weights[3];

		//mat4 BoneTransform = mat4(1.0);

		vec4 animatedPos = BoneTransform * vec4(vertexPos, 1.0);
		vec4 animatedNorm = BoneTransform * vec4(vertexNorm, 1.0);

		gl_Position = Projection * View * ModelView * vec4(animatedPos.xyz, 1.0);
		ex_Normal = normalize(vec3(ModelView * vec4(animatedNorm.xyz, 1.0)));
		ex_VertPos = vec3(ModelView * vec4(animatedPos.xyz, 1.0));
		
		vec4 test = vec4(1.0, 1.0, 1.0, 1.0);
        cols = BoneTransform * test;
	}

	else{
		gl_Position = Projection * View * ModelView * vec4(vertexPos, 1.0);
		ex_Normal = normalize(vec3(ModelView * vec4(vertexNorm,1.0)));
		ex_VertPos = vec3(ModelView * vec4(vertexPos, 1.0));
	}
	
	//divide the light dir by a radius, large number = large surface area affected
	float radius1 = 35.0; //spot light
	float radius2 = 80.0; //second small room light
	float radius3 = 200.0; //first big room light and second big room

	ex_LightDir = (lightPosWorld - ex_VertPos) /radius1; //remove -ex_VertPos for dir light
	spotDir = spotLightDir;

	ex_LightDir2 = (vec3(-270.0, 15.0, 90.0) - ex_VertPos) / radius3;    //big room
	ex_LightDir3 = (vec3(-450.0, 15.0, 120.0) - ex_VertPos) /radius2;    //small room 2 
	ex_LightDir4 = (vec3(-530.0, 15.0, -200.0) - ex_VertPos) / radius3;  //big room 2

	vec3 surfaceToEye = normalize(-ex_VertPos);
	halfVec = normalize(ex_LightDir + surfaceToEye);
	halfVec2 = normalize(ex_LightDir2 + surfaceToEye);
	halfVec3 = normalize(ex_LightDir3 + surfaceToEye);
	ex_UV = vertexUV;
}