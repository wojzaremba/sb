disp('test_plot_dist...')

randn('seed', 1);
z = 2*randn(1000, 1) + 3;

opt = struct('plot_flag', false);
[p, x] = plot_dist(z, opt);

assert(abs(auc(x', p', max(x)) - 1) < 1e-2);
