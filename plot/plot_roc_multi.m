%f = figure;
%set(gcf, 'units', 'inches', 'position', [10 10 25 16])

skips = cell(2,1);
skips{1} = ones(num_classifiers,1);
skips{2} = ones(num_classifiers,1);
num_exp = size(TPR{1},1);
numfigs = 1;

for N_idx = 1:length(num_samples_range)
    for fig = 1:numfigs
        subplot(numfigs,num_N,N_idx + (fig-1)*num_N)
        hold on
        ts = sprintf('N=%d, arity=%d, %d experiments, %s CPDs',num_samples_range(N_idx),arity,num_exp,cpd_type); %ROC on CPDs generated from asia network, 
        skip = skips{fig};
        if fig == 1
            ts = ['Full ROC, ' ts];
            xlims = [0 1];
        else
            ts = ['ROC small FPR, ' ts];
            xlims = [0 0.05];
        end
        plot_roc(N_idx,TPR,FPR,options,name,skip);
        xlim(xlims);
        title(ts,'fontsize',12);
    end
end
    