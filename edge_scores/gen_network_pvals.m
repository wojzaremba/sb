function out = gen_network_pvals(network, N)

% network params
%network = 'asia';
data_gen = 'quadratic_ggm';
variance = 0.05;

% run params
%N = 100;
maxS = 2;
save_flag = true;
run_parallel = true;

if save_flag
    check_dir();
end

seed_rand(1);
out = network_pvals(network, data_gen, variance, N, maxS, save_flag, run_parallel);
