xlims = {};
ylims = {};
xlims{1} = [0 1];
xlims{2} = [0 0.05];
ylims{1} = [0 1];
ylims{2} = [0 0.2];

skips = {};
%skips{1} = [50 100 1000 1000 1000];
%skips{2} = [10 10 100 100 1000];
skips{1} = 20;%[1000 1000 10]./10;
skips{2} = 20; %[100 100 100]./10;
% idx = cell(1,num_classifiers);
% for c = 1:num_classifiers
%     idx{c} = 1:skip(c):length(options{c}.range);
%     idx{c}(end+1) = length(options{c}.range); % this may repeat the last index but that's fine
% end

for fig = 1:length(xlims)
    figure
    hold on
    skip = skips{fig};
    plot(linspace(0,1),linspace(0,1),'k--');
    for c = 1:num_classifiers
        o = options{c};

        idx = 1:skip(c):length(options{c}.range);
        idx(end+1) = length(options{c}.range);
        
        tpr = mean(TPR{c});
        tpr = tpr(idx);
        %tpr = tpr(tpr<=ylims{fig}(2));

        tpr_err = std(TPR{c});
        tpr_err = tpr_err(idx);
        fpr = mean(FPR{c});
        fpr = fpr(idx);
        fpr_err = std(FPR{c});
        fpr_err = fpr_err(idx);
        h(c) = plot(fpr,tpr,[o.color '*-'],'linewidth',2);
        errorbarxy(fpr,tpr,fpr_err,tpr_err,{o.color,o.color,o.color});
        hold on
        fprintf('Classifier %s, mean best w_acc = %f\n',name{c},mean(w_acc{c}));
    end
    legend(h,name);
    xlabel('FPR');
    ylabel('TPR');
    title(sprintf('ROC on CPDs generated from linear asia network, arity=%d, N=%d',arity,num_samples),'fontsize',14);
    xlim(xlims{fig});
    ylim(ylims{fig});
end