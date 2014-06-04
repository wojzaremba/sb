function plot_pvals_for_paper()

load edge_scores/pval_mats/2014_06_02/child_200_reg_eps
set = partition_ps(out);
figure;

subplot(2, 3, 1)
hold on
[sb{1}, opt{1}] = learn_edge_classifier(set{1}.p, 0, true);
ylim([0 4]);

subplot(2, 3, 2)
hold on
[sb{2}, opt{2}] = learn_edge_classifier(set{2}.p, 1, true);
ylim([0 4]);

subplot(2, 3, 3)
hold on
[sb{3}, opt{3}] = learn_edge_classifier(set{3}.p, 2, true);
ylim([0 4]);

for k = 1:3
    plot_betas(k, set, sb);
end

end

function plot_betas(k, set, sb)
    subplot(2, 3, 3 + k)
    hold on
    [psort, order] = sort(set{k}.p);
    beta = exp(-sb{k});
    beta_sort = beta(order);
    plot(psort, beta_sort, 'b-', 'linewidth', 3);
    xlabel('p-value', 'fontsize', 16);
    ylabel('P(H1)', 'fontsize', 16);
    title(sprintf('Cond sets size %d', k - 1), 'fontsize', 16);
end




