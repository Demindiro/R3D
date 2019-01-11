module graphics.gl.gl;

/*
Constants
*/
const uint GL_DEPTH_BUFFER_BIT = 0x00000100;
const uint GL_COLOR_BUFFER_BIT = 0x00004000;

const uint GL_TRIANGLES        = 0x0004;

const uint GL_DEPTH_TEST       = 0x0B71;
const uint GL_LESS             = 0x0201;

const uint GL_TEXTURE_1D       = 0x0DE0;
const uint GL_TEXTURE_2D       = 0x0DE1;

const uint GL_FLOAT            = 0x1406;

const uint GL_MODELVIEW        = 0x1700;
const uint GL_PROJECTION       = 0x1701;

const uint GL_RENDERER         = 0x1F01;
const uint GL_VERSION          = 0x1F02;

const uint GL_MULTISAMPLE      = 0x809D;

const uint GL_ARRAY_BUFFER     = 0x8892;
const uint GL_STATIC_DRAW      = 0x88E4;

const uint GL_FRAGMENT_SHADER  = 0x8B30;
const uint GL_VERTEX_SHADER    = 0x8B31;

const uint GL_COMPILE_STATUS   = 0x8B81;
const uint GL_LINK_STATUS      = 0x8B82;

// Textures
const uint GL_REPEAT           = 0x2901;
const uint GL_MIRRORED_REPEAT  = 0x8370;
const uint GL_CLAMP_TO_EDGE    = 0x812F;
const uint GL_CLAMP_TO_BORDER  = 0x812D;
const uint GL_TEXTURE_WRAP_S       = 0x2802;
const uint GL_TEXTURE_WRAP_T       = 0x2803;
const uint GL_TEXTURE_BORDER_COLOR = 0x1004;
const uint GL_NEAREST = 0x2600;
const uint GL_LINEAR  = 0x2601;
const uint GL_NEAREST_MIPMAP_NEAREST = 0x2700;
const uint GL_LINEAR_MIPMAP_NEAREST  = 0x2701;
const uint GL_NEAREST_MIPMAP_LINEAR  = 0x2702;
const uint GL_LINEAR_MIPMAP_LINEAR   = 0x2703;
const uint GL_TEXTURE_MAG_FILTER = 0x2800;
const uint GL_TEXTURE_MIN_FILTER = 0x2801;


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
// Dunno
@nogc extern (C): void glClear(uint flags);
@nogc extern (C): void glEnable(uint flag);
@nogc extern (C): void glDisable(uint flag);
@nogc extern (C): void glDepthFunc(uint flag);
@nogc extern (C): const(char*) glGetString(uint name);
@nogc extern (C): uint glGetError();

// Parts of the old OpenGL API I think?
@nogc extern (C): void glViewport(float x, float y, float width, float height);
@nogc extern (C): void glMatrixMode(uint mode);
@nogc extern (C): void glLoadIdentity();
@nogc extern (C): void glOrtho(double left, double right, double bottom,
	double top, double nearval, double farval);
@nogc extern (C): void glFrustum(double left, double right, double bottom,
	double top, double nearval, double farval);

// Shaders
@nogc extern (C): Shader glCreateShader(uint flag);
@nogc extern (C): void glShaderSource(Shader shader, uint count,
	const(char**) strings, const(uint*)lengths);
@nogc extern (C): void glCompileShader(Shader shader);
@nogc extern (C): void glGetShaderiv(Shader shader, uint pname, int* params);
@nogc extern (C): void glGetShaderInfoLog(Shader shader, size_t maxlen, size_t *len,
	char *log);

// Programmes
@nogc extern (C): Program glCreateProgram();
@nogc extern (C): void glAttachShader(Program program, Shader shader);
@nogc extern (C): void glLinkProgram(Program program);
@nogc extern (C): void glUseProgram(Program program);
@nogc extern (C): void glGetProgramiv(Program program, uint pname, int *params);
@nogc extern (C): void glGetProgramInfoLog(Program program, size_t maxLength,
	size_t *length, char *log);

