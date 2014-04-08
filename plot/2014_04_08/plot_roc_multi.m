f = figure;
set(f, 'units', 'inches', 'position', [10 10 25 16])
for N_idx = 1:length(num_samples_range)
    for fig = 1:2
        subplot(2,num_N,N_idx + (fig-1)*num_N)
        hold on
        ts = sprintf('N=%d, arity=%d',num_samples_range(N_idx),arity); %ROC on CPDs generated from asia network, 
        skip = skips{fig};
        if fig == 1
            ts = ['Full ROC, ' ts];
            xlims = [0 1];
        else
            ts = ['ROC small FPR, ' ts];
            xlims = [0 0.05];
        end
        h = plot_roc(N_idx,TPR,FPR,num_samples_range,arity,options,name,skip);
        xlim(xlims);
        title(ts,'fontsize',12);
    end
end
    