module r3d.core.vector;


struct Vector2
{
	double x, y;

	auto opCast(T)()
	{
		static if (is(T == Vector3))
			return Vector3(x, y, 0);	
	}

	inout auto opBinary(string op, T)(inout(T) c)
	{
		static if(is(T == Vector2))
			return mixin("Vector3(x" ~ op ~ "c.x, y" ~ op ~ "c.y, 0)");
		else
			return mixin("Vector3(x" ~ op ~ "c, y" ~ op ~ "c, 0)");
	}

	enum Vector2 zero  = { x:  0, y:  0 };
	enum Vector2 right = { x:  1, y:  0 };
	enum Vector2 left  = { x: -1, y:  0 };
	enum Vector2 up    = { x:  0, y:  1 };
	enum Vector2 down  = { x:  0, y: -1 };
	enum Vector2 one   = { x:  1, y:  1 };
}

struct Vector3
{
	double x, y, z;

	inout auto opBinary(string op, T)(inout(T) c)
	{
		static if(is(T == Vector3))
			return mixin("Vector3(x" ~ op ~ "c.x, y" ~ op ~ "c.y, z" ~ op ~ "c.z)");
		else
			return mixin("Vector3(x" ~ op ~ "c, y" ~ op ~ "c, z" ~ op ~ "c)");
	}

	auto opBinaryRight(string op, T)(inout(T) c)
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

	void opOpAssign(string op, T)(inout(T) c)
	{
		this = mixin("this " ~ op[0] ~ "c");
	}

	auto toFloat() const
	{
		float[3] f = [x, y, z];
		return f;
	}

	static auto cross(Vector3 u, Vector3 v)
	{
			auto dx = u.y * v.z - u.z * v.y;
			auto dy = u.x * v.z - u.z * v.x;
			auto dz = u.x * v.y - u.y * v.x;
			return Vector3(dx, -dy, dz);
	}

	enum Vector3 zero    = { x:  0, y:  0,  z:  0};
	enum Vector3 right   = { x:  1, y:  0,  z:  0};
	enum Vector3 left    = { x: -1, y:  0,  z:  0};
	enum Vector3 up      = { x:  0, y:  1,  z:  0};
	enum Vector3 down    = { x:  0, y: -1,  z:  0};
	enum Vector3 forward = { x:  0, y:  0,  z:  1};
	enum Vector3 back    = { x:  0, y:  0,  z: -1};
	enum Vector3 one     = { x:  1, y:  1,  z:  1};
}


auto cross(T)(T u, T v)
{
	return T.cross(u, v);
}
