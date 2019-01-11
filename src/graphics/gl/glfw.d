module graphics.gl.glfw;


// Constants
const uint GLFW_CONTEXT_VERSION_MAJOR = 0x00022002;
const uint GLFW_CONTEXT_VERSION_MINOR = 0x00022003;
const uint GLFW_OPENGL_FORWARD_COMPAT = 0x00022006;
const uint GLFW_OPENGL_PROFILE        = 0x00022008;
const uint GLFW_OPENGL_CORE_PROFILE   = 0x00032001;
const uint GLFW_SAMPLES               = 0x0002100D;


// Aliases
struct GLFWwindow { void* _; T opCast(T)() { return cast(T)_; } }
extern (C) alias GLFWerrorfun = void function(int code, const(char*) description);


// Init
@nogc extern (C): GLFWerrorfun glfwSetErrorCallback(GLFWerrorfun cbfun);
@nogc extern (C): bool glfwInit();

// Windows
@nogc extern (C): GLFWwindow glfwCreateWindow(int width, int height, const(char*) title,
	void* dunno, void* dunnoEither);
@nogc extern (C): void glfwWindowHint(uint hint, int value);
@nogc extern (C): bool glfwWindowShouldClose(GLFWwindow window);
@nogc extern (C): void glfwGetWindowPos(GLFWwindow window, int *x, int *y);
@nogc extern (C): void glfwSetWindowPos(GLFWwindow window, int  x, int  y);
@nogc extern (C): void glfwDestroyWindow(GLFWwindow window);

// Other
@nogc extern (C): void glfwMakeContextCurrent(GLFWwindow window);
@nogc extern (C): void glfwSwapBuffers(GLFWwindow);
@nogc extern (C): void glfwPollEvents();
@nogc extern (C): void glfwTerminate();
@nogc extern (C): double glfwGetTime();
@nogc extern (C): void glfwSetWindowTitle(GLFWwindow window, const(char*) ptr);
