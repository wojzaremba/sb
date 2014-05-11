function [prob Z] = computeAllEdgeProb( allFamilyLogPrior, allFamilyLogMargLik )
global nNodes;


[nNodes] = size(allFamilyLogMargLik, 1); % set it once. used to determine no. of bits used for set/element ops

warning('off','MATLAB:log:logOfZero');

[alpha beta] = mkAlphaBeta(allFamilyLogPrior, allFamilyLogMargLik );

left = mkLeft(alpha');
right = mkRight(alpha');

Z = left(end); % normalization constant

mask0 = zeros(nNodes,2^nNodes);
for v=1:nNodes
	mask0(v, 2^(v-1)+1 ) = 1;
	mask0(v, :) = fumt(mask0(v, :));
end

gamma = mkGamma(left, right);
prob = repmat(-Inf,[nNodes nNodes]);

for v=1:nNodes
	maskv = ~(mask0(v,:)>0); % none of the sets containing v
	for u=1:nNodes
		if u==v, continue; end
        
        mask = find(maskv&mask0(u,:));
        pxe = logadd_sum( beta(v,mask) + gamma(v,mask) );
                
		prob(u,v) = pxe;
	end
end

warning('on','MATLAB:log:logOfZero');

prob = exp(prob - Z);

