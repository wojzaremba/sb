
dag = load('data/asia1000/asia.adj');
mdag = moralize_dag(dag);

opt = struct('kernel',GaussKernel(),'pval',true);
pre = dummy_prealloc(1,1);

edge_ps = [];
indep_ps = [];

edge_rhos = [];
indep_rhos = [];

K = 7;

for d = 0 : 9
    file = sprintf('data/asia1000/%d/asia1000.dat', d);
    data = load(file);
    data = data';
    
    for i = 1:K
        for j = i+1:K
            others = setdiff(1:K,[i j]);
            trip = [i j others];
            [pval, rho] = kci_classifier(data, trip, opt, pre);
            
            %if ( dag(i,j) || dag(j,i))
            if (mdag(i,j) || mdag(j,i) )
                edge_ps = [edge_ps pval];
                edge_rhos = [edge_rhos rho];
            else
                indep_ps = [indep_ps pval];
                indep_rhos = [indep_rhos rho];
            end
            fprintf('finished (%d,%d)\n',i,j);
        end
    end
end


figure
hold on
h(1) = scatter(1 - indep_ps,rand(size(indep_ps)),'r*');
h(2) = scatter(1 - edge_ps,rand(size(edge_ps)),'b*');
title('KCI p-values for variable pairs in asia network', 'fontsize', 14);
legend(h, 'no edge', 'edge');

figure
hold on
h(1) = scatter(indep_rhos,rand(size(indep_rhos)),'r*');
h(2) = scatter(edge_rhos,rand(size(edge_rhos)),'b*');
title('KCI raw statistics for variable pairs in moralized asia network', 'fontsize', 14);
legend(h, 'no edge', 'edge');




