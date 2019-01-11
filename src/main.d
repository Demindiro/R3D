import std.stdio;
import std.string;
import graphics;
import core.vector;
import core.quaternion;


const string source_vertex = q"[
	#version 400

	uniform vec3 cam_pos;
	uniform vec3 cam_rot;

	in vec3 vert_pos;
	in vec3 vert_text;
	in vec3 vert_norm;

	out vec3 frag_pos;
	out vec3 frag_text;
	out vec3 frag_norm;
	#define pi 3.1415

	void main()
	{
		mat4 invCamM = inverse(mat4(
			1, 0, 0, 0,
			0,  cos(cam_rot.x), sin(cam_rot.x), 0,
			0, -sin(cam_rot.x), cos(cam_rot.x), 0,
			0, 0, 0, 1
		) * mat4(
			cos(cam_rot.y), 0, sin(cam_rot.y), 0,
			0, 1, 0, 0,
			-sin(cam_rot.y), 0, cos(cam_rot.y), 0,
			0, 0, 0, 1
		));

		// "Physical"
		gl_Position = vec4(vert_pos,1);
		frag_pos  = vec3(gl_Position);
		frag_norm = vert_norm;

		// Camera
		gl_Position = invCamM * (gl_Position - vec4(cam_pos,1));
		gl_Position.w = 1 + gl_Position.z / 0.5;

		frag_norm = vec3(invCamM * vec4(vert_text,0));
	}
]";
const string source_fragment = q"[
	#version 400

	in vec3 frag_pos;
	in vec3 frag_text;
	in vec3 frag_norm;
	out vec4 frag_color;

	void main()
	{
		float intensity = dot(frag_norm, vec3(0,1,-1));
		intensity /= 2;
		frag_color = vec4(vec3(1,0,0) * clamp(intensity, 0, 1), 1);
	}
]";




double previous_seconds = 0;
int frame_count;
void _update_fps_counter(Window window) {
  import graphics.gl.glfw : glfwGetTime;
  double current_seconds = glfwGetTime();
  double elapsed_seconds = current_seconds - previous_seconds;
  if (elapsed_seconds > 0.25) {
    previous_seconds = current_seconds;
    double fps = cast(double)frame_count / elapsed_seconds;
    window.title = format!"OpenGL | FPS %.2f"(fps);
    frame_count = 0;
  }
  frame_count++;
}





int main()
{
	graphics.init();
	auto window = new Window(640, 480, "Hello world!");
	auto mesh = Mesh.fromFile("mesh.obj");
	
	writeln(graphics.renderer);

	// Load the shaders
	auto vertex   = new   VertexShader(source_vertex);
	auto fragment = new FragmentShader(source_fragment);

	// Create the program
	auto program = new Program;
	program.attach(vertex);
	program.attach(fragment);
	program.link();

	// ╰(✿˙ᗜ˙)੭━☆ﾟ.*･｡ﾟ
	import std.math;
	Vector3 rot = Vector3.zero;
	Vector3 pos = Vector3.back * 4 + Vector3.up;
	while (!window.shouldClose)
	{
		_update_fps_counter(window);
		window.clear();
		program.use();
		program.setUniform(0, pos);
		program.setUniform(1, rot);
		mesh.draw(Vector3.zero, Quaternion.zero, Vector3.one);
		//mesh.draw(Vector3.zero, Quaternion.zero, Vector3.one);
		window.swapBuffers();
		window.poll();
		rot.y += 0.01;
		pos.x = 4 * sin(rot.y);
		pos.y = 3;
		pos.z = -4 * cos(rot.y);
	}

	return 0;
}
