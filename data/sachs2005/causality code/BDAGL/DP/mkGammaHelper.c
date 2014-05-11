#include "mex.h"

#include <string.h>
#include <stdio.h>
#include <math.h>
#include <ctype.h>

double Inf;

#define LOGADD(la,lb) if(la==-Inf||lb-la>100) la=lb;else la+=log(1+exp(lb-la));

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]) {

	double *left;
	double *right;
	double *gamma;
	int wi;
	int nNodes;
	int nodeI;
	
	double *flat;
    int nr,S;

	if( nrhs!=3 ) {
		mexErrMsgTxt("Usage: mkGammaHelper(nodeI, left, right)");
	}
	
	nodeI = (int)mxGetScalar(prhs[0]);
	left = mxGetPr(prhs[1]);
	right = mxGetPr(prhs[2]);
	nr = mxGetM(prhs[1]); /* 2^nNodes */
	
	nNodes = (int)(log(nr)/log(2.0f));
		
	Inf = mxGetInf();
		
	plhs[0] = mxCreateDoubleMatrix( 1, nr, mxREAL );
	gamma = mxGetPr(plhs[0]);
	
	for( S=0; S<(1<<nNodes); S++ ) {
		if( (S>>nodeI) & 1 ) {
			gamma[S] = -Inf;
		} else {
			int compl = (1<<nNodes)-1-S-(1<<nodeI);
			gamma[S] = left[S] + right[compl];			
		}
	}
}
