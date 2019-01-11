module graphics.window;

import std.container;
import std.conv;
import std.exception;
import std.file;
import std.stdio;
import std.string;
import graphics.exceptions;
import graphics.gl.glfw;
import graphics.gl.gl;
import graphics : initialized;
import core.vector;


// Classes
class Window
{
	private GLFWwindow _window;
	private int _width, _height;
	private string _title;
	version (OSX) ubyte _osx_fixed = 0;
	private bool _closed = false;

	this(int width, int height, string title)
	{
		_width  = width;
		_height = height;
		_title  = title;
		_window = glfwCreateWindow(width, height, title.ptr, null, null);
		if (!_window)
			throw new GraphicsException();
		glfwMakeContextCurrent(_window);

		glEnable(GL_DEPTH_TEST);
		glEnable(GL_MULTISAMPLE);
		glDepthFunc(GL_LESS);
	}

	@nogc
	~this()
	{
		close();
	}

	@property uint width () { return _width;  }
	@property uint height() { return _height; }
	@property string title () { return _title;  }

	@property string title (string newTitle) 
	{
		_title = newTitle;
		glfwSetWindowTitle(_window, toStringz(newTitle));
		return newTitle;
	}

	@property bool shouldClose()
	{
		return glfwWindowShouldClose(_window);
	}

	void clear()
	{
		glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
	}

	@nogc
	void close()
	{
		if (!_closed)
			glfwDestroyWindow(_window);
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
