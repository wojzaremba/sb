function [edgeProb midpointTime] = samplesToEdgeMarginalsFixedTime(samples, diagnostics, increment)
% convert the output of sampleDags*.m to edge marginals
% use the sampler timing -- use all samples up to t1, where t1 is
% increasing by increment

t0 = diagnostics.timing(1);
tEnd = diagnostics.timing(end);

nTicks = ceil((tEnd-t0)/increment);

edgeProb = zeros(samples.nNodes, samples.nNodes, nTicks);
midpointTime = (1:nTicks)*increment - increment/2;

runningSum = zeros(samples.nNodes);

normConst = 0;
j = 1;
for i=1:nTicks
	while j<=samples.nSamples && (diagnostics.timing(j)-t0)<=(i*increment)
		key = samples.order2DagHT.get( samples.order(j) );
		value = samples.HT.get(key);
		
		weight = 1; % order-fix reweighting (only applies for dag samples derived from order samples)
		if length(value)==3, weight = value(3); end
		
		normConst = normConst + weight;
		runningSum = runningSum + weight*char2dag(key, samples.nNodes);
		j = j+1;
	end

	edgeProb( :,:, i ) = runningSum/normConst;
end
