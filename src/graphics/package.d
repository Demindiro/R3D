module graphics;

public import graphics.exceptions;
public import graphics.mesh;
public import graphics.window;
public import graphics.shader;
public import graphics.program;

import std.conv : to;
import graphics.gl.glfw;
import graphics.gl.gl : glGetString, GL_RENDERER, GL_VERSION;


// Globals
private shared bool initialized = false;

package void delegate(int error, const(char*) description) error_handler;
package int    error_code;
package string error_description;


// Functions
void init() {
	if (initialized)
		throw new GraphicsException("Already intialized");
	glfwSetErrorCallback(&glfwCallback);
	if (!glfwInit())
		throw new GraphicsException("Could not initialize GLFW");

	glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, 3);
	glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR, 2);
	glfwWindowHint(GLFW_OPENGL_FORWARD_COMPAT, true);
	glfwWindowHint(GLFW_OPENGL_PROFILE, GLFW_OPENGL_CORE_PROFILE);
	glfwWindowHint(GLFW_SAMPLES, 4);

	initialized = true;
}

/*
void terminate()
{
	if (!initialized)
		throw new GraphicsException("Not intialized");
	glfwTerminate();
	initialized = false;
}
*/

@property string renderer()
{
	return "GPU: "    ~ glGetString(GL_RENDERER).to!string ~
	       " | " ~
	       "OpenGL: " ~ glGetString(GL_VERSION ).to!string;
}


// Callbacks
extern (C) private void glfwCallback(int code, const(char*) description)
{
	error_code = code;
	error_description = to!string(description);
}
