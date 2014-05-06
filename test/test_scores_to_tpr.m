disp('test_scores_to_tpr...');

network = 'asia';
arity = 3;
type = 'quadratic_ggm';
variance = 0.05;
N = 50;
num_exp = 1;
maxS = 0;
plot_flag = false;
save_flag = false;
f_sel = 2; % gaussian kernel

[bn_opt, runparams, opt] = init_compute_roc_scores(network, arity, type, variance, N, num_exp, maxS, plot_flag, save_flag, f_sel);
[scores] = compute_roc_scores(bn_opt, runparams, opt); 
[fpr, tpr] = scores_to_tpr(scores{1});

assert(isequal([tpr(1),fpr(1)],[0,0]));
assert(isequal([tpr(end),fpr(end)],[1,1]));
assert(issorted(tpr));
assert(issorted(fpr));

