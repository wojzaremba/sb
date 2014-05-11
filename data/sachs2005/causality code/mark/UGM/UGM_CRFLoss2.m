function [f,g] = UGM_loss(wv,X,Xedge,y,edgeStruct,infoStruct,inferFunc,varargin)
% wv(variable)
% X(instance,feature,node)
% Xedge(instance,feature,edge)
% y(instance,node)
% edgeStruct
% inferFunc
% varargin - additional parameters of inferFunc

showErr = 0;

[nInstances,nNodeFeatures,nNodes] = size(X);
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
nodePot = UGM_makeCRFNodePotentials(X,w,edgeStruct,infoStruct);
if edgeStruct.useMex
    edgePot = UGM_makeEdgePotentialsC(Xedge,v,int32(edgeStruct.edgeEnds),int32(edgeStruct.nStates),int32(infoStruct.tieEdges),int32(infoStruct.ising));
else
    edgePot = UGM_makeCRFEdgePotentials(Xedge,v,edgeStruct,infoStruct);
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

actions = unique(X(:,:,1),'rows')
f = zeros(nInstances,1);
for a = 1:size(actions,1)
   actionNdx = find(all(X(:,:,1) == repmat(actions(a,:),[nInstances 1]),2));
   
   % We only need to do inference once for each action
   [nodeBel,edgeBel,logZ] = inferFunc(nodePot(:,:,actionNdx(1)),edgePot(:,:,:,actionNdx(1)),edgeStruct,varargin{:});
   
   for i = actionNdx(:)'
       
       % Caculate Potential of Observed Labels
       pot = 0;
       for n = 1:nNodes
           pot = pot + log(nodePot(n,y(i,n),i));
       end
       for e = 1:nEdges
           n1 = edgeEnds(e,1);
           n2 = edgeEnds(e,2);
           pot = pot + log(edgePot(y(i,n1),y(i,n2),e,i));
       end
       
       % Update objective based on this trainig example
       f(i) = -pot + logZ;
   end
   
end
end

