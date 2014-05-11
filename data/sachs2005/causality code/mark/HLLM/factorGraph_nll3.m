function [nll,g] = factorGraph_nll3(w,ind1,ind2,ind3,Y,nStates,edges2,edges3)

useMex = 1;

[nSamples,nNodes] = size(Y);
nEdges2 = size(edges2,1);
nEdges3 = size(edges3,1);

[w1,w2,w3] = factorGraph_splitWeights3(w,ind1,ind2,ind3,nStates,nNodes,nEdges2,nEdges3);

nll = 0;

% Update based on sufficient statistics of data
for s = 1:nSamples
    logPot = factorGraph_logPotential3(Y(s,:),w1,w2,w3,edges2,edges3);
    nll = nll - logPot;
end

if nargout > 1
    g1 = zeros(size(w1));
    g2 = zeros(size(w2));
    g3 = zeros(size(w3));
   for s = 1:nSamples
       for n = 1:nNodes
           g1(Y(s,n),n) = g1(Y(s,n),n) - 1;
       end
       for e = 1:nEdges2
          g2(Y(s,edges2(e,1)),Y(s,edges2(e,2)),e) =  g2(Y(s,edges2(e,1)),Y(s,edges2(e,2)),e) - 1;
       end
       for e = 1:nEdges3
          g3(Y(s,edges3(e,1)),Y(s,edges3(e,2)),Y(s,edges3(e,3)),e) =  g3(Y(s,edges3(e,1)),Y(s,edges3(e,2)),Y(s,edges3(e,3)),e) - 1;
       end
   end
end

% Update based on sufficient statistics of model
if useMex
    [Z,bel1,bel2,bel3] = factorGraph_infer3C(w1,w2,w3,int32(edges2),int32(edges3));
else
    [Z,bel1,bel2,bel3] = factorGraph_infer3(w1,w2,w3,edges2,edges3);
end

nll = nll + nSamples*log(Z);

if nargout > 1
   g1 = g1 + nSamples*bel1;
   g2 = g2 + nSamples*bel2;
   g3 = g3 + nSamples*bel3;
   g = [g1(ind1);g2(ind2);g3(ind3)];
end