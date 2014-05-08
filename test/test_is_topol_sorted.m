disp('test_is_topol_sorted...');

opt = struct('network', 'asia', 'moralize', true);
dag = get_dag(opt);
assert(is_topol_sorted(dag));

dag(3, 3) = 1;
assert(~is_topol_sorted(dag));

dag(3, 3) = 0;
dag(3, 1) = 1;
assert(~is_topol_sorted(dag));
