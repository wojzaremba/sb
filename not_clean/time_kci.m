function time_kci(network)

randn('seed',1);
rand('seed',1);

figure
hold on
arity = 1;
type = 'quadratic_ggm';
variance = 0.05;
N = 200;
num_exp = 1;
maxS = 2;
plot_flag = false;
save_flag = false;
f_sel = 2;

[bn_opt, rp, opt] = init_compute_roc_scores(network, arity, type, variance, N, num_exp, maxS, plot_flag, save_flag, f_sel);
[scores, rp] = compute_roc_scores(bn_opt, rp, opt);