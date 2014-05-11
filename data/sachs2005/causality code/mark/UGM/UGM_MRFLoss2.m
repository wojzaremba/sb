function [f,g] = UGM_loss(wv,X,Xedge,y,edgeStruct,infoStruct,inferFunc,varargin)
% wv(variable)
% X(instance,feature,node)
% Xedge(instance,feature,edge)
% y(instance,node)
% edgeStruct
% inferFunc
% varargin - additional parameters of inferFunc

[nInstances,nNodeFeatures,nNodes] = size(X);
nInstances = size(y,1);
nEdgeFeatures = size(Xedge,2);
nFeatures = nNodeFeatures+nEdgeFeatures;
edgeEnds = edgeStruct.edgeEnds;
nEdges = size(edgeEnds,1);
tieNodes = infoStruct.tieNodes;
tieEdges = infoStruct.tieEdges;
ising = infoStruct.ising;
nStates = edgeStruct.nStates;
maxState = max(nStates);

% Form weights
[w,v] = UGM_splitWeights(wv,infoStruct);

f = 0;
if nargout > 1
    gw = zeros(size(w));
    gv = zeros(size(v));
end

% Make Potentials
nodePot = UGM_makeNodePotentials(X,w,edgeStruct,infoStruct);
if edgeStruct.useMex
    edgePot = UGM_makeEdgePotentialsC(Xedge,v,int32(edgeStruct.edgeEnds),int32(edgeStruct.nStates),int32(infoStruct.tieEdges),int32(infoStruct.ising));
else
    edgePot = UGM_makeEdgePotentials(Xedge,v,edgeStruct,infoStruct);
end

% Check that potentials don't overflow
if sum(nodePot(:))+sum(edgePot(:)) > 1e100
    f = inf;
    if nargout > 1
        gw = gw(infoStruct.wLinInd);
        gv = gv(infoStruct.vLinInd);
        g = [gw(:);gv(:)];
    end
    return;
end

% For MRFs, we only do inference once
[nodeBel,edgeBel,logZ] = inferFunc(nodePot,edgePot,edgeStruct,varargin{:});

f = logZ*ones(nInstances,1);
for i = 1:nInstances
    % Caculate Potential of Observed Labels
    pot = 0;
    for n = 1:nNodes
        pot = pot + log(nodePot(n,y(i,n)));
    end
    for e = 1:nEdges
        n1 = edgeEnds(e,1);
        n2 = edgeEnds(e,2);
        pot = pot + log(edgePot(y(i,n1),y(i,n2),e));
    end

    % Update  based on this training example
    f(i) = f(i) - pot;
end


end

