module r3d.graphics.window;

import std.container;
import std.conv;
import std.exception;
import std.file;
import std.stdio;
import std.string;
import r3d.core.vector;
import r3d.graphics : checkForGlError, initialized;
import r3d.graphics.exceptions;
import r3d.graphics.opengl.glfw;
import r3d.graphics.opengl.glfw : GLFWwindow = Window;
import r3d.graphics.opengl.gl;
import r3d.input.keyboard;

// Globals
private Window[GLFWwindow] _windows;

// Callbacks
private extern (C) void keyCallback(GLFWwindow window, KeyCode key, int scancode,
                                    KeyAction action, int mods)
{
	_windows[window]._keyCallback(key, action);
}

private extern (C) void cursorPosCallback(GLFWwindow window, double x, double y)
{
	_windows[window]._cursorPosCallback(x, y);
}

private extern (C) void cursorEnterCallback(GLFWwindow window, bool entered)
{
	_windows[window]._cursorEnterCallback(entered);
}


// Classes
class Window
{
	private GLFWwindow     _window;
	private int            _width, _height;
	private string         _title;
	private bool           _closed        = false;
	private KeyAction[512] _keyActions;
	private Vector!2       _cursorPos     = Vector!2(0, 0);
	private bool           _cursorEntered = false;
	version (OSX) private ubyte _osx_fixed = 0;

	this(int width, int height, string title)
	{
		_width  = width;
		_height = height;
		_title  = title;
		_window = glfwCreateWindow(width, height, title.ptr, null, null);
		if (!_window)
			throw new GraphicsException();

		glfwMakeContextCurrent(_window);
		glfwSetKeyCallback(_window, &keyCallback);
		glfwSetCursorPosCallback(_window, &cursorPosCallback);
		glfwSetCursorEnterCallback(_window, &cursorEnterCallback);

		//glEnable(GL_BLEND);
		glEnable(GL_DEPTH_TEST);
		glEnable(GL_MULTISAMPLE);
		glDepthFunc(GL_LESS);
		//glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
		checkForGlError();

		_windows[_window] = this;
	}

	~this()
	{
		if (initialized)
			close();
	}

	private void _updateDimensions()
	{
		glfwGetWindowSize(_window, &_width, &_height);
	}

	private void _keyCallback(KeyCode key, KeyAction action)
	{
		_keyActions[key] = action;
	}

	private void _cursorPosCallback(double x, double y)
	{
		_cursorPos = Vector2(x, y);
	}

	private void _cursorEnterCallback(bool entered)
	{
		_cursorEntered = entered;
	}

	uint   width () { _updateDimensions(); return _width;  }
	uint   height() { _updateDimensions(); return _height; }
	string title () { return _title;  }
	bool   closed() { return _closed; }

	string title (string newTitle) 
	{
		_title = newTitle;
		glfwSetWindowTitle(_window, toStringz(newTitle));
		return newTitle;
	}

	bool shouldClose()
	{
		return glfwWindowShouldClose(_window);
	}

	KeyAction keyAction(KeyCode key)
	{
		return _keyActions[key];
	}

	Vector2 cursorPos()
	{
		return _cursorPos;
	}

	bool cursorEntered()
	{
		return _cursorEntered;
	}

	void clear()
	{
		glClearColor(0,0,0,0);
		glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
		checkForGlError();
	}

	void close()
	{
		if (!_closed)
			glfwDestroyWindow(_window);
		_windows[_window] = null;
		_closed = true;
	}

	void swapBuffers()
	{
		glfwSwapBuffers(_window);

		version(OSX)
		{
			// BUG OpenGL on OS X doesn't render unless the window
			// is resized or moved at some point after startup
			if (_osx_fixed < 2) {
				int x, y;
				glfwGetWindowPos(_window, &x, &y);
				glfwSetWindowPos(_window,  x+1,y);
				glfwSetWindowPos(_window,  x,  y);
				_osx_fixed++;
			}
		}
	}

	void poll()
	{
		glfwPollEvents();
	}
}
