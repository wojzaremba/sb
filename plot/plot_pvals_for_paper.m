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
    plot_sb(k, set, sb);
end

end

function plot_sb(k, set, sb)
    subplot(2, 3, 3 + k)
    hold on
    [psort, order] = sort(set{k}.p);
    sb_sort = sb{k}(order); 
    plot(psort, sb_sort, 'b-', 'linewidth', 3);
    xlabel('p-value', 'fontsize', 16);
    ylabel('sb(p)', 'fontsize', 16);
    title(sprintf('Cond sets size %d', k - 1), 'fontsize', 16);
end




