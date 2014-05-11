#include "mex.h"

#include <string.h>
#include <stdio.h>
#include <math.h>
#include <ctype.h>

double **alpha;
double *right;
int wi;
int nNodes;
double Inf;

#define LOGADD(la,lb) if(la==-Inf||lb-la>100) la=lb;else la+=log(1+exp(lb-la));

void mkRightHelper(unsigned int S, int d);
void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]) {

	double *flat;
    int nr,nc, ni;

	flat = mxGetPr(prhs[0]);
	nr = mxGetM(prhs[0]); /* 2^nNodes */
	nc = mxGetN(prhs[0]); /* nNodes */
	
	wi = nr;
	nNodes = nc;

	if(wi!=(1<<nNodes))
		mexErrMsgTxt("The size of the input must be: size(alpha) = [2^nNodes nNodes]");

	Inf = mxGetInf();
	
	alpha = (double**)malloc( nNodes*sizeof(double*) );
 	for( ni=0; ni<nNodes; ni++ ) {
 		alpha[ni] = flat;
		flat += nr;
 	}
	
	plhs[0] = mxCreateDoubleMatrix( nr, 1, mxREAL );
	right = mxGetPr(plhs[0]);
	
	mkRightHelper(0, 0);
	
	free(alpha);

}

void mkRightHelper(unsigned int S, int d){
	if( d<nNodes ) {
		mkRightHelper( S, d+1 );
		mkRightHelper( S|(1<<d), d+1 );
	} else {
		double sm;
		unsigned int cmp, sub, compl;
		int j;
		
		sm = -Inf;
		cmp = S;
		sub = 1;
		compl = (1<<nNodes)-1-S;
		
		for( j=0; j<nNodes; j++ ) {
			if( cmp&1 ) {
				LOGADD( sm, alpha[j][compl] + right[S-sub] );
			}
			cmp >>= 1; sub <<= 1;
		}
		
		if( S==0 )
			right[0] = 0;
		else
			right[S] = sm;
	}
}
