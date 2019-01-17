import std.datetime;
import std.datetime.stopwatch : StopWatch, AutoStart;
import std.file;
import std.math;
import std.stdio;
import std.string;
import r3d;
import motion;

enum dimX = 10;
enum dimY = 10;

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
	StandaloneMeshInstance[dimX * dimY] instances;
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
		obj.position = Vector3(4 * (i % dimX), 0, 4 * (i / dimY));
		world.insert(obj);
	}

	// Yadayada
	auto camRot = Vector!2(0, 0);
	auto camRotMat = Matrix!(float,3,3)([1, 0, 0, 0, 1, 0, 0, 0, 1]);
	auto camPos = Vector!3(0, 0, 0);
	auto cursorPrevPos = window.cursorPos;
	auto sw = StopWatch(AutoStart.yes);

	// ╰(✿˙ᗜ˙)੭━☆ﾟ.*･｡ﾟ
	program.use;
	while (!window.shouldClose)
	{
		// Determine time passed
		auto delta  = sw.peek;
		auto deltaf = delta.total!"usecs" / 1_000_000.0L;
		sw.reset;

		// Rotate the camera
		auto dRot = (window.cursorPos - cursorPrevPos) / 100;
		dRot.x = -dRot.x;
		camRot -= dRot;

		camRotMat =  (Matrix!(float,3,3)([1, 0,          0,
		                                 0, cos(camRot.y), -sin(camRot.y),
                                         0, sin(camRot.y),  cos(camRot.y)])
		            * Matrix!(float,3,3)([cos(camRot.x), 0, -sin(camRot.x),
                                                      0, 1, 0,
                                          sin(camRot.x), 0,  cos(camRot.x)])
		             ).inverse;
		cursorPrevPos = window.cursorPos;

		// Move the camera
		Vector!3 dpos = Vector!3(0, 0, 0);
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
		dpos = camRotMat * dpos;
		camPos += dpos * deltaf * 3;

		// Set the camera
		program.setView!true(window, camPos, camRotMat);

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
