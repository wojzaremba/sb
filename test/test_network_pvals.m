disp('test_network_pvals...')

% network params
network = 'Y';
type = 'quadratic_ggm';
variance = 0.05;

% run params
N = 100;
maxS = 0;
pval = true;
save_flag = false;

[~, ind] = network_pvals(network, type, variance, N, maxS, pval, save_flag);

assert(isequal(ind, [1 0 0 0 0 0]'));


% network params
network = 'empty';
type = 'linear_ggm';
maxS = 1;
N = 200;


% [z, ind, ~, ~, k]  = network_pvals(network, type, variance, N, maxS, pval, save_flag);
% assert(all(ind == 1));
% x = linspace(-4, 4, 1000)';
% % assert that z follows the distribution of min(X1,X2,...Xk) where Xi ~
% % N(0,1), k is the number of conditioning sets
% assert(~kstest(z, [x normcdf_min(x, k)])); % this isn't working for some
% reason

fprintf('WARNING: need to add more tests in test_network_pvals\n');


