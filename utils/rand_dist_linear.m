function P = rand_dist_linear(arity)

% generate a random distribution
P = abs(randn(arity,arity)) + eye(arity);
norm_factor = sum(P(:));
P = P ./ norm_factor;