function bnet = mk_asia_simple_bnet()

Smoking = 1;
Bronchitis = 2;
LungCancer = 3;
VisitToAsia = 4;
TB = 5;
TBorCancer = 6;
Dys = 7;
Xray = 8;

n = 8;
dag = zeros(n);
dag(Smoking, [Bronchitis LungCancer]) = 1;
dag(Bronchitis, Dys) = 1;
dag(LungCancer, TBorCancer) = 1;
dag(VisitToAsia, TB) = 1;
dag(TB, TBorCancer) = 1;
dag(TBorCancer, [Dys Xray]) = 1;

node_sizes = 2 * ones(1,n);
discrete_nodes = 1:n;
bnet = mk_bnet(dag, node_sizes, 'discrete', discrete_nodes,'observed',[]);

% true is 2, false is 1
bnet.CPD{VisitToAsia} = tabular_CPD(bnet, VisitToAsia, [0.5   0.5]);                            % uniform
bnet.CPD{TB} = tabular_CPD(bnet, TB, [0.9 0.2  0.1 0.8]);                                       % activation
bnet.CPD{Smoking} = tabular_CPD(bnet, Smoking, [0.5 0.5]);                                      % uniform
bnet.CPD{LungCancer} = tabular_CPD(bnet, LungCancer, [0.3 0.95  0.7 0.05]);                     % inhibition
bnet.CPD{Bronchitis} = tabular_CPD(bnet, Bronchitis,[0.9 0.2  0.1 0.8]);                        % activation
bnet.CPD{Dys} = tabular_CPD(bnet, Dys, [.95 .05 .05 .95   .05 0.95 0.95 0.05]);                 % activation: exclusive OR
bnet.CPD{TBorCancer} = tabular_CPD(bnet, TBorCancer, [.95 .05 .05 .05   .05 0.95 0.95 0.95]);   % activation: inclusive OR
bnet.CPD{Xray} = tabular_CPD(bnet, Xray, [0.3 0.95  0.7 0.05]);                                 % inhibition


  
  
