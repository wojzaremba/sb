function model = UGM_ig(data,ising,lambda,infer,doGroupL1,lambdaSmall)

if nargin < 5
    doGroupL1 = 0;
end

if nargin < 6
    lambdaSmall = 1e-4;
end

EXACT = 0;
PSEUDO = 1;
MEANFIELD = 2;
LOOPY = 3;
TRBP = 4;

Y = data.X;
[nSamples,nNodes] = size(Y);
nStates = data.nStates;

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

model.wv = wv;
model.edgeStruct = edgeStruct;
model.infoStruct = infoStruct;
model.nll = @nll;
model.nll_unnormalized = @nll_unnormalized;

end


function NLL = nll(model,data)

Y = data.X;
[nInstances,nNodes] = size(Y);

wv = model.wv;
edgeStruct = model.edgeStruct;
infoStruct = model.infoStruct;

nEdges = edgeStruct.nEdges;
Xnode = ones(1,1,nNodes);
Xedge = ones(1,1,nEdges);
NLL = UGM_MRFLoss2(wv,Xnode,Xedge,Y,edgeStruct,infoStruct,@UGM_Infer_Exact);

end

function NLL = nll_unnormalized(model,data)

Y = data.X;
[nInstances,nNodes] = size(Y);

wv = model.wv;
edgeStruct = model.edgeStruct;
infoStruct = model.infoStruct;

nEdges = edgeStruct.nEdges;
Xnode = ones(1,1,nNodes);
Xedge = ones(1,1,nEdges);
NLL = UGM_MRFLoss3(wv,Xnode,Xedge,Y,edgeStruct,infoStruct,@UGM_Infer_Exact);

end
