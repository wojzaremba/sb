clear all;
addpath(genpath('.'));
global debug
debug = 0;

% utils
test_enumerate_assignments();
test_allocate_tensor();
test_threshold();
test_gen_triples();
test_get_marginal_dist();
test_emp_to_dist();
test_condition_emp();
test_cond_emp_to_counts();
test_empir_vs_dists();
test_sample_N_from_dist();
test_auc();
test_dist1();
test_normalize_data();
test_mk_random_cpd();
test_normalize_cpd();
test_mk_linear_cpd_const();
test_discretize();

% sb
test_sb_expectation();
test_sb_variance();
test_compute_sb();

% data
test_mk_asia_linear_gauss();

% classifiers
test_mi_classifier();
test_pc_classifier();
test_kci_classifier();
test_sb_classifier();
test_cc_classifier();

disp('Passed all tests!');
