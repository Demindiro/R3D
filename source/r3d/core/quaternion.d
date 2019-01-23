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
	Returns: the conjugate of the quaternion.
	*/
	auto conjugate() pure @nogc
	{
		return Quaternion(-x,-y,-z, w);
	}

	/**
	Returns: the inverse of the quaternion.
	*/
	auto inverse() pure @nogc
	{
		return conjugate / norm;
	}

	auto ln() pure @nogc
	{
		auto n = (x * x + y * y + z * z).sqrt;
		auto t = acos(w / norm) / n;
		return Quaternion(x * t, y * t, z * t, norm.log);
	}

	auto exp() pure @nogc
	{
		auto n = (x * x + y * y + z * z).sqrt;
		auto s = n.sin / n;
		return w.exp * Quaternion(x * s, y * s, z * s, n.cos);
	}

	auto pow(double n) pure @nogc
	{
		return (ln * n).exp;
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
		v = `Vector!3` representation of the euler angles to be converted.
	*/
	void eulerAngles(Vector!3 v) pure @nogc
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

	Returns: `Vector!3` representing the quaternion in euler angles.
	*/
	Vector!3 eulerAngles() pure @nogc
	{
		return Vector!3(atan2(2 * (w*x + y*z), 1 - 2 * (x*x + y*y)),
		                asin (2 * (w*y - z*x)),
		                atan2(2 * (w*z - x*y), 1 - 2 * (y*y + z*z)));
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
				mixin("q.elements[]" ~ op ~ "= c.elements[];");
			}
			else static if (op == "*")
			{
				q.w = this.w * c.w - this.x * c.x - this.y * c.y - this.z * c.z;
				q.x = this.x * c.w + this.w * c.x - this.z * c.y + this.y * c.z;
				q.y = this.y * c.w + this.w * c.y + this.z * c.x - this.x * c.z;
				q.z = this.z * c.w + this.w * c.z + this.x * c.y - this.y * c.x;
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

	// Ditto
	auto opUnary(string op)() pure @nogc
	{
		return mixin("Quaternion(" ~ op ~ "x," ~ op ~ "y," ~ op ~ "z," ~ op ~ "w)");
	}

	/// Ditto
	void opOpAssign(string op, T)(T c) pure @nogc
	{
		mixin("this = this" ~ op[0] ~ "c;");
	}

	/**
	Returns: the dot product of the quaternion.
	*/
	static auto dot(Quaternion q, Quaternion p) pure @nogc nothrow
	{
		return q.x * p.x + q.y * p.y + q.z * p.z + q.w * p.w;
	}


	static auto slerp(Quaternion from, Quaternion to, double frac)
	{
		from /= from.norm;
		to   /= to  .norm;
		auto d = dot(from, to);
		if (d < 0)
		{
			to = -to;
			d  = -d;
		}
		// Linearly interpolate if acos may fail.
		if (d > 0.9995)
		{
			auto r = from + frac * (to - from);
			r /= r.norm;
			return r;
		}
		auto a0  = acos(d);
		auto a   = a0 * frac;
		auto sa  = sin(a);
		auto sa0 = sin(a0);
		auto f = cos(a) - d * sa / sa0;
		auto t = sa / sa0;

		return (f * from) + (t * to);
	}

	/**
	The unit quaternion, defined as `q = 1`.
	*/
	static const Quaternion unit = { x: 0, y: 0, z: 0, w: 1 };
}
