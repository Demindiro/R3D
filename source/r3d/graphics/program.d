module r3d.graphics.program;

import std.conv : to;
import std.string : toStringz;

import r3d.core.vector;
import r3d.core.quaternion;
import r3d.core.matrix;
import r3d.graphics : checkForGlError;
import r3d.graphics.exceptions;
import r3d.graphics.shader : Shader;
import r3d.graphics.opengl.gl;
import r3d.graphics.opengl.gl : GLProgram = Program, GLShader = Shader;
import r3d.graphics.window : Window;


class Program
{
	private GLProgram _program;
	private GLProgram _active;

	this()
	{
		_program = glCreateProgram();
		checkForGlError();
	}

	~this()
	{
		glDeleteProgram(_program);
		checkForGlError();
	}

	void attach(Shader shader)
	{
		glAttachShader(_program, shader._shader);
		checkForGlError();
	}

	void link()
	{
		glLinkProgram(_program);
		int params;
		glGetProgramiv(_program, GL_LINK_STATUS, &params);
		// TODO Perhaps use a subclass of GlException?
		if (!params) {
			char[2048] log;
			size_t len;
			glGetProgramInfoLog(_program, log.length, &len, log.ptr);
			throw new GraphicsException(log[0 .. len].to!string);
		}
	}

	void setUniform(T)(int location, const(T) value)
	{
		alias v = value;
		static if (is(T == float))
			glUniform1f(location, v);
		else static if (is(T == Vector!2))
			glUniform2f(location, v.x, v.y);
		else static if (is(T == Vector!3))
			glUniform3f(location, v.x, v.y, v.z);
		else static if (is(T == Quaternion))
			glUniform4f(location, v.x, v.y, v.z, v.w);
		else static if (is(T == Matrix!(float,3,3)))
		{
			const(float*) ptr = v.ptr;
			glUniformMatrix3fv(location, 1, false, ptr);
		}
		else
			static assert(0, "Unsupported argument type: " ~ T.stringof);
		checkForGlError();
	}

	void setUniform(T)(string name, T value)
	{
		uint loc = glGetUniformLocation(_program, toStringz(name));
		return setUniform(loc, value);
	}

	void setView(bool inverted, T)(Window window, Vector!3 position, T rotation)
	if (is(T == Quaternion) || is(T == Matrix!(float,3,3)))
	{
		setUniform("screen_ratio", cast(float)window.width / window.height);
		setUniform("cam_pos", position);
		static if (is(T == Quaternion))
			auto m = rotation.matrix!float;
		else
			auto m = rotation;
		static if (!inverted)
			m = m.inverse;
		setUniform("cam_rot", m);
	}

	void use()
	{
		glUseProgram(_program);
		checkForGlError();
	}
}
