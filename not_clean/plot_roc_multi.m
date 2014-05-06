function plot_roc_multi(TPR, FPR, runparams)

num_exp = size(TPR{1},1);
numfigs = 1;

for N_idx = 1:length(num_samples_range) 
    for fig = 1:numfigs
        subplot(numfigs,num_N,N_idx + (fig-1)*num_N)
        hold on
        ts = sprintf('%s network with %s CPDs, N=%d, %d experiments, ', network, cpd_type, N, num_exp);
        if fig == 1
            xlims = [0 1];
        else
            xlims = [0 0.05];
        end
        plot_roc(N_idx,TPR,FPR,options,name);
        xlim(xlims);
        title(ts,'fontsize',12);
    end
end
hold on
pause(1) 
end