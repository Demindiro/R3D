module graphics.program;

import std.conv : to;

import graphics.exceptions;
import graphics.shader;
import graphics.gl.gl;
import core.vector;


class Program
{
	private graphics.gl.gl.Program _program;
	
	this()
	{
		_program = glCreateProgram();
		if (!_program)
			throw new GraphicsException();
	}

	~this()
	{
	}

	@nogc
	void attach(graphics.shader.Shader shader)
	{
		glAttachShader(_program, shader._shader);
	}

	void link()
	{
		glLinkProgram(_program);
		int params;
		glGetProgramiv(_program, GL_LINK_STATUS, &params);
		if (!params) {
			char[2048] log;
			size_t len;
			glGetProgramInfoLog(_program, log.length, &len, log.ptr);
			throw new GraphicsException(log[0 .. len].to!string);
		}
	}

	@nogc
	void setUniform(T)(int location, const(T) v)
	{
		static if (is(T == float))
			glUniform1f(location, v);
		else static if (is(T == Vector2))
			glUniform2f(location, v.x, v.y);
		else static if (is(T == Vector3))
			glUniform3f(location, v.x, v.y, v.z);
		else static if (is(T == Vector4))
			glUniform4f(location, v.x, v.y, v.z, v.w);
		else
			static assert(0, "Unsupported argument type: " ~ T.stringof);
	}

	@nogc
	void use()
	{
		glUseProgram(_program);
	}
}
