module r3d.core.matrix;

struct Matrix(T, size_t _rows, size_t _columns)
{
	private T[rows * columns] _data;
	enum rows    = _rows;
	enum columns = _columns;
	enum size    = rows * columns;
	
	this (T[rows * columns] data)
	{
		_data = data;
	}

	ref auto opIndex(size_t i, size_t j)
	{
		assert (i < rows);
		assert (j < columns);
		return _data[columns * i + j];
	}
	ref auto opIndex(size_t n)
	{
		assert(n < size);
		return _data[n];
	}

	ref auto opIndex(size_t[2] i, size_t[2] j)
	{
		// TODO
	}

	const(T*) ptr() const { return _data.ptr; };

	// I can't actually believe this works
	private static auto determinantCut(size_t dim, size_t r)(Matrix!(T,dim,dim) m)
	{
		auto m2 = Matrix!(T, dim - 1, dim - 1)();
		static foreach (i; 0 .. dim)
		{
			static if (i != r)
			{{
				auto l = (i > r) ? i - 1 : i;
				static foreach (j; 1 .. dim)
					m2[l,j - 1] = m[i,j];
			}}
		}
		return m2;
	}

	private static auto determinantStep(size_t dim)(Matrix!(T,dim,dim) m)
	{
		T sum = 0;
		static if (dim == 1)
			return m[0,0];
		static foreach (i; 0 .. dim)
		{{
				 auto m2  = determinantCut!(dim, i)(m);
				 auto val = determinantStep(m2) * (i % 2 ? -1 : 1);
				 sum += m[i,0] * val;
		 }}
		return sum;
	}

	auto determinant()
	{
			return determinantStep(this);
	}


	// TODO: handle divide by 0 (row-swap)
	auto inverse()
	{
			static assert(rows == columns);

			enum dim = rows; // = columns
			auto orgM = Matrix!(T, rows, columns)(_data);
			auto invM = Matrix!(T, rows, columns)();
		static foreach (i; 0 .. rows)
		{
			static foreach (j; 0 .. columns)
				invM[i,j] = i == j;
		}

		static foreach (n; 0 .. dim)
		{{
			auto val = orgM[n,n];
			static foreach (j; 0 .. columns)
			{
				orgM[n,j] /= val;
				invM[n,j] /= val;
			}
			static foreach (i; 0 .. rows)
			{
				static if (i != n)
				{{
					auto val2 = orgM[i,n];
					static foreach (j; 0 .. columns)
					{
						orgM[i,j] -= orgM[n,j] * val2;
						invM[i,j] -= invM[n,j] * val2;
					}
				}}
			}
		}}

		return invM;
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
