function kl = computeKL(P,Q)
% P "true" distribution

kl = sum( P.*log(P./Q) );