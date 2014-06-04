#include "mex.h"

#include <string.h>
#include <stdio.h>
#include <math.h>
#include <ctype.h>

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]) {

	int nrA, ncA;
	int nrB, ncB;

	double *A, *B;
	int sz;
	
	double *R;
	double Inf;
	
	int i; 
	
	A = mxGetPr(prhs[0]);	
	ncA = mxGetN(prhs[0]);
	nrA = mxGetM(prhs[0]);

	B = mxGetPr(prhs[1]);	
	ncB = mxGetN(prhs[1]);
	nrB = mxGetM(prhs[1]);

	Inf = mxGetInf();

	sz = ncA*nrA;
	if( sz != ncB*nrB ) 
	{
		mexErrMsgTxt("numel(A)~=numel(B)");
		return;
	}

	plhs[0] = mxCreateDoubleMatrix( nrA, ncA, mxREAL );
	R = mxGetPr(plhs[0]);

	for( i=0; i<sz; i++ )
	{
		if( A[i]==-Inf || (B[i]-A[i])>100 )
			R[i] = B[i];
		else 
			R[i] = A[i] + log(1+exp(B[i]-A[i]));
	}
}

