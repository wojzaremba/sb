#include <math.h>
#include "mex.h"
#include "UGM_common.h"
 
 
void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
   /* Variables */
    int i,c,n,tmp,*Y,nInstances,nNodes,nStates,nComponents,sizGamma[2];
    
    double *gamma, *pi,*mu,Z;
    
    /* Input */
    Y = mxGetPr(prhs[0]);
    pi = mxGetPr(prhs[1]);
    mu = mxGetPr(prhs[2]);
    gamma = mxGetPr(prhs[3]);
    
    /* Compute Sizes */
    nInstances = mxGetDimensions(prhs[0])[0];
    nNodes = mxGetDimensions(prhs[2])[0];
    nStates = mxGetDimensions(prhs[2])[1];
    nComponents = mxGetDimensions(prhs[1])[1];
    
    /*printf("%d,%d,%d,%d\n",nInstances,nNodes,nStates,nComponents);*/
    
    for(i=0; i < nInstances; i++)
    {
        for(c=0; c < nComponents;c++)
        {
            for(n=0; n < nNodes;n++)
            {
                tmp = Y[i + nInstances*n]-1;
                gamma[i+nInstances*c] *= mu[n+nNodes*(tmp + nStates*c)];
            }
        }
    }
    for(i=0; i < nInstances; i++)
    {
        for(c=0;c < nComponents;c++)
        {
            gamma[i+nInstances*c]*=pi[c];
        }
    }
    for(i=0; i < nInstances; i++)
    {
        Z = 0;
        for(c=0;c < nComponents;c++)
        {
            Z += gamma[i+nInstances*c];
        }
        for(c=0;c < nComponents;c++)
        {
            gamma[i+nInstances*c]/=Z;
        }
    }
}