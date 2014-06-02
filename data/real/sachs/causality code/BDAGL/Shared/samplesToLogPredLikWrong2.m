function logPredLik = samplesToLogPredLik(samples, allFamilyLogMargLik_train, allFamilyLogMargLik_data)
% convert the output of sampleDags*.m to edge marginals

count = samples.nSamples;

logPredLik = -Inf;

normConst = 0;
keys = samples.HT.keys;
while keys.hasMoreElements()
	dagKey = keys.nextElement();
	dagVal = samples.HT.get(dagKey);	
	
	if length(dagVal)==3, weight = dagVal(3); % order-fix reweighting (only applies for dag samples derived from order samples)
	else weight = 1; end
	
	normConst = normConst + dagVal(1)/count*weight;		
end


keys = samples.HT.keys;
while keys.hasMoreElements()
	dagKey = keys.nextElement();
	dagVal = samples.HT.get(dagKey);	
	
	if length(dagVal)==3, weight = dagVal(3); % order-fix reweighting (only applies for dag samples derived from order samples)
	else weight = 1; end
		
	dag = char2dag(dagKey, samples.nNodes);
	logPredLik = logadd( logPredLik, log( (dagVal(1)*weight/count)/normConst) + logMargLikDag( dag, allFamilyLogMargLik_data) - logMargLikDag( dag, allFamilyLogMargLik_train) );
end
