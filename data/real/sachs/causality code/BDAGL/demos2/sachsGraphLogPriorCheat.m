function [logPrior isCyclic]= sachsGraphLogPriorCheat( dag )

[G, F, H] = sachsTrueDAG();

isCyclic = ~acyclic(dag);
if isCyclic
  logPrior = -Inf;
else
  ndiff = sum(abs(dag(:)-G(:)));
  logPrior = -5*ndiff; % p(G) propto exp(-num differences)
end
