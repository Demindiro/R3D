module graphics.mesh;

import std.container;
import std.conv;
import std.exception;
import std.file;
import std.stdio;
import std.string;
import graphics.gl.gl;
import graphics.exceptions;
import core.vector;
import core.quaternion;


class Mesh
{
	private Buffer _vbo_geometric;
	private Buffer _vbo_texture;
	private Buffer _vbo_normal;
	//private VertexArray _vao_geometric;
	//private VertexArray _vao_texture;
	//private VertexArray _vao_normal;
	private VertexArray _vao;
	private uint _vec_count;

private this(Array!float geom_verts, Array!float text_verts,
	             Array!float norm_verts)
	{
		assert(geom_verts.length == norm_verts.length);
		assert(geom_verts.length == text_verts.length);
		if (geom_verts.length == 0)
			throw new CorruptFileException("No polygons");
		_vec_count = cast(uint)geom_verts.length / 3;

		void initBuffer(Buffer b, Array!float a)
		{
			glBindBuffer(GL_ARRAY_BUFFER, b);
			if (glGetError())
				throw new GraphicsException();
			glBufferData(GL_ARRAY_BUFFER, a.length * a[0].sizeof, &a[0],
			             GL_STATIC_DRAW);
			if (glGetError())
				throw new GraphicsException();
		}

		void initVertexArray(VertexArray a, Buffer b, uint index)
		{
			glBindVertexArray(a);
			if (glGetError())
				throw new GraphicsException();
			glEnableVertexAttribArray(index);
			if (glGetError())
				throw new GraphicsException();
			glBindBuffer(GL_ARRAY_BUFFER, b);
			if (glGetError())
				throw new GraphicsException();
			glVertexAttribPointer(index, 3, GL_FLOAT, false, 0, null);
			if (glGetError())
				throw new GraphicsException();
		}

		// Buffers
		Buffer[3] vbos;
		glGenBuffers(3, vbos.ptr);
		if (glGetError())
			throw new GraphicsException();
		_vbo_geometric = vbos[0];
		_vbo_texture   = vbos[1];
		_vbo_normal    = vbos[2];
		initBuffer(_vbo_geometric, geom_verts);
		initBuffer(_vbo_texture  , text_verts);
		initBuffer(_vbo_normal   , norm_verts);

		// Arrays
		//VertexArray[3] vaos;
		glGenVertexArrays(1, &_vao);
		if (glGetError())
			throw new GraphicsException();
		//_vao_geometric = vaos[0];
		//_vao_texture   = vaos[1];
		//_vao_normal    = vaos[2];
		initVertexArray(_vao/*_geometric*/, _vbo_geometric, 0);
		initVertexArray(_vao/*_texture  */, _vbo_texture  , 1);
		initVertexArray(_vao/*_normal   */, _vbo_normal   , 2);
	}

	@nogc
	~this()
	{
		Buffer[3]      vbos = [_vbo_geometric, _vbo_texture, _vbo_normal];
		glDeleteBuffers(3, vbos.ptr);
	}

	static Mesh fromFile(string path)
	{
		auto file  = File(path);
		auto geomv = Array!(float[3])();
		auto textv = Array!(float[3])();
		auto normv = Array!(float[3])();
		auto spacv = Array!(float[3])();
		auto faces_geomv = Array!float();
		auto faces_textv = Array!float();
		auto faces_normv = Array!float();
		auto lines = Array!(float[])();
		foreach (line ; file.byLine)
		{
			line = line.strip();
			if (line == "" || line[0] == '#')
				continue;
			auto args = line.split();
			auto type = args[0];
			writeln(args);
			if (type == "v")
			{
				auto a = args[1 .. 4].to!(float[3]);
				geomv.insert(a);
			}
			else if (type == "vt")
			{
				auto a = args[1 .. 4].to!(float[3]);
				textv.insert(a);
			}
			else if (type == "vn")
			{
				auto a = args[1 .. 4].to!(float[3]);
				normv.insert(a);
			}
			else if (type == "vp")
			{
				auto a = args[1 .. 4].to!(float[3]);
				spacv.insert(a);
			}
			else if (type == "f")
			{
				if (args.length > 4)
					throw new GraphicsException("Not implemented");
				if (args.length < 4)
					throw new CorruptFileException("A polygon must have at least 3 vertices");
				float[9] v;
				float[9] vt;
				float[9] vn;
				foreach (i, e ; args[1 .. $])
				{
					i *= 3;
					auto a = e.split("/");
					if (a.length > 0 && a[0] != "")
						v [i .. i + 3] = geomv[a[0].to!uint - 1][];
					if (a.length > 1 && a[1] != "")
						vt[i .. i + 3] = textv[a[1].to!uint - 1][];
					if (a.length > 2 && a[2] != "")
						vn[i .. i + 3] = normv[a[2].to!uint - 1][];
				}
				faces_geomv.insert(v[]);
				faces_textv.insert(vt[]);
				faces_normv.insert(vn[]);
			}
			else if (type == "l")
			{
				throw new CorruptFileException(
					to!string("Invalid type: " ~ type));
			}
		}
		return new Mesh(faces_geomv, faces_textv, faces_normv);
	}

	void draw(Vector3 position, Quaternion rotation, Vector3 scale)
	{
		//glBindVertexArray(_vao_geometric);
		//glBindVertexArray(_vao_texture  );
		//glBindVertexArray(_vao_normal   );
		glBindVertexArray(_vao);
		glDrawArrays(GL_TRIANGLES, 0, _vec_count);
	}
}


class MeshBatch
{
	private Mesh _mesh;

	this(Mesh mesh)
	{
		_mesh = mesh;
	}

	void draw()
	{

	}
}
