function gamma0 = mkGamma(left, right)
global nNodes;

%qPrior = mkUiPrior(N);
qPrior = 1;

gamma0 = repmat(-Inf, nNodes, 2^nNodes);

for v=1:nNodes
	
	if exist('mkGammaHelper')==3
		
		gamma0(v, :) = mkGammaHelper(v-1, left, right );
		
	else
		
		% this cannot really be sped up with an fumt
		for bi=0:2^nNodes-1
			if bitget(bi, v), continue; end

			leftInd = bi;
			rightInd = bitset(bitcmp(bi, nNodes), v, 0);

			gamma0(v,leftInd+1) = left(leftInd+1) + right(rightInd+1); % */+ qPrior omitted since it's 1 * or + depending if in log dom or not
		end
	end
	
	gamma0(v,:) = fdmtl(gamma0(v,:));
end
