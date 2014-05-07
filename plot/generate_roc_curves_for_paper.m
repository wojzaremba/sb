function generate_roc_curves_for_paper()

randn('seed',1);
rand('seed',1);


% asia network
figure
hold on
network = 'asia';
arity = 3;
type = 'quadratic_ggm';
variance = 0.05;
N = 50;
num_exp = 10;
maxS = 2;
plot_flag = false;
save_flag = true;
f_sel = 1:4;

%[bn_opt, rp, opt] = init_compute_roc_scores(network, arity, type, variance, N, num_exp, maxS, plot_flag, save_flag, f_sel);
%for i = 1:4
%  opt{i}.pval = false;
%end
%[scores_asia, rp_asia] = compute_roc_scores(bn_opt, rp, opt);

% child network
network = 'child';
[bn_opt, rp, opt] = init_compute_roc_scores(network, arity, type, variance, N, num_exp, maxS, plot_flag, save_flag, f_sel);
[scores_child, rp_child] = compute_roc_scores(bn_opt, rp, opt);

% insurance network
network = 'ins';
[bn_opt, rp, opt] = init_compute_roc_scores(network, arity, type, variance, N, num_exp, maxS, plot_flag, save_flag, f_sel);
[scores_ins, rp_ins] = compute_roc_scores(bn_opt, rp, opt);


