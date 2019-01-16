/*
A simple shader suitable for displaying 3D models.
*/

#version 400

uniform float screen_ratio;
uniform vec3 cam_pos;
uniform mat3 cam_rot;

layout(location=0) in vec3 vert_pos;
layout(location=1) in vec3 vert_text;
layout(location=2) in vec3 vert_norm;

layout(location=3) in vec3 worldpos;
layout(location=4) in mat3 world_rot;
layout(location=7) in vec3 world_scale;

out vec3 frag_pos;
out vec3 frag_text;
out vec3 frag_norm;


void main()
{
	// Calculate the position
	// Order of operations: scale, rotate, translate
	vec3 pos  = worldpos + world_rot * (world_scale * vert_pos);
	vec3 norm = world_rot * normalize(world_scale * vert_norm);

	// Set arguments for the fragment shader
	frag_pos  = pos;
	frag_norm = norm;

	// Calculate the position relative to the camera
	gl_Position = vec4(cam_rot * (pos - cam_pos), 1);
	gl_Position.w = 1 + gl_Position.z / 0.5;

	// Scale the vieworldposort properly
	gl_Position.x /= screen_ratio;
}
