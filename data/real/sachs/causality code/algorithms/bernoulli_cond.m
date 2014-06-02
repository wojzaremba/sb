function model = bernoulli_cond(data,lambda,lambdaSmall)
% fits a seperate product of bernoullis for every action regime

if nargin < 3
    lambdaSmall = 1e-4;
end

X = data.X;
[nSamples,nNodes] = size(X);
nStates = data.nStates;

A = data.A;
nActionVars = size(A,2);

options.Display = 'none';
w_init = zeros(1+nActionVars,nStates-1);
lambdaMatrix = ones(1+nActionVars,nStates-1);
lambdaMatrix(1,:) = lambdaSmall; % Small regularization on bias
nVars = (1+nActionVars)*(nStates-1);
for n = 1:nNodes
    funObj = @(w)SoftmaxLoss2(w,[ones(nSamples,1) A],X(:,n),nStates);
    w{n} = minFunc(@penalizedL2,w_init(:),options,funObj,lambda*lambdaMatrix(:));
end

model.w = w;
model.nll = @nll;
model.nll_unnormalized = @nll;

end

function NLL = nll(model,data)

X = data.X;
A = data.A;
[nInst,nNodes] = size(X);

NLL = zeros(nInst,1);
for n = 1:nNodes
   NLL = NLL + SoftmaxLoss3(model.w{n},[ones(nInst,1) data.A],X(:,n),data.nStates); 
end

end