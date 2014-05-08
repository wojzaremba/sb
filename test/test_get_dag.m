disp('test_get_dag...');

v = 0.05;

bnet = mk_child_poly_gauss(v);
dag = get_dag(struct('network','child'));
assert(isequal(bnet.dag, dag));

bnet = mk_asia_linear_gauss(v);
dag = get_dag(struct('network','asia'));
assert(isequal(bnet.dag, dag));

bnet = mk_ins_poly_gauss(v);
dag = get_dag(struct('network','ins'));
assert(isequal(bnet.dag, dag));


    