#include "util.h"
#include "mex.h"
#include <memory.h>

#define WORDSIZE 4   /* Size of machine word in bytes.  Must be power of 2. */
#define BLOCKSIZE 2048	/* Minimum number of bytes requested at a time from
			   the system.  Must be multiple of WORDSIZE. */

/* Pointers to base of current block for each storage pool (C automatically
   initializes them to NULL). */
static char *PoolBase[POOLNUM];

/* Number of bytes left in current block for each storage pool (initialized
   to 0). */
static int PoolRemain[POOLNUM];

/* Returns a pointer to a piece of new memory of the given size in bytes
   allocated from a named pool.
 */
void *MallocPool(int size, int pool)
{
	char *m, **prev;
	int bsize;
	
	/* Round size up to a multiple of wordsize.  The following expression
	   only works for WORDSIZE that is a power of 2, by masking last bits of
	   incremented size to zero. */
	size = (size + WORDSIZE - 1) & ~(WORDSIZE - 1);
	
	/* Check whether new block must be allocated.  Note that first word of
	   block is reserved for pointer to previous block. */
	if (size > PoolRemain[pool]) {
		bsize = (size + sizeof(char **) > BLOCKSIZE) ?
		size + sizeof(char **) : BLOCKSIZE;
		m = (char*) mxMalloc(bsize);
		if (! m) printf("Failed to allocate memory\n");
		else 
			mexMakeMemoryPersistent((void *)m);
		PoolRemain[pool] = bsize - sizeof(void *);
	/* Fill first word of new block with pointer to previous block. */
		prev = (char **) m;
		prev[0] = PoolBase[pool];
		PoolBase[pool] = m;
	}
	/* Allocate new storage from end of the block. */
	PoolRemain[pool] -= size;
	return (PoolBase[pool] + sizeof(char **) + PoolRemain[pool]);
}

/* Free all storage that was previously allocated with MallocPool from
   a particular named pool.
 */
void FreeStoragePool(int pool)
{
	char *prev;
	
	while (PoolBase[pool] != NULL) {
		prev = *((char **) PoolBase[pool]);  /* Get pointer to prev block. */
		mxFree(PoolBase[pool]);
		PoolBase[pool] = prev;
	}
	PoolRemain[pool] = 0;
}
