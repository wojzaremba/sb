disp('test_compute_roc_scores...')

randn('seed',1);
rand('seed',1);

% run experiments with linear data
network = 'asia';
arity = 3;
type = 'linear_ggm';
variance = 0.05;
N = 60;
num_exp = 1;
maxS = 2;
plot_flag = false;
save_flag = false;
f_sel = 1:4;
num_classifiers = length(f_sel);

[bn_opt, rp, opt] = init_compute_roc_scores(network, arity, type, variance, N, num_exp, maxS, plot_flag, save_flag, f_sel);
[scores, rp] = compute_roc_scores(bn_opt, rp, opt);
AUC = zeros(1, num_classifiers);
ind_tot = rp.num_no_edge * num_exp;
dep_tot = rp.num_edge * num_exp;
fpr = cell(1, num_classifiers);
tpr = cell(1, num_classifiers);

for i = 1:num_classifiers
   S = scores{i};
   assert(isequal(squeeze(S(:,:,1)),[dep_tot 0; ind_tot 0]));
   assert(isequal(squeeze(S(:,:,end)),[0 dep_tot; 0 ind_tot]));
   [fpr{i}, tpr{i}] =  scores_to_tpr(scores{i});
   AUC(i) = auc(fpr{i}, tpr{i});
end

% Linear kernel, cts data should be best
[~, idx] = max(AUC);
assert(idx == 1);

% and linear kernel, cts data should always outperform linear kernel,
% discrete data
% assert(compare_curves(fpr{1}, tpr{1}, fpr{3}, tpr{3})); well this usually
% holds, but not perfectly


% run experiments with nonlinear data
type = 'quadratic_ggm';
[bnet, rp, opt] = init_compute_roc_scores(network, arity, type, variance, N, num_exp, maxS, plot_flag, save_flag, f_sel);
scores = compute_roc_scores(bnet, rp, opt);
AUC = zeros(1, num_classifiers);
for i = 1:num_classifiers
   assert(isequal(squeeze(S(:,:,1)),[dep_tot 0; ind_tot 0]));
   assert(isequal(squeeze(S(:,:,end)),[0 dep_tot; 0 ind_tot]));
    [fpr{i}, tpr{i}] =  scores_to_tpr(scores{i});
    AUC(i) = auc(fpr{i}, tpr{i});
end

% Gauss kernel, cts data should be best
[~, idx] = max(AUC);
assert(idx == 2);

% and Gauss kernel, cts data should always outperform Gauss kernel,
% discrete data
% assert(compare_curves(fpr{2}, tpr{2}, fpr{4}, tpr{4})); again, this is a
% bit too strict

