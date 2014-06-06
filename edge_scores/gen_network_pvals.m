function out = gen_network_pvals(network, N, seed)

% network params
data_gen = 'quadratic_ggm';
variance = 0.05;

% run params
maxS = 2;
save_flag = true;
run_parallel = false;

if save_flag
    check_dir();
end

seed_rand(seed);
out = network_pvals(network, data_gen, variance, N, maxS, save_flag, run_parallel);
