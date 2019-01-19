module r3d.graphics;

public import r3d.graphics.exceptions;
public import r3d.graphics.mesh;
public import r3d.graphics.program;
public import r3d.graphics.shader;
public import r3d.graphics.texture;
public import r3d.graphics.window;

import std.conv : to;
import r3d.graphics.opengl.glfw;
import r3d.graphics.opengl.gl : glGetString, GL_RENDERER, GL_VERSION, glGetError;


// Globals
package shared bool initialized = false;

package void delegate(int error, const(char*) description) error_handler;
package int    error_code;
package string error_description;


shared static this() {
	if (initialized)
		throw new GraphicsException("Already intialized");
	glfwSetErrorCallback(&glfwCallback);
	if (!glfwInit())
		throw new GraphicsException("Could not initialize GLFW");

	int maj, min, rev;
	glfwGetVersion(&maj, &min, &rev);
	import std.stdio;
	writefln("GLFW version %d.%d.%d", maj, min, rev);

	glfwWindowHint(Hint.contextVersionMajor, 3);
	glfwWindowHint(Hint.contextVersionMinor, 2);
	glfwWindowHint(Hint.openGlForwardCompat, true);
	glfwWindowHint(Hint.openGlProfile, Hint.openGlCoreProfile);
	glfwWindowHint(Hint.samples, 4);
	glfwWindowHint(Hint.transparentFramebuffer, true);

	initialized = true;
}

shared static ~this()
{
	if (!initialized)
		throw new GraphicsException("Not intialized");
	glfwTerminate();
	initialized = false;
}


@property string renderer()
{
	return "GPU: "    ~ glGetString(GL_RENDERER).to!string ~
	       " | " ~
	       "OpenGL: " ~ glGetString(GL_VERSION ).to!string;
}


void checkForGlError()
{
	//auto err = glGetError();
	//if (err)
	//	throw new GlException(err, __FILE__, __LINE__);
}


// Callbacks
extern (C) private void glfwCallback(int code, const(char*) description)
{
	error_code = code;
	error_description = to!string(description);
	import std.stdio;
	writeln(error_description);
}
