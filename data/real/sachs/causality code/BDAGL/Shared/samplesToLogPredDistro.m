function logPredDistro = samplesToLogPredDistro(samples, nodeArity, ADTreePtr_train )

subs = ind2subv( nodeArity, 1:prod(nodeArity) ); % all possible values

count = samples.nSamples;
    
nDags = samples.HT.size;

logPredDistro = zeros( nDags, size(subs,1) ); % #dags by #states

empiricalDagPosterior = zeros( nDags, 1);

keys = samples.HT.keys;
j = 0;
while keys.hasMoreElements()
    dagKey = keys.nextElement();
    dagVal = samples.HT.get(dagKey);

    dag = char2dag(dagKey, samples.nNodes);
    
    params = posteriorMeanParams(dag, nodeArity, ADTreePtr_train);
    weight = dagVal(1)/count; % q(M|D)
    
    j=j+1;
    
    empiricalDagPosterior(j) = log(weight);
        
    for si=1:size(subs,1)
        logPredDistro(j,si) = logPredLikDag(dag, params, nodeArity, subs(si,:)' );    
    end
    
    fprintf('%i/%i\n', j, size(logPredDistro,1));
end

empiricalDagPosterior = empiricalDagPosterior - logsumexp(empiricalDagPosterior);
empiricalDagPosterior = repmat(empiricalDagPosterior, 1, size(subs,1) );

logPredDistro = logsumexp(empiricalDagPosterior + logPredDistro);