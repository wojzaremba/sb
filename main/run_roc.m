function [scores, rp] = run_roc(network)

arity = 1;
type = 'quadratic_ggm';
variance = 0.05;
N = 100;
num_exp = 10;
maxS = 2;
plot_flag = true;
save_flag = false;
f_sel = 2;

data = {};
fid = fopen(sprintf('%s_pvals.list', network), 'r');
tline = strtrim(fgets(fid));
while ischar(tline)
    tline = strtrim(fgets(fid));
    eval(sprintf('load %s', tline));
    data{end+1} = out.data;
end

[bn_opt, rp, opt] = init_compute_roc_scores(network, arity, type, variance, N, num_exp, maxS, plot_flag, save_flag, f_sel);
dag = get_dag(bn_opt);
[scores, rp] = compute_roc_scores(rp, opt, dag, data);
