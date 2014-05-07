disp('mrf roc WARNING not clean')

randn('seed',1);
rand('seed',1);

% run experiments with linear data
network = 'asia';
arity = 3;
type = 'linear_ggm';
variance = 0.05;
N = 60;
num_exp = 1;
maxS = 2;
plot_flag = false;
save_flag = false;
f_sel = 1:4;
num_classifiers = length(f_sel);

[bn_opt, rp, opt] = init_compute_roc_scores(network, arity, type, variance, N, num_exp, maxS, plot_flag, save_flag, f_sel);
[scores, rp] = compute_roc_scores(bn_opt, rp, opt);






