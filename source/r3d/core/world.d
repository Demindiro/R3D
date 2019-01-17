module r3d.core.world;

import std.container;
import std.datetime;
import std.parallelism;
import r3d.core.object;


/**
Represents a world where objects can live in peace and harmony.
*/
class World
{
	private auto _entities = Array!R3DObject();

	/**
	Gets or sets the object at the given index.

	Params:
		i = The index of the object.
	*/
	ref auto opIndex(size_t i)
	{
		return _entities[i];
	}

	/**
	Adds a object.

	Params:
		object = The object to add.
	*/
	void insert(R3DObject object)
	{
		_entities.insert(object);
	}

	/**
	Updates all objects in this world.

	Params:
		deltaTime = The time passed since the last update.
	*/
	void update(Duration deltaTime)
	{
		foreach (obj; parallel(_entities[]))
			obj.update(this, deltaTime);
	}
}
