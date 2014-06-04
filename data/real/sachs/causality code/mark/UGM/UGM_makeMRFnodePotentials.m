function [nodePot] = makeNodePotentials(w,edgeStruct,infoStruct)
% Makes class potentials for each node
%
% w(feature,variable,variable) - node weights
% nStates - number of states per node
%
% nodePot(node,class)

if edgeStruct.useMex
   % Mex Code
   nodePot = UGM_makeNodePotentialsC(ones(1,1,edgeStruct.nNodes),w,int32(edgeStruct.nStates),int32(infoStruct.tieNodes));
else
   % Matlab Code
   nodePot = makeNodePotentials(ones(1,1,edgeStruct.nNodes),w,edgeStruct,infoStruct);
end
end

% C code does the same as below:
function [nodePot] = makeNodePotentials(X,w,edgeStruct,infoStruct)

nNodes = edgeStruct.nNodes;
tied = infoStruct.tieNodes;
nStates = edgeStruct.nStates;

if tied
    nw = w;
end

% Compute Node Potentials
nodePot = zeros(nNodes,max(nStates),1);
   for n = 1:nNodes
      if ~tied
         nw = w(:,1:nStates(n)-1,n);
      end
      nodePot(n,1:nStates(n)) = exp([X(i,:,n)*nw 0]);
   end
end
