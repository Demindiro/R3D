module r3d.graphics.libpng.png;

enum versionString = "1.6.36";

enum Fp
{
	one  = 100000,
	half = 50000,
	max  = 0x7fffffffL,
	min  = -max,
}

enum ColorMask
{
	palette = 1,
	color   = 2,
	alpha   = 4,
}

enum ColorType
{
	gray      = 0,
	palette   = ColorMask.color | ColorMask.palette,
	rgb       = ColorMask.color,
	rgba      = ColorMask.color | ColorMask.alpha,
	grayAlpha = ColorMask.alpha,
}

enum CompressionType
{
	dunno_lol
}

struct PngPtr  { void* ptr; }
struct JmpBuf  { void* ptr; }
struct InfoPtr { void* ptr; }

// ?
alias ErrorPtr = void*;
// I have a feeling this should NOT be used.
alias LongJmpPtr = void*;

extern (C)
{
	// Dunno
	const(char*) png_get_header_ver();
	bool png_sig_cmp(char* header, size_t offset, size_t count);

	// Struct things?
	PngPtr  png_create_read_struct (const(char*) vers, void* errorPtr,
	                                ErrorPtr errorFunc, ErrorPtr warnFunc,
	                                size_t uh = '?');
	PngPtr  png_create_write_struct(const(char*) vers, void* errorPtr,
	                                ErrorPtr errorFunc, ErrorPtr warnFunc,
	                                size_t uhmmm = '?');
	InfoPtr png_create_info_struct (PngPtr ptr);

	// Compression!
	size_t png_get_compression_buffer_size(const(PngPtr) ptr);
	void   png_set_compression_buffer_size(const(PngPtr) ptr, size_t size);

	// Longjumps (don't use these, please)
	JmpBuf png_set_longjmp_fn(PngPtr ptr, LongJmpPtr longJumpFunc, size_t jmpBufSize);
	void   png_longjmp(PngPtr ptr, int val);

	// Uhmm...
	int    png_reset_zstream(PngPtr ptr);
}
