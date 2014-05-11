function logPredLik = computeLogPredLik_Exact( logPrior, allFamilyLogMargLik_train, ADTreePtr_train, data_test, nodeArity )
% compute p(G(i,j)=1|D) by summing over all graphs

[nNodes] = size(allFamilyLogMargLik_train, 1);

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

logPredLik = zeros(1,length(dags));
likelihood = zeros(1,length(dags));
tic;
for gi=1:length(dags)
	if mod(gi,2500)==0 && nNodes>=5, fprintf('likelihood %i/%i\n',gi,length(dags)); toc, end
	
	dag = char2dag(char(dags(gi,:)),nNodes);
	logPredLik(gi) = logPredLikDag( dag, posteriorMeanParams(dag, nodeArity, ADTreePtr_train), nodeArity, data_test );
	likelihood(gi) = logMargLikDag( dag, allFamilyLogMargLik_train );    
end

posterior = likelihood + prior;
posterior = posterior - logsumexp(posterior);

logPredLik = logadd_sum( posterior + logPredLik);
