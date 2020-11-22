module r3d.graphics.opengl.glfw;

import r3d.input.keyboard;

// Constants
enum Hint
{
	transparentFramebuffer = 0x0002000A,
	samples                = 0x0002100D,
	contextVersionMajor    = 0x00022002,
	contextVersionMinor    = 0x00022003,
	openGlForwardCompat    = 0x00022006,
	openGlProfile          = 0x00022008,
	openGlCoreProfile      = 0x00032001,
}

enum InputMode
{
	cursor             = 0x00033001,
	stickyKeys         = 0x00033002,
	stickyCursorButtons = 0x00033003,
}

enum CursorMode
{
	normal   = 0x00034001,
	hidden   = 0x00034002,
	disabled = 0x00034003,
}


// Aliases
struct Window { void* _; T opCast(T)() { return cast(T)_; } }
extern (C) alias ErrorFun = void function(int code, const(char*) description);
extern (C) alias KeyFun = void function(Window window, KeyCode key, int scancode,
                                        KeyAction action, int mods);
extern (C) alias CursorPosFun = void function(Window window, double x, double y);
extern (C) alias CursorEnterFun = void function(Window window, bool entered);


// Init
@nogc extern (C): ErrorFun glfwSetErrorCallback(ErrorFun callback);
@nogc extern (C): bool glfwInit();

// Windows
@nogc extern (C): Window glfwCreateWindow(int width, int height, const(char*) title,
                                          void* dunno, void* dunnoEither);
@nogc extern (C): void   glfwDestroyWindow     (Window window);
@nogc extern (C): void   glfwGetWindowPos      (Window window, int* x, int* y);
@nogc extern (C): void   glfwGetWindowSize     (Window window, int* x, int* y);
@nogc extern (C): float  glfwGetWindowOpacity  (Window window);
@nogc extern (C): void   glfwSetWindowPos      (Window window, int  x, int  y);
@nogc extern (C): void   glfwSetWindowSize     (Window window, int  x, int  y);
@nogc extern (C): void   glfwSetWindowTitle    (Window window, const(char*) ptr);
@nogc extern (C): void   glfwSetWindowOpacity  (Window window, float opacity);
@nogc extern (C): void   glfwMakeContextCurrent(Window window);
@nogc extern (C): void   glfwSwapBuffers       (Window);
@nogc extern (C): void   glfwWindowHint        (Hint hint, int value);
@nogc extern (C): bool   glfwWindowShouldClose (Window window);

// Input
@nogc extern (C): void glfwSetKeyCallback      (Window window,       KeyFun callback);
@nogc extern (C): void glfwSetCursorPosCallback(Window window, CursorPosFun callback);
@nogc extern (C): void glfwSetCursorEnterCallback(Window window, CursorEnterFun callback);
@nogc extern (C): void glfwSetInputMode(Window window, InputMode mode,
                                        CursorMode value);
// How did this compile before?
//@nogc extern (C): void glfwSetInputMode(Window window, InputMode mode, bool value);
@nogc extern (C): void glfwSetInputMode(Window window, InputMode mode, int value);


// Other
@nogc extern (C): void glfwGetVersion(int* major, int* minor, int* revision);
@nogc extern (C): void glfwPollEvents();
@nogc extern (C): void glfwTerminate();
@nogc extern (C): double glfwGetTime();
@nogc extern (C): void glfwSwapInterval(int interval);
