module r3d.core.object;

import std.container;
import std.datetime;
import r3d.core.vector;
import r3d.core.quaternion;
import r3d.core.world;


// Really, Phobos?
private bool contains(T)(Array!T a, T x) @nogc nothrow
{
	foreach (y; a)
	{
		if (x is y)
			return true;
	}
	return false;
}


abstract class Component
{
	abstract void update(World world, R3DObject object, Duration deltaTime);
}


class R3DObject
{
	private auto _components  = Array!Component();
	Quaternion    orientation = Quaternion.unit;
	Vector3       position    = Vector3.zero;
	bool          enabled     = true;
	//alias _components this;

	ref auto opIndex(size_t i)
	{
		return _components[i];
	}

	void insert(Component component)
	{
		_components.insert(component);
	}

	void update(World world, Duration deltaTime)
	{
		foreach (c; _components)
			c.update(world, this, deltaTime);
	}
}
