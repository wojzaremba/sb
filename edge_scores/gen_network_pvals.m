function [z, ind] = gen_network_pvals()

% network params
network = 'asia';
type = 'quadratic_ggm';
variance = 0.05;

% run params
N = 100;
maxS = 0;
pval = true;
save_flag = true;

if save_flag
    check_dir();
end

[z, ind] = network_pvals(network, type, variance, N, maxS, pval, save_flag);

