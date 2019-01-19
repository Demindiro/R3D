module r3d.graphics.opengl.gl;

/*
Constants
*/
enum GL_DEPTH_BUFFER_BIT = 0x00000100;
enum GL_COLOR_BUFFER_BIT = 0x00004000;

enum GL_TRIANGLES        = 0x0004;

enum GL_LESS             = 0x0201;

enum GL_SRC_ALPHA        = 0x0302;
enum GL_ONE_MINUS_SRC_ALPHA = 0x0303;

enum GL_BLEND            = 0x0BE2;
enum GL_DEPTH_TEST       = 0x0B71;

enum GL_TEXTURE_1D       = 0x0DE0;
enum GL_TEXTURE_2D       = 0x0DE1;

enum GL_FLOAT            = 0x1406;

enum GL_MODELVIEW        = 0x1700;
enum GL_PROJECTION       = 0x1701;

enum GL_RENDERER         = 0x1F01;
enum GL_VERSION          = 0x1F02;

enum GL_MULTISAMPLE      = 0x809D;

enum GL_ARRAY_BUFFER     = 0x8892;
enum GL_STATIC_DRAW      = 0x88E4;
enum GL_DYNAMIC_DRAW     = 0x88E8;

enum GL_FRAGMENT_SHADER  = 0x8B30;
enum GL_VERTEX_SHADER    = 0x8B31;

enum GL_COMPILE_STATUS   = 0x8B81;
enum GL_LINK_STATUS      = 0x8B82;

// Textures
enum GL_REPEAT           = 0x2901;
enum GL_MIRRORED_REPEAT  = 0x8370;
enum GL_CLAMP_TO_EDGE    = 0x812F;
enum GL_CLAMP_TO_BORDER  = 0x812D;
enum GL_TEXTURE_WRAP_S       = 0x2802;
enum GL_TEXTURE_WRAP_T       = 0x2803;
enum GL_TEXTURE_BORDER_COLOR = 0x1004;
enum GL_NEAREST = 0x2600;
enum GL_LINEAR  = 0x2601;
enum GL_NEAREST_MIPMAP_NEAREST = 0x2700;
enum GL_LINEAR_MIPMAP_NEAREST  = 0x2701;
enum GL_NEAREST_MIPMAP_LINEAR  = 0x2702;
enum GL_LINEAR_MIPMAP_LINEAR   = 0x2703;
enum GL_TEXTURE_MAG_FILTER = 0x2800;
enum GL_TEXTURE_MIN_FILTER = 0x2801;

enum Error
{
	none                        = 0,
	invalidEnum                 = 0x0500,
	invalidValue                = 0x0501,
	invalidOperation            = 0x0502,
	outOfMemory                 = 0x0505,
	invalidFramebufferOperation = 0x0506,
}


/*
"Classes"
*/
struct Shader      { private uint _; T opCast(T)() { return cast(T)_; } }
struct Program     { private uint _; T opCast(T)() { return cast(T)_; } }
struct Buffer      { private uint _; T opCast(T)() { return cast(T)_; } }
struct VertexArray { private uint _; T opCast(T)() { return cast(T)_; } }
struct Texture     { private uint _; T opCast(T)() { return cast(T)_; } }


