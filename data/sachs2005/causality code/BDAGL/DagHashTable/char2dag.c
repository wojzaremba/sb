#include "mex.h"

#include <string.h>
#include <stdio.h>
#include <math.h>
#include <ctype.h>

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]) {
	
	double *dag;

	unsigned int hash;
	unsigned int *hashCode;
	unsigned short *charArr; /* unsigned short */
		
	unsigned char accum;
	int nNodes;
	int bit;
	
	int i, j, k; 
	

	if(nrhs<2)
		mexErrMsgTxt("char2dag(string, nNodes)");
	
	charArr = (unsigned short*)malloc(sizeof(unsigned short)*mxGetNumberOfElements(prhs[0])); 
	memcpy( charArr, mxGetChars(prhs[0]), sizeof(unsigned short)*mxGetNumberOfElements(prhs[0]));
	nNodes = (int)mxGetScalar(prhs[1]);
		
	plhs[0] = mxCreateDoubleMatrix(nNodes, nNodes, mxREAL);
	dag = mxGetPr(plhs[0]);
	
	for(k=0; k<mxGetNumberOfElements(prhs[0]); k++) {
		charArr[k] -= 1;
	/*	printf("%i %i\n", k, (int)charArr[k]); */
	}
	
	k = 0; j = 0;
	for( i=0; i<nNodes*nNodes; i++ )
	{				
		if( (i%(nNodes+1))==0 )
			continue;

/*		printf("%i %i\n", i, k); */
		
		dag[i] = (charArr[k]&0x0080)>>7; /* this value is type double, but is really only 0 or 1 */
		charArr[k] <<= 1;
		
		j ++;
		
		if( j==8 ) {
			k ++;
			j = 0;
		}
	}		
	free(charArr);

}
