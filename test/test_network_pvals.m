disp('test_network_pvals...')

% network params
network = 'Y';
data_gen = 'quadratic_ggm';
variance = 0.05;

% run params
N = 100;
maxS = 0;
save_flag = false;
run_parallel = false;

out = network_pvals(network, data_gen, variance, N, maxS, ...
    save_flag, run_parallel);
assert(isequal(out.ind, [1 0 0 0 0 0]'));
assert(all(out.p(find(out.edge)) < 0.1));
assert(length(find(out.p > 0.1)) > 0);

