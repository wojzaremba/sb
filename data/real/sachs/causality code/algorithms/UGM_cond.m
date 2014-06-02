function model = UGM_cond(data,ising,lambda,infer,doGroupL1,lambdaSmall)

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

A = data.A;
nActions = size(A,2);

[nInstances,nNodes] = size(Y);

% Use all possible edges
adj = fixed_Full(nNodes);

edgeStruct = UGM_makeEdgeStruct(adj,nStates);
nEdges = edgeStruct.nEdges;

% Make feature vectors
Xnode = repmat(A,[1 1 nNodes]);
Xedge = UGM_makeEdgeFeatures(Xnode,edgeStruct.edgeEnds,ones(nActions,1));

% Add bias to each node and edge
Xnode = [ones(nInstances,1,nNodes) Xnode];
Xedge = [ones(nInstances,1,nEdges) Xedge];

infoStruct = UGM_makeCRFInfoStruct(Xnode,Xedge,edgeStruct,ising,0);
[w,v] = UGM_initWeights(infoStruct,@zeros);

switch infer
    case EXACT
        funObj = @(wv)UGM_CRFLoss(wv,Xnode,Xedge,Y,edgeStruct,infoStruct,@UGM_Infer_Exact);
    case PSEUDO
        funObj = @(wv)UGM_CRFpseudoLoss(wv,Xnode,Xedge,Y,edgeStruct,infoStruct);
    case MEANFIELD
        funObj = @(wv)UGM_CRFLoss(wv,Xnode,Xedge,Y,edgeStruct,infoStruct,@UGM_Infer_MF);
    case LOOPY
        funObj = @(wv)UGM_CRFLoss(wv,Xnode,Xedge,Y,edgeStruct,infoStruct,@UGM_Infer_LBP);
    case TRBP
        funObj = @(wv)UGM_CRFLoss(wv,Xnode,Xedge,Y,edgeStruct,infoStruct,@UGM_Infer_TRBP);
end

wv = [w(:);v(:)];

if doGroupL1
     % Set up L2-regularization of node biases
     regW = zeros(size(w));
     regW(1,:,:) = lambdaSmall;
     regV = zeros(size(v));
     regVectL2 = [regW(:);regV(:)];
     wrapFunObj = @(wv)penalizedL2(wv,funObj,regVectL2);
    
    % Set up Group-L1 regularization of edge parameters
    nodeGroups = zeros(size(w));
    g = 1;
    for f = 1:nActions
        for n = 1:nNodes
            nodeGroups(f+1,:,n) = g;
            g = g+1;
        end
    end
    edgeGroups = zeros(size(v));
    for f = 0:nActions
        for e = 1:nEdges
            edgeGroups(f+1,:,e) = g;
            g=g+1;
        end
    end
    groups = [nodeGroups(:);edgeGroups(:)];
    
    options.maxIter = 500;
    options.optTol = 1e-5;
    options.mode = 'sop';
    wv = L1groupMinConF(wrapFunObj,wv,groups,lambda,options);
else
    regW = lambda*ones(size(w));
    regW(1,:,:) = lambdaSmall;
    regV = lambda*ones(size(v));
    regVect = [regW(:);regV(:)];
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
nEdges = edgeStruct.nEdges;
infoStruct = model.infoStruct;

% Make feature vectors
A = data.A;
nActions = size(A,2);
Xnode = repmat(A,[1 1 nNodes]);
Xedge = UGM_makeEdgeFeatures(Xnode,model.edgeStruct.edgeEnds,ones(nActions,1));

% Add bias to each node and edge
Xnode = [ones(nInstances,1,nNodes) Xnode];
Xedge = [ones(nInstances,1,nEdges) Xedge];

NLL = UGM_CRFLoss2(wv,Xnode,Xedge,Y,edgeStruct,infoStruct,@UGM_Infer_Exact);

end
