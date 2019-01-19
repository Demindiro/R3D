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
}


struct Triangle
{
	private struct Point
	{
		Vector!3 vertex;
		Vector!3 texture;
		Vector!3 normal;
	};

	Point[3] points;

	this(Vector!3[3] vertices)
	{
		Vector!3[3] text, norm;
		auto n = cross(vertices[1] - vertices[0], vertices[2] - vertices[0]);
		norm[0] = norm[1] = norm[2] = n;
		foreach (i; 0 .. 3)
			points[i] = Point(vertices[i], text[i], norm[i]);
	}

	this(Vector!3[3] vertices, Vector!3[3] textures, Vector!3[3] normals)
	{
		foreach (i; 0 .. 3)
			points[i] = Point(vertices[i], textures[i], normals[i]);
	}

	static auto splitPolygon(const Vector!3[] vertices, const Vector!3[] textures,
	                         const Vector!3[] normals)
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


final class Mesh
{
	private Buffer _vbo;
	private VertexArray _vao;
	private uint _vec_count;

	this(Range)(Range triangles)
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
		auto geomv     = Array!(Vector!3)();
		auto textv     = Array!(Vector!3)();
		auto normv     = Array!(Vector!3)();
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
				geomv.insert(Vector!3(a[0], a[1], a[2]));
			}
			else if (type == "vt")
			{
				auto a = args[1 .. 4].to!(float[3]);
				textv.insert(Vector!3(a[0], a[1], a[2]));
			}
			else if (type == "vn")
			{
				auto a = args[1 .. 4].to!(float[3]);
				normv.insert(Vector!3(a[0], a[1], a[2]));
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
				auto v = new Vector!3[args.length - 1];
				auto t = new Vector!3[args.length - 1];
				auto n = new Vector!3[args.length - 1];
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

	void draw(size_t count = 1)
	{
		glBindVertexArray(_vao);
		glDrawArraysInstanced(GL_TRIANGLES, 0, _vec_count, count);
		checkForGlError();
	}
}



interface MeshInstance
{
	Quaternion orientation();
	Vector!3    position();
	Vector!3    scale();

	void orientation(Quaternion newOrientation);
	void position(Vector!3 newPosition);
	void scale(Vector!3 newScale);
}



class StandaloneMeshInstance : MeshInstance
{
	private Quaternion _orientation = { x: 0, y: 0, z: 0, w: 1 };
	private Vector!3    _position = { 0, 0, 0 };
	private Vector!3    _scale = { 1, 1, 1 };
	private Mesh   _mesh;
	private Buffer _world_pos;
	private Buffer _world_rot;
	private Buffer _world_scl;
	protected bool _dirty = true;

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

	~this()
	{
		// TODO
	}

	Quaternion orientation() { return _orientation; }
	Vector!3    position()    { return _position;    }
	Vector!3    scale()       { return _scale;       }

	void orientation(Quaternion newOrientation)
	{
		_orientation = newOrientation;
		_dirty = true;
	}
	void position(Vector!3 newPosition)
	{
		_position = newPosition;
		_dirty = true;
	}
	void scale(Vector!3 newScale)
	{
		_scale = newScale;
		_dirty = true;
	}

	private void setVertexBuffers()
	{
		float[3] pos = [position.x, position.y, position.z];
		auto     rot = orientation.matrix!float;
		float[3] scl = [scale.x, scale.y, scale.z];
		setVertexBufferData(_world_pos, pos.ptr, pos.length * pos[0].sizeof);
		setVertexBufferData(_world_rot, rot.ptr, rot.size   * 4);
		setVertexBufferData(_world_scl, scl.ptr, scl.length * scl[0].sizeof);
	}

	void draw()
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
		private size_t _index;
		private MeshInstanceBatch _batch;

		private this(MeshInstanceBatch batch, size_t index)
		{
			_batch = batch;
			_index = index;
		}

		Quaternion orientation() { return _batch._orientations[_index]; }
		Vector!3    position()    { return _batch._positions[_index];    }
		Vector!3    scale()       { return _batch._scales[_index];       }

		void orientation(Quaternion newOrientation)
		{
			_batch._orientations[_index] = newOrientation;
		}
		void position(Vector!3 newPosition)
		{
			_batch._positions[_index] = newPosition;
		}
		void scale(Vector!3 newScale)
		{
			_batch._scales[_index] = newScale;
		}
	}

	import r3d.core.matrix;
	private Mesh   _mesh;
	private Buffer _world_pos;
	private Buffer _world_rot;
	private Buffer _world_scl;
	private auto _instances    = Array!SharedMeshInstance();
	private auto _orientations = Array!Quaternion();
	private auto _positions    = Array!(Vector!3)();
	private auto _scales       = Array!(Vector!3)();
	private auto _orientations_cache = Array!(Matrix!(float,3,3))();
	private auto _positions_cache = Array!(float[3])();
	private auto _scales_cache = Array!(float[3])();

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

	~this()
	{
		// TODO
	}

	final auto length() { return _instances.length; }
	alias opDollar = length;

	final SharedMeshInstance opIndex(size_t i)
	{
		return _instances[i];
	}

	SharedMeshInstance createInstance()
	{
		auto instance = new SharedMeshInstance(this, _instances.length);
		_instances.insert(instance);
		_orientations.insert(Quaternion(0,0,0,1));
		_positions.insert(Vector!3(0,0,0));
		_scales.insert(Vector!3(1,1,1));
		_orientations_cache.length = _instances.length;
		_positions_cache.length = _instances.length;
		_scales_cache.length = _scales.length;
		return instance;
	}

	private void setVertexBuffers()
	{
		import std.parallelism, std.range;
		foreach (i; parallel(iota(0,_instances.length)))
		{
			_orientations_cache[i] = _orientations[i].matrix!float;
			auto e = _positions[i].elements;
			float[3] v = [e[0], e[1], e[2]];
			_positions_cache[i] = v;
			e = _scales[i].elements;
			v = [e[0], e[1], e[2]];
			_scales_cache[i] = v;
		}
		setVertexBufferData(_world_pos, &_positions_cache[0],
		                    _instances.length * _positions_cache[0].sizeof);
		setVertexBufferData(_world_rot, &_orientations_cache[0],
		                    _instances.length * _orientations_cache[0].sizeof);
		setVertexBufferData(_world_scl, &_scales_cache[0],
		                    _instances.length * _scales_cache[0].sizeof);
	}


	void draw()
	{
		setVertexBuffers();
		_mesh.setInstanceBuffer(_world_pos, 3, 1);
		_mesh.setInstanceBuffer(_world_rot, 4, 1, 3);
		_mesh.setInstanceBuffer(_world_scl, 7, 1);
		_mesh.draw(_instances.length);
	}
}
