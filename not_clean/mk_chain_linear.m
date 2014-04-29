function dummy()
assert(0)
-d function dummy()\nassert(0)
function bnet = mk_chain_linear(arity)

randn('seed', 1);

n = 4;
dag = zeros(n);
dag(1,2) = 1;
dag(2,3) = 1;
dag(3,4) = 1;

node_sizes = arity * ones(1,n);
discrete_nodes = 1:n;
bnet = mk_bnet(dag, node_sizes, 'discrete', discrete_nodes,'observed',[]);

cpd = mk_linear_cpd_const(arity,2);
unif = ones(1, arity) / arity;

bnet.CPD{1} = tabular_CPD(bnet, 1, unif);        
bnet.CPD{2} = tabular_CPD(bnet, 2, cpd);                            
bnet.CPD{3} = tabular_CPD(bnet, 3, cpd);                
bnet.CPD{4} = tabular_CPD(bnet, 4, cpd);   