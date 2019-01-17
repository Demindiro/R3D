module r3d.graphics.mesh;

import std.container;
import std.conv;
import std.exception;
import std.file;
import std.range;
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
	glBufferData(GL_ARRAY_BUFFER, len, ptr, GL_STATIC_DRAW);
	checkForGlError();
}


private struct Triangle
{
	private struct Point
	{
		Vector3 vertex;
		Vector3 texture;
		Vector3 normal;
	};

	Point[3] points;

	this(Vector3[3] vertices)
	{
		Vector3[3] text, norm;
		auto n = cross(vertices[1] - vertices[0], vertices[2] - vertices[0]);
		norm[0] = norm[1] = norm[2] = n;
		foreach (i; 0 .. 3)
			points[i] = Point(vertices[i], text[i], norm[i]);
	} 

	this(Vector3[3] vertices, Vector3[3] textures, Vector3[3] normals)
	{
		foreach (i; 0 .. 3)
			points[i] = Point(vertices[i], textures[i], normals[i]);
	}

	static auto splitPolygon(const Vector3[] vertices, const Vector3[] textures,
	                         const Vector3[] normals)
	{
		assert(vertices.length == textures.length);
		assert(vertices.length == normals .length);
		auto triangles = new Triangle[vertices.length - 2];
		foreach(i, ref t; triangles)
		{
			auto k = i + 1, l = i + 2;
			t = Triangle([vertices[0], vertices[k], vertices[l]],
			             [textures[0], textures[k], textures[l]],
			             [normals [0], normals [k], normals [l]]);
		}
		return triangles;
	}

	import std.range;
	// TODO use a range or something
	static auto toFloatArr(Array!Triangle triangles)
	{
		auto arr = new float[triangles.length * 27];
		//foreach (size_t i, Triangle t; triangles[])
		for (size_t i = 0; i < triangles.length; i++)
		{
			auto t = triangles[i];
			//foreach (j, ref p; t.points)
			for (size_t j = 0; j < t.points.length; j++)
			{
				auto p = t.points[j];
				auto off = i * 27 + j * 9;
				arr[off + 0 .. off + 3] = p.vertex .elements.to!(float[3]);
				arr[off + 3 .. off + 6] = p.texture.elements.to!(float[3]);
				arr[off + 6 .. off + 9] = p.normal .elements.to!(float[3]);
			}
		}
		return arr;
	}
}


class Mesh
{
	private Buffer _vbo;
	private VertexArray _vao;
	private uint _vec_count;

	private this(Array!Triangle triangles)
	{
		if (triangles.length == 0)
			throw new CorruptFileException("No polygons");
		_vec_count = cast(uint)triangles.length * 3;

		// Buffers
		glGenBuffers(1, &_vbo);
		auto arr = Triangle.toFloatArr(triangles);
		auto size = arr.length * arr[0].sizeof;
		setVertexBufferData(_vbo, arr.ptr, size);

		// Arrays
		glGenVertexArrays(1, &_vao);
		glBindVertexArray(_vao);
		glBindBuffer(GL_ARRAY_BUFFER, _vbo);
		glVertexAttribPointer(0, 3, GL_FLOAT, false, 9 * 4, 0 * 4);
		glEnableVertexAttribArray(0);
		glVertexAttribPointer(1, 3, GL_FLOAT, false, 9 * 4, 3 * 4);
		glEnableVertexAttribArray(1);
		glVertexAttribPointer(2, 3, GL_FLOAT, false, 9 * 4, 6 * 4);
		glEnableVertexAttribArray(2);
		checkForGlError();
	}

	~this()
	{
		glDeleteBuffers(1, &_vbo);
		glDeleteVertexArrays(1, &_vao);
	}

	static Mesh fromFile(string path)
	{
		auto file      = File(path);
		auto geomv     = Array!Vector3();
		auto textv     = Array!Vector3();
		auto normv     = Array!Vector3();
		auto triangles = Array!Triangle();
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
				geomv.insert(Vector3(a[0], a[1], a[2]));
			}
			else if (type == "vt")
			{
				auto a = args[1 .. 4].to!(float[3]);
				textv.insert(Vector3(a[0], a[1], a[2]));
			}
			else if (type == "vn")
			{
				auto a = args[1 .. 4].to!(float[3]);
				normv.insert(Vector3(a[0], a[1], a[2]));
			}
			else if (type == "vp")
			{
				// TODO
				// auto a = args[1 .. 4].to!(float[3]);
				// spacv.insert(a);
			}
			else if (type == "f")
			{
				if (args.length < 4)
					throw new CorruptFileException("A polygon must have at least 3 vertices");
				auto v = new Vector3[args.length - 1];
				auto t = new Vector3[args.length - 1];
				auto n = new Vector3[args.length - 1];
				foreach (i, e; args[1 .. $])
				{
					auto a = e.split("/");
					if (a.length > 0 && a[0] != "")
						v[i] = geomv[a[0].to!uint - 1];
					if (a.length > 1 && a[1] != "")
						t[i] = textv[a[1].to!uint - 1];
					if (a.length > 2 && a[2] != "")
						n[i] = normv[a[2].to!uint - 1];
				}
				triangles.insert(Triangle.splitPolygon(v, t, n));
			}
			else if (type == "g")
			{
				// TODO
			}
			else if (type == "l")
			{
				// TODO
			}
			else if (type == "s")
			{
				// TODO
			}
			else
			{
				throw new CorruptFileException(to!string("Invalid type: " ~ type));
			}
		}
		return new Mesh(triangles);
	}

	void setVertexBuffer(Buffer b, uint index, bool normalize = false,
	                     size_t stride = 0, size_t offset = 0)
	{
		glBindVertexArray(_vao);
		glBindBuffer(GL_ARRAY_BUFFER, b);
		glVertexAttribPointer(index, 3, GL_FLOAT, normalize, stride, offset);
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
		glDrawArrays(GL_TRIANGLES, 0, _vec_count);
		checkForGlError();
	}
}



abstract class MeshInstance
{
	private   Quaternion _orientation = { x: 0, y: 0, z: 0, w: 1 };
	private   Vector3    _position = { 0, 0, 0 };
	private   Vector3    _scale = { 1, 1, 1 };
	protected bool       _dirty = true;
	          bool       active = true;

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
	private Mesh   _mesh;
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
		this(MeshInstanceBatch b)
		{

		}
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

	SharedMeshInstance createMeshInstance()
	{
		auto instance = new SharedMeshInstance(this);
		_instances.insert(instance);
		return instance;
	}

	void draw()
	{
		for (size_t i = 0; i < length; i++)
		{
			//if (
		}
	}
}
