module r3d.core.matrix;

import r3d.core.vector;

/**
This structure represents a two-dimensional matrix. It can be used to store
any kind of data, though it is designed to only work with scalars.

Params:
	T = The type to store.
	_rows = The amount of columns this matrix has.
	_columns = The amount of rows this matrix has.
*/
struct Matrix(T, size_t _rows, size_t _columns)
{
	T[rows * columns] elements;
	enum rows    = _rows;
	enum columns = _columns;
	enum size    = rows * columns;
	alias elements this;

	/**
	Creates a new matrix by copying the given array.

	Params:
		data = The data to copy.
	*/
	this (T[rows * columns] data) @nogc pure
	{
		elements = data;
	}

	/**
	Creates a new matrix by copying the *column* vectors in the given array.

	Params:
		cols = The column vectors to copy.
	*/
	this(T)(Vector!3[rows] cols) @nogc pure if (is(T == double) && columns == 3)
	{
		static foreach (i, v; cols)
		{
			elements[i * columns + 0] = v.x;
			elements[i * columns + 1] = v.y;
			elements[i * columns + 2] = v.z;
		}
	}

	/**
	Returns the element at the given coordinate.

	Params:
		i = The index of the row.
		j = The index of the column.

	Returns: The element at the given coordinate.
	*/
	ref auto opIndex(size_t i, size_t j) @nogc pure
	{
		assert (i < rows);
		assert (j < columns);
		return elements[columns * i + j];
	}

	/**
	Returns the element at the given index in the internal array. This is useful
	if you need to perform the same operation on all elements regardless of
	coordinate.

	Params:
		n = The index of the element in the internal array.

	Returns: The element at the given index.
	*/
	ref auto opIndex(size_t n) @nogc pure
	{
		return elements[n];
	}

	/**
	TODO
	*/
	ref auto opIndex(size_t[2] i, size_t[2] j) @nogc pure
	{
		// TODO
	}

	/**
	Performs multiplication with the given element.

	Params:
		op = Always "*".
		U = Either a matrix, a vector or a scalar.
		c = The value of the left-hand variable.

	Returns:
		A matrix if two matrices are multiplied.
		A vector if a matrix and a vector are multiplied.
		A matrix if a matrix and a scalar are multiplied.
	*/
	U opBinary(string op, U)(U c) @nogc pure if (op == "*")
	{
		static if (is(U == Matrix))
		{
			static assert(columns == c.rows);
			enum n = columns;
			auto b = Matrix!(T, rows, c.columns)();
			static foreach (i; 0 .. b.rows)
			{
				static foreach (j; 0 .. b.columns)
				{
					b[i,j] = 0;
					static foreach (k; 0 .. n)
						b[i,j] += this[i,k] * c[k,j];
				}
			}
		}
		else static if (is(U == Vector!3))
		{
			static assert(rows == 3);
			auto b = U(0);
			b.x = c.x * this[0,0] + c.y * this[0,1] + c.z * this[0,2];
			b.y = c.x * this[1,0] + c.y * this[1,1] + c.z * this[1,2];
			b.z = c.x * this[2,0] + c.y * this[2,1] + c.z * this[2,2];
		}
		else static if (is(U : real))
		{
			auto b = Matrix!(T, rows, c.columns);
			foreach(ref e; b)
				e *= c;
		}
		return b;
	}

	/**
	Performs any operation that is not multiplication or division.

	Params:
		op = Any operator except for "*" and "/".
		U = A matrix with the same type and dimensions as this matrix.
		m = The matrix to perform the operation with.

	Returns: A matrix with the same type and dimensions as this matrix.
	*/
	auto opBinary(string op, U)(U m) @nogc pure
	if (is(U == Matrix!(T, rows, columns)) && op != "*" && op != "/")
	{
		float[size] r = mixin("this.elements[]" ~ op ~ "m._data[]");
		return Matrix!(T, rows, columns)(r);
	}

	/**
	Performs a opBinary operation on itself, if applicable.

	Params:
		op = The operator to apply.
		U = The type of the element to perform the operation with.
		c = The element to perform the operation with.
	*/
	void opOpAssign(string op, U)(U c) @nogc pure
	{
		this = mixin("this" ~ op[0] ~ "c");
	}

	/**
	Returns: a pointer to the internal array.
	*/
	const(T*) ptr() const @nogc pure { return elements.ptr; };

	private static auto determinantCut(size_t dim, size_t r)(Matrix!(T,dim,dim) m)
	@nogc pure
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

	private static auto determinantStep(size_t dim)(Matrix!(T,dim,dim) m) @nogc pure
	{
		T sum = 0;
		static if (dim == 1)
		{
			return m[0,0];
		}
		else
		{
			static foreach (i; 0 .. dim)
			{{
				 auto m2  = determinantCut!(dim, i)(m);
				 auto val = determinantStep(m2) * (i % 2 ? -1 : 1);
				 sum += m[i,0] * val;
			}}
			return sum;
		}
	}

	/**
	Returns: The determinant of this matrix.
	*/
	auto determinant() @nogc pure
	{
			return determinantStep(this);
	}


	/**
	Returns: The inverse of this matrix.

	Bugs:
		If a pivot is zero, the algorithm won't attempt to correct the value
		correct the value before dividing, causing the matrix to become invalid.
		It is also unable to recognize matrices that cannot be inverted.
	*/
	auto inverse() @nogc pure
	{
		static assert(rows == columns);

		enum dim  = rows;
		auto orgM = Matrix!(T, rows, columns)(elements);
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

	/**
	Returns: a multiline string representation of the matrix.
	*/
	string toString() const @safe
	{
		import std.range : chunks;
		import std.conv  : to;
		string str = "";
		foreach (r; chunks(elements[0 .. $ - 3], columns))
			str ~= r.to!string ~ "\n";
		str ~= elements[$ - 3 .. $].to!string;
		return str;
	}
}

unittest
{
	import std.math;
	import std.random;
	import std.stdio;
	bool cmp(T, size_t r, size_t c)(Matrix!(T,r,c) a, Matrix!(T,r,c) b)
	{
		foreach (i; 0 .. a.size)
		{
			if (abs(a[i] - b[i]) > 10e-10)
				return false;
		}
		return true;
	}
	auto m = Matrix!(real,3,3)([ 5.43, 33.55, 30.43,
	                            44.43, 89.43, 34.11,
	                            11.11, 42.22, 99.99]);
	writeln(m);
	writeln(m.inverse);
	writeln(m.inverse * m);
	assert(cmp(m * m.inverse, Matrix!(real,3,3)([1,0,0,0,1,0,0,0,1])));
}
