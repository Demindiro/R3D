module r3d.graphics.gl.glfw;


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


// Aliases
struct Window { void* _; T opCast(T)() { return cast(T)_; } }
extern (C) alias GLFWerrorfun = void function(int code, const(char*) description);


// Init
@nogc extern (C): GLFWerrorfun glfwSetErrorCallback(GLFWerrorfun cbfun);
@nogc extern (C): bool glfwInit();

// Windows
@nogc extern (C): Window glfwCreateWindow(int width, int height, const(char*) title,
                                          void* dunno, void* dunnoEither);
@nogc extern (C): void glfwWindowHint(Hint hint, int value);
@nogc extern (C): bool glfwWindowShouldClose(Window window);
@nogc extern (C): void glfwGetWindowPos(Window window, int* x, int* y);
@nogc extern (C): void glfwSetWindowPos(Window window, int  x, int  y);
@nogc extern (C): void glfwGetWindowSize(Window window, int* x, int* y);
@nogc extern (C): void glfwSetWindowSize(Window window, int  x, int  y);
@nogc extern (C): void glfwSetWindowTitle(Window window, const(char*) ptr);
@nogc extern (C): float glfwGetWindowOpacity(Window window);
@nogc extern (C): void glfwSetWindowOpacity(Window window, float opacity);
@nogc extern (C): void glfwDestroyWindow(Window window);

// Other
@nogc extern (C): void glfwGetVersion(int* major, int* minor, int* revision);
@nogc extern (C): void glfwMakeContextCurrent(Window window);
@nogc extern (C): void glfwSwapBuffers(Window);
@nogc extern (C): void glfwPollEvents();
@nogc extern (C): void glfwTerminate();
@nogc extern (C): double glfwGetTime();
@nogc extern (C): void glfwSwapInterval(int interval);
