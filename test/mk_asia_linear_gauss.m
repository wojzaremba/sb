function bnet = mk_asia_linear_gauss(variance)

randn('seed', 1);
rand('seed',1);

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

node_sizes = ones(1,n);
bnet = mk_bnet(dag, node_sizes,'observed',[],'discrete', []);

bnet.CPD{VisitToAsia} = gaussian_CPD(bnet, VisitToAsia, 'mean',0,'cov',variance);        
bnet.CPD{TB} = gaussian_CPD(bnet, TB, 'mean',0,'cov',variance,'weights',1);                            
bnet.CPD{Smoking} = gaussian_CPD(bnet, Smoking, 'mean',0,'cov',variance);                
bnet.CPD{LungCancer} = gaussian_CPD(bnet, LungCancer, 'mean',0,'cov',variance,'weights',1);           
bnet.CPD{Bronchitis} = gaussian_CPD(bnet, Bronchitis, 'mean',0,'cov',variance,'weights',1);            
bnet.CPD{Dys} = gaussian_CPD(bnet, Dys, 'mean',0,'cov',variance,'weights',sample_dirichlet([1 1],1));             
bnet.CPD{TBorCancer} = gaussian_CPD(bnet, TBorCancer, 'mean',0,'cov',variance,'weights',sample_dirichlet([1 1],1));
bnet.CPD{Xray} = gaussian_CPD(bnet, Xray, 'mean',0,'cov',variance,'weights',1);  