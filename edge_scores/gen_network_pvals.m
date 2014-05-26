function [z, ind, edge, rho, set_size, k] = gen_network_pvals()

% network params
network = 'asia';
type = 'quadratic_ggm';
variance = 0.05;

% run params
N = 400;
maxS = 2;
pval = true;
save_flag = true;

if save_flag
    check_dir();
end

[z, ind, edge, rho, set_size, k] = network_pvals(network, type, variance, N, maxS, pval, save_flag);
