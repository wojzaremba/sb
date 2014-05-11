#ifndef __UTIL_H
#define __UTIL_H

#define POOLNUM 5

void *MallocPool(int size, int pool);
void FreeStoragePool(int pool);

#endif

