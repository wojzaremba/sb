#include "mex.h"

#include <string.h>
#include <stdio.h>
#include <math.h>
#include <ctype.h>

#include "util.h"
#include "ADTree.h"


double **data;

int **tempRecordList; /* CHildnumssk from moore '98 */

int maxArity;
int *arity;
int nNodes, nRecords;
ADTreeNode *root;
int poolNo;

void cleanup(void) {
	int i;
/*	printf("ADTree cleaned up\n"); */
	
	for( i=0; i<POOLNUM; i++ )
		FreeStoragePool(i);
}

void cleanupSingle(int i) {
	FreeStoragePool(i);
}

ADTreeNode *mkADTree( int nodeI, int count, int *records, int dp);
ADVaryNode *mkADVaryNode( int nodeI, int count, int *records, int dp );

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]) {
	/* mkADTree( data, arities)
	 *** DATA MUST LIE IN THE RANGE 1..K *** */
	
	double *tarity;
	unsigned int *ptr;
	int *records;
	double *flatData;
	int ci,ri;

	if(nrhs<2) {
		mexErrMsgTxt("usage: mkADTree( data, arities, [MEMPOOL#])");
	}
		
	flatData = mxGetPr(prhs[0]); /* expect: #records x #variables */
	nRecords = mxGetM(prhs[0]);
	nNodes = mxGetN(prhs[0]);
	
	if(nrhs<3) {
		poolNo = 0;
	} else {
		poolNo = (int)mxGetScalar(prhs[2]);
		if( poolNo>=POOLNUM ) {
			mexErrMsgTxt("poolNo>=POOLNUM: increase POOLNUM, the number of memory pools in mkADTree.c");
		}
	}

	cleanupSingle(poolNo);
	mexAtExit(cleanup);
		
	arity = (int*)mxMalloc( nNodes*sizeof(int) );
	maxArity = 0;
	tarity = mxGetPr(prhs[1]);
	for( ci=0; ci<nNodes; ci++ ) {
		arity[ci] = (int)tarity[ci];
		if( arity[ci]>maxArity ) maxArity = arity[ci];
	}
	
	data = (double **)mxMalloc( nNodes*sizeof(double *) );
	
	for( ci=0; ci<nNodes; ci++ ) {
		data[ci] = flatData;
		flatData += nRecords;
	}
	
	tempRecordList = (int**)mxMalloc((maxArity+1)*sizeof(int *)); /* trade away memory efficiency to avoid dynamic memory allocation */
	for( ri=1; ri<=maxArity; ri++ )
		tempRecordList[ri] = (int *)mxMalloc(nRecords*sizeof(int *));
	
	records = (int*)mxMalloc(nRecords*sizeof(int));
	for(ri=0; ri<nRecords; ri++)
		records[ri] = ri;
	
	/*printf("proceeding %i %i %i\n", nNodes, nRecords, maxArity);*/
	
	root = mkADTree( 0, nRecords, records,0 );
		
	for( ri=1; ri<=maxArity; ri++ )
		mxFree(tempRecordList[ri]);
	mxFree( tempRecordList );
	mxFree(records);
	mxFree(arity);
	mxFree(data);
	
	plhs[0] = mxCreateNumericMatrix( 1, 1, mxUINT32_CLASS, 0 );
	ptr = ((unsigned int *)mxGetData(plhs[0]));
	ptr[0] = (unsigned int)root;
}

ADTreeNode *mkADTree( int nodeI, int count, int *records, int dp) {
	int ni, nChildren;
	ADTreeNode *node = (ADTreeNode *)MallocPool(sizeof(ADTreeNode), poolNo);
	
	node->count = count;
	node->nChildren = nNodes - nodeI; /* not +1 since we're 0-indexed */
	node->children = (void **)MallocPool(node->nChildren*sizeof(ADVaryNode*), poolNo);
	/* base case -- nChildren==0 => nothing more to do on this branch */
	for(ni=nodeI; ni<nNodes; ni++ ) {
		node->children[ni-nodeI] = (void*)mkADVaryNode( ni, count, records, dp+1 );
	}
	
/*	for(ni=0; ni<dp; ni++) printf("\t");
	printf("AD %i %i\n", nodeI, node->count ); */
	return node;
}

ADVaryNode *mkADVaryNode( int nodeI, int count, int *records, int dp ) {
	int ki, ri, maxCount, MCV;
	ADVaryNode *node = (ADVaryNode *)MallocPool(sizeof(ADVaryNode), poolNo);
	int **memoryBaton;
	int *memoryBatonLength = (int*)mxMalloc((arity[nodeI]+1)*sizeof(int));
	memset(memoryBatonLength, 0, (arity[nodeI]+1)*sizeof(int) );
	
	for( ri=0; ri<count; ri++ ) {
		int v = (int)data[nodeI][records[ri]];
		tempRecordList[v][memoryBatonLength[v]++] = records[ri];
	}

	MCV = 1;
	maxCount = 0; /* find the MCV */
	for( ki=1; ki<=arity[nodeI]; ki++ ) {
		if( memoryBatonLength[ki] > maxCount ) {
			maxCount = memoryBatonLength[ki];
			MCV = ki;
		}
	}
	node->MCV = MCV;
	node->nodeI = nodeI;
	
	/* so that our lists don't get overwritten  by a recursive call
	// can't think of any way around this, but better than "mallocing as we go" (building the lists) */
	memoryBaton = (int**)mxMalloc((arity[nodeI]+1)*sizeof(int*));
	for( ki=1; ki<=arity[nodeI]; ki++ ) {
		if( memoryBatonLength[ki]!=0 && ki!=MCV) {
			memoryBaton[ki] = (int*)mxMalloc(memoryBatonLength[ki]*sizeof(int));
			memcpy( memoryBaton[ki], tempRecordList[ki], memoryBatonLength[ki]*sizeof(int) ); 
		}
	}
	
	node->nChildren = arity[nodeI];
	node->children = (void **)MallocPool(node->nChildren*sizeof(ADTreeNode*), poolNo);
	memset(node->children, 0, node->nChildren*sizeof( ADTreeNode *) );
	for( ki=1; ki<=arity[nodeI]; ki++ ) {
		if( memoryBatonLength[ki]==0 || ki==MCV )
			node->children[ki-1] = NULL;
		else {
			node->children[ki-1] = (void*)mkADTree( nodeI+1, memoryBatonLength[ki], memoryBaton[ki], dp+1 );
			mxFree(memoryBaton[ki]);
		}
	}

	mxFree(memoryBatonLength);
	mxFree(memoryBaton);
/*	for(ri=0; ri<dp; ri++) printf("\t");
	printf("VARY i=%i mcv=%i \n", nodeI, MCV ); */
	
	return node;
}

