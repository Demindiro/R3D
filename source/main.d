import std.file;
import std.stdio;
import std.string;
import r3d;


double previous_seconds = 0;
int frame_count;
void _update_fps_counter(Window window) {
	import r3d.graphics.gl.glfw : glfwGetTime;
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
	// Create the window
	auto window = new Window(630, 480, "Hello world!");

	// Create the mesh
	auto mesh = Mesh.fromFile("mesh.obj");

	// Create some instances sharing the same mesh
	auto instances = [new StandaloneMeshInstance(mesh),
	                  new StandaloneMeshInstance(mesh)];

	writeln(renderer);

	// Load the shaders
	auto source_vertex   = readText("shaders/basic.vert");
	auto source_fragment = readText("shaders/basic.frag");
	auto vertex   = new   VertexShader(source_vertex);
	auto fragment = new FragmentShader(source_fragment);

	// Create the program
	auto program = new Program;
	program.attach(vertex);
	program.attach(fragment);
	program.link();

	// ╰(✿˙ᗜ˙)੭━☆ﾟ.*･｡ﾟ
	import std.math;
	import std.datetime.stopwatch : StopWatch, AutoStart;
	Vector3 rot = Vector3.zero;
	Vector3 pos = Vector3.back * 5 + Vector3.up;
	Quaternion q = Quaternion.unit;
	program.use();
	program.setUniform("screen_ratio", cast(float)window.width / window.height);
	program.setUniform("cam_pos", pos);
	program.setUniform("cam_rot", q.matrix!float);
	auto sw = StopWatch(AutoStart.yes);
	while (!window.shouldClose)
	{
		_update_fps_counter(window);
		window.clear();
		q.eulerAngles = rot;
		program.setUniform("cam_pos", pos);
		program.setUniform("cam_rot", q.matrix!float);
		q.eulerAngles = rot / 2;
		instances[0].position = Vector3(-2,3*sin(rot.y),0);
		instances[1].position = Vector3( 2,3*cos(rot.y),0);
		instances[0].orientation = Quaternion.unit;
		instances[1].orientation = q;
		instances[0].draw();
		instances[1].draw();
		window.swapBuffers();
		window.poll();

		auto delta = sw.peek.total!"usecs";
		sw.reset();

		rot.y += cast(double)delta / 1_000_000 * 1.3;
		pos.x =  5 * sin(rot.y);
		pos.z = -5 * cos(rot.y);
	}

	return 0;
}
