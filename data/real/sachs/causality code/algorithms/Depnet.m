function model = Depnet(Y,lambdaL2, ignore, ignore2)
% Note: Assumes binary {1,2} data
[nSamples,nNodes] = size(Y);
nStates = max(Y(:));

% Convert from {1,2} to {-1,1}
Y(Y==2)=-1;

options = [];
options.Display = 1;
options.TolX = 1e-5;
options.TolFun = 1e-5;
for n = 1:nNodes
    fprintf('Processing Node %d\n',n);
    X = [ones(nSamples,1) Y(:,[1:n-1 n+1:nNodes])];
    lambda = lambdaL2*[0;ones(nNodes-1,1)];
    funObj = @(w)LogisticLoss(w,X,Y(:,n));
    w(:,n) = minFunc(@penalizedL2,zeros(nNodes,1),options,funObj,lambda);
end

model.w = w;
model.nll = @nll;
model.nll_unnormalized = @nll_unnormalized;

end

function NLL = nll(model,Y, ignore)
fprintf('Warning: David implemented something wrong\n');
    NLL = NaN(size(Y,1),1);
end

function NLL = nll_unnormalized(model,Y)
[nSamples,nNodes] = size(Y);

Y(Y==2) = -1;

NLL = zeros(nSamples,1);
for n = 1:nNodes
    X = [ones(nSamples,1) Y(:,[1:n-1 n+1:nNodes])];
    Xw = X*model.w(:,n);
    yXw = Y(:,n).*Xw;
    NLL = NLL + mylogsumexp([zeros(nSamples,1) -yXw]);
end
end