disp('test_make_bnet...');

v = 0.05;
opt = struct('variance', v, 'network', 'asia', 'arity', 1, 'type', 'linear_ggm', 'moralize', false);

bnet1 = mk_asia_linear_gauss(v);
bnet2 = make_bnet(opt);

compare_bnets(bnet1, bnet2);

opt.network = 'ins';
opt.type = 'quadratic_ggm';

bnet1 = mk_ins_poly_gauss(v);
bnet2 = make_bnet(opt);

compare_bnets(bnet1, bnet2);

opt.network = 'child';
opt.type = 'random';
opt.arity = 2;

bnet1 = mk_child_random(opt.arity);
bnet2 = make_bnet(opt);

compare_bnets(bnet1, bnet2);
