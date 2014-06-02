function [logZ] = computeLogZ( allFamilyLogPrior, allFamilyLogMargLik )
global nNodes;

[nNodes] = size(allFamilyLogMargLik, 1); % set it once. used to determine no. of bits used for set/element ops

warning('off','MATLAB:log:logOfZero');

[alpha beta] = mkAlphaBeta(allFamilyLogPrior, allFamilyLogMargLik );

left = mkLeft(alpha);

logZ = left(end); % normalization constant

warning('on','MATLAB:log:logOfZero');


