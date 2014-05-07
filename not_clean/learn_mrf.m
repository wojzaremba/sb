%function [edge_ps, indep_ps, pred_dag, true_dag] = learn_mrf(v, N)

v = 0.05;
N = 1000;

randn('seed',1);

bn_opt = struct('variance', v, 'network', 'asia', 'arity', 1, 'type', 'quadratic_ggm', 'moralize', true);
bnet = make_bnet(bn_opt);
true_dag = bnet.dag;
true_pdag = dag_to_cpdag(true_dag);

opt = struct('kernel',GaussKernel(),'pval',true);

data = samples(bnet, N);
data = normalize_data(data);

K = size(data, 1);
pre = dummy_prealloc(1,1);

pred_dag = zeros(K);

edge_ps = [];
indep_ps = [];

edge_rhos = [];
indep_rhos = [];


for i = 1:K
    for j = i+1:K
        others = setdiff(1:K,[i j]);
        trip = [i j others];
        [pval, rho] = kci_classifier(data, trip, opt, pre);

        if ( bnet.dag(i,j) || bnet.dag(j,i))
            edge_ps = [edge_ps pval];
            edge_rhos = [edge_rhos rho];
        else
            indep_ps = [indep_ps pval];
            indep_rhos = [indep_rhos rho];
        end
        fprintf('finished (%d,%d)\n',i,j);
    end
end

pred_pdag = dag_to_cpdag(pred_dag);
SHD = shd(pred_pdag, true_pdag);
fprintf('SHD = %d\n',SHD);

figure
hold on
h(1) = scatter(indep_ps,rand(size(indep_ps)),'r*');
h(2) = scatter(edge_ps,rand(size(edge_ps)),'b*');
title('KCI p-values for variable pairs in moralized asia network', 'fontsize', 14);
legend(h, 'no edge', 'edge');

figure
hold on
h(1) = scatter(indep_rhos,rand(size(indep_rhos)),'r*');
h(2) = scatter(edge_rhos,rand(size(edge_rhos)),'b*');
title('KCI raw statistics for variable pairs in moralized asia network', 'fontsize', 14);
legend(h, 'no edge', 'edge');




