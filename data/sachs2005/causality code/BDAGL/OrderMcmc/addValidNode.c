#include "mex.h"

#include <string.h>
#include <stdio.h>
#include <math.h>
#include <ctype.h>

/*#define printf(N);*/

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]) {

	int *currentValidFamilies;
	int newNode;
	int len,i;
	
	int *newValidFamilies;

	if(nrhs<2) {
		mexErrMsgTxt("usage: addValidNode( currentValidFamilies, newNode)");
	}
		
	currentValidFamilies = (int *)mxGetData(prhs[0]); /* expect: #records x #variables */
	len = mxGetM(prhs[0])*mxGetN(prhs[0]);
	
	newNode = (int)mxGetScalar(prhs[1]);
	
	plhs[0] = mxCreateNumericMatrix(1, len*2, mxUINT32_CLASS, mxREAL);
	newValidFamilies = (int *)mxGetData(plhs[0]);
	
	memcpy( newValidFamilies, currentValidFamilies, len*sizeof(int) );
	memcpy( newValidFamilies+len, currentValidFamilies, len*sizeof(int) );
	
	for( i=len; i<len*2; i++ ) {
		newValidFamilies[i] |= (1<<newNode);
	}
}