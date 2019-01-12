module r3d.core.matrix;

struct Matrix(T, size_t rows, size_t columns)
{
	private T[rows * columns] _data;
	//enum rows    = rows;
	//enum columns = columns;
	enum size    = rows * columns;
	const T* ptr; // TODO learn D syntax properly instead of wasting memory

	this (T[rows * columns] data)
	{
		_data = data;
		ptr = _data.ptr;
	}

	string toString() const @safe
	{
		import std.range : chunks;
		import std.conv  : to;
		string str = "";
		foreach (r; chunks(_data[], columns))
			str ~= r.to!string ~ "\n";
		return str;
	}
}
