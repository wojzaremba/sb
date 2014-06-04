function marginals = exactEdgeMarginals_Orders( allFamilyLogScore )
% compute edge marginals by exact enumeration over orders
% allFamilyLogScore = allFamilyLogMargLik, allFamilyLogPrior

nNodes = size(allFamilyLogScore,1);

[post allOrders] = exactOrdersPosterior( allFamilyLogScore );
marginals = zeros(nNodes);

for i=1:nNodes
	for j=1:nNodes
				
		featureSum = 0;

		for pi = 1:size(allOrders,1)
			featureSum = featureSum + post(pi) * edgeProbGivenOrder( i, j, allFamilyLogScore, allOrders(pi, :) );
		end
		
		marginals(i,j) = featureSum;
	end
end

