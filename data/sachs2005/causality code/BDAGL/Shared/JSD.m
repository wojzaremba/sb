function j = JSD( P, Q )
% jensen shannon distance

R = 1/2 * (P + Q);
j = 1/2 * ( KL( P, R ) + KL( Q, R ) );