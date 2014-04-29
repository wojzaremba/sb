disp('test_get_dag...');

networks = {'child','asia','ins','chain','vstruct'};

v = 0.05;

bnet = mk_child_poly_gauss(v);
dag = get_dag('child');
assert(isequal(bnet.dag, dag));

bnet = mk_asia_linear_gauss(v);
dag = get_dag('asia');
assert(isequal(bnet.dag, dag));

bnet = mk_ins_poly_gauss(v);
dag = get_dag('ins');
assert(isequal(bnet.dag, dag));


    