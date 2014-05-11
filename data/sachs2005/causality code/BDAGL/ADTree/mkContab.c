#include "mex.h"

#include <string.h>
#include <stdio.h>
#include <math.h>
#include <time.h>
#include <ctype.h>

#include "ADTree.h"

ADTreeNode *root;
int *query;
int queryLength;
int *arities;
double *result;
int nNodes;

int **dimMultiplier;

void mkZeros( int queryOffset, int index );
void mkContab( int queryOffset, ADTreeNode *node, int index );

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]) {
	/* mkContab( ADTreeRootPtr, queryVars, arities ) */

	double *tarities;
	int maxArity;
	int ci, vi;
	int prod;
	unsigned int *rootPtr;
	double *queryPtr;
	double t1, t2;
		
	if(nrhs<3) {
		mexErrMsgTxt("usage: mkADTree( data, queryVars, arities)");
	}
	
	rootPtr = (unsigned int*)mxGetData(prhs[0]);
	root = (ADTreeNode*)rootPtr[0];
	
	nNodes = root->nChildren;
	
	queryPtr = mxGetPr(prhs[1]);
	queryLength = mxGetM(prhs[1])*mxGetN(prhs[1]);
	query = (int*)mxMalloc( queryLength*sizeof(int) );
	for( ci=0; ci<queryLength; ci ++) {
		query[ci] = (int)queryPtr[ci]-1; /* 0/1 indexing */
	}

	arities = (int*)mxMalloc( queryLength*sizeof(int) );
	maxArity = 0;
	tarities = mxGetPr(prhs[2]);
	for( ci=0; ci<queryLength; ci++ ) {
		arities[ci] = (int)tarities[ci];
		if( arities[ci]>maxArity ) maxArity = arities[ci];
	}
		
	prod = 1;
	dimMultiplier = (int**)mxMalloc( queryLength*sizeof(int*) );
	for( ci=0; ci<queryLength; ci++ ) {
		dimMultiplier[ci] = (int*)mxMalloc( arities[ci]*sizeof(int) );
		for( vi=0; vi<arities[ci]; vi++ ) {
			dimMultiplier[ci][vi] = prod * vi;
		}
		prod *= arities[ci];
	}

	plhs[0] = mxCreateNumericArray( queryLength, arities, mxDOUBLE_CLASS, mxREAL );
	result = mxGetPr(plhs[0]);
	memset(result, 0, prod*sizeof(double) );
	
	mkContab( 0, root, 0 );

	for( ci=0; ci<queryLength; ci++ ) {
		mxFree(dimMultiplier[ci]);
	}
	mxFree(dimMultiplier);
	mxFree(arities);
	mxFree(query);
		
}

void cleanup( int queryOffset, int index, int mcvIndex ) {
	int v;
	
	if( queryOffset==queryLength ) {
		result[mcvIndex] -= result[index];
		return;
	}
	
	for( v=0; v<arities[queryOffset]; v++ ) {
		cleanup( queryOffset+1, index + dimMultiplier[queryOffset][v], mcvIndex + dimMultiplier[queryOffset][v] );
	}
}


void mkContab( int queryOffset, ADTreeNode *node, int index ) {

	ADVaryNode *varyNode;
	int MCV;
	int v, k;
	int sum;
	int MCVindex;
	
	if( queryOffset==queryLength ) { /* base case */
		result[index] += node->count;
		return;
	}

	/* find the a_i(1) subnode of node */
	k = 0;
	for( k=0; k<node->nChildren; k++ )
		if( ((ADVaryNode*)node->children[k])->nodeI == query[queryOffset] )
			break;
		
	varyNode = (ADVaryNode*)node->children[k];
	MCV = varyNode->MCV;

	/* MCV */
	MCVindex = index + dimMultiplier[queryOffset][MCV-1];
	mkContab( queryOffset+1, node, MCVindex );

	/* recurse */
	for( v=0; v<arities[queryOffset]; v++ ) {
		ADTreeNode *nextNode;
		
		if( v==(MCV-1) ) 
			continue;

		nextNode = (ADTreeNode*)varyNode->children[v];
		if( nextNode != NULL ) { 
			mkContab( queryOffset+1, nextNode, index + dimMultiplier[queryOffset][v] );
			cleanup( queryOffset+1, index + dimMultiplier[queryOffset][v], MCVindex );
		}
	}

}

