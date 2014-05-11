#include "mex.h"

#include <string.h>
#include <stdio.h>
#include <math.h>
#include <ctype.h>

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]) {

	int nrA, ncA;
	
	double *A;
	
	double *R;
	double Inf;
	
    int sz;
	int i; 
	
	A = mxGetPr(prhs[0]);	
	ncA = mxGetN(prhs[0]);
	nrA = mxGetM(prhs[0]);

	Inf = mxGetInf();

    sz = ncA*nrA;
    
	plhs[0] = mxCreateDoubleMatrix( 1, 1, mxREAL );
	R = mxGetPr(plhs[0]);
    
    R[0] = A[0];

	for( i=1; i<sz; i++ )
	{
		if( !(A[i]==-Inf || (R[0]-A[i])>100) )
			R[0] = A[i] + log(1+exp(R[0]-A[i]));
	}
}

