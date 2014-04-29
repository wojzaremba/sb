function bnet = mk_asia_random(arity)

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

unif = ones(1, arity) / arity;

% source node
bnet.CPD{1} = tabular_CPD(bnet, 1, unif); 
bnet.CPD{4} = tabular_CPD(bnet, 4, unif);

% nodes with one parent
one_parent = [2 3 5 8];
for i = 1:length(one_parent)
    idx = one_parent(i);
    bnet.CPD{idx} = tabular_CPD(bnet,idx,mk_random_cpd(arity,2));
end

% nodes with two parents
two_parents = [6 7];
for i = 1:length(two_parents)
    idx = two_parents(i);
    bnet.CPD{idx} = tabular_CPD(bnet,idx,mk_random_cpd(arity,3));
end

% cpd = abs(randn(arity, arity));
% for i = 1:arity
%     cpd(i,:) = cpd(i,:) / sum(cpd(i,:));
% end
% 
% cpd3 = abs(randn(arity, arity, arity));
% for i = 1:arity
%     for j = 1:arity
%         cpd3(i,j,:) = cpd3(i,j,:) / sum(cpd3(i,j,:));
%     end
% end
% 
% 
% bnet.CPD{VisitToAsia} = tabular_CPD(bnet, VisitToAsia, unif);        
% bnet.CPD{TB} = tabular_CPD(bnet, TB, cpd);                            
% bnet.CPD{Smoking} = tabular_CPD(bnet, Smoking, unif);                
% bnet.CPD{LungCancer} = tabular_CPD(bnet, LungCancer, cpd);           
% bnet.CPD{Bronchitis} = tabular_CPD(bnet, Bronchitis, cpd);            
% bnet.CPD{Dys} = tabular_CPD(bnet, Dys, cpd3);             
% bnet.CPD{TBorCancer} = tabular_CPD(bnet, TBorCancer, cpd3);
% bnet.CPD{Xray} = tabular_CPD(bnet, Xray, cpd);  



  
  
