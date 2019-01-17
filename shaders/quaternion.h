typedef vec4 quat;

typedef struct dquat
{
	vec4 r, d;
} dquat;


quat quat_mul(quat p, quat q)
{
	quat r;
	r.w = p.w * q.w - p.x * q.x - p.y * q.y - p.z * q.z;
	r.x = p.x * q.w + p.w * q.x - p.z * q.y + p.y * q.z;
	r.y = p.y * q.w + p.w * q.y - p.z * q.x - p.x * q.z;
	r.z = p.z * q.w - p.y * q.x + p.x * q.y + p.w * q.z;
	return r;
}

dquat dquat_mul(dquat p, dquat q)
{
	dquat r = {
		.r = quat_mul(p.r, q.r),
		.d = quat_mul(p.r, q.d) + quat_mul(p.d, q.r)
	};
	return r;
}
