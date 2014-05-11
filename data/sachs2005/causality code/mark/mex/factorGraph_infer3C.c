#include <math.h>
#include "mex.h"

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    /* Variables */
    int n,e,n1,n2,n3,nNodes,nStates,nEdges2,nEdges3,*edges2,*edges3,*y,sizeBel2[3],sizeBel3[4];
    double *w1,*w2,*w3,*Z,*bel1,*bel2,*bel3,logPot,pot;
    
    /* Input */
    w1 = mxGetPr(prhs[0]);
    w2 = mxGetPr(prhs[1]);
    w3 = mxGetPr(prhs[2]);
    edges2 = mxGetPr(prhs[3]);
    edges3 = mxGetPr(prhs[4]);
    
    /* Compute Sizes */
    nStates = mxGetDimensions(prhs[0])[0];
    nNodes = mxGetDimensions(prhs[0])[1];
    nEdges2 = mxGetDimensions(prhs[3])[0];
    nEdges3 = mxGetDimensions(prhs[4])[0];
    
    /* Compute sizes of 3D+ arrays */
    sizeBel2[0] = nStates;
    sizeBel2[1] = nStates;
    sizeBel2[2] = nEdges2;
    sizeBel3[0] = nStates;
    sizeBel3[1] = nStates;
    sizeBel3[2] = nStates;
    sizeBel3[3] = nEdges3;
    
    /*printf("Computed Sizes: %d %d %d %d\n",nStates,nNodes,nEdges2,nEdges3);*/
    
    /* Output */
    plhs[0] = mxCreateDoubleMatrix(1,1,mxREAL);
    plhs[1] = mxCreateDoubleMatrix(nStates,nNodes,mxREAL);
    plhs[2] = mxCreateNumericArray(3,sizeBel2,mxDOUBLE_CLASS,mxREAL);
    plhs[3] = mxCreateNumericArray(4,sizeBel3,mxDOUBLE_CLASS,mxREAL);
    Z = mxGetPr(plhs[0]);
    bel1 = mxGetPr(plhs[1]);
    bel2 = mxGetPr(plhs[2]);
    bel3 = mxGetPr(plhs[3]);
    
    
    *Z = 0;
    y = mxCalloc(nNodes,sizeof(int));
    while(1)
    {
      /* Compute logPot */
        logPot = 0;
        for(n=0;n < nNodes;n++)
        {
            logPot += w1[y[n] + nStates*n];
        }
        for(e=0;e < nEdges2;e++)
        {
            n1 = edges2[e]-1;
            n2 = edges2[e+nEdges2]-1;
            logPot += w2[y[n1] + nStates*(y[n2] + nStates*e)];
        }
        for(e=0;e < nEdges3;e++)
        {
            n1 = edges3[e]-1;
            n2 = edges3[e+nEdges3]-1;
            n3 = edges3[e+nEdges3+nEdges3]-1;
            logPot += w3[y[n1] + nStates*(y[n2] + nStates*(y[n3] + nStates*e))];
        }
        pot = exp(logPot);
        /* printf("pot = %f\n",pot); */
        
        /* Update Z */
        *Z += pot;
        
        /* Update marginals */
        for(n=0;n < nNodes;n++)
        {
            bel1[y[n] + nStates*n] += pot;
        }
        for(e=0;e < nEdges2;e++)
        {
            n1 = edges2[e]-1;
            n2 = edges2[e+nEdges2]-1;
            bel2[y[n1] + nStates*(y[n2] + nStates*e)] += pot;
        }
        for(e=0;e < nEdges3;e++)
        {
            n1 = edges3[e]-1;
            n2 = edges3[e+nEdges3]-1;
            n3 = edges3[e+nEdges3+nEdges3]-1;
            bel3[y[n1] + nStates*(y[n2] + nStates*(y[n3] + nStates*e))] += pot;
        }
        
        /* Go to next state */
        for(n=0;n < nNodes;n++)
        {
            if(y[n] < nStates-1)
            {
                y[n]++;
                break;
            }
            else
            {
                y[n] = 0;
            }
        }
        
        if(n == nNodes && y[nNodes-1]==0) {
            break;
        }
    }
    
    /* Normalize Marginals */
    for(n=0;n<nStates*nNodes;n++)
        bel1[n] /= *Z;
    for(e=0;e<nStates*nStates*nEdges2;e++)
        bel2[e] /= *Z;
    for(e=0;e<nStates*nStates*nStates*nEdges3;e++)
        bel3[e] /= *Z;
    
    mxFree(y);
}
