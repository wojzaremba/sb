#include "mex.h"

#include <string.h>
#include <stdio.h>
#include <math.h>
#include <ctype.h>

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]) {
	
	double *dag;

	unsigned int hash;
	unsigned int *hashCode;
	unsigned char *charArr;
		
	int dims[2];
	unsigned char accum;
	
    int sz, hi, wi, nb;
	int i, j, k; 
	
	dag = mxGetPr(prhs[0]);
	hi = mxGetM(prhs[0]);
	wi = mxGetN(prhs[0]);
	sz = hi*wi;
	nb = (int)ceil( (double)(sz-hi)/8.0f );

	
	if(hi!=wi)
		mexErrMsgTxt("Input matrix must be square");
	
	dims[0] = 1;
	dims[1] = 1;
	plhs[0] = mxCreateNumericArray( 2, dims, mxUINT32_CLASS, mxREAL );
	hashCode = (unsigned int*)mxGetData(plhs[0]);
	
	if(nlhs>1) {
		dims[0] = 1;
		dims[1] = nb;
		plhs[1] = mxCreateNumericArray( 2, dims, mxUINT8_CLASS, mxREAL );
		charArr = (unsigned char*)mxGetData(plhs[1]);
	}
    	
	k = 0;
	hash = 0;
	accum = 0; j = 0;
	for( i=0; i<sz; i++ )
	{
				
		if( (i%(wi+1))==0 )
			continue;
		
		accum |= (unsigned char)dag[i]; /* this value is type double, but is really only 0 or 1 */
		
		j++;
		
		/*printf("%i %i %i\n", i, (unsigned char)dag[i], accum);*/
		
		if( j==8 || i==(sz-2) ) /* -2 b/c the last element is always skipped */
		{
			hash += accum;
			hash += (hash << 10);
			hash ^= (hash >> 6);
			/*printf("%i %i\n", i, accum);*/

			if( nlhs>1 ) {
				charArr[k] = accum;
				k++;
			}
			
			j = 0;
			accum = 0;
		}
		else
			accum <<= 1;				
	}		
	
	hash += (hash << 3);
    hash ^= (hash >> 11);
	hash += (hash << 15);
	
	hashCode[0] = hash;
}

