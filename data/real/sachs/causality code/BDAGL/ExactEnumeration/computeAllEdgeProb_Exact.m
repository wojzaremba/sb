function [marginals map] = computeAllEdgeProb_Exact( logPrior, allFamilyLogMargLik )
% compute p(G(i,j)=1|D) by summing over all graphs

[nNodes] = size(allFamilyLogMargLik, 1);

if nNodes>6
    error('Calling this function for nNodes>6 is not recommended.');
end

dags = mkAllDags(nNodes);
%dags = mkAllDagsSlow(nNodes);

if logPrior==0
	prior = zeros(1, length(dags));
else
	if isa( logPrior, 'function_handle' )
		prior = zeros(1,length(dags));
		for gi=1:length(prior)
			prior(gi) = logPrior(char2dag(char(dags(gi,:)), nNodes));
%			prior(gi) = logPrior(dags{gi});
		end
	else
		prior = mkGraphLogPrior(nNodes, nNodes-1, logPrior, dags );
	end
end

likelihood = zeros(1,length(dags));
for gi=1:length(dags)
	if mod(gi,10000)==0 && nNodes>=5, fprintf('likelihood %i/%i\n',gi,length(dags)); end
	
	likelihood(gi) = logMargLikDag( char2dag(char(dags(gi,:)), nNodes), allFamilyLogMargLik );
%    likelihood(gi) = logMargLikDag( dags{gi}, allFamilyLogMargLik );
end

posterior = likelihood + prior;
posterior = exp(posterior - logsumexp(posterior));

[v mapI] = max(posterior);
map = char2dag(char(dags(mapI,:)), nNodes);

% now take weighted sum of all dags
marginals = zeros(nNodes, nNodes);
for gi=1:length(dags)
	if mod(gi,10000)==0 && nNodes>=5, fprintf('marginals %i/%i\n',gi,length(dags)); end
	
	marginals = marginals + posterior(gi) * char2dag(char(dags(gi,:)), nNodes);
%	marginals = marginals + posterior(gi) * dags{gi};
end


