module r3d.core.vector;


struct Vector2
{
	double x, y;

	static const Vector2 zero  = { x:  0, y:  0 };
	static const Vector2 right = { x:  1, y:  0 };
	static const Vector2 left  = { x: -1, y:  0 };
	static const Vector2 up    = { x:  0, y:  1 };
	static const Vector2 down  = { x:  0, y: -1 };
	static const Vector2 one   = { x:  1, y:  1 };
}

struct Vector3
{
	double x, y, z;

	const auto opBinary(string op, T)(const(T) c)
	{
		static if(is(T == Vector3))
			return mixin("Vector3(x" ~ op ~ "c.x, y" ~ op ~ "c.y, z" ~ op ~ "c.z)");
		else
			return mixin("Vector3(x" ~ op ~ "c, y" ~ op ~ "c, z" ~ op ~ "c)");
	}

	auto opBinaryRight(string op, T)(T c)
	{
		return opBinary!op(c);
	}

	auto opUnary(string op)()
	{
		Vector3 v = {
			x: mixin(op ~ "x"),
			y: mixin(op ~ "y"),
			z: mixin(op ~ "z"),
		};
		return v;
	}

	static const Vector3 zero    = { x:  0, y:  0,  z:  0};
	static const Vector3 right   = { x:  1, y:  0,  z:  0};
	static const Vector3 left    = { x: -1, y:  0,  z:  0};
	static const Vector3 up      = { x:  0, y:  1,  z:  0};
	static const Vector3 down    = { x:  0, y: -1,  z:  0};
	static const Vector3 forward = { x:  0, y:  0,  z:  1};
	static const Vector3 back    = { x:  0, y:  0,  z: -1};
	static const Vector3 one     = { x:  1, y:  1,  z:  1};
}

struct Vector4
{
	double x, y, z, w;
}
