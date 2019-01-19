/+dub.sdl:
dependency "r3d" path="../"
+/
import std.datetime;
import std.datetime.stopwatch : StopWatch, AutoStart;
import std.file;
import std.math;
import std.random;
import std.stdio;
import std.string;
import r3d;

/**
These values determine the amount of objects in the X and Z dimensions
*/
enum dimX = 20;
/// Ditto
enum dimY = 20;

enum cameraDeadZone = 0.001;


/**
Totally not stolen from some OpenGL tutorial.

(Source: http://antongerdelan.net/opengl/glcontext2.html)
*/
void _update_fps_counter(Window window) {
	import r3d.graphics.opengl.glfw : glfwGetTime;
	static double previous_seconds = 0;
	static int frame_count;
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



class Motion : Component
{
	private double _rand;
	private double _rand2;
	private MeshInstance _mesh;
	private double _rot = 0;

	this(MeshInstance mesh)
	{
		rndGen.popFront;
		_rand  = 1.0L;
		_rand -= (rndGen.front % 2000.0L) / 1000.0L;
		_rand *= 2;
		rndGen.popFront;
		_rand2  = 1.0L;
		_rand2 -= (rndGen.front % 2000.0L) / 1000.0L;
		_rand2 *= 2;
		_mesh  = mesh;
	}

	override void update(World world, R3DObject object, Duration deltaTime)
	{
		auto i = (object.position.x + 1) + 3 * (object.position.z + 1);
		object.orientation.eulerAngles = Vector3(0, _rot * _rand * 2.3, 0);
		object.position.y = 2 * sin(_rot * _rand2);

		_rot += deltaTime.total!"usecs" / 1_000_000.0L * 1.3;

		_mesh.position    = object.position;
		_mesh.orientation = object.orientation;
	}
}


int main()
{
	// Create the window
	auto window = new Window(640, 480, "Hello world!");

	writeln(renderer);

	// Create the mesh
	auto mesh = Mesh.fromFile("mesh.obj");

	// Create some instances sharing the same mesh
	auto batch = new MeshInstanceBatch(mesh);

	// Load the shaders
	auto source_vertex   = readText("shaders/basic.vert");
	auto source_fragment = readText("shaders/basic.frag");
	auto vertex   = new   VertexShader(source_vertex);
	auto fragment = new FragmentShader(source_fragment);

	// Create a skybox
	auto skybox = new Skybox("skybox/up.tga", "skybox/down.tga",
	                         "skybox/right.tga", "skybox/left.tga",
	                         "skybox/front.tga", "skybox/back.tga",
	                         "shaders/skybox.vert", "shaders/skybox.frag");

	// Create the program
	auto program = new Program;
	program.attach(vertex);
	program.attach(fragment);
	program.link();

	// Create the world
	auto world = new World;
	foreach (i; 0 .. dimX * dimY)
	{
		auto obj = new R3DObject;
		auto e   = batch.createInstance();
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
		if (camRot.y < -PI_2 + cameraDeadZone)
			camRot.y = -PI_2 + cameraDeadZone;
		else if (camRot.y > PI_2 - cameraDeadZone)
			camRot.y = PI_2 - cameraDeadZone;

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
		camPos += dpos * deltaf * 10;

		// Set the camera

		// Update the world
		world.update(delta);

		// Render
		window.clear;

		program.use;
		program.setView!true(window, camPos, camRotMat);
		batch .draw;

		skybox.use;
		skybox.setView!true(window, camRotMat);
		skybox.draw;

		window.swapBuffers;
		window.poll;

		// "Statistics"
		_update_fps_counter(window);
	}

	return 0;
}
