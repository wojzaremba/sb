clear all;
addpath(genpath('.'));
global debug
debug = 0;

% utils
test_enumerate_assignments();
test_allocate_tensor();
test_threshold();
test_gen_triples();
test_get_cpd();
test_emp_to_cpd();
test_condition_emp();
test_cond_emp_to_counts();
test_sample_N_from_dist();
test_auc();
test_dist1();
test_mk_random_cpd();
test_normalize_discrete();

% sb
test_sb_expectation();
test_sb_variance();
test_compute_sb();


% classifiers
test_mi_classifier();
test_pc_classifier();
test_kci_classifier();
test_sb_classifier();
test_cc_classifier();

disp('Passed all tests!');
