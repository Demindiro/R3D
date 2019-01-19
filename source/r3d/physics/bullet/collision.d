static if (0) // Poof
extern (C++)
{
	class btCollisionObject;
	class btCollisionShape;
	class btCollisionWorld;
	class btGhostObject;

	class btDbvtBroadphase;
	class btAxisSweep3;
	class bt32BitAxisSweep3;
	class btSimpleBroadphase;

	class btPersistentManifold;

	extern (C++, btDispatcher)
	{
		void registerCollisionAlgorithm();
	}

	class btOverlapFilterCallback;
}
