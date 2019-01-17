module r3d.core.vector;

import std.traits;


alias Vector2 = Vector!2;
alias Vector3 = Vector!3;

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

	static auto cross(Vector3 u, Vector3 v)
	{
			auto dx = u.y * v.z - u.z * v.y;
			auto dy = u.x * v.z - u.z * v.x;
			auto dz = u.x * v.y - u.y * v.x;
			return Vector3(dx, -dy, dz);
	}
}

auto cross(T)(T u, T v)
{
	return T.cross(u, v);
}
