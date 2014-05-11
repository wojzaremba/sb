function h = plot_roc(scores,opt)

num_classifiers = length(opt);
% ts = sprintf(['%s network with %s CPDs, N=%d, %d experiments,\n '...
%     'tested %d edge and %d non-edge pairs.'], ...
%     capitalize(runparams.network), runparams.cpd_type, ...
%     runparams.N, runparams.exp, runparams.num_edge, runparams.num_no_edge);

% ts = sprintf('%s network with %s CPDs, N=%d, %d experiments', ...
%     capitalize(runparams.network), runparams.cpd_type, ...
%     runparams.N, runparams.exp);

%ts = sprintf('%s network', capitalize(runparams.network));
ts = '';

for c = 1:num_classifiers
    [fpr, tpr] = scores_to_tpr(scores{c});
    h(c) = plot(fpr,tpr,opt{c}.color,'linewidth',2);
    hold on
    plot(fpr(2),tpr(2),'r*');
    AUC = sprintf('%0.2f', auc(fpr, tpr));
    name{c} = [opt{c}.name ', AUC=' AUC];
end

h(num_classifiers + 1) = plot(linspace(0,1),linspace(0,1),'k--',...
    'linewidth',2);
legend(h,[name 'random']);
xlabel('FPR');
ylabel('TPR');
xlim([0 1]);
ylim([0 1]);
title(ts, 'fontsize', 14);

