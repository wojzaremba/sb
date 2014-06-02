function model = factorGraph_exp_PairwiseUGMfull(Y,ising,lambda,infer)

if nargin < 4
    infer = 'Exact';
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
Xnode = ones(nInstances,1,nNodes);
Xedge = ones(nInstances,1,nEdges);
infoStruct = UGM_makeInfoStruct(Xnode,Xedge,edgeStruct,ising,0);
[w,v] = UGM_initWeights(infoStruct,@zeros);

% Set-up GroupL1 regularizer
lambda = 1;
nodeGroups = zeros(size(w));
edgeGroups = zeros(size(v));
for e = 1:nEdges
   edgeGroups(:,:,e) = e; 
end
switch infer
    case 'Exact'
        funObj = @(wv)UGM_MRFLoss(wv,Xnode,Xedge,Y,edgeStruct,infoStruct,@UGM_Infer_Exact);
    case 'Pseudo'
        funObj = @(wv)UGM_PseudoLoss(wv,Xnode,Xedge,Y,edgeStruct,infoStruct);
    case 'MF'
        funObj = @(wv)UGM_MRFLoss(wv,Xnode,Xedge,Y,edgeStruct,infoStruct,@UGM_Infer_MF);
    case 'LBP'
        funObj = @(wv)UGM_MRFLoss(wv,Xnode,Xedge,Y,edgeStruct,infoStruct,@UGM_Infer_LBP);
    case 'TRBP'
        funObj = @(wv)UGM_MRFLoss(wv,Xnode,Xedge,Y,edgeStruct,infoStruct,@UGM_Infer_TRBP);
end
options.mode = 'spg';
options.method = 'lbfgs';
options.corrections = 10;
options.maxIter = 1000;
options.verbose = 1;%3;

    wv = [w(:);v(:)];
        wv = L1groupMinConF(funObj,wv,[nodeGroups(:);edgeGroups(:)],lambda,options);

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
Xnode = ones(nInstances,1,nNodes);
Xedge = ones(nInstances,1,nEdges);
NLL = UGM_MRFLoss2(wv,Xnode,Xedge,Y,edgeStruct,infoStruct,@UGM_Infer_Exact);

end

function NLL = nll_unnormalized(model,Y)

[nInstances,nNodes] = size(Y);

wv = model.wv;
edgeStruct = model.edgeStruct;
infoStruct = model.infoStruct;

nEdges = edgeStruct.nEdges;
Xnode = ones(nInstances,1,nNodes);
Xedge = ones(nInstances,1,nEdges);
NLL = UGM_MRFLoss3(wv,Xnode,Xedge,Y,edgeStruct,infoStruct,@UGM_Infer_Exact);

end
