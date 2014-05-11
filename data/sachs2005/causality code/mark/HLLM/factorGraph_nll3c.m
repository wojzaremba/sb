function [nll,g] = factorGraph_nll3(w,ind1,ind2,ind3,Y,nStates,edges2,edges3)

useMex = 1;

[nSamples,nNodes] = size(Y);
nEdges2 = size(edges2,1);
nEdges3 = size(edges3,1);

[w1,w2,w3] = factorGraph_splitWeights3(w,ind1,ind2,ind3,nStates,nNodes,nEdges2,nEdges3);


% Update based on sufficient statistics of data
nll = zeros(nSamples,1);
for s = 1:nSamples
    nll(s) = -factorGraph_logPotential3(Y(s,:),w1,w2,w3,edges2,edges3);
end