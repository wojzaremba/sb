disp('test_density_est...')

randn('seed', 1);
z = 2*randn(1000, 1) + 3;

opt = struct('plot_flag', false);
[p, x] = density_est(z, opt);

assert(abs(auc(x', p', max(x), min(x)) - 1) < 1e-2);
