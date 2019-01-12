module r3d.graphics.mesh;

import std.container;
import std.conv;
import std.exception;
import std.file;
import std.stdio;
import std.string;
import r3d.graphics : checkForGlError;
import r3d.graphics.opengl.gl;
import r3d.graphics.exceptions;
import r3d.core.vector;
import r3d.core.quaternion;


void setVertexBufferData(Buffer b, const(void*) ptr, size_t len)
{
	glBindBuffer(GL_ARRAY_BUFFER, b);
	checkForGlError();
	glBufferData(GL_ARRAY_BUFFER, len, ptr, GL_STATIC_DRAW);
	checkForGlError();
}


class Mesh
{
	private Buffer _vbo_geometric;
	private Buffer _vbo_texture;
	private Buffer _vbo_normal;
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

		// Buffers
		Buffer[3] vbos;
		glGenBuffers(3, vbos.ptr);
		checkForGlError();
		_vbo_geometric = vbos[0];
		_vbo_texture   = vbos[1];
		_vbo_normal    = vbos[2];
		size_t verts_size = geom_verts.length * geom_verts[0].sizeof;
		setVertexBufferData(_vbo_geometric, &geom_verts[0], verts_size);
		setVertexBufferData(_vbo_texture  , &text_verts[0], verts_size);
		setVertexBufferData(_vbo_normal   , &norm_verts[0], verts_size);

		// Arrays
		glGenVertexArrays(1, &_vao);
		checkForGlError();
		setVertexBuffer(_vbo_geometric, 0);
		setVertexBuffer(_vbo_texture  , 1);
		setVertexBuffer(_vbo_normal   , 2, true);
	}

	~this()
	{
		Buffer[3] vbos = [_vbo_geometric, _vbo_texture, _vbo_normal];
		glDeleteBuffers(3, vbos.ptr);
		checkForGlError();
		glDeleteVertexArrays(1, &_vao);
		checkForGlError();
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

	void setVertexBuffer(Buffer b, uint index, bool normalize = false,
	                     size_t stride = 0, size_t offset = 0)
	{
		glBindVertexArray(_vao);
		checkForGlError();
		glBindBuffer(GL_ARRAY_BUFFER, b);
		checkForGlError();
		glVertexAttribPointer(index, 3, GL_FLOAT, normalize, stride, offset);
		checkForGlError();
		glEnableVertexAttribArray(index);
		checkForGlError();
	}

	void setInstanceBuffer(Buffer b, uint index, uint divisor = 1,
		                   uint count = 1, bool normalize = false)
	{
		for (uint i = 0; i < count; i++)
		{
			setVertexBuffer(b, index + i, normalize, count * 3 * 4, i * 3 * 4);
			glVertexAttribDivisor(index + i, divisor);
		}
		checkForGlError();
	}

	void draw()
	{
		glBindVertexArray(_vao);
		checkForGlError();
		glDrawArrays(GL_TRIANGLES, 0, _vec_count);
	//	glDrawArraysInstanced(GL_TRIANGLES, 0, _vec_count, 1);
		checkForGlError();
	}
}



abstract class MeshInstance
{
	private   Quaternion _orientation = { x: 0, y: 0, z: 0, w: 1 };
	private   Vector3    _position = { 0, 0, 0 };
	private   Vector3    _scale = { 1, 1, 1 };
	protected bool       _dirty;

	@property auto orientation() { return _orientation; }
	@property auto position()    { return _position;    }
	@property auto scale()       { return _scale;       }

	@property void orientation(Quaternion newOrientation)
	{
		_orientation = newOrientation;
		_dirty = true;
	}
	@property void position(Vector3 newPosition)
	{
		_position = newPosition;
		_dirty = true;
	}
	@property void scale(Vector3 newScale)
	{
		_scale = newScale;
		_dirty = true;
	}

	abstract void draw();
}



class StandaloneMeshInstance : MeshInstance
{
	private Mesh _mesh;
	private Buffer _world_pos;
	private Buffer _world_rot;
	private Buffer _world_scl;

	this(Mesh mesh)
	{
		_mesh = mesh;
		Buffer[3] vbos;
		glGenBuffers(3, vbos.ptr);
		checkForGlError();
		_world_pos = vbos[0];
		_world_rot = vbos[1];
		_world_scl = vbos[2];
		setVertexBuffers();
	}

	void setVertexBuffers()
	{
		float[3] pos = [position.x, position.y, position.z];
		auto     rot = orientation.matrix!float;
		float[3] scl = [scale.x, scale.y, scale.z];
		setVertexBufferData(_world_pos, pos.ptr, pos.length * pos[0].sizeof);
		setVertexBufferData(_world_rot, rot.ptr, rot.size   * 4);
		setVertexBufferData(_world_scl, scl.ptr, scl.length * scl[0].sizeof);
	}

	override void draw()
	{
		if (_dirty)
			setVertexBuffers();
		_mesh.setInstanceBuffer(_world_pos, 3, 1);
		_mesh.setInstanceBuffer(_world_rot, 4, 1, 3);
		_mesh.setInstanceBuffer(_world_scl, 7, 1);
		_mesh.draw();
	}
}



class MeshInstanceBatch
{
	class SharedMeshInstance : MeshInstance
	{
		override void draw()
		{
			// TODO
			throw new GraphicsException("Not implemented");
		}
	}

	private Mesh _mesh;
	private auto _instances = Array!SharedMeshInstance();

	this(Mesh mesh)
	{
		_mesh = mesh;
	}

	@property final auto length() { return _instances.length; }
	alias opDollar = length;

	final SharedMeshInstance opIndex(size_t i)
	{
		return _instances[i];
	}

	void draw()
	{
		
	}
}
