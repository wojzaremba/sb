function test_sb_expectation()


arity = 3;
D = 10000*ones(arity);
N = sum(D(:));
P = D ./ N;

E = sb_expectation(D,0);
mi = mutual_information(P);
A = ((arity-1)^2)/(2*N);
tol = 30*(N^(-2));

assert(abs(E - mi - A) < tol);
