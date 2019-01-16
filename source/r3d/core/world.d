module r3d.core.world;

import std.container;
import std.datetime;
import std.parallelism;
import r3d.core.object;


class World
{
	private auto _entities = Array!R3DObject();

	auto opIndex(size_t i)
	{
		return _entities[i];
	}

	auto addObject(R3DObject object)
	{
		_entities.insert(object);
	}

	void insert(R3DObject object)
	{
		_entities.insert(object);
	}

	void update(Duration deltaTime)
	{
		// Update positions
		foreach (obj; parallel(_entities[]))
		{
			obj.update(this, deltaTime);
		}
	}
}
