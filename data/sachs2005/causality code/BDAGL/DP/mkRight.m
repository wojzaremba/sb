function out = mkRight(alpha)
global R;
global nNodes;
global alpha2;

% expects alpha to be transposed... ie. size(alpha) = [2^nNodes nNodes]
% this is to enable a equiv interfaces for matlab/c versions

alpha2 = alpha;

S = uint32(0);
R = repmat(-1, 2^nNodes,1);

mkRightHelper(S, 0);
out = R;

clear('alpha2');

function mkRightHelper(S, d)
global R;
global nNodes;
global alpha2;

if d<nNodes
	mkRightHelper(S, d+1);
	mkRightHelper(bitset(S, d+1, 1), d+1);
else
	sm = -Inf;
	for j=find(bitget(S,1:nNodes))
		sm = logadd( sm, alpha2( bitcmp(S, nNodes)+1, j ) + R(bitset(S, j, 0)+1) );
	end
	if S==0,
		R(S+1) = 0;
	else
		R(S+1) = sm;
	end
end
