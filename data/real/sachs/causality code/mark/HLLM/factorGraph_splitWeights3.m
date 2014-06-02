function [w1,w2,w3] = factorGraph_splitWeights3(w,ind1,ind2,ind3,nStates,nNodes,nEdges2,nEdges3)

ndx1 = 1;
ndx2 = length(ind1);
w1 = zeros(nStates,nNodes);
w1(ind1) = w(ndx1:ndx2);

ndx1 = ndx2+1;
ndx2 = ndx2+length(ind2);
w2 = zeros(nStates,nStates,nEdges2);
w2(ind2) = w(ndx1:ndx2);

ndx1 = ndx2+1;
ndx2 = ndx2+length(ind3);
w3 = zeros(nStates,nStates,nStates,nEdges3);
w3(ind3) = w(ndx1:end);