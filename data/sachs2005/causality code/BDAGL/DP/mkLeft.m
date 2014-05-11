function out = mkLeft(alpha)
global L;
global nNodes;
global alpha2;

% expects alpha to be transposed... ie. size(alpha) = [2^nNodes nNodes]
% this is to enable a equiv interfaces for matlab/c versions

alpha2 = alpha;

L = repmat(Inf, 2^nNodes,1);

S = uint32(0);

mkLeftHelper(S, 0);
out = L;

clear('alpha2');

function mkLeftHelper(S, d)
global L;
global nNodes;
global alpha2;

if d<nNodes
	mkLeftHelper(S, d+1);
	mkLeftHelper(bitset(S, d+1, 1), d+1);
else
	sm = -Inf;
	for j=find(bitget(S,1:nNodes))
		ind = bitset(S, j, 0);
		sm = logadd( sm, alpha2( ind+1, j ) + L(ind+1) );
	end
	if S==0, 
		L(S+1) = 0; 
	else
		L(S+1) = sm;
	end
end
