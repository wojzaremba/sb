function bnet = mk_bnet4_vstruct(arity)

n = 4;
dag = zeros(n);
dag(1,3) = 1;
dag(2,3) = 1;
dag(3,4) = 1;

node_sizes = arity * ones(1,n);
discrete_nodes = 1:n;
bnet = mk_bnet(dag, node_sizes, 'discrete', discrete_nodes, 'observed',[]);

randn('seed',15);
cpd3 = mk_random_cpd(arity, 3);
cpd4 =  mk_random_cpd(arity, 2);

% true is 2, false is 1
bnet.CPD{1} = tabular_CPD(bnet, 1, ones(arity, 1) / arity);  
bnet.CPD{2} = tabular_CPD(bnet, 2, ones(arity, 1) / arity); 
bnet.CPD{3} = tabular_CPD(bnet, 3, cpd3);   
bnet.CPD{4} = tabular_CPD(bnet, 4, cpd4);