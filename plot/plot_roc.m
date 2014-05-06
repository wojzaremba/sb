function h = plot_roc(scores,opt,runparams)

clear h;
num_classifiers = length(opt);
ts = sprintf(['%s network with %s CPDs, N=%d, %d experiments,\n '...
    'Tested %d edge and %d non-edge pairs.'], ...
    capitalize(runparams.network), runparams.cpd_type, ...
    runparams.N, runparams.exp, runparams.num_edge, runparams.num_no_edge);

for c = 1:num_classifiers
    
    [fpr, tpr] = scores_to_tpr(scores{c});
    
    %tpr_err = std(TPR{c},[],1);
    %fpr_err = std(FPR{c},[],1);
    
    h(c) = plot(fpr,tpr,opt{c}.color,'linewidth',2);
    hold on
    plot(fpr(2),tpr(2),'r*');
    
    name{c} = opt{c}.name;
end

h(num_classifiers + 1) = plot(linspace(0,1),linspace(0,1),'k--',...
    'linewidth',2);
legend(h,[name 'random']);
xlabel('FPR');
ylabel('TPR');
xlim([0 1]);
ylim([0 1]);
title(ts, 'fontsize', 14);

