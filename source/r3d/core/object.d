module r3d.core.object;

import std.container.array;
import std.algorithm : filter, remove;
import std.range;
import r3d.core.vector;
import r3d.core.quaternion;


// Really, Phobos?
@nogc
private bool contains(T)(Array!T a, T x)
{
	foreach (y; a)
	{
		if (x is y)
			return true;
	}
	return false;
}


class R3DObject
{
	private R3DObject _parent;
	private auto _children = Array!R3DObject();
	Quaternion rotation;
	Vector3 position;
	bool enabled = true;

	// Getters
	@property auto parent() { return _parent; }

	// Setters
	@property auto parent(R3DObject parent)
	{
		if (_parent)
		{
			// Surely there is a std function, but I can't figure out which
			for (size_t i = 0; i < _parent._children.length; i++)
			{
				auto c = _parent._children[i];
				if (c == this)
				{
					for (size_t j = i + 1; j < _parent._children.length; j++)
						_parent._children[j - 1] = _parent._children[j];
					_parent._children.removeBack();
					break;
				}
			}
		}
		_parent = parent;
	}

	// Methods
	void addChildren(InputRange!R3DObject children)
	{
		auto f = children.filter!(c => !_children.contains(c));
		_children.insert(f);
	}

	void removeChildren(InputRange!R3DObject children)
	{
		auto f = children.filter!(c => _children.contains(c));
		_children.insert(f);
	}
}
