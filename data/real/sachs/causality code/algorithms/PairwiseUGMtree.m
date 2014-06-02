function model = factorGraph_exp_Tree(Y,ising,lambda)

[nInstances,nNodes] = size(Y);
nStates = max(Y(:));

% Run Chow-Liu to find optimal tree
[tree,cpts,ll,adj] = chowliu(Y',nStates*ones(nNodes,1),0);
adj = adj+adj';

% Set up UGM
edgeStruct = UGM_makeEdgeStruct(adj,nStates);
nEdges = edgeStruct.nEdges;
Xnode = ones(nInstances,1,nNodes);
Xedge = ones(nInstances,1,nEdges);
infoStruct = UGM_makeInfoStruct(Xnode,Xedge,edgeStruct,ising,0);
[w,v] = UGM_initWeights(infoStruct,@zeros);
funObj = @(wv)UGM_MRFLoss(wv,Xnode,Xedge,Y,edgeStruct,infoStruct,@UGM_Infer_Tree);

wv = [w(:);v(:)];
regVect = lambda*[zeros(numel(w),1);ones(numel(v),1)];
wv = minFunc(@penalizedL2,wv,[],funObj,regVect);


model.wv = wv;
model.edgeStruct = edgeStruct;
model.infoStruct = infoStruct;
model.nll = @nll;
model.nll_unnormalized = @nll;

end


function NLL = nll(model,Y)

[nInstances,nNodes] = size(Y);

wv = model.wv;
edgeStruct = model.edgeStruct;
infoStruct = model.infoStruct;

nEdges = edgeStruct.nEdges;
Xnode = ones(nInstances,1,nNodes);
Xedge = ones(nInstances,1,nEdges);
NLL = UGM_MRFLoss2(wv,Xnode,Xedge,Y,edgeStruct,infoStruct,@UGM_Infer_Tree);

end
