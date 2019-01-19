module r3d.physics.bullet.memory;

extern (C++)
{
	void* btAlignedAlloc(size_t size);
	void  btAlignedFree();
	void  btAlignedAllocSetCustom();
	void  btAlignedAllocSetCustomAligned();

	void  btAlignedObjectArray();
}
