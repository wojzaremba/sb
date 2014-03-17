clear all;
addpath(genpath('.'));
global debug
debug = 2;

% utils
disp('test_enumerate_assignments...');
test_enumerate_assignments();
disp('test_allocate_tensor...');
test_allocate_tensor();

% data
disp('test_get_cpd...');
test_get_cpd();
disp('test_empir_vs_cpds...');
test_empir_vs_cpds();
disp('test_emp_to_cpd...');
test_emp_to_cpd();

% classifiers
disp('test_mutual_information_classifier...');
test_mutual_information_classifier();

disp('Passed all tests! Great job RACHEL and WOJCIECH!!!  Go have a snack!');
