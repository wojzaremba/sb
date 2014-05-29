disp('test_dsep_cond_sets...')

n = 4;
bn_opt = struct('network', 'chain', 'moralize', false, 'n', n);
dag = get_dag(bn_opt);
triples = gen_triples(n, 0:2);
T = dsep_cond_sets(dag, triples);

myT = -Inf*ones(n);
for i = 1:n
    for j = i+1:n
        myT(i,j) = 0;
    end
    for j = i+2:n
        myT(i,j) = 1;
    end
end
assert(isequal(T, myT));

n = 3;
bn_opt = struct('network', 'vstruct', 'moralize', false, 'n', n);
dag = get_dag(bn_opt);
triples = gen_triples(n, 0:1);
T = dsep_cond_sets(dag, triples);

myT = -Inf*ones(n);
myT(1,2) = 1;
myT(1,3) = 0;
myT(2,3) = 0;
assert(isequal(T, myT));

