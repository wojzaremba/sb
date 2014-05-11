function [scores, opt, dag, mdag] = mrf_rocs_multi_n(nvec)

colors = {'g--','b-','m-.','r:','c--'};
randn('seed', 1);
rand('seed', 1);

for i = 1 : length(nvec)
    n = nvec(i);
    [edge_rhos{i}, indep_rhos{i}, dag{i}, mdag{i}] = learn_mrf('large', n, 1000);
    scores{i} = compute_mrf_scores(edge_rhos{i}, indep_rhos{i});
    opt{i}.name = sprintf('%d vars', n);
    opt{i}.color = colors{i};
end

figure;
plot_roc(scores, opt);