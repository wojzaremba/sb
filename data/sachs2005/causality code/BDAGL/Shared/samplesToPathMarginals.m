function pathProb = samplesToPathMarginals(samples )
% convert the output of sampleDags*.m to path marginals (ie. does a
% directed path exist from node a->b for all a,b)

keys = samples.HT.keys;

normConst = 0;
pathProb = zeros(samples.nNodes);
while keys.hasMoreElements()
	
	dagKey = keys.nextElement();
	dagVal = samples.HT.get(dagKey);
	
	weight = 1; % order-fix reweighting (only applies for dag samples derived from order samples)
	if length(dagVal)==3, weight = dagVal(3); end
	
    dag = char2dag(dagKey, samples.nNodes);
    reachability = reachability_graph(dag);
    
	pathProb = pathProb + weight*dagVal(1)*reachability;
	normConst = normConst + weight*dagVal(1);
end

pathProb = pathProb / normConst;
