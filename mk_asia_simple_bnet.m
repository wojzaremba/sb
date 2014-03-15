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

ns = 2 * ones(1,n);
dnodes = 1:n;
bnet = mk_bnet(dag, ns, 'discrete', dnodes);

% true is 2, false is 1
bnet.CPD{VisitToAsia} = tabular_CPD(bnet, VisitToAsia, [0.5   0.5]);
bnet.CPD{TB} = tabular_CPD(bnet, TB, [0.9 0.2  0.1 0.8]);
bnet.CPD{Smoking} = tabular_CPD(bnet, Smoking, [0.5 0.5]);
bnet.CPD{LungCancer} = tabular_CPD(bnet, LungCancer, [0.3 0.95  0.7 0.05]);

bnet.CPD{Bronchitis} = tabular_CPD(bnet, Bronchitis,[0.9 0.2  0.1 0.8]);
% minka: bug fix
bnet.CPD{Dys} = tabular_CPD(bnet, Dys, [0.9 0.2 0.3 0.1   0.1 0.8 0.7 0.9]);
bnet.CPD{TBorCancer} = tabular_CPD(bnet, TBorCancer, [1 0 0 0   0 1 1 1]);
% minka: bug fix



bnet.CPD{Xray} = tabular_CPD(bnet, Xray, [0.95 0.02  0.05 0.98]);


  
  
