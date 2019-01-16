module r3d.input.keyboard;

import r3d.graphics.opengl.glfw;

enum KeyCode
{
	unknown    = -1,
	space      = 32, //  
	apostrophe = 39, // '
	comma      = 44, // ,
	minus      = 45, // -
	period     = 46, // .
	slash      = 47, // /
	k0         = 48, // 0
	k1         = 49, // 1
	k2         = 50, // 2
	k3         = 51, // 3
	k4         = 52, // 4
	k5         = 53, // 5
	k6         = 54, // 6
	k7         = 55, // 7
	k8         = 56, // 8
	k9         = 57, // 9
	semicolon  = 59, // ;
	equal      = 60, // =
	a          = 65, // a
	b          = 66, // b
	c          = 67, // c
	d          = 68, // d
	e          = 69, // e
	f          = 70, // f
	g          = 71, // g
	h          = 72, // h
	i          = 73, // i
	j          = 74, // j
	k          = 75, // k
	l          = 76, // l
	m          = 77, // m
	n          = 78, // n
	o          = 79, // o
	p          = 80, // p
	q          = 81, // q
	r          = 82, // r
	s          = 83, // s
	t          = 84, // t
	u          = 85, // u
	v          = 86, // v
	w          = 87, // w
	x          = 88, // x
	y          = 89, // y
	z          = 90, // z


	lshift     = 340,
}

enum KeyAction
{
	release = 0,
	press   = 1,
	repeat  = 2,
}