/*
C API
*/
extern (C)
{
	// Dunno
	@nogc void glClear(uint flags);
	@nogc void glClearColor(float red, float green, float blue, float alpha);
	@nogc void glEnable(uint flag);
	@nogc void glDisable(uint flag);
	@nogc void glDepthFunc(uint flag);
	@nogc void glBlendFunc(uint sfactor, uint dfactor);
	@nogc const(char*) glGetString(uint name);
	@nogc Error glGetError();
	@nogc void glFinish();

	// Parts of the old OpenGL API I think?
	@nogc void glViewport(float x, float y, float width, float height);
	@nogc void glMatrixMode(uint mode);
	@nogc void glLoadIdentity();
	@nogc void glOrtho(double left, double right, double bottom, double top,
	                   double nearval, double farval);
	@nogc void glFrustum(double left, double right, double bottom, double top,
	                     double nearval, double farval);

	// Shaders
	@nogc Shader glCreateShader(uint flag);
	@nogc void glShaderSource(Shader shader, uint count, const(char**) strings,
		                      const(uint*) lengths);
	@nogc void glCompileShader(Shader shader);
	@nogc void glGetShaderiv(Shader shader, uint pname, int* params);
	@nogc void glGetShaderInfoLog(Shader shader, size_t maxlen, size_t *len,
	                              char *log);

	// Programmes
	@nogc Program glCreateProgram();
	@nogc void glAttachShader(Program program, Shader shader);
	@nogc void glLinkProgram(Program program);
	@nogc void glUseProgram(Program program);
	@nogc void glGetProgramiv(Program program, uint pname, int *params);
	@nogc void glGetProgramInfoLog(Program program, size_t maxLength, size_t *length,
	                               char *log);
	@nogc void glDeleteProgram(Program program);

	// Uniforms
	@nogc void glUniform1f(int location, float v0);
	@nogc void glUniform2f(int location, float v0, float v1);
	@nogc void glUniform3f(int location, float v0, float v1, float v2);
	@nogc void glUniform4f(int location, float v0, float v1, float v2, float v3);
	@nogc void glUniform1i(int location, int v0);
	@nogc void glUniform2i(int location, int v0, int v1);
	@nogc void glUniform3i(int location, int v0, int v1, int v2);
	@nogc void glUniform4i(int location, int v0, int v1, int v2, int v3);
	@nogc void glUniform1ui(int location, uint v0);
	@nogc void glUniform2ui(int location, uint v0, uint v1);
	@nogc void glUniform3ui(int location, uint v0, uint v1, uint v2);
	@nogc void glUniform4ui(int location, uint v0, uint v1, uint v2, uint v3);
	@nogc void glUniform1fv(int location, size_t count, const(float*) value);
	@nogc void glUniform2fv(int location, size_t count, const(float*) value);
	@nogc void glUniform3fv(int location, size_t count, const(float*) value);
	@nogc void glUniform4fv(int location, size_t count, const(float*) value);
	@nogc void glUniform1iv(int location, size_t count, const(int*) value);
	@nogc void glUniform2iv(int location, size_t count, const(int*) value);
	@nogc void glUniform3iv(int location, size_t count, const(int*) value);
	@nogc void glUniform4iv(int location, size_t count, const(int*) value);
	@nogc void glUniform1uiv(int location, size_t count, const(uint*) value);
	@nogc void glUniform2uiv(int location, size_t count, const(uint*) value);
	@nogc void glUniform3uiv(int location, size_t count, const(uint*) value);
	@nogc void glUniform4uiv(int location, size_t count, const(uint*) value);
	@nogc void glUniformMatrix2fv(int location, size_t count, bool transpose,
	                              const(float*) value);
	@nogc void glUniformMatrix3fv(int location, size_t count, bool transpose,
                                  const(float*) value);
	@nogc void glUniformMatrix4fv(int location, size_t count, bool transpose,
                                  const(float*) value);
	@nogc void glUniformMatrix2x3fv(int location, size_t count, bool transpose,
                                    const(float*) value);
	@nogc void glUniformMatrix3x2fv(int location, size_t count, bool transpose,
                                    const(float*) value);
	@nogc void glUniformMatrix2x4fv(int location, size_t count, bool transpose,
                                    const(float*) value);
	@nogc void glUniformMatrix4x2fv(int location, size_t count, bool transpose,
                                    const(float*) value);
	@nogc void glUniformMatrix3x4fv(int location, size_t count, bool transpose,
                                    const(float*) value);
	@nogc void glUniformMatrix4x3fv(int location, size_t count, bool transpose,
	                                const(float*) value);
	@nogc int glGetUniformLocation(Program program, const(char*) name);

	// Buffers
	@nogc void glGenBuffers(uint count, Buffer *buffers);
	@nogc void glBindBuffer(uint type,  Buffer  buffer);
	@nogc void glBufferData(uint target, size_t size, const void* ptr, uint usage);
	@nogc void glDeleteBuffers(uint count, Buffer *buffers);

	// Vertex arrays
	@nogc void glGenVertexArrays(uint count, VertexArray *buffers);
	@nogc void glBindVertexArray(VertexArray buffer);
	@nogc void glEnableVertexAttribArray(uint index);
	@nogc void glVertexAttribPointer(uint index, int size, uint type,
	                                 bool normalized, size_t stride, size_t offset);
	@nogc void glVertexAttribDivisor(uint index, uint divisor);
	@nogc void glDeleteVertexArrays(uint count, VertexArray *buffers);

	// Textures
	@nogc void glGenTextures(size_t count, Texture *textures);
	@nogc void glBindTexture(uint target, Texture texture);
	@nogc void glTexParameterf(uint target, uint pname, float param);
	@nogc void glTexParameteri(uint target, uint pname, int param);
	@nogc void glTexParameterfv(uint target, uint pname, const(float*) params);
	@nogc void glTexParameteriv(uint target, uint pname, const(int*) params);

	// Rendering
	@nogc void glDrawArrays(uint mode, int first, size_t count);
	@nogc void glDrawArraysInstanced(uint mode, int first, size_t count,
	                                 size_t primcount);
}
