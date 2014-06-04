function logPot = factorGraph_logPotential3(y,w1,w2,w3,edges2,edges3)

nNodes = size(w1,2);
nEdges2 = size(w2,3);
nEdges3 = size(w3,4);

logPot = 0;
for n = 1:nNodes
   logPot = logPot + w1(y(n),n);
end
for e = 1:nEdges2
   logPot = logPot + w2(y(edges2(e,1)),y(edges2(e,2)),e); 
end
for e = 1:nEdges3
   logPot = logPot + w3(y(edges3(e,1)),y(edges3(e,2)),y(edges3(e,3)),e); 
end