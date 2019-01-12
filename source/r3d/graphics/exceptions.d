module r3d.graphics.exceptions;

import std.conv : to;
import r3d.graphics;
import r3d.graphics.opengl.gl : Error;

class GraphicsException : Exception
{
	this(string msg = null, string file = __FILE__, size_t line = __LINE__)
	{
		super(msg, file, line);
	}
}


class GlException : GraphicsException
{
	Error error;

	this(Error error, string file = __FILE__, size_t line = __LINE__)
	{
		super(error.to!string, file, line);
		this.error = error;
	}
}


class CorruptFileException : Exception
{
	this(string msg, string file = __FILE__, size_t line = __LINE__)
	{
		super(msg, file, line);
	}
}
