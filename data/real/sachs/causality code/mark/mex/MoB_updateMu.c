#include <math.h>
#include "mex.h"
#include "UGM_common.h"
 
 
void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
   /* Variables */
    int i,c,n,s,tmp,*Y,nInstances,nNodes,nStates,nComponents,sizGamma[2];
    
    double *gamma, *N,*mu,Z,*dirPrior;
    
    /* Input */
    Y = mxGetPr(prhs[0]);
    N = mxGetPr(prhs[1]);
    mu = mxGetPr(prhs[2]);
    gamma = mxGetPr(prhs[3]);
    dirPrior = mxGetPr(prhs[4]);
    
    /* Compute Sizes */
    nInstances = mxGetDimensions(prhs[0])[0];
    nNodes = mxGetDimensions(prhs[2])[0];
    nStates = mxGetDimensions(prhs[2])[1];
    nComponents = mxGetDimensions(prhs[1])[1];
    
    for(i=0;i < nInstances; i++)
    {
        for(n=0; n < nNodes;n++)
        {
            s = Y[i+nInstances*n]-1;
            for(c=0; c < nComponents;c++)
            {
                mu[n+nNodes*(s + nStates*c)] += gamma[i+nInstances*c]/N[c];
            }
        }
    }
    
    for(c=0; c < nComponents;c++)
    {
        for(n=0; n < nNodes;n++)
        {
            for(s=0;s < nStates; s++)
            {
                mu[n+nNodes*(s + nStates*c)] *= N[c]/(N[c]+*dirPrior);
                mu[n+nNodes*(s + nStates*c)] += *dirPrior/(N[c]+*dirPrior);
            }
        }
    }
    
    for(c=0; c < nComponents;c++)
    {
        for(n=0; n < nNodes;n++)
        {
            Z = 0;
            for(s=0;s < nStates; s++)
            {
                Z += mu[n+nNodes*(s + nStates*c)];
            }
            for(s=0;s < nStates; s++)
            {
               mu[n+nNodes*(s + nStates*c)] /= Z;
            }
        }
    }
}