// Shaders/Programs (uniform values)
@nogc extern (C): void glUniform1f(int location, float v0);
@nogc extern (C): void glUniform2f(int location, float v0, float v1);
@nogc extern (C): void glUniform3f(int location, float v0, float v1, float v2);
@nogc extern (C): void glUniform4f(int location, float v0, float v1, float v2, float v3);
@nogc extern (C): void glUniform1i(int location, int v0);
@nogc extern (C): void glUniform2i(int location, int v0, int v1);
@nogc extern (C): void glUniform3i(int location, int v0, int v1, int v2);
@nogc extern (C): void glUniform4i(int location, int v0, int v1, int v2, int v3);
@nogc extern (C): void glUniform1ui(int location, uint v0);
@nogc extern (C): void glUniform2ui(int location, uint v0, uint v1);
@nogc extern (C): void glUniform3ui(int location, uint v0, uint v1, uint v2);
@nogc extern (C): void glUniform4ui(int location, uint v0, uint v1, uint v2, uint v3);
@nogc extern (C): void glUniform1fv(int location, size_t count, const(float*) value);
@nogc extern (C): void glUniform2fv(int location, size_t count, const(float*) value);
@nogc extern (C): void glUniform3fv(int location, size_t count, const(float*) value);
@nogc extern (C): void glUniform4fv(int location, size_t count, const(float*) value);
@nogc extern (C): void glUniform1iv(int location, size_t count, const(int*) value);
@nogc extern (C): void glUniform2iv(int location, size_t count, const(int*) value);
@nogc extern (C): void glUniform3iv(int location, size_t count, const(int*) value);
@nogc extern (C): void glUniform4iv(int location, size_t count, const(int*) value);
@nogc extern (C): void glUniform1uiv(int location, size_t count, const(uint*) value);
@nogc extern (C): void glUniform2uiv(int location, size_t count, const(uint*) value);
@nogc extern (C): void glUniform3uiv(int location, size_t count, const(uint*) value);
@nogc extern (C): void glUniform4uiv(int location, size_t count, const(uint*) value);
@nogc extern (C): void glUniformMatrix2fv(int location, size_t count,
                                          bool transpose, const(float*) value);
@nogc extern (C): void glUniformMatrix3fv(int location, size_t count,
                                          bool transpose, const(float*) value);
@nogc extern (C): void glUniformMatrix4fv(int location, size_t count,
                                          bool transpose, const(float*) value);
@nogc extern (C): void glUniformMatrix2x3fv(int location, size_t count,
                                            bool transpose, const(float*) value);
@nogc extern (C): void glUniformMatrix3x2fv(int location, size_t count,
                                            bool transpose, const(float*) value); 
@nogc extern (C): void glUniformMatrix2x4fv(int location, size_t count,
                                            bool transpose, const(float*) value); 
@nogc extern (C): void glUniformMatrix4x2fv(int location, size_t count,
                                            bool transpose, const(float*) value);
@nogc extern (C): void glUniformMatrix3x4fv(int location, size_t count,
                                            bool transpose, const(float*) value);
@nogc extern (C): void glUniformMatrix4x3fv(int location, size_t count,
                                            bool transpose, const(float*) value); 

// Buffers
@nogc extern (C): void glGenBuffers(uint count, Buffer *buffers);
@nogc extern (C): void glBindBuffer(uint type,  Buffer  buffer);
@nogc extern (C): void glBufferData(uint target, size_t size, const void *ptr,
                                    uint usage);
@nogc extern (C): void glDeleteBuffers(uint count, Buffer *buffers);

// Vertex arrays
@nogc extern (C): void glGenVertexArrays(uint count, VertexArray *buffers);
@nogc extern (C): void glBindVertexArray(VertexArray buffer);
@nogc extern (C): void glEnableVertexAttribArray(uint index);
@nogc extern (C): void glVertexAttribPointer(uint index, int size, uint type,
                                             bool normalized, size_t stride,
                                             const void *ptr);
@nogc extern (C): void glDeleteVertexArrays(uint count, VertexArray *buffers);

// Textures
@nogc extern (C): void glGenTextures(size_t count, Texture *textures);
@nogc extern (C): void glBindTexture(uint target, Texture texture);
@nogc extern (C): void glTexParameterf(uint target, uint pname, float param);
@nogc extern (C): void glTexParameteri(uint target, uint pname, int param);
@nogc extern (C): void glTexParameterfv(uint target, uint pname,
                                        const(float*) params);
@nogc extern (C): void glTexParameteriv(uint target, uint pname,
                                        const(int*) params);

// Rendering
@nogc extern (C): void glDrawArrays(uint mode, int first, size_t count);
