clear all;
addpath(genpath('.'));
global debug
debug = 2;

% utils
test_enumerate_assignments();
test_allocate_tensor();
test_threshold();
test_gen_triples();
test_get_cpd();
test_emp_to_cpd();
test_condition_emp();
test_cond_emp_to_counts();
test_sb_expectation();

% classifiers
test_mi_classifier();
test_ci_classifier();
test_kci_classifier();

disp('Passed all tests!');
