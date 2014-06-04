function [model] = graphLearn_CPDsoftmax(X,y,options)

if nargin < 3
    options = [];
end

[nStates,lambdaL2,lambdaL1,lambdaGL1,groups] = myProcessOptions(options,'nStates',0,'lambdaL2',0,'lambdaL1',0,'lambdaGL1',0,'groups',[]);

assert(nStates~=0,'nStates must be specified for softmax CPD');

[n,p] = size(X);

funObj = @(w)softmaxLoss2C(w,X,int32(y),nStates);

subOptions.Display = 'none';
subOptions.verbose = 0;
if lambdaL2 > 0
    lambdaMatrix = [zeros(1,nStates-1);lambdaL2*ones(p-1,nStates-1)];
    w = minFunc(@penalizedL2,zeros(p*(nStates-1),1),subOptions,funObj,lambdaMatrix(:));
    w = reshape(w,p,nStates-1);
    model.regloglik = @regloglikL2;
    model.lambda = lambdaMatrix(:);
elseif lambdaL1 > 0
    lambdaMatrix = [zeros(1,nStates-1);lambdaL2*ones(p-1,nStates-1)];
    w = L1GeneralProjectedSubGradient(funObj,zeros(p*(nStates-1),1),lambdaMatrix(:),subOptions);
    w = reshape(w,p,nStates-1);
elseif lambdaGL1 > 0
    subOptions.method = 'lbfgs';
    subOptions.mode = 'sop';
    groups=repmat(groups,[1 nStates-1]);
    if 0 % Group-L1 on edges
        w = L1groupMinConF(funObj,zeros(p*(nStates-1),1),groups(:),lambdaGL1,subOptions);
    else % Group-L1 on edges, small L2 on all parameters
        wrapFunObj = @(w)penalizedL2(w,funObj,1e-4);
        w = L1groupMinConF(wrapFunObj,zeros(p*(nStates-1),1),groups(:),lambdaGL1,subOptions);
    end
    w = reshape(w,p,nStates-1);
    model.lambda = lambdaGL1;
    model.regloglik = @regloglikGL1;
    model.groups = groups;
else
    w = minFunc(funObj,zeros(p*(nStates-1),1),subOptions);
    w = reshape(w,p,nStates-1);
end

model.w = w;
model.p = p;
model.nStates = nStates;
model.groups = groups;
model.loglik = @loglik;
model.loglik2 = @loglik2;
model.testNLL = @testNLL;
model.getWeights = @getWeights;

end

%%
function [f] = loglik(model,X,y)
f = -SoftmaxLoss2(model.w(:),X,y,model.nStates);
end

function [f] = loglik2(model,X,y)
f = -SoftmaxLoss3(model.w(:),X,y,model.nStates);
end

function [f] = regloglikL2(model,X,y)
f = -penalizedL2(model.w(:),@SoftmaxLoss2,model.lambda,X,y,model.nStates);
end

function [f] = regloglikGL1(model,X,y)
f = -penalizedL2(model.w(:),@SoftmaxLoss2,1e-4,X,y,model.nStates);
for g = 1:max(model.groups)
   f = f - model.lambda*norm(model.w(model.groups==g));
end
end

function weights = getWeights(model)
if length(model.groups) > 1
    weights = accumarray(model.groups(2:end),sum(abs(model.w(2:end,:)),2));
else
    weights = [];
end
end

function [f] = testNLL(model,Y,child,parents,nStates,clamped)

if isempty(clamped)
    X = Y(:,parents);
    y = Y(:,child);
else
    X = Y(clamped(:,child)==0,parents);
    y = Y(clamped(:,child)==0,child);
end

[nInstances,nVars] = size(X);
        nStatesX = nStates(parents);
        Xnew = zeros(nInstances,sum(nStatesX));
        for i = 1:nInstances
            offset = 1;
            for v = 1:nVars
                Xnew(i,offset+X(i,v)-1) = 1;
                offset = offset+nStatesX(v);
            end
        end
        X = [ones(nInstances,1) Xnew];

f = softmaxLoss2(model.w(:),X,y,model.nStates);
end