function model = factorGraph_exp_PairwiseUGMfull(Y,ising,lambda,infer)

if nargin < 4
    infer = 'Exact'
end

% add a check that we don't try to do inference on a giant dataset
%if size( Y, 2 ) >= 20
%    error('Attempting to run exact inference on a model with > 20 dimensions.  There is no reason you can''t do this, it is just really really slow\n' );
%end

[nInstances,nNodes] = size(Y);
nStates = max(Y(:));

% Use all possible edges
adj = fixed_Full(nNodes);

edgeStruct = UGM_makeEdgeStruct(adj,nStates);
nEdges = edgeStruct.nEdges;

if strcmp(infer,'Pseudo')
    Xnode = ones(1,1,nNodes);
    Xedge = ones(1,1,nEdges);
else
    Xnode = ones(nInstances,1,nNodes);
    Xedge = ones(nInstances,1,nEdges);
end
infoStruct = UGM_makeInfoStruct(Xnode,Xedge,edgeStruct,ising,0);
[w,v] = UGM_initWeights(infoStruct,@zeros);

switch infer
    case 'Exact'
        funObj = @(wv)UGM_MRFLoss(wv,Xnode,Xedge,Y,edgeStruct,infoStruct,@UGM_Infer_Exact);
    case 'Pseudo'
        funObj = @(wv)UGM_MRFpseudoLoss(wv,Xnode,Xedge,Y,edgeStruct,infoStruct);
    case 'MF'
        funObj = @(wv)UGM_MRFLoss(wv,Xnode,Xedge,Y,edgeStruct,infoStruct,@UGM_Infer_MF);
    case 'LBP'
        funObj = @(wv)UGM_MRFLoss(wv,Xnode,Xedge,Y,edgeStruct,infoStruct,@UGM_Infer_LBP);
    case 'TRBP'
        funObj = @(wv)UGM_MRFLoss(wv,Xnode,Xedge,Y,edgeStruct,infoStruct,@UGM_Infer_TRBP);
end

wv = [w(:);v(:)];
regVect = lambda*[zeros(numel(w),1);ones(numel(v),1)];
%options.LS_init = 2;
options.Display = 'Full';
options.TolX = 1e-5;
options.TolFun = 1e-5;
%options.LS = 2;
wv = minFunc(@penalizedL2,wv,options,funObj,regVect);

model.wv = wv;
model.edgeStruct = edgeStruct;
model.infoStruct = infoStruct;
model.nll = @nll;
model.nll_unnormalized = @nll_unnormalized;

end


function NLL = nll(model,Y)

[nInstances,nNodes] = size(Y);

wv = model.wv;
edgeStruct = model.edgeStruct;
infoStruct = model.infoStruct;

nEdges = edgeStruct.nEdges;
Xnode = ones(1,1,nNodes);
Xedge = ones(1,1,nEdges);
NLL = UGM_MRFLoss2(wv,Xnode,Xedge,Y,edgeStruct,infoStruct,@UGM_Infer_Exact);

end

function NLL = nll_unnormalized(model,Y)

[nInstances,nNodes] = size(Y);

wv = model.wv;
edgeStruct = model.edgeStruct;
infoStruct = model.infoStruct;

nEdges = edgeStruct.nEdges;
Xnode = ones(1,1,nNodes);
Xedge = ones(1,1,nEdges);
NLL = UGM_MRFLoss3(wv,Xnode,Xedge,Y,edgeStruct,infoStruct,@UGM_Infer_Exact);

end
