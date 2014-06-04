function [ind1,ind2,ind3] = factorGraph_makeIndices3(nStates,nNodes,nEdges2,nEdges3)

tmp = ones(nStates,nNodes);
tmp(nStates,:) = 0;
ind1 = find(tmp(:));
tmp = ones(nStates,nStates,nEdges2);
tmp(nStates,nStates,:) = 0;
ind2 = find(tmp(:));
tmp = ones(nStates,nStates,nStates,nEdges3);
tmp(nStates,nStates,nStates,:) = 0;
ind3 = find(tmp(:));