import std.datetime;
import std.datetime.stopwatch : StopWatch, AutoStart;
import std.file;
import std.math;
import std.stdio;
import std.string;
import r3d;
import motion;


double previous_seconds = 0;
int frame_count;
void _update_fps_counter(Window window) {
	import r3d.graphics.opengl.glfw : glfwGetTime;
	double current_seconds = glfwGetTime();
	double elapsed_seconds = current_seconds - previous_seconds;
	if (elapsed_seconds > 0.25) {
		previous_seconds = current_seconds;
		double fps = frame_count / elapsed_seconds;
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
	StandaloneMeshInstance[9] instances;
	foreach (ref e; instances[])
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

	// Create the world
	auto world = new World;
	foreach (i, e; instances[])
	{
		auto obj = new R3DObject;
		obj.insert(new Motion(e));
		obj.position = Vector3(4 * (i % 3 - 1f), 0, 4 * (i / 3 - 1f));
		world.insert(obj);
	}

	// Yadayada
	auto cam_rot = Vector3.zero;
	auto cam_pos = Vector3.back * 10 + Vector3.up * 3;
	auto cursorPrevPos = window.cursorPos;
	auto sw = StopWatch(AutoStart.yes);

	// ╰(✿˙ᗜ˙)੭━☆ﾟ.*･｡ﾟ
	program.use;
	while (!window.shouldClose)
	{
		// Determine time passed
		auto delta  = sw.peek;
		auto deltaf = delta.total!"usecs" / 1_000_000.0L;
		sw.reset();

		// Rotate the camera
		auto drot = window.cursorPos - cursorPrevPos;
		cam_rot += Vector3(0, -drot.x, 0) / 100;
		cursorPrevPos = window.cursorPos;

		// Move the camera
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
		cam_pos += dpos * deltaf * 3;

		// Set the camera
		Quaternion q;
		q.eulerAngles = cam_rot;
		program.setView(window, cam_pos, q);

		// Update the world
		world.update(delta);

		// Render
		window.clear();
		foreach (e; instances[])
			e.draw();
		window.swapBuffers();
		window.poll();

		// "Statistics"
		_update_fps_counter(window);
	}

	return 0;
}
