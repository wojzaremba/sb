function logPredLik = samplesToLogPredLik(samples, allFamilyLogMargLik_data, allFamilyLogMargLik_train )
% convert the output of sampleDags*.m to edge marginals

count = samples.nSamples;

normConst = 0;
keys = samples.HT.keys;
while keys.hasMoreElements()
	dagKey = keys.nextElement();
	dagVal = samples.HT.get(dagKey);	
	
	if length(dagVal)==3, weight = dagVal(3); % order-fix reweighting (only applies for dag samples derived from order samples)
	else weight = 1; end
	
	normConst = normConst + dagVal(1)/count*weight;		
end

logPredLikNum = -Inf;
logPredLikDenom = -Inf;

keys = samples.HT.keys;
while keys.hasMoreElements()
	dagKey = keys.nextElement();
	dagVal = samples.HT.get(dagKey);	
	
	if length(dagVal)==3, weight = dagVal(3); % order-fix reweighting (only applies for dag samples derived from order samples)
	else weight = 1; end
		
	dag = char2dag(dagKey, samples.nNodes);
	logPredLikNum = logadd( logPredLikNum, log( (dagVal(1)*weight/count)/normConst) + logMargLikDag( dag, allFamilyLogMargLik_data) );
	logPredLikDenom = logadd( logPredLikDenom, log( (dagVal(1)*weight/count)/normConst) + logMargLikDag( dag, allFamilyLogMargLik_train) );
end

logPredLik = logPredLikNum - logPredLikDenom;