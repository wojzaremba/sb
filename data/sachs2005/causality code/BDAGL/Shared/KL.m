function d = KL(P, Q)

Pm = P; Pm(Pm==0) = 1;
d = sum( P.*log2(Pm./Q) );