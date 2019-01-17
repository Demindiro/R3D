/**
The R3D engine is a heavily multithreaded framework intended to exploit
multicore processors to their fullest.

Many games are singlethreaded with only some (or even none) threads for
background tasks, such as networking. This paradigm worked while individual
processor cores became faster almost exponentially but nowadays it is difficult
at best to create faster cores. It is time developers start adopting
multithreading paradigms since the only way in the future to improve performance
is by using multiple cores simultaneously.

Everything in this library as well as the D language is engineered to write
multithreaded code without having to worry too much about synchronization.
*/
module r3d;


public import r3d.core;
public import r3d.graphics;
public import r3d.input;
public import r3d.physics;
