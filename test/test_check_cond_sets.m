disp('test_check_cond_sets...')

opt = struct('network', 'Y', 'moralize', false);
dag = get_dag(opt);
assert(check_cond_sets(dag, 1));

opt.network = 'asia';
dag = get_dag(opt);
assert(~check_cond_sets(dag, 1));
assert(check_cond_sets(dag, 2));