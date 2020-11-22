#version 400

in vec3 frag_pos;
in vec3 frag_text;
in vec3 frag_norm;
out vec4 frag_color;

void main()
{
	float intensity = dot(frag_norm, normalize(vec3(0.5,-0.5,1)));
	frag_color = vec4(vec3(1,1,1) * clamp(intensity,0.2,1.0), 1.0);
}
