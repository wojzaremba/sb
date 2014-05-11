function [logPredLik midpointTime] = samplesToLogPredLikFixedTime(samples, diagnostics, nodeArity, ADTreePtr_train,  ...
	data_test, increment, lengthOnly )
% convert the output of sampleDags*.m to log predictive likelihoods
% use the sampler timing -- use all samples up to t1, where t1 is
% increasing by increment

t0 = diagnostics.timing(1);
tEnd = diagnostics.timing(end);

nTicks = ceil((tEnd-t0)/increment);

logPredLik = repmat(-Inf, 1, nTicks);
midpointTime = (1:nTicks)*increment - increment/2;

if nargin==7 && lengthOnly
	return;
end

runningHT = java.util.Hashtable(2^15);

j = 1;
for i=1:nTicks
		
	while j<=samples.nSamples && (diagnostics.timing(j)-t0)<=(i*increment)
		dagKey = samples.order2DagHT.get( samples.order(j) );
		dagValue = runningHT.get(dagKey);
		if isempty(dagValue)
			count = 1;
			dag = char2dag(dagKey, samples.nNodes);
			dagValueOriginal = samples.HT.get( dagKey );
			if length(dagValueOriginal)==3, weight = dagValueOriginal(3);
			else weight = 1; end
			
			lpl = logPredLikDagOld(dag, posteriorMeanParams(dag, nodeArity, ADTreePtr_train), nodeArity, data_test );
		else
			count = dagValue(1) + 1;
			lpl = dagValue(2);
			weight = dagValue(3);
		end
		runningHT.put(dagKey, [count lpl weight]);

		j = j+1;
	end
	
	normConstant = 0;
	values = runningHT.values.iterator;
	while values.hasNext()
		v = values.next();
		weight = v(3); % order-fix reweighting (only applies for dag samples derived from order samples)
		normConstant = normConstant + v(1)/(j-1)*weight;
	end

	logPredLik(i) = -Inf;
	values = runningHT.values.iterator;
	while values.hasNext()
		v = values.next();
		weight = v(3); % order-fix reweighting (only applies for dag samples derived from order samples)
		
		logPredLik(i) = logadd( logPredLik(i), log( (v(1)/(j-1)*weight)/normConstant ) + v(2) );
    end
    logPredLik(i) = logPredLik(i) / size(data_test,2);
%	edgeProb( :,:, i ) = runningSum/(j-1);
end

clear('runningHT');