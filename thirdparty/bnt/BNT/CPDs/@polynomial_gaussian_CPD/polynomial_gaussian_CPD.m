function CPD = polynomial_gaussian_CPD(bnet, self, varargin)
% POLYNOMIAL_GAUSSIAN_CPD Make a conditional "polynomial" Gaussian distrib,
% i.e. the mean of the child is a polynomial function of the mean of the
% parents, plus some Gaussian noise.  
% CPD = polynomial_gaussian_CPD(bnet, node, ...) will create a CPD with
% random parameters, 
% where node is the number of a node in this equivalence class.
%
% Only defined for continuous parents.

% To define this CPD precisely, call the continuous (cts) parents (if any)
% X, 
% the discrete parents (if any) Q, and this node Y. Then the distribution
% on Y is: 
% - no parents: Y ~ N(mu, Sigma)
% - cts parents : Y|X=x ~ N(mu + W x, Sigma)
% - discrete parents: Y|Q=i ~ N(mu(i), Sigma(i))
% - cts and discrete parents: Y|X=x,Q=i ~ N(mu(i) + W(i) x, Sigma(i))
%
% The list below gives optional arguments [default value in brackets].
% (Let ns(i) be the size of node i, X = ns(X), Y = ns(Y) and Q =
% prod(ns(Q)).) 
% Parameters will be reshaped to the right size if necessary.
%
% mean       - mu(:,i) is the mean given Q=i [ randn(Y,Q) ]
% cov        - Sigma(:,:,i) is the covariance given Q=i [
% repmat(100*eye(Y,Y), [1 1 Q]) ] 
% weights    - W(:,:,i) is the regression matrix given Q=i [ randn(Y,X,Q) ]

if nargin==0
  % This occurs if we are trying to load an object from a file.
  CPD = init_fields;
  clamp = 0;
  CPD = class(CPD, 'polynomial_gaussian_CPD', generic_CPD(clamp));
  return;
elseif isa(bnet, 'polynomial_gaussian_CPD')
  % This might occur if we are copying an object.
  CPD = bnet;
  return;
end
CPD = init_fields;

CPD = class(CPD, 'polynomial_gaussian_CPD', generic_CPD(0));

args = varargin;
ns = bnet.node_sizes;
ps = parents(bnet.dag, self);
dps = myintersect(ps, bnet.dnodes);
cps = myintersect(ps, bnet.cnodes);
fam_sz = ns([ps self]);

CPD.self = self;
CPD.sizes = fam_sz;

% Figure out which (if any) of the parents are discrete, and which cts, and how big they are
% dps = discrete parents, cps = cts parents
CPD.cps = find_equiv_posns(cps, ps); % cts parent index
CPD.dps = find_equiv_posns(dps, ps);
ss = fam_sz(end);
psz = fam_sz(1:end-1);
dpsz = prod(psz(CPD.dps));
cpsz = sum(psz(CPD.cps));

% set default params
CPD.degree = 2;
CPD.mean = randn(ss, dpsz);
CPD.cov = 100*repmat(eye(ss), [1 1 dpsz]);    
CPD.weights = randn(cpsz, CPD.degree);
% while (sum(abs(CPD.weights) < 0.3) > 0)
%     CPD.weights = randn(cpsz, CPD.degree);
% end

nargs = length(args);
if nargs > 0
  CPD = set_fields(CPD, args{:});
end

CPD.mean = myreshape(CPD.mean, [ss ns(dps)]);
CPD.cov = myreshape(CPD.cov, [ss ss ns(dps)]);
CPD.nparams = cpsz*CPD.degree + 2; % weight parameters plus mean and variance

function CPD = init_fields()
% This ensures we define the fields in the same order 
% no matter whether we load an object from a file,
% or create it from scratch. (Matlab requires this.)

CPD.self = [];
CPD.sizes = [];
CPD.cps = [];
CPD.dps = [];
CPD.degree = [];
CPD.mean = [];
CPD.cov = [];
CPD.weights = [];
CPD.nsamples = [];
CPD.nparams = [];            

