% run experiments with linear data

network = 'child';
arity = 3;%20;
type = 'linear_ggm';
variance = 0.05;
N = 50;
num_exp = 1;
maxS = 2;
plot_flag = true;
save_flag = false;
f_sel = [3 4];
num_classifiers = length(f_sel);

[bn_opt, rp, opt] = init_compute_roc_scores(network, arity, type, variance, N, num_exp, maxS, plot_flag, save_flag, f_sel);
%opt{3}.check_counts = true;
if save_flag
    diary(sprintf('%s/%s.diary', rp.dir_name, rp.file_name));
end
[scores, rp] = compute_roc_scores(bn_opt, rp, opt);
if save_flag 
    diary off;
end
