load wine_out

figure
hold on
n = 100:100:500;

for i = 1:3
    h(i) = errorbar(n + 3*i, mean(LL{i}(:, 1:5)), std(LL{i}(:, 1:5)), learn_opt{i}.color, 'linewidth', 2);
    names{i} = learn_opt{i}.name;
end

xlabel('number of samples (n)', 'fontsize', 14);
ylabel('average log likelihood (mean over 10 folds)', 'fontsize', 14);
title('Wine dataset, log likelihood of held out data (higher is better)', 'fontsize', 14);
legend(h, names);