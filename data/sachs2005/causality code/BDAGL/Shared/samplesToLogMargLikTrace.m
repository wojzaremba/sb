function logMargLikTrace = samplesToLogMargLikTrace(samples, aflml )

logMargLikTrace = zeros(size(samples.order));

runningHT = java.util.Hashtable(2^15);

% compute log predictive likelihood for each unique sample
keys = samples.HT.keys;
while keys.hasMoreElements()
	dagKey = keys.nextElement();

    dag = char2dag(char(dagKey), samples.nNodes );
    
    lml = logMargLikDag(dag, aflml);
    runningHT.put(dagKey, lml);
end

for oi=1:length(samples.order)
   key = samples.order2DagHT.get(samples.order(oi));
   logMargLikTrace(oi) = runningHT.get(key);
end

clear('runningHT');