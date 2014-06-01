function out = gen_network_pvals(network, N)

% network params
%network = 'child';
data_gen = 'quadratic_ggm';
variance = 0.05;

% run params
%N = 100;
maxS = 2;
save_flag = true;

if save_flag
    check_dir();
end

seed_rand(1);
fprintf('WARNING: seeding rand\n');
out = network_pvals(network, data_gen, variance, N, maxS, save_flag);
