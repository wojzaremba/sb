#include "mex.h"

#include <string.h>
#include <stdio.h>
#include <math.h>
#include <ctype.h>

#include "util.h"

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]) {
	/* mkADTree( data, arities)
	 *** DATA MUST LIE IN THE RANGE 1..K *** */
	
	plhs[0] = mxCreateDoubleScalar( (double)POOLNUM );
}
