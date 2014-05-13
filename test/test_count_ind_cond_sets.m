disp('test_count_ind_cond_sets...');

dag = get_dag(struct('network', 'Y'));
[total, num_ind, num_dep] = count_ind_cond_sets(dag, 0);
assert(num_ind == 1);
assert(num_dep == 5);

dag = get_dag(struct('network', 'chain', 'n', 4));
[total, num_ind, num_dep] = count_ind_cond_sets(dag, [0 1]);
assert(num_ind == 4);
assert(num_dep == 14);
