function plot_sachs_missing_edges()

[D, labels] = preprocess_sachs_data(false);

idx1 = find(labels == 1);
idx2 = find(labels == 2);

D1 = D(:, idx1);
D2 = D(:, idx2);

plot_sachs_pair(D1, D2, 5, 7);

plot_sachs_pair(D1, D2, 4, 9);

plot_sachs_pair(D1, D2, 3, 9);



end

function plot_sachs_pair(D1, D2, p1, p2)
    
figure
hold on
fs = 14;
names = {'Raf', 'Mek', 'Plc_g', 'PIP2', 'PIP3', 'Erk', 'Akt', 'PKA', 'PKC', 'P38', 'Jnk'};
h(1) = scatter(D1(p1,:), D1(p2,:), 'r*');
h(2) = scatter(D2(p1,:), D2(p2,:), 'b*');
xlabel(names{p1}, 'fontsize', fs);
ylabel(names{p2}, 'fontsize', fs);
title(sprintf('%s vs. %s', names{p1}, names{p2}), 'fontsize', 14);
legend(h, 'cond 1', 'cond 2');

end


