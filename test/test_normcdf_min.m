disp('test_normcdf_min...')

k = 10;
y = randn(k, 1000);
z = min(y);

[f, x] = ecdf(z);
F = normcdf_min(x, k); 

assert(~kstest(z, [x F]));
