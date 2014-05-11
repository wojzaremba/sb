#include <math.h>
#include "mex.h"

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    /* Variables */
    int i,c,v,n,p,k,*y;
    double *w,*X,*Xw, *Z, *nll, *g, marg;
    
    /* Input */
    w = mxGetPr(prhs[0]);
    X = mxGetPr(prhs[1]);
    y = mxGetPr(prhs[2]);
    k = mxGetScalar(prhs[3]);
    
    /* Compute Sizes */
    n = mxGetDimensions(prhs[1])[0];
    p = mxGetDimensions(prhs[1])[1];
    
    /* Output */
    plhs[0] = mxCreateDoubleMatrix(1,1,mxREAL);
    nll = mxGetPr(plhs[0]);
    
    /* Xw = X*[w 0] */
    Xw = mxCalloc(n*k,sizeof(double));
    for(i = 0; i < n; i++)
    {
        for(c = 0; c < k-1; c++)
        {
            for(v = 0; v < p; v++)
            {
                Xw[i + n*c] += X[i + n*v]*w[v + p*c];
            }
        }
    }
    
    /* Z = sum(exp(X*w),2) */
    Z = mxCalloc(n,sizeof(double));
    for(i = 0; i < n; i++)
    {
        for(c = 0; c < k-1; c++)
        {
            Z[i] += exp(Xw[i + n*c]);
        }
        Z[i] += 1;;
    }
        
    /* nll = sum_i -Xw(i,y(i)) + log(Z(i)) */
    *nll = 0;
    for(i = 0; i < n; i++)
    {
        *nll += -Xw[i + n*(y[i]-1)] + log(Z[i]);
    }
    
    if(nlhs == 2)
    {
        plhs[1] = mxCreateDoubleMatrix(p*(k-1),1,mxREAL);
        g = mxGetPr(plhs[1]);
        
        /* g(:,c) = -DX, with D = diag((y==c) - exp(Xw(c))/Z) */
        for(i = 0; i < n; i++)
        {
            for(c = 0; c < k-1; c++)
            {
                marg = 0;
                if(y[i]-1==c)
                    marg = 1;
                marg -= exp(Xw[i + n*c])/Z[i];
                for(v = 0; v < p; v++)
                {
                    g[v + p*c] -= X[i + n*v]*marg;
                }
            }
        }
    }
    
    mxFree(Xw);
    mxFree(Z);
}
