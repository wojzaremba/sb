function model = UGM_ind(data,ising,lambda,infer,doGroupL1,lambdaSmall)

if nargin < 5
    groupL1 = 0;
end

if nargin < 6
    lambdaSmall = 1e-4;
end

Y = data.X;
[nInst,nNodes] = size(Y);
nStates = data.nStates;

% Sort actions
A = data.A;
[A,ind] = sortrows(A);
Y = Y(ind,:);

% Fit a model for every action
action = 1;
actionStart = 1;
for i = 1:nInst
    if i < nInst && ~all(A(i,:)==A(i+1,:));
        actionEnd = i;
        [wv{action},edgeStruct{action},infoStruct{action}] = fit(Y(actionStart:actionEnd,:),nStates,ising,lambda,infer,doGroupL1,lambdaSmall);

        action = action+1;
        actionStart = i+1;
    end
    if i == nInst
        actionEnd = i;
        [wv{action},edgeStruct{action},infoStruct{action}] = fit(Y(actionStart:actionEnd,:),nStates,ising,lambda,infer,doGroupL1,lambdaSmall);
    end
end

model.wv = wv;
model.edgeStruct = edgeStruct;
model.infoStruct = infoStruct;
model.nll = @nll;
model.nll_unnormalized = @nll_unnormalized;
model.actions = unique(A,'rows');

end

function [wv,edgeStruct,infoStruct] = fit(Y,nStates,ising,lambda,infer,doGroupL1,lambdaSmall)
EXACT = 0;
PSEUDO = 1;
MEANFIELD = 2;
LOOPY = 3;
TRBP = 4;

[nInst,nNodes] = size(Y);

% Use all possible edges
adj = fixed_Full(nNodes);

edgeStruct = UGM_makeEdgeStruct(adj,nStates);
nEdges = edgeStruct.nEdges;

infoStruct = UGM_makeMRFInfoStruct(nNodes,edgeStruct,ising,0);
[w,v] = UGM_initWeights(infoStruct,@zeros);

switch infer
    case EXACT
        funObj = @(wv)UGM_MRFLoss(wv,Y,edgeStruct,infoStruct,@UGM_Infer_Exact);
    case PSEUDO
        funObj = @(wv)UGM_MRFpseudoLoss(wv,Y,edgeStruct,infoStruct);
    case MEANFIELD
        funObj = @(wv)UGM_MRFLoss(wv,Y,edgeStruct,infoStruct,@UGM_Infer_MF);
    case LOOPY
        funObj = @(wv)UGM_MRFLoss(wv,Y,edgeStruct,infoStruct,@UGM_Infer_LBP);
    case TRBP
        funObj = @(wv)UGM_MRFLoss(wv,Y,edgeStruct,infoStruct,@UGM_Infer_TRBP);
end

wv = [w(:);v(:)];

if doGroupL1
    % Set up L2-regularization of node biases
    regVectL2 = [lambdaSmall*ones(numel(w),1);zeros(numel(v),1)];
    wrapFunObj = @(wv)penalizedL2(wv,funObj,regVectL2);
    
    % Set up Group-L1 regularization of edge parameters
    nodeGroups = zeros(size(w));
    edgeGroups = zeros(size(v));
    for e = 1:nEdges
       edgeGroups(:,:,e) = e;
    end
    groups = [nodeGroups(:);edgeGroups(:)];
    
    options.maxIter = 500;
    options.optTol = 1e-5;
    options.mode = 'sop';
    wv = L1groupMinConF(wrapFunObj,wv,groups,lambda,options);
else
    % Just use L2-regularization
    regVect = [lambdaSmall*ones(numel(w),1);lambda*ones(numel(v),1)];
    options.Display = 'Full';
    options.TolX = 1e-5;
    options.TolFun = 1e-5;
    wv = minFunc(@penalizedL2,wv,options,funObj,regVect);
end
end


function NLL = nll(model,data)

Y = data.X;
[nInst,nNodes] = size(Y);

A = data.A;
nStates = data.nStates;

actions_train = model.actions;
nActions = size(actions_train,1);

actions_test = unique(A,'rows');

NLL = zeros(nInst,1);
for a = 1:size(actions_test,1)
    actionNdx = find(all(A == repmat(actions_test(a,:),[nInst 1]),2));

    actionFound = 0;
    for atrain = 1:nActions
        if all(actions_test(a,:)==actions_train(atrain,:))
            actionFound = 1;
            wv = model.wv{atrain};
            edgeStruct = model.edgeStruct{atrain};
            infoStruct = model.infoStruct{atrain};

            nEdges = edgeStruct.nEdges;
            Xnode = ones(1,1,nNodes);
            Xedge = ones(1,1,nEdges);
            NLL(actionNdx) = UGM_MRFLoss2(wv,Xnode,Xedge,Y(actionNdx,:),edgeStruct,infoStruct,@UGM_Infer_Exact);
        end
    end
    if ~actionFound
        % This is an action that was not present in training
        NLL(actionNdx) = -nNodes*log(1/nStates);
    end
end
end

