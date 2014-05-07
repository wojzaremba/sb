disp('test_is_topol_sorted...');

dag = get_dag('asia', true);
assert(is_topol_sorted(dag));

dag(3, 3) = 1;
assert(~is_topol_sorted(dag));

dag(3, 3) = 0;
dag(3, 1) = 1;
assert(~is_topol_sorted(dag));
