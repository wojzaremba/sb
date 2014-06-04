function [dagSamples] = sampleDagsFromOrder( allFamilyLogScore, order, nDagSamples )

nNodes = size(allFamilyLogScore, 1);

dagSamples = cell(1, nDagSamples);
for si=1:nDagSamples
	dagSamples{si} = zeros(nNodes);
end

for ni=1:nNodes
	invalidParents = find(order==ni);
	invalidParents = order(invalidParents:nNodes);
	invalidFamilies = zeros(1,2^nNodes);
	invalidFamilies( 2.^(invalidParents-1)+1 ) = 1;
	invalidFamilies = fumt(invalidFamilies)>0;
	allFamilyLogScore(ni, invalidFamilies) = -Inf;
	allFamilyLogScore(ni,:) = allFamilyLogScore(ni,:) - logsumexp(allFamilyLogScore(ni,:));
	
	familyCumProbInds = find(allFamilyLogScore(ni,:)>-Inf); %cumulative distirbution over valid families
    familyCumProb = allFamilyLogScore(ni, familyCumProbInds);
	for fi=2:length(familyCumProb)
		familyCumProb(fi) = logadd(familyCumProb(fi-1), familyCumProb(fi) );
	end
	
	familyCumProb = exp(familyCumProb);
	unifSamples = rand(1,nDagSamples);
	for si=1:nDagSamples
		familyIndex = familyCumProbInds(sum( unifSamples(si)>familyCumProb )+1);
		parents = logical(bitget( familyIndex-1, 1:nNodes ));
		dagSamples{si}(parents, ni) = 1;
	end
end
