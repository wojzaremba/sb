disp('test_plot_empirical_pvals...')

seed_rand(1);
x = randn(500, 1);
y = rand(200, 1);

z = [x; y];
ind = logical([ones(500, 1); zeros(200, 1)]);

plot_empirical_pvals(z, ind, ~ind, false);



