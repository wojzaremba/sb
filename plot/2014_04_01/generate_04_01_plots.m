%main;
clear all;
load linear_asia_arity_3.mat

% plot AUC surface
figure
[AUC,flag] = plot_auc(TPR{1},FPR{1},o.params,1);
title(sprintf('AUC for sb classifier, linear asia network, arity = %d, N = %d',arity,num_samples),'fontsize',16);

% plot pAUC surface
figure
[AUC,flag] = plot_auc(TPR{1},FPR{1},o.params,0.05);
title(sprintf('pAUC (to 0.05) for sb classifier, linear asia network, arity = %d, N = %d',arity,num_samples),'fontsize',16);
%xlim([-3 2]);
%ylim([1,1.07])

% plot ROC curve for max pAUC
[eta_idx,alpha_idx] = ind2sub(size(AUC),find(AUC==max(AUC(:))));
plot_roc_choose_range;


clear all;

% plot ROC curves for all classifiers, arity=2 (using eta = 0.01, alpha=1, now with confidence!)
load all_classifiers_linear_2.mat
plot_roc_choose_range_all_classifiers;

