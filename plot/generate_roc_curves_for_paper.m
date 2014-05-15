function generate_roc_curves_for_paper(network)

randn('seed',1);
rand('seed',1);

figure
hold on
arity = 3;
type = 'quadratic_ggm';
variance = 0.05;
N = 50;
num_exp = 3;
maxS = 2;
plot_flag = false;
save_flag = true;
f_sel = 1:2;

[bn_opt, rp, opt] = init_compute_roc_scores(network, arity, type, variance, N, num_exp, maxS, plot_flag, save_flag, f_sel);
[scores, rp] = compute_roc_scores(bn_opt, rp, opt);
