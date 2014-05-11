function logMargLik = logMargLikOrder2( order, allFamilyLogScore )
% the log marginal likelihood of an order
% allFamilyLogScore = allFamilyLogMargLik+allFamilyLogPrior
% uses the C function addValidNode.c

nNodes = size(allFamilyLogScore, 1);

logMargLik = 0;

validFamilies = uint32(0);

for ni=1:nNodes
	logMargLik = logMargLik + logsumexp(allFamilyLogScore(order(ni),validFamilies+1));
	validFamilies = addValidNode( validFamilies, order(ni)-1 );
end

