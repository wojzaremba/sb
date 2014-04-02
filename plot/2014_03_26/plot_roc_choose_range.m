xlims = {};
ylims = {};
xlims{1} = [0 1];
xlims{2} = [0 0.05];
ylims{1} = [0 1];
ylims{2} = [0 0.5];

skips = {};
%skips{1} = [50 100 1000 1000 1000];
%skips{2} = [10 10 100 100 1000];
skips{1} = 10;%[1000 1000 10]./10;
skips{2} = 30; %[100 100 100]./10;
% idx = cell(1,num_classifiers);
% for c = 1:num_classifiers
%     idx{c} = 1:skip(c):length(options{c}.range);
%     idx{c}(end+1) = length(options{c}.range); % this may repeat the last index but that's fine
% end

% from AUCfull_sb_linear_asia_arity2_N200, choosing corners of stable,
% optimal range
% eta_idx = 12; %71; (12 <=> 0.016), (71 <=> 0.1)
% alpha_idx = 24; %(24 <=> 25), (2 <=> 0.001)
eta_idx = 2;
alpha_idx = 18;

myTPR = TPR{1}(:,:,eta_idx,alpha_idx); 
myFPR = FPR{1}(:,:,eta_idx,alpha_idx);

for fig = 1:length(xlims)
    figure
    hold on
    skip = skips{fig};
    plot(linspace(0,1),linspace(0,1),'k--');
    for c = 1:num_classifiers
        o = options{c};

        idx = 1:skip(c):length(options{c}.range);
        idx(end+1) = length(options{c}.range);
        
        tpr = mean(myTPR);%mean(TPR{c});
        tpr = tpr(idx);
        tpr_err = std(myTPR);%std(TPR{c});
        tpr_err = tpr_err(idx);
        
        fpr = mean(myFPR); %mean(FPR{c});
        fpr = fpr(idx);
        fpr_err = std(myFPR); %std(FPR{c});
        fpr_err = fpr_err(idx);
        
        h(c) = plot(fpr,tpr,[o.color '*-'],'linewidth',2);
        errorbarxy(fpr,tpr,fpr_err,tpr_err,{o.color,o.color,o.color});
        hold on
        %fprintf('Classifier %s, mean best w_acc = %f\n',name{c},mean(w_acc{c}));
    end
    legend(h,name);
    xlabel('FPR');
    ylabel('TPR');
    title(sprintf('ROC on CPDs generated from linear asia network, arity=%d, N=%d, eta=%.3f, alpha=%.3f',arity,num_samples,o.params.eta(eta_idx),o.params.alpha(alpha_idx)),'fontsize',12);
    xlim(xlims{fig});
    ylim(ylims{fig});
end