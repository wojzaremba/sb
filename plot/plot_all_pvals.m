
network = {'asia', 'child', 'insurance'};
N = 100:100:500;

for i = 1:3
    for j = 1:5
        command = sprintf('load edge_scores/pval_mats/2014_05_30/%s_%d_pvals.mat', network{i}, N(j));
        eval(command);
        set = partition_ps(out);
        plot_all_cond_sets(set);
        suptitle(sprintf('%s N=%d', network{i}, N(j)));
        clear set out
    end
end
