module core.quaternion;

import core.vector;
import std.math;


/**
This implementation is based on https://en.wikipedia.org/wiki/Conversion_between_quaternions_and_Euler_angles.
*/
@nogc
struct Quaternion
{
	double w, x, y, z;

	@property Vector3 eulerAngles()
	{
		Vector3 v = {
			x: atan2(2 * (w*x + y*z), 1 - 2 * (x*x + y*y)),
			y: asin (2 * (w*y - z*x)),
			z: atan2(2 * (w*z - x*y), 1 - 2 * (y*y + z*z))
		};
		return v;
	}

	@property Vector3 eulerAngles(Vector3 v)
	{
		auto cx = cos(v.x * 0.5), sx = sin(v.x * 0.5);
		auto cy = cos(v.y * 0.5), sy = sin(v.y * 0.5);
		auto cz = cos(v.z * 0.5), sz = sin(v.z * 0.5);

		w = cx * cy * cz + sx * sy * sz;
		x = cx * cy * sz - sx * sy * cz;
		y = sx * cy * sz + cx * sy * cz;
		z = sx * cy * cz - cx * sy * sz;

		return v;
	}

	static const Quaternion zero = { x: 0, y: 0, z: 0, w: 1 };
}
