function F = normcdf_min(x, k)

F = 1 - (1 - normcdf(x)).^k;