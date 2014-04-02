function bnet = mk_asia_large_arity_nonlinear(arity)

randn('seed', 1);
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

node_sizes = arity * ones(1,n);
discrete_nodes = 1:n;
bnet = mk_bnet(dag, node_sizes, 'discrete', discrete_nodes,'observed',[]);

% true is 2, false is 1
cpd = eye(arity, arity) + abs(randn(arity, arity)) / (arity * 3);
cpd = cpd / sum(cpd(:));
cpd3 = abs(randn(arity, arity, arity)) / (arity * arity * 3);
for i = 1:arity
    cpd3(i, i, i) = cpd3(i, i, i) + 1;
end
cpd3 = cpd3 / sum(cpd(:));
ident = ones(1, arity) / arity;

bnet.CPD{VisitToAsia} = tabular_CPD(bnet, VisitToAsia, ident);        
bnet.CPD{TB} = tabular_CPD(bnet, TB, cpd);                            
bnet.CPD{Smoking} = tabular_CPD(bnet, Smoking, ident);                
bnet.CPD{LungCancer} = tabular_CPD(bnet, LungCancer, cpd');           
bnet.CPD{Bronchitis} = tabular_CPD(bnet, Bronchitis, cpd);            
bnet.CPD{Dys} = tabular_CPD(bnet, Dys, cpd3);             
bnet.CPD{TBorCancer} = tabular_CPD(bnet, TBorCancer, cpd3);
bnet.CPD{Xray} = tabular_CPD(bnet, Xray, cpd);                        


  
  
