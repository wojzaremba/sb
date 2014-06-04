function ml = logMargLikDag( dag, logMargLik )
% compute the log marginal likelihood of a given dag
% use mkAllFamilyLogMargLik to compute the logMargLik

ml = 0;
for ni=1:length(dag)
	pa = find(dag(:,ni));
	k = sum(2.^(pa-1));
	ml = ml + logMargLik(ni, k+1);
end