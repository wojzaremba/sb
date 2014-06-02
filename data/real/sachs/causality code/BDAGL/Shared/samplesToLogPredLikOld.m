function mlogPredLik = samplesToLogPredLik(samples, nodeArity, ADTreePtr_train, testData )
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

iii = 0;
mlogPredLik = -Inf;
keys = samples.HT.keys;
while keys.hasMoreElements()
	dagKey = keys.nextElement();
	dagVal = samples.HT.get(dagKey);	
	
	if length(dagVal)==3, weight = dagVal(3); % order-fix reweighting (only applies for dag samples derived from order samples)
	else weight = 1; end
			
	dag = char2dag(dagKey, samples.nNodes);
	
	iii = iii + 1;
	if mod(iii,1000)==0, fprintf('%i/%i\n', iii, samples.HT.size); end
	
	mlogPredLik = logadd(mlogPredLik,  log( (dagVal(1)*weight/count)/normConst ) + logPredLikDagOld(dag, posteriorMeanParams(dag, nodeArity, ADTreePtr_train), nodeArity, testData ));
end
