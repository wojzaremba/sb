nInstances = 100;
nVars = 10;

X = randn(nInstances,nVars);
A = X'*X;
b = randn(nVars,1);

wDirect = A\b

optTol = 1e-10;
[wCG,k,res] = conjGrad(A,b,optTol,nVars)

precFunc = @precondFull;
precArgs = {eye(nVars)};
[wCG,k,res] = conjGrad(A,b,optTol,nVars,1,precFunc,precArgs)


P = iterPCG(A,b,1e-5,nVars);
precArgs = {P};
[wCG,k,res] = conjGrad(A,b,optTol,nVars,1,precFunc,precArgs)