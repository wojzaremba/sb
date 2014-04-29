function dummy()
assert(0)
-d function dummy()\nassert(0)
function bnet = mk_asia_poly_gauss(variance)


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

node_sizes = ones(1,n);
bnet = mk_bnet(dag, node_sizes,'observed',[],'discrete', []);

%w1 = [0 1];      % just y = x^2 + eps
%w2 = [0 1; 0 1]; % just y = x_1 ^2 + x_2 ^2 + eps 
source_var = 0.1;

assert(variance <= (source_var / 2));

bnet.CPD{VisitToAsia} = polynomial_gaussian_CPD(bnet, VisitToAsia, 'mean',0,'cov', source_var);         % node 4       
bnet.CPD{TB} = polynomial_gaussian_CPD(bnet, TB, 'mean',0,'cov',variance,'weights',mk_weights(1));                 % node 5             
bnet.CPD{Smoking} = polynomial_gaussian_CPD(bnet, Smoking, 'mean',0,'cov', source_var);                 % node 1
bnet.CPD{LungCancer} = polynomial_gaussian_CPD(bnet, LungCancer, 'mean',0,'cov',variance,'weights',mk_weights(1)); % node 3
bnet.CPD{Bronchitis} = polynomial_gaussian_CPD(bnet, Bronchitis, 'mean',0,'cov',variance,'weights',mk_weights(1)); % node 2   
bnet.CPD{Dys} = polynomial_gaussian_CPD(bnet, Dys, 'mean',0,'cov',variance,'weights',mk_weights(2));               % node 7
bnet.CPD{TBorCancer} = polynomial_gaussian_CPD(bnet, TBorCancer, 'mean',0,'cov',variance,'weights',mk_weights(2)); % node 6
bnet.CPD{Xray} = polynomial_gaussian_CPD(bnet, Xray, 'mean',0,'cov',variance,'weights',mk_weights(1));             % node 8

end

function w = mk_weights(numpa)
    degree = 2;
    w = randn(numpa, degree);
end