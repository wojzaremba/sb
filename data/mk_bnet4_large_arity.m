function bnet = mk_bnet4_large_arity(arity)
randn('seed', 1);
n = 4;
dag = zeros(n);
dag(1,2) = 1;
dag(2,3) = 1;
dag(3,4) = 1;

node_sizes = arity * ones(1,n);
discrete_nodes = 1:n;
bnet = mk_bnet(dag, node_sizes, 'discrete', discrete_nodes, 'observed',[]);

bnet.CPD{1} = tabular_CPD(bnet, 1, ones(1, arity) / arity); % uniform
bnet.CPD{2} = tabular_CPD(bnet, 2, mk_random_cpd(arity,1)); 
bnet.CPD{3} = tabular_CPD(bnet, 3, mk_random_cpd(arity,1)); 
bnet.CPD{4} = tabular_CPD(bnet, 4, mk_random_cpd(arity,1));   
