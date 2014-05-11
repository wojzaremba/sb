#include "mex.h"

#include <string.h>
#include <stdio.h>
#include <math.h>
#include <ctype.h>

#include "ADTree.h"

#define MYMEMPOOL 0

ADTreeNode *root;

void traverseAD(ADTreeNode* node, int dp );
void traverseVary(ADVaryNode* node, int dp );
	
void traverseAD(ADTreeNode* node, int dp ) {
	int k, kk;
	for(k=0; k<dp; k++) printf("\t");
	printf("AD %i %i \n", node->count, node->nChildren);
	
	for(k=0; k<node->nChildren; k++ ){
		if( node->children[k] == NULL ){
			for(kk=0; kk<dp; kk++) printf("\t");
			printf("\tNULL\n");
		}
		else
			traverseVary( node->children[k], dp + 1 );
	}
}

void traverseVary(ADVaryNode* node, int dp ) {
	int k, kk;
	for(k=0; k<dp; k++) printf("\t");
	printf("VARY %i %i [%i] \n", node->MCV, node->nChildren,  node->nodeI);
	
	for(k=0; k<node->nChildren; k++ ){
		if( node->children[k] == NULL ) {
			for(kk=0; kk<dp; kk++) printf("\t");
			printf("\tNULL\n");
		} else
			traverseAD( node->children[k], dp + 1 );
	}
}

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]) {
	/* expects a pointer to the root */
	
	unsigned int *ptr;

	ptr = (unsigned int*)mxGetData(prhs[0]);
	root = (ADTreeNode *)ptr[0];

	traverseAD(root, 0);
}

