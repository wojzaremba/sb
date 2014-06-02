#include "mex.h"

#include <string.h>
#include <stdio.h>
#include <math.h>
#include <ctype.h>

double *dag;
int source;
int nc, nr;
int sink;

int sub(int currentNode);

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]) {
    
    /* assuming that dag is acyclic, this function checks if
     * the graph resulting from the reversal of the edge source->sink
     * induces a cycle */
    
	
    double* result;

	if( nrhs != 3 ) 
	{
		mexErrMsgTxt("isCyclic_revEdge(dag,source,sink)");
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

    result[0] = (double)sub(source);
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
            if( i==sink && currentNode!=source ) {
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

