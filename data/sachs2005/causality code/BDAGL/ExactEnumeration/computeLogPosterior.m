function posterior = computeLogPosterior( allFamilyLogMargLik, dags )
% compute p(G(i,j)=1|D) by summing over all graphs

% assumes a uniform prior over graphs

[nNodes] = size(allFamilyLogMargLik, 1);

prior = zeros(1, size(dags,1));

likelihood = zeros(1,size(dags,1));
for gi=1:size(dags,1 )
	if mod(gi,10000)==0 && nNodes>=5, fprintf('likelihood %i/%i\n',gi,length(dags)); end
	
	likelihood(gi) = logMargLikDag( char2dag(char(dags(gi,:)), nNodes), allFamilyLogMargLik );
end

posterior = likelihood + prior;
posterior = posterior - logsumexp(posterior);
