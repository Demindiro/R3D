#version 330 core

uniform samplerCube cube_map;

in vec3 tex_crd;

out vec4 color;


void main()
{
	color = texture(cube_map, tex_crd);
}
