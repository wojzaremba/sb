function [scores, rp] = run_roc(network)

arity = 3;
data_gen = 'quadratic_ggm';
variance = 0.05;
N = 100;
num_exp = 10;
maxS = 2;
plot_flag = true;
save_flag = false;
f_sel = [1 2 3 5 7];

[bn_opt, rp, opt] = init_compute_roc_scores(network, arity, data_gen, variance, N, num_exp, maxS, plot_flag, save_flag, f_sel);
dag = get_dag(bn_opt);

eval(sprintf('load %s_data_E', network));

[scores, rp] = compute_roc_scores(rp, opt, dag, data, E);
