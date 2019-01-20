#version 330 core

uniform float screen_ratio;
uniform mat3 cam_rot;

layout(location=0) in vec3 vert_pos;

out vec3 tex_crd;

void main()
{
	tex_crd = cam_rot * vert_pos;
	gl_Position = vec4(vert_pos, 1);
	gl_Position.z = 1;
	if (screen_ratio > 1)
		gl_Position.y *= screen_ratio;
	else
		gl_Position.x /= screen_ratio;
}
