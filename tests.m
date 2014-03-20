clear all;
addpath(genpath('.'));
global debug
debug = 2;

% utils
test_enumerate_assignments();
test_allocate_tensor();

% data
test_get_cpd();
test_empir_vs_cpds();
test_emp_to_cpd();

% classifiers
test_mi_classifier();

disp('Passed all tests! Great job RACHEL and WOJCIECH!!!  Go work!');
