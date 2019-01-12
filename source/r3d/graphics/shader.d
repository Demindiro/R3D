module r3d.graphics.shader;

import std.conv;
import std.string;
import r3d.graphics : checkForGlError;
import r3d.graphics.exceptions;
import r3d.graphics.opengl.gl;
import r3d.graphics.opengl.gl : GLShader = Shader;

abstract class Shader
{
	package GLShader _shader;

	this(string source, uint type)
	{
		_shader = glCreateShader(type);
		checkForGlError();

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
