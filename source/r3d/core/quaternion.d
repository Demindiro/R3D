module r3d.core.quaternion;

import r3d.core.vector;
import r3d.core.matrix;
import std.math;


/**
This implementation is based on https://en.wikipedia.org/wiki/Conversion_between_quaternions_and_Euler_angles
and https://en.wikipedia.org/wiki/Quaternions_and_spatial_rotation.
*/
/**
This struct represents a quaternion.
*/
@nogc struct Quaternion
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

	@property double norm2()
	{
		return w * w + x * x + y * y + z * z;
	}

	@property double norm()
	{
		return norm2.sqrt;
	}


	// TODO norm
	@property Matrix!(T,3,3) matrix(T)()
	{
		static if (!is(T == float) && !is(T == double))
			static assert(0, "Type must be float or double, not " ~ T.stringof);
		T xx = x * x, yy = y * y, zz = z * z;
		T xy = x * y, yz = y * z, xz = x * z;
		T wx = w * x, wy = w * y, wz = w * z;
		T[9] a = [
			1 - 2 * (yy + zz),     2 * (xy - wz),     2 * (xz + wy),
			    2 * (xy + wz), 1 - 2 * (xx + zz),     2 * (yz - wx),
			    2 * (xz - wy),     2 * (yz + wx), 1 - 2 * (xx + yy),
		];
		return Matrix!(T,3,3)(a);
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

	auto opBinary(string op, T)(T c)
	{
		Quaternion q = this;
		static if (is(T == Quaternion))
		{
		}
		else
		{
			static if (op == "+" || op == "-")
			{
				mixin("q " ~ op ~ "= c;");
			}
			else static if (op == "*" || op == "/")
			{
				static foreach (char s ; "wxyz")
					mixin("q." ~ s ~ op ~ "= c;");
			}
			else
			{
				static assert(0, op ~ "unsupported");
			}
		}
		return q;
	}

	auto opBinaryRight(string op, T)(T c)
	{
		return opBinary!(op,T)(c);
	}

	void opOpAssign(string op, T)(T c)
	{
		mixin("this = this" ~ op[0] ~ "c;");
	}

	void normalize()
	{
		this /= this.norm;
	}

	static const Quaternion unit = { x: 0, y: 0, z: 0, w: 1 };
}
