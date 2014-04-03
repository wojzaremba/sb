xlims = {};
ylims = {};
xlims{1} = [0 1];
xlims{2} = [0 0.05];
ylims{1} = [0 1];
ylims{2} = [0 1];
xmax = [1.0, 0.05];


% skips = {};
% skips{1} = [1 2 50 100 50 100];
% skips{2} = [1 1 50 10 1 100];

%skips{1} = [50 100 1000 1000 1000];
%skips{2} = [10 10 100 100 1000];
%skips{1} = 10;%[1000 1000 10]./10;
%skips{2} = 30; %[100 100 100]./10;
% idx = cell(1,num_classifiers);
% for c = 1:num_classifiers
%     idx{c} = 1:skip(c):length(options{c}.range);
%     idx{c}(end+1) = length(options{c}.range); % this may repeat the last index but that's fine
% end

% from AUCfull_sb_linear_asia_arity2_N200, choosing corners of stable,
% optimal range
% eta_idx = 12; %71; (12 <=> 0.016), (71 <=> 0.1)
% alpha_idx = 24; %(24 <=> 25), (2 <=> 0.001)
%eta_idx = 2;
%alpha_idx = 18;

%myTPR = TPR{1}(:,:,eta_idx,alpha_idx); 
%myFPR = FPR{1}(:,:,eta_idx,alpha_idx);

for fig = 1:length(xlims)
    figure
    hold on
    skip = skips{fig};
    for c = 1:num_classifiers
        o = options{c};

        idx = 1:skip(c):length(options{c}.range);
        idx(end+1) = length(options{c}.range);
        
        tpr = mean(TPR{c});
        fpr = mean(FPR{c});
        
        %AUC = auc(fpr',tpr',xmax(fig));
        
        tpr = tpr(idx);
        tpr_err = std(TPR{c});
        tpr_err = tpr_err(idx);
        
        fpr = fpr(idx);
        fpr_err = std(FPR{c});
        fpr_err = fpr_err(idx);
        
        %h(c) = plot(fpr,tpr,[o.color '*-'],'linewidth',2);
        %errorbarxy(fpr,tpr,fpr_err,tpr_err,{o.color,o.color,o.color});
        h(c) = plot(fpr,tpr,[o.color '*-']); %,'linewidth',2);
        hold on
        %fprintf('Classifier %s, mean best w_acc = %f\n',name{c},mean(w_acc{c}));
    end
    h(num_classifiers + 1) = plot(linspace(0,1),linspace(0,1),'k--');%'linewidth',2);
    %name{num_classifiers + 1} = 'random';
    legend(h,[name 'random']);
    xlabel('FPR');
    ylabel('TPR');
    title(sprintf('ROC on CPDs generated from linear asia network, arity=%d, N=%d',arity,num_samples),'fontsize',12);
    xlim(xlims{fig});
    ylim(ylims{fig});
end