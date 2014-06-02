#include "mex.h"

#include <string.h>
#include <stdio.h>
#include <math.h>
#include <ctype.h>

double *dag;
int source;
int nc, nr;

int sub(int currentNode);

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]) {
    
    /* assuming that dag is acyclic, this function checks if
     * the graph resulting from the addition of the edge source->sink
     * induces a cycle */
    
    int sink;
	
    double* result;

	if( nrhs != 3 ) 
	{
		mexErrMsgTxt("isCyclic(dag,source,sink)");
		return;
	}
    
	dag = mxGetPr(prhs[0]);	
	nc = mxGetN(prhs[0]);
	nr = mxGetM(prhs[0]);
    
    if( nc!=nr ) {
		mexErrMsgTxt("dag must be a square adjacency matrix");
		return;
    }
    
    source = mxGetScalar(prhs[1])-1;
    sink = mxGetScalar(prhs[2])-1;
    

	plhs[0] = mxCreateDoubleMatrix( 1, 1, mxREAL );
	result = mxGetPr(plhs[0]);

    if( sink==source || dag[ sink + source*nr ] )
        result[0] = 1;
    else
        result[0] = (double)sub(sink);
}

int sub(int currentNode) {
    
    int i;
    int off;
    int isCyclic;

/*    printf("current node %i\n", currentNode+1); */
    
    isCyclic = 0;
    off = currentNode;
    for( i=0; i<nr; i++ ) {
      /*  printf("   %i -> %i (%f)\n", i+1, currentNode+1, dag[off]); */
        
        if( dag[off]==1 ) {
            if( i==source ) {
                return 1;
            } else {
                isCyclic = sub( i );
            }
        }
        
        if( isCyclic )
            break;

        off = off + nr;
    }
    
    return isCyclic;
}

