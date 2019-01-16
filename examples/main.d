import std.file;
import std.stdio;
import std.string;
import r3d;


double previous_seconds = 0;
int frame_count;
void _update_fps_counter(Window window) {
	import r3d.graphics.opengl.glfw : glfwGetTime;
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
	auto window = new Window(640, 480, "Hello world!");

	writeln(renderer);

	// Create the mesh
	auto mesh = Mesh.fromFile("mesh.obj");

	// Create some instances sharing the same mesh
	import std.random;
	float[9] rands;
	foreach (ref e; rands[0 .. $])
	{
		rndGen.popFront;
		e = 1f - rndGen.front % 2000f / 1000f;
		e *= 2;
	}
	StandaloneMeshInstance[9] instances;
	foreach (ref e; instances[0 .. $])
		e = new StandaloneMeshInstance(mesh);

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
	auto cam_rot = Vector3.zero;
	auto cam_pos = Vector3.back * 10 + Vector3.up * 3;
	auto rot = Vector3.zero;
	auto pos = Vector3.zero;
	auto cursorPrevPos = window.cursorPos;
	Quaternion q = Quaternion.unit;
	program.use();
	q.eulerAngles = rot;
	program.setView(window, pos, q);
	auto sw = StopWatch(AutoStart.yes);
	while (!window.shouldClose)
	{
		_update_fps_counter(window);
		window.clear();

		q.eulerAngles = cam_rot;
		program.setView(window, cam_pos, q);
		foreach (x; -1 .. 2)
		{
			foreach (y; -1 .. 2)
			{
				auto i = (x + 1) + 3 * (y + 1);
				q.eulerAngles = rot * sin(i * 2.3);
				instances[i].position = Vector3(4*x, 2*sin(rot.y * rands[i]), 4*y);
				instances[i].orientation = q;
				instances[i].draw();
			}
		}
		window.swapBuffers();
		window.poll();

		auto delta = cast(double)sw.peek.total!"usecs" / 1_000_000;
		sw.reset();

		// Rotate the camera
		auto drot = window.cursorPos - cursorPrevPos;
		cam_rot += Vector3(0, -drot.x, 0) / 100;
		cursorPrevPos = window.cursorPos;

		// Move the camera
		rot.y += delta * 1.3;
		Vector3 dpos = Vector3.zero;
		if (window.keyAction(KeyCode.w))
			dpos.z += 1;
		if (window.keyAction(KeyCode.s))
			dpos.z -= 1;
		if (window.keyAction(KeyCode.a))
			dpos.x -= 1;
		if (window.keyAction(KeyCode.d))
			dpos.x += 1;
		if (window.keyAction(KeyCode.space))
			dpos.y += 1;
		if (window.keyAction(KeyCode.lshift))
			dpos.y -= 1;
		double ca = cos(cam_rot.y), sa = sin(cam_rot.y);
		dpos = Vector3(dpos.x * ca - dpos.z * sa, dpos.y, dpos.x * sa + dpos.z * ca);
		cam_pos += dpos * delta * 3;
	}

	return 0;
}
