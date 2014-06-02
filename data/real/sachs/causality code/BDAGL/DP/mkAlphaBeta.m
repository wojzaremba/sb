function [alpha beta] = mkAlphaBeta(logRho, logAllFamilyMargLik)
global nNodes;

beta = logAllFamilyMargLik + logRho;

% we assume q, the "factor" (prior) on orderings, is always uniform.
% othwerwise, alpha is the product of the mobius-transformed beta, and q
% q = 1;

alpha = zeros(nNodes, 2^nNodes);
for i=1:nNodes
	alpha(i,:) = fumtl(beta(i,:));
end
