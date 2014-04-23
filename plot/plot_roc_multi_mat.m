%function plot_roc_multi_mat(cpd_type,arity)
f = figure;
set(gcf, 'units', 'inches', 'position', [10 10 18 10])

base_dir = 'results/2014_04_22/discrete';
n_range = [50 100 200];

for n_idx = 1:length(n_range)
    for fig = 1:2
        n = n_range(n_idx);
        file = sprintf('%s_arity%d_N%d',cpd_type,arity,n);
       
        mat_file = sprintf('%s/%s/%s.mat',base_dir,file,file);
        load(mat_file);
        num_exp = size(TPR{1},1);
        ts = sprintf('N=%d arity=%d, %d exp %s CPDs',n,arity,num_exp,cpd_type);
        skip = ones(num_classifiers,1);
        if fig == 1
            ts = ['Full ROC, ' ts];
            xlims = [0 1];
        else
            ts = ['Sm ROC, ' ts];
            xlims = [0 0.05];
        end
        subplot(2,length(n_range),n_idx + (fig-1)*length(n_range))
        plot_roc(1,TPR,FPR,options,name,skip);
        xlim(xlims);
        title(ts,'fontsize',12);
    end
end

