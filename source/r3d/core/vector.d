module r3d.core.vector;

import std.math : sqrt;
import std.traits;


struct Vector(size_t size)
{
	union
	{
		struct
		{
			double x, y;
			static if (size == 3) double z;
			static if (size == 4) double w;
		}
		double[size] elements;
	}
	enum length = elements.length;
	alias elements this;

	this(T)(T v)
	{
		//static if (isInstanceOf!(Vector, T))
		static if (isNumeric!(T))
		{
			elements[] = v;
		}
		else
		{
			static if (v.elements.length < elements.length)
			{
				elements[0 .. v.elements.length] = v.elements[];
				elements[v.elements.length .. $] = 0;
			}
			else
			{
				elements[] = v.elements[0 .. elements.length];
			}
		}
		//else static assert(0, "Beep beep I'm a sheep (T must be of type Vector)");
	}

	static if (length == 2)
	{
		this(double x, double y)
		{
			this.x = x;
			this.y = y;
		}
	}
	else static if (length == 3)
	{
		this(double x, double y, double z)
		{
			this.x = x;
			this.y = y;
			this.z = z;
		}
	}
	else static if (length == 4)
	{
		this (double x, double y, double z, double w)
		{
			this.x = x;
			this.y = y;
			this.z = z;
			this.w = w;
		}
	}



	/**
	Converts this vector to a Range type.

	Params:
		T = The type to cast to.

	Returns: An element of the specified type. Added elements are zeroed.
	*/
	auto opCast(T)()
	{
		T v;
		auto max = v.length < length ? v.length : length;
		v.elements[0 .. max] = elements[0 .. max];
		v.elements[max .. $] = 0;
		return v;
	}

	/**
	Performs element-wise arithemic with another vector with the same size.

	Params:
		op = The operator to apply.

	Returns: An element of type T.
	*/
	inout auto opBinary(string op)(inout(Vector!size) c)
	{
		Vector!size v;
		v.elements[] = mixin("this[]" ~ op ~ "c[]");
		return v;
	}

	inout auto opBinary(string op, T)(inout(T) c)
	if ((op == "*" || op == "/") && isNumeric!T)
	{
		Vector!size v;
		v.elements[] = mixin("this[]" ~ op ~ "c");
		return v;
	}

	auto opBinaryRight(string op, T)(inout(T) c)
	{
		return opBinary!op(c);
	}

	auto opUnary(string op)()
	{
		Vector!size v = this;
		v.elements[] = mixin(op ~ "v.elements[]");
		return v;
	}

	void opOpAssign(string op, T)(inout(T) c)
	{
		this = mixin("this" ~ op[0] ~ "c");
	}

	auto norm2()
	{
		double n = 0;
		foreach(e; elements)
			n += e * e;
		return n;
	}

	auto norm()
	{
		return norm2.sqrt;
	}

	static auto cross(Vector!3 u, Vector!3 v)
	{
			auto dx = u.y * v.z - u.z * v.y;
			auto dy = u.x * v.z - u.z * v.x;
			auto dz = u.x * v.y - u.y * v.x;
			return Vector!3(dx, -dy, dz);
	}
}

auto cross(T)(T u, T v)
{
	return T.cross(u, v);
}
