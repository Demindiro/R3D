module r3d.graphics.texture;

import imageformats : IFImage, readImage = read_image;
import r3d.core.matrix;
import r3d.core.vector;
import r3d.core.quaternion;
import r3d.graphics : checkForGlError;
import r3d.graphics.opengl.gl;
import r3d.graphics.opengl.gl : GLTexture = Texture;
import r3d.graphics.shader : VertexShader, FragmentShader, GeometryShader, Shader;
import r3d.graphics.program : Program;
import r3d.graphics.window : Window;


final class Texture
{
	private GLTexture _texture;
	private IFImage _image;

	this(string file)
	{
		_image = readImage(file);
		glGenTextures(1, &_texture);
	}

	~this()
	{
	}
}

final class CubeMap
{
	private GLTexture  _texture;
	private IFImage[6] _images;
	private enum _sides = [ GL_TEXTURE_CUBE_MAP_POSITIVE_X,
	                        GL_TEXTURE_CUBE_MAP_NEGATIVE_X,
	                        GL_TEXTURE_CUBE_MAP_POSITIVE_Y,
	                        GL_TEXTURE_CUBE_MAP_NEGATIVE_Y,
	                        GL_TEXTURE_CUBE_MAP_POSITIVE_Z,
							GL_TEXTURE_CUBE_MAP_NEGATIVE_Z ];

	this(string up   , string down,
	     string right, string left,
		 string front, string back)
	{
		foreach (i, f; [ right, left, up, down, front, back ])
			_images[i] = readImage(f);
		glGenTextures(1, &_texture);
		glBindTexture(GL_TEXTURE_CUBE_MAP, _texture);
		foreach (i, e; _images)
		{
			glTexImage2D(_sides[i], 0, GL_RGB, e.w, e.h, 0, GL_RGB,
			             GL_UNSIGNED_BYTE, e.pixels.ptr);
		}
		glTexParameteri(GL_TEXTURE_CUBE_MAP, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
		glTexParameteri(GL_TEXTURE_CUBE_MAP, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
		glTexParameteri(GL_TEXTURE_CUBE_MAP, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
		glTexParameteri(GL_TEXTURE_CUBE_MAP, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
		glTexParameteri(GL_TEXTURE_CUBE_MAP, GL_TEXTURE_WRAP_R, GL_CLAMP_TO_EDGE);
		checkForGlError;
	}

	void bind()
	{
		glBindTexture(GL_TEXTURE_CUBE_MAP, _texture);
	}
}


final class Skybox
{
	private CubeMap     _map;
	private Program     _program;
	private Buffer      _vbo;
	private VertexArray _vao;
	private Shader      _vert, _frag;

	this(string up   , string down,
	     string right, string left,
	     string front, string back,
	     string vert , string frag)
	{
		import std.file;
		_map     = new CubeMap(up, down, right, left, front, back);
		_vert    = new VertexShader(readText(vert));
		_frag    = new FragmentShader(readText(frag));
		_program = new Program;

		_program.attach(_vert);
		_program.attach(_frag);
		_program.link;

		// Create the cube
		float[] points = [
			-1,  1, -1,
			-1, -1, -1,
			 1, -1, -1,
			 1, -1, -1,
			 1,  1, -1,
			-1,  1, -1,

			-1, -1,  1,
			-1, -1, -1,
			-1,  1, -1,
			-1,  1, -1,
			-1,  1,  1,
			-1, -1,  1,

			 1, -1, -1,
			 1, -1,  1,
			 1,  1,  1,
			 1,  1,  1,
			 1,  1, -1,
			 1, -1, -1,

			-1, -1,  1,
			-1,  1,  1,
			 1,  1,  1,
			 1,  1,  1,
			 1, -1,  1,
			-1, -1,  1,

			-1,  1, -1,
			 1,  1, -1,
			 1,  1,  1,
			 1,  1,  1,
			-1,  1,  1,
			-1,  1, -1,

			-1, -1, -1,
			-1, -1,  1,
			 1, -1, -1,
			 1, -1, -1,
			-1, -1,  1,
			 1, -1,  1,
		];
		glGenBuffers(1, &_vbo);
		glGenVertexArrays(1, &_vao);
		glBindBuffer(GL_ARRAY_BUFFER, _vbo);
		glBufferData(GL_ARRAY_BUFFER, points.length * 4, points.ptr, GL_STATIC_DRAW);
		glBindVertexArray(_vao);
		glVertexAttribPointer(0, 3, GL_FLOAT, false, 0, 0);
		glEnableVertexAttribArray(0);
		checkForGlError;
	}

	void use()
	{
		_program.use;
	}

	void draw()
	{
		glDepthMask(false);
		_map.bind;
		glBindVertexArray(_vao);
		glDrawArrays(GL_TRIANGLES, 0, 6 * 2 * 3);
		glDepthMask(true);
		checkForGlError;
	}

	void setView(bool inverted, T)(Window window, T orientation)
	{
		// Dunno why I have to invert it twice (or not at all)
		_program.setView!(!inverted)(window, Vector!3(0,0,0), orientation);
	}
}
