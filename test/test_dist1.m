x = randn(5, 2);
y = randn(6, 2);
res = dist1(x, y);
assert(size(res, 1) == 5);
assert(size(res, 2) == 6);

