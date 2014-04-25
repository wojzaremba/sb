disp('test_shd...');


G = zeros(5,5);
G(1,2) = 1;
G(2,4) = 1; 
G(3,4) = 1;
G(4,5) = 1;

PDAG1 = dag_to_cpdag(G);

% edge reversal
B = G;
B(1,2) = 0;
B(2,1) = 1;

PDAG2 = dag_to_cpdag(B);

assert(shd(PDAG1,PDAG2) == 0);
assert(shd(B,G) == 1);

% edge deletion
C = G;
C(1,2) = 0;

assert(shd(C,G) == 1);

% undirected edge deletion
C(1,2) = 1;
C(2,1) = 1;
assert(shd(C,G) == 1);

% undirected edge addition
C(3,5) = 1;
C(5,3) = 1;
assert(shd(C,G) == 2);

