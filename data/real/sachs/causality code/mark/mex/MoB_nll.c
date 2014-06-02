#include <math.h>
#include "mex.h"
#include "UGM_common.h"
 
 
void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
   /* Variables */
    int i,c,n,tmp,*Y,nInstances,nNodes,nStates,nComponents,sizGamma[2];
    
    double p_x,p_x_mu, *pi,*mu,*NLL;
    
    /* Input */
    Y = mxGetPr(prhs[0]);
    pi = mxGetPr(prhs[1]);
    mu = mxGetPr(prhs[2]);
    NLL = mxGetPr(prhs[3]);
    
    /* Compute Sizes */
    nInstances = mxGetDimensions(prhs[0])[0];
    nNodes = mxGetDimensions(prhs[2])[0];
    nStates = mxGetDimensions(prhs[2])[1];
    nComponents = mxGetDimensions(prhs[1])[1];
    
    for(i=0; i < nInstances; i++)
    {
        p_x = 0;
        for(c=0; c < nComponents;c++)
        {
            p_x_mu = 1;
            for(n=0; n < nNodes;n++)
            {
                tmp = Y[i + nInstances*n]-1;
                p_x_mu *= mu[n+nNodes*(tmp + nStates*c)];
            }
            p_x += pi[c]*p_x_mu;
        }
        NLL[i] -= log(p_x);
    }
    
}