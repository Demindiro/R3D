module graphics.shader;

import std.conv;
import std.string;
import graphics.exceptions;
import graphics.gl.gl;

abstract class Shader
{
	package graphics.gl.gl.Shader _shader;

	this(string source, uint type)
	{
		_shader = glCreateShader(type);
		if (!_shader)
			throw new GraphicsException();

		immutable(char*) sourcez = toStringz(source);
		uint len = cast(uint)source.length;
		glShaderSource(_shader, 1, &sourcez, &len);
		glCompileShader(_shader);

		int params;
		glGetShaderiv(_shader, GL_COMPILE_STATUS, &params);
		if (!params) {
			char[2048] log;
			size_t loglen;
			glGetShaderInfoLog(_shader, log.length, &loglen, log.ptr);
			throw new GraphicsException(to!string(log[0 .. loglen]));
		}
	}

	~this()
	{
	}
}


class VertexShader : Shader
{
	this(string source)
	{
		super(source, GL_VERTEX_SHADER);
	}
}

class FragmentShader : Shader
{
	this(string source)
	{
		super(source, GL_FRAGMENT_SHADER);
	}
}
