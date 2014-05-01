function h = plot_roc(N_idx,TPR,FPR,options,name,skip)

%close all;
clear h;
num_classifiers = size(TPR,1);

for fig = 1
    for c = 1:num_classifiers
        o = options{c};

        idx = 1:skip(c):length(options{c}.thresholds);
        idx(end+1) = length(options{c}.thresholds);
        
        tpr = mean(TPR{c,N_idx},1);
        fpr = mean(FPR{c,N_idx},1);
        
        tpr = tpr(idx);
        tpr_err = std(TPR{c},[],1);
        tpr_err = tpr_err(idx);
        
        fpr = fpr(idx);
        fpr_err = std(FPR{c},[],1);
        fpr_err = fpr_err(idx);
        
        %errorbarxy(fpr,tpr,fpr_err,tpr_err,{o.color,o.color,o.color});
        %h(c) = errorbar(fpr,tpr,tpr_err,[o.color '*-'],'linewidth',2);
        h(c) = plot(fpr,tpr,o.color,'linewidth',2);
        hold on
        plot(fpr(2),tpr(2),'r*');
    end
    h(num_classifiers + 1) = plot(linspace(0,1),linspace(0,1),'k--','linewidth',2);
    legend(h,[name(1:num_classifiers) 'random']);
    xlabel('FPR');
    ylabel('TPR');
    ylim([0 1]);
end
