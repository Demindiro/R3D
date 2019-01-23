module r3d.core.object;

import std.container;
import std.datetime;
import r3d.core.vector;
import r3d.core.quaternion;
import r3d.core.world;


/**
A customizable component attachable to a object in the world.
*/
abstract class Component
{
	/**
	This function is called once every update loop. Note that it will be called
	in parallel, so race conditions may occur if interacting with other components.

	Params:
		world = The world the object resides in.
		object = The object this component is attached to.
		deltaTime = The time passed since the last update.
	*/
	abstract void update(World world, R3DObject object, Duration deltaTime);
}

/**
This object represents a single object in the world. All object in the world are
of this type.

These objects can be customized with components
*/
final class R3DObject
{
	private auto _components  = Array!Component();
	/// The orientation and position of this object in the world.
	Quaternion    orientation = Quaternion.unit;
	/// Ditto
	auto position    = Vector!3(0, 0, 0);
	/// Wether this object is enabled or not. If not, it will not be updated.
	bool          enabled     = true;

	/**
	Gets or sets a component.

	Params:
		i = The index of the component.
	*/
	ref auto opIndex(size_t i)
	{
		return _components[i];
	}

	/**
	Adds a component.

	Params:
		component = The component to be added.
	*/
	void insert(Component component)
	{
		_components.insert(component);
	}

	package void update(World world, Duration deltaTime)
	{
		foreach (c; _components)
			c.update(world, this, deltaTime);
	}
}
