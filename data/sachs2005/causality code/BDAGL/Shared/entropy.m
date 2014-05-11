function H = entropy(P)
% discrete entropy

Pm = P; Pm(Pm==0) = 1;
H = -sum( P .* log2(Pm) );