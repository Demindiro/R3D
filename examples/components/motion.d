import std.datetime;
import std.math;
import std.random;
import r3d.core.object;
import r3d.core.quaternion;
import r3d.core.vector;
import r3d.core.world;
import r3d.graphics.mesh : MeshInstance;


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
