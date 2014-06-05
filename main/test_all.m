clear all;
addpath(genpath('.'));
global debug
debug = 2;
dbstop if error
check_dir();

test_edge_scores();
% end-to-end
test_compute_roc_scores();
test_bn_learn_synthetic();

% structure learning
test_run_gobnilp();
test_mmhc();
%test_learn_mrf();

% utils
test_enumerate_assignments();
test_allocate_tensor();
test_threshold();
test_gen_triples();
test_flatten_triples();
test_get_marginal_dist();
test_emp_to_dist();
test_condition_emp();
test_cond_emp_to_counts();
test_empir_vs_dists();
test_sample_N_from_dist();
test_auc();
test_dist1();
test_shd();
test_extract_vector();
test_scores_to_tpr();
test_compare_curves();
test_is_topol_sorted();
test_check_cond_sets();
test_count_ind_cond_sets();
test_normcdf_min();
test_dsep_cond_sets();
test_flatten_loop();

% scores
test_network_pvals();
test_compute_bic();
test_kernel_ridge_likelihood();

% plot
test_density_est();
test_plot_empirical_pvals();

% sb
test_sb_expectation();
test_sb_variance();
test_compute_sb();

% data
test_normalize_data();
test_mk_random_cpd();
test_normalize_cpd();
test_discretize_data();
test_get_dag();
test_moralize_dag();
test_make_bnet();

% classifiers
test_mi_classifier();
test_pc_classifier();
test_kci_classifier();
test_sb_classifier();
test_cc_classifier();



disp('Passed all tests!');
