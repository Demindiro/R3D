/+dub.sdl:
dependency "r3d" path="../../"
+/
import std.datetime;
import std.datetime.stopwatch : StopWatch, AutoStart;
import std.file;
import std.math;
import std.random;
import std.stdio;
import std.string;
import r3d;

enum cameraDeadZone = 0.001;
enum rotAcceleration = 1.0L;


auto accelerateRotation(double vel, double wantedVel, double deltaTime)
{
	auto diff = wantedVel - vel;
	auto a = diff < 0 ? -rotAcceleration : rotAcceleration;
	if (abs(diff) < abs(a * deltaTime))
		a = diff / deltaTime;
	return a;
}


int main()
{
	// Create the window
	auto window = new Window(640, 480, "Space shooters");

	writeln(renderer);

	// Load ze börgh kubus
	//auto mesh = Mesh.fromFile("examples/space-shooters/models/ship.obj");
	auto mesh = Mesh.fromFile("mesh.obj");

	// Create some instances sharing the same mesh
	auto batch = new StandaloneMeshInstance(mesh);
	batch.position = Vector!3(0,0,0);
	batch.orientation = Quaternion(0,0,0,1);

	// :o
	auto bigShip = new StandaloneMeshInstance(Mesh.fromFile("models/wh40k.obj"));
	bigShip.position = Vector!3(0,-10000,100);

	// Load the shaders
	auto source_vertex   = readText("shaders/basic.vert");
	auto source_fragment = readText("shaders/basic.frag");
	auto vertex   = new   VertexShader(source_vertex);
	auto fragment = new FragmentShader(source_fragment);

	// Create a skybox
	auto skybox = new Skybox("skybox/space/up.tga", "skybox/space/down.tga",
	                         "skybox/space/right.tga", "skybox/space/left.tga",
	                         "skybox/space/front.tga", "skybox/space/back.tga",
	                         "shaders/skybox.vert", "shaders/skybox.frag");

	// Create the program
	auto program = new Program;
	program.attach(vertex);
	program.attach(fragment);
	program.link();

	// Create the world
	auto world = new World;

	// Yadayada
	auto camRotMat = Matrix!(float,3,3)([1, 0, 0, 0, 1, 0, 0, 0, 1]);
	auto camRot  = Quaternion(0,0,0,1);
	auto camPos  = Vector!3(0,0,0);
	auto relCamPos = Vector!3(0,0,-20);
	auto shipPos = Vector!3(0,0,10);
	auto shipVel = Vector!3(0,0,0);
	auto shipRot = Quaternion(0,0,0,1);
	auto shipRotSpeed = Vector!3(0,0,0);
	auto cursorPrevPos = window.cursorPos;
	auto sw = StopWatch(AutoStart.yes);

	// ╰(✿˙ᗜ˙)੭━☆ﾟ.*･｡ﾟ
	while (!window.shouldClose)
	{
		// Determine time passed
		auto delta  = sw.peek;
		auto deltaf = delta.total!"usecs" / 1_000_000.0L;
		sw.reset;

		// Turn the ship
		Vector!3 dpos = Vector!3(0,0,0);
		if (window.keyAction(KeyCode.a))
			dpos.x -= 1;
		if (window.keyAction(KeyCode.d))
			dpos.x += 1;
		if (window.keyAction(KeyCode.space))
			dpos.z += 1;
		if (window.keyAction(KeyCode.lshift))
			dpos.z -= 1;

		shipRotSpeed.x += accelerateRotation(shipRotSpeed.x, dpos.x * 2, deltaf * 3) * deltaf * 3;
		shipRotSpeed.z += accelerateRotation(shipRotSpeed.z, dpos.z * 2, deltaf * 3) * deltaf * 3;

		Quaternion dquat;
		dquat.eulerAngles = shipRotSpeed * deltaf;
		shipRot  = dquat * shipRot;
		shipRot /= shipRot.norm;
		batch.orientation = shipRot;

		// Move the ship
		dpos = Vector!3(0,0,0);
		if (window.keyAction(KeyCode.w))
			dpos.z += 60;
		if (window.keyAction(KeyCode.s))
			dpos.z -= 30;
		shipVel += shipRot.matrix!double.inverse * dpos * deltaf;
		shipPos += shipVel * deltaf;
		batch.position = shipPos;

		// Interpolate the camera's position towards the back of the ship
		auto toPos = Vector!3(0,1,-10 - dpos.z / 10);
		dpos = toPos - relCamPos;
		auto dist2 = dpos.norm2;
		if (dist2 > 0)
		{
			dpos = dpos / dpos.norm * deltaf * 10;
			if (dist2 <= dpos.norm2)
				relCamPos = toPos;
			else
				relCamPos += dpos;
		}
		camPos = shipPos + shipRot.matrix!double.inverse *  relCamPos;

		// Interpolate the camera's orientation to align with the ship
		dpos = shipPos - camPos;
		camRot = Quaternion.slerp(camRot, shipRot, deltaf * 3);
		camRotMat = camRot.matrix!float.inverse;

		// Update the world
		world.update(delta);

		// Render
		window.clear;

		program.use;
		program.setView!true(window, camPos, camRotMat);
		batch .draw;
		bigShip.draw;

		skybox.use;
		skybox.setView!true(window, camRotMat);
		skybox.draw;

		window.swapBuffers;
		window.poll;
	}

	return 0;
}
