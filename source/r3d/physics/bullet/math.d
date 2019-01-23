import r3d.core.matrix;

alias btScalar = double;

struct btVector3
{
	import r3d.core.vector;
	btScalar x, y, z, w;
	this(Vector!3 v)
	{
		x = v.x;
		y = v.y;
		z = v.z;
		w = 0;
	}
}

struct btQuaternion
{
	import r3d.core.quaternion;
	btScalar x, y, z, w;
	this(Quaternion q)
	{
		x = q.x;
		y = q.y;
		z = q.z;
		w = q.w;
	}
}

alias btMatrix3x3 = Matrix!(btScalar,3,3);

struct btTransform
{
	btVector3 position;
	btQuaternion quaternion;
}
