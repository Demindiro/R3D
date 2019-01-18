module r3d.core.quaternion;

import r3d.core.vector;
import r3d.core.matrix;
import std.math;


/**
This struct represents a quaternion.
*/
struct Quaternion
{
	union
	{
		struct
		{
			double x, y, z, w;
		}
		double[4] elements;
	}

	/**
	Returns: the square of the norm of the quaternion.
	*/
	double norm2() pure @nogc
	{
		return w * w + x * x + y * y + z * z;
	}

	/**
	Returns: the norm of the quaternion.
	*/
	double norm() pure @nogc
	{
		return norm2.sqrt;
	}

	/**
	Converts a quaternion to a 3x3 matrix.

	Params:
		T = either `float` or `double`.
		normalize = Wether to normalize the matrix. It is by default true.

	Returns: A 3x3 matrix representation of the quaternion.
	*/
	Matrix!(T,3,3) matrix(T, bool normalize = true)() pure @nogc
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
		static if (normalize)
		{
			auto n = norm2;
			foreach (ref e; a)
				e /= n;
		}
		return Matrix!(T,3,3)(a);
	}

	/**
	Sets the quaternion values based on the given euler angles.

	Params:
		v = `Vector3` representation of the euler angles to be converted.
	*/
	void eulerAngles(Vector3 v) pure @nogc
	{
		auto cx = cos(v.x * 0.5), sx = sin(v.x * 0.5);
		auto cy = cos(v.y * 0.5), sy = sin(v.y * 0.5);
		auto cz = cos(v.z * 0.5), sz = sin(v.z * 0.5);

		w = cx * cy * cz + sx * sy * sz;
		x = cx * cy * sz - sx * sy * cz;
		y = sx * cy * sz + cx * sy * cz;
		z = sx * cy * cz - cx * sy * sz;
	}

	/**
	Gets a quaternion representation in euler angles.

	Returns: `Vector3` representing the quaternion in euler angles.
	*/
	Vector3 eulerAngles() pure @nogc
	{
		Vector3 v = {
			x: atan2(2 * (w*x + y*z), 1 - 2 * (x*x + y*y)),
			y: asin (2 * (w*y - z*x)),
			z: atan2(2 * (w*z - x*y), 1 - 2 * (y*y + z*z))
		};
		return v;
	}

	/**
	Performs the given operations on two quaternions.
	Scalars are treated as quaternions.

	Params:
		op = The operation to apply.
		T = The type of the argument. Can be either a scalar or a quaternion.

	Returns: The result of the operation.
	*/
	auto opBinary(string op, T)(T c) pure @nogc
	{
		Quaternion q = this;
		static if (is(T == Quaternion))
		{
			static if (op == "+" || op == "-")
			{
				mixin("q.elements[]" ~ op ~ "= c.elements[]");
			}
			else static if (op == "*")
			{
				q.w = p.w * this.w - p.x * this.x - p.y * this.y - p.z * this.z;
				q.x = p.x * this.w + p.w * this.x - p.z * this.y + p.y * this.z;
				q.y = p.y * this.w + p.w * this.y - p.z * this.x - p.x * this.z;
				q.z = p.z * this.w - p.y * this.x + p.x * this.y + p.w * this.z;
			}
			else
			{
				static assert(0, "Operator " ~ op ~ " is not supported.");
			}
		}
		else
		{
			static if (op == "+" || op == "-")
				mixin("q " ~ op ~ "= c;");
			else static if (op == "*" || op == "/")
				mixin("q.elements[]" ~ op ~ "= c;");
			else
				static assert(0, "Operator " ~ op ~ " is not supported.");
		}
		return q;
	}

	/// Ditto
	auto opBinaryRight(string op, T)(T c) pure @nogc
	{
		return opBinary!(op,T)(c);
	}

	/// Ditto
	void opOpAssign(string op, T)(T c) pure @nogc
	{
		mixin("this = this" ~ op[0] ~ "c;");
	}

	/**
	The unit quaternion, defined as `q = w`.
	*/
	static const Quaternion unit = { x: 0, y: 0, z: 0, w: 1 };
}
