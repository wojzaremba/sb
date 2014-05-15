disp('test_fit_f0...');

randn('seed', 1);

plot_flag = false;
cv_flag = false;

z = randn(1000, 1);
[f, x] = fit_f(z', plot_flag, cv_flag);
[mu, sigma] = fit_f0(f, x, plot_flag);

assert(abs(mu) < 0.1);
assert(abs(sigma - 1) < 0.1);

