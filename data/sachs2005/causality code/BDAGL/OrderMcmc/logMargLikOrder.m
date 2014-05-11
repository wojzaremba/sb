function logMargLik = logMargLikOrder( order, allFamilyLogScore )
% the log marginal likelihood of an order
% allFamilyLogScore = allFamilyLogMargLik+allFamilyLogPrior

% right now we cannot use the computational trick mentioned in kollers
% paper, ie saving computation when you only swap two indices of the order.
% this is because for both endpoints and all nodes in between you still
% have to identify all the changed families (with the addition/deletion of
% the endpoints)... which requires a fumt... well, maybe not. what i'm
% trying to say is that it's 3am and i don't "think" it's going to speed us
% up much. it helped koller b/c their "allFamilyLogScore" "matrix" was
% highly sparse, since they have a high in-bound restriction and use
% pruning to get rid of a lot of low-prob families

nNodes = size(allFamilyLogScore, 1);

logMargLik = 0;

validFamilies = uint32(0);

for ni=1:nNodes
	logMargLik = logMargLik + logsumexp(allFamilyLogScore(order(ni),validFamilies+1));
	validFamilies = addValidNode( validFamilies, order(ni)-1 );
end

