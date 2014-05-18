function [z, ind, edge, rho] = gen_network_pvals()

% network params
network = 'child';
type = 'quadratic_ggm';
variance = 0.05;

% run params
N = 200;
maxS = 2;
pval = true;
save_flag = true;

if save_flag
    check_dir();
end

[z, ind, edge, rho] = network_pvals(network, type, variance, N, maxS, pval, save_flag);

