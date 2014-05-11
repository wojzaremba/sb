function marginals = empiricalEdgeMarginals_Orders(allFamilyLogScores, orderSamples )

nNodes = size(allFamilyLogScores,1);
marginals = zeros(nNodes);

for i=1:nNodes
	for j=1:nNodes
				
        if i==j, continue; end
        
		featureSum = 0;

		% empirical average
		keys = orderSamples.HT.keys();
		while keys.hasMoreElements()
			key = keys.nextElement();
			value = orderSamples.HT.get(key);
			
			featureSum = featureSum + value(1)/orderSamples.nSamples * edgeProbGivenOrder( i, j, allFamilyLogScores, uint32(key) );
		end

		marginals(i,j) = featureSum;
	end
end

