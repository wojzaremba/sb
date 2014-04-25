disp('test_extract_vector...');

[X, Y, Z] = meshgrid(1:5, 1:5, 1:3);

assert(isequal(extract_vector(X, [2 0 1]), 1:5));
assert(isequal(extract_vector(X, [3 1 0]), ones(3,1)));


