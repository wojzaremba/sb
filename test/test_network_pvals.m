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

assert(isequal(ind, [1 0 0 0 0 0]));


% network params
network = 'empty';
type = 'linear_ggm';

[z, ind] = network_pvals(network, type, variance, N, maxS, pval, save_flag);

assert(all(ind == 1));
assert(~kstest(z)); % assert that z follows a standard normal



