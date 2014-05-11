function logPredLikTrace = samplesToLogPredLikTrace(samples, nodeArity, ADTreePtr_train, data_test )

logPredLikTrace = zeros(size(samples.order));

runningHT = java.util.Hashtable(2^15);

% compute log predictive likelihood for each unique sample
keys = samples.HT.keys;
while keys.hasMoreElements()
	dagKey = keys.nextElement();

    dag = char2dag(char(dagKey), length(nodeArity));
    
    lpl = logPredLikDag(dag, posteriorMeanParams(dag, nodeArity, ADTreePtr_train), nodeArity, data_test );
    runningHT.put(dagKey, lpl);
end

for oi=1:length(samples.order)
   key = samples.order2DagHT.get(samples.order(oi));
   logPredLikTrace(oi) = runningHT.get(key);
end

clear('runningHT');