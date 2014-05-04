%function [edge_rhos, indep_rhos, pred_dag, true_dag] = learn_mrf(v, N)

v = 0.05;
N = 1000;

bn_opt = struct('variance', v, 'network', 'asia_M', 'arity', 1, 'type', 'quadratic_ggm');
bnet = make_bnet(bn_opt);
true_dag = bnet.dag;
true_pdag = dag_to_cpdag(true_dag);


opt = struct('kernel', GaussKernel());

data = samples(bnet, N);
data = normalize_data(data);

K = size(data, 1);
pre = dummy_prealloc(1,1);

%cutoff = 0.15;
pred_dag = zeros(K);

edge_rhos = [];
indep_rhos = [];

r1 = zeros(K, K, K-2);
edge_r1 = [];
indep_r1 = [];

mean_edge_r1 = [];
mean_indep_r1 = [];

for i = 1:K
    for j = i+1:K
        others = setdiff(1:K,[i j]);
        trip = [i j others];
        rho = kci_classifier(data, trip, opt, pre);
        %pred_dag(i,j) = ~(threshold(cutoff,rho));
        for o = others
           trip = [i j setdiff(others, o)];
           r1(i,j,o) = kci_classifier(data, trip, opt, pre);
        end
        if bnet.dag(i,j)
            edge_rhos = [edge_rhos rho];
            edge_r1 = [edge_r1 r1(i,j,:)];
            mean_edge_r1 = [mean_edge_r1 mean(r1(i,j,:))];
        else
            indep_rhos = [indep_rhos rho];
            indep_r1 = [indep_r1 r1(i,j,:)];
            mean_indep_r1 = [mean_indep_r1 mean(r1(i,j,:))];
        end
        fprintf('finished (%d,%d)\n',i,j); %: pred %d, true %d \n',i,j, pred_dag(i,j), bnet.dag(i,j));
    end
end

pred_pdag = dag_to_cpdag(pred_dag);
SHD = shd(pred_pdag, true_pdag);
fprintf('SHD = %d\n',SHD);

figure
hold on
scatter(indep_rhos,ones(size(indep_rhos)),'r*')
scatter(edge_rhos,ones(size(edge_rhos)),'b*')
scatter(mean_indep_r1,2*ones(size(mean_indep_r1)), 'r*');
scatter(mean_edge_r1,2*ones(size(mean_edge_r1)), 'b*');




