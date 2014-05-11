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
	dims[1] = nb;
	plhs[0] = mxCreateCharArray( 2, dims);
	charArr = mxGetChars(plhs[0]);
		
	k = 0;
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
			if( i==(sz-2) )
			{
				/*printf("%i\n", nb*8-(sz-hi));*/
				accum <<= (nb*8-(sz-hi));
			}
			
			charArr[k] = (unsigned short)accum+1; /* offset by 1, to avoid introducing any null terminators (zeros) */
			k++;
			
			j = 0;
			accum = 0;
		}
		else
			accum <<= 1;				
	}		

}
