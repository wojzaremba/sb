function pi = edgeProbGivenOrder( i, j, allFamilyScores, order )
% probability of an edge i->j given a node ordering
% from koller/friedman's paper

validParents = find(order==j);
validParents = order(1:validParents-1);

withEdge = allFamilyScores(j,:);
withoutEdge = allFamilyScores(j,:);

for ni=1:size(allFamilyScores,2)
	
	pa = find(bitget(ni-1,1:size(allFamilyScores,1)));
	if length(myintersect( pa, validParents ))==length(pa)
		if ~any( pa == i )
			withEdge(ni) = -Inf;
		end
	else
		withEdge(ni) = -Inf;
		withoutEdge(ni) = -Inf;
	end
	
end

if all(withEdge==-Inf), 
	pi = 0; 
else
	pi = exp(logsumexp(withEdge) - logsumexp(withoutEdge));
end
