function edgeProb = samplesToEdgeMarginals(samples)
% convert the output of sampleDags*.m to edge marginals

keys = samples.HT.keys;

normConst = 0;
edgeProb = zeros(samples.nNodes);
while keys.hasMoreElements()
	
	dagKey = keys.nextElement();
	dagVal = samples.HT.get(dagKey);
	
	weight = 1; % order-fix reweighting (only applies for dag samples derived from order samples)
	if length(dagVal)==3, weight = dagVal(3); end
	
	edgeProb = edgeProb + weight*dagVal(1)*char2dag(dagKey, samples.nNodes);
	normConst = normConst + weight*dagVal(1);
end

edgeProb = edgeProb / normConst;
