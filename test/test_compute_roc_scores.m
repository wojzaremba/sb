disp('test_compute_tpr...')

randn('seed',1);
rand('seed',1);

% run experiments with linear data
network = 'child';
arity = 2;
type = 'linear_ggm';
variance = 0.05;
N = 40;
num_exp = 1;
maxS = 1;
plot_flag = false;
save_flag = false;
f_sel = 1:4;
num_classifiers = length(f_sel);

[bn_opt, runparams] = init_compute_roc_scores(network, arity, type, variance, N, num_exp, maxS, plot_flag, save_flag, f_sel);
[scores, runparams] = compute_roc_scores(bn_opt, runparams);
AUC = zeros(1, num_classifiers);
ind = runparams.num_no_edge;
dep = runparams.num_edge;
fpr = cell(1, num_classifiers);
tpr = cell(1, num_classifiers);

for i = 1:num_classifiers
   S = scores{i};
   assert(isequal(squeeze(S(:,:,1)),[dep 0; ind 0]));
   assert(isequal(squeeze(S(:,:,end)),[0 dep; 0 ind]));
   [fpr{i}, tpr{i}] =  scores_to_tpr(scores{i});
   AUC(i) = auc(fpr{i}, tpr{i});
end
AUC

% assert that AUCs show that continuous data is better than discrete data
% when the data matches the assumptions of the hypothesis test (i.e. if the
% data is nonlinear, KCI should have nonlinear kernel such as Gaussian)

% hence linear kernel, cts data should be best
[~, idx] = max(AUC);
assert(idx == 1);

% and linear kernel, cts data should always outperform linear kernel,
% discrete data
assert(compare_curves(fpr{1}, tpr{1}, fpr{3}, tpr{3}));


% run experiments with nonlinear data
type = 'quadratic_ggm';
[bnet, runparams] = init_compute_roc_scores(network, arity, type, variance, N, num_exp, maxS, plot_flag, save_flag, f_sel);
scores = compute_roc_scores(bnet, runparams);
AUC = zeros(1, num_classifiers);
for i = 1:num_classifiers
   assert(isequal(squeeze(S(:,:,1)),[dep 0; ind 0]));
   assert(isequal(squeeze(S(:,:,end)),[0 dep; 0 ind]));
    [fpr{i}, tpr{i}] =  scores_to_tpr(scores{i});
    AUC(i) = auc(fpr{i}, tpr{i});
end
AUC

% assert that AUCs show that continuous data is better than discrete data
% when the data matches the assumptions of the hypothesis test (i.e. if the
% data is nonlinear, KCI should have nonlinear kernel such as Gaussian)

% hence Gauss kernel, cts data should be best
[~, idx] = max(AUC);
assert(idx == 2);

% and linear kernel, cts data should always outperform linear kernel,
% discrete data
assert(compare_curves(fpr{2}, tpr{2}, fpr{4}, tpr{4}));

