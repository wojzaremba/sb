function [logPrior isCyclic]= sachsGraphLogPriorKEGG( dag )

load sachsPriorKEGG
% From Werhli and Husmeier, 2007
%"Reconstructing Gene Regulatory Networks with Bayesian
%Networks by Combining Expression Data with Multiple Sources of Prior Knowledge",


isCyclic = ~acyclic(dag);
if isCyclic
  logPrior = -Inf;
else
  ndiff = sum(abs(dag(:)-Gprior(:)));
  logPrior = -8*ndiff; % p(G) propto exp(-num differences)
end
