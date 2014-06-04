clear all
load glenn.adult.mat
%load VOC2006
%load USPS
X(X==0) = 2;
X(X==-1) = 2;
%X = X(1:20000,1:50);
X = X(1:10000,1:25);
%X = X(1:100,1:5);

doModels = 0;
doInfer = 0;
dirPrior = 1;
lambdaL2 = .0001;
ising = 1;

%% Different Models

rand('state',0);
randn('state',0);
    fprintf('MoB\n');
nComponents = 2;
model = MoB(X,nComponents,dirPrior)
nll = model.nll(model,X);
size(nll)
sum(nll)

rand('state',0);
randn('state',0);
    fprintf('Mixture of Bernoulli\n');
nComponents = 2;
model = mixBernoulli(X,nComponents,dirPrior)
nll = model.nll(model,X);
size(nll)
sum(nll)


return

% fprintf('ARC\n');
% model = ARC(X,lambdaL2)
% nll = model.nll(model,X);
% size(nll)
% sum(nll)

    fprintf('Mixture of Bernoulli\n');
    for nComponents = [1 10 100 1000]
tic
model = mixBernoulli(X,nComponents,dirPrior,5)
toc
tic
nll = model.nll(model,X);
toc
size(nll)
sum(nll)
pause
    end

fprintf('ARC\n');
model = ARC(X,lambdaL2)
nll = model.nll(model,X);
size(nll)
sum(nll)

fprintf('DepNet\n');
model = DepNet(X,lambdaL2)
nll = model.nll(model,X);
size(nll)
sum(nll)
nll_un = model.nll_unnormalized(model,X);
sum(nll_un)
pause

if doModels
    
    fprintf('Mixture of Bernoulli\n');
nComponents = 2;
model = mixBernoulli(X,nComponents,dirPrior)
nll = model.nll(model,X);
size(nll)
sum(nll)
    
fprintf('ARC\n');
model = ARC(X,lambdaL2)
nll = model.nll(model,X);
size(nll)
sum(nll)

fprintf('Pairwise Full\n');
ising = 1;
model = PairwiseUGMfull(X,ising,lambdaL2)
nll = model.nll(model,X);
size(nll)
sum(nll)

fprintf('Tree\n');
ising = 1;
model = PairwiseUGMtree(X,ising,lambdaL2)
nll = model.nll(model,X);
size(nll)
sum(nll)
    
% fprintf('Bernoulli\n');
% model = bernoulli(X,dirPrior)
% nll = model.nll(model,X);
% size(nll)
% sum(nll)
% 


fprintf('DAG\n');
model = DAGlinear(X,lambdaL2)
nll = model.nll(model,X);
size(nll)
sum(nll)
pause;

fprintf('Full DAG\n');
model = DAGfullLinear(X,lambdaL2)
nll = model.nll(model,X);
size(nll)
sum(nll)



fprintf('Pairwise GL1\n');
ising = 1;
model = PairwiseUGMfull(X,ising,lambdaL2)
nll = model.nll(model,X);
size(nll)
sum(nll)
end

%% Approximate Inference Methods

if doInfer
fprintf('Exact\n');
ising = 1;
model = PairwiseUGMfull(X,ising,lambdaL2,'Exact')
nll = model.nll(model,X);
size(nll)
sum(nll)

fprintf('Pseudolikelihood\n');
ising = 1;
model = PairwiseUGMfull(X,ising,lambdaL2,'Pseudo')
nll = model.nll(model,X);
size(nll)
sum(nll)

% fprintf('Mean Field\n');
% ising = 1;
% model = PairwiseUGMfull(X,ising,lambdaL2,'MF')
% nll = model.nll(model,X);
% size(nll)
% sum(nll)

fprintf('Loopy BP\n');
ising = 1;
model = PairwiseUGMfull(X,ising,lambdaL2,'LBP')
nll = model.nll(model,X);
size(nll)
sum(nll)

fprintf('TRBP\n');
ising = 1;
model = PairwiseUGMfull(X,ising,lambdaL2,'TRBP')
nll = model.nll(model,X);
size(nll)
sum(nll)

fprintf('Exact\n');
ising = 1;
model = PairwiseUGMgL1(X,ising,lambdaL2,'Exact')
nll = model.nll(model,X);
size(nll)
sum(nll)

fprintf('Pseudolikelihood\n');
ising = 1;
model = PairwiseUGMgL1(X,ising,lambdaL2,'Pseudo')
nll = model.nll(model,X);
size(nll)
sum(nll)

% fprintf('Mean Field\n');
% ising = 1;
% model = PairwiseUGMgL1(X,ising,lambdaL2,'MF')
% nll = model.nll(model,X);
% size(nll)
% sum(nll)

fprintf('Loopy BP\n');
ising = 1;
model = PairwiseUGMgL1(X,ising,lambdaL2,'LBP')
nll = model.nll(model,X);
size(nll)
sum(nll)

fprintf('TRBP\n');
ising = 1;
model = PairwiseUGMgL1(X,ising,lambdaL2,'TRBP')
nll = model.nll(model,X);
size(nll)
sum(nll)
end