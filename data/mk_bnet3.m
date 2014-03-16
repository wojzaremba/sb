function bnet = mk_bnet3()

n = 3;
dag = zeros(n);
dag(1,2) = 1;
dag(2,3) = 1;

node_sizes = 2 * ones(1,n);
discrete_nodes = 1:n;
bnet = mk_bnet(dag, node_sizes, 'discrete', discrete_nodes,'observed',[]);

% true is 2, false is 1
bnet.CPD{1} = tabular_CPD(bnet, 1, [0.5   0.5]);            % uniform
bnet.CPD{2} = tabular_CPD(bnet, 2, [0.9 0.2  0.1 0.8]);     % activation
bnet.CPD{3} = tabular_CPD(bnet, 3, [0.3 0.95  0.7 0.05]);   % inhibition
