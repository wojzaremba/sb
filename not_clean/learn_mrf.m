function [edge_rhos, indep_rhos] = learn_mrf(network, n, N)

v = 0.05;

global debug;
debug = 2;

randn('seed',1);

bn_opt = struct('variance', v, 'network', network, 'arity', 1, 'type', 'quadratic_ggm', 'moralize', false, 'n', n);
bnet = make_bnet(bn_opt);
mdag = moralize_dag(bnet.dag);
fprintf('number of edges in dag: %d, mdag: %d\n', sum(sum(bnet.dag)), sum(sum(mdag)));

opt = struct('kernel', GaussKernel(), 'pval', false);
data = samples(bnet, N);
data = normalize_data(data);

K = size(data, 1);
pre = dummy_prealloc(1,1);

%edge_ps = [];
%indep_ps = [];

edge_rhos = [];
indep_rhos = [];

pairs = choose_pairs_to_test(mdag);

for p = 1:size(pairs, 1)
   pair = pairs(p, :);
   i = pair(1);
   j = pair(2);
   others = setdiff(1:K,[i j]);
   trip = [i j others];
   [~, rho] = kci_classifier(data, trip, opt, pre);
   
   if ( mdag(i,j) || mdag(j,i))
       %edge_ps = [edge_ps pval];
       edge_rhos = [edge_rhos rho];
       printf(2, 'edge..');
   else
       %indep_ps = [indep_ps pval];
       indep_rhos = [indep_rhos rho];
       printf(2, 'non_edge..');
   end
   fprintf('finished (%d,%d)\n',i,j);
   
end

% for i = 1:K
%     for j = i+1:K
%         others = setdiff(1:K,[i j]);
%         trip = [i j others];
%         [~, rho] = kci_classifier(data, trip, opt, pre);
% 
%         if ( mdag(i,j) || mdag(j,i))
%             %edge_ps = [edge_ps pval];
%             edge_rhos = [edge_rhos rho];
%         else
%             %indep_ps = [indep_ps pval];
%             indep_rhos = [indep_rhos rho];
%         end
%         fprintf('finished (%d,%d)\n',i,j);
%     end
% end

% figure
% hold on
% h(1) = scatter(indep_ps,rand(size(indep_ps)),'r*');
% h(2) = scatter(edge_ps,rand(size(edge_ps)),'b*');
% title('KCI p-values for variable pairs in moralized asia network', 'fontsize', 14);
% legend(h, 'no edge', 'edge');

figure
hold on
h(1) = scatter(indep_rhos,rand(size(indep_rhos)),'r*');
h(2) = scatter(edge_rhos,rand(size(edge_rhos)),'b*');
title(sprintf('KCI rho for variable pairs in moralized %s network', network), 'fontsize', 14);
legend(h, 'no edge', 'edge');
end

function pairs = choose_pairs_to_test(mdag)

K = size(mdag, 1);

if K > 40
    fprintf('choosing random subset of pairs\n');
    [I J] = find(mdag);
    num_pairs = size(I, 1);
    edge_pairs = [I J];
    
    % get num_pairs pairs from non-edges
    [I, J] = find(~mdag);
    perm = randperm(length(I));
    non_edge_pairs = [I(perm(1:num_pairs)), J(perm(1:num_pairs))];
    
    pairs = [edge_pairs; non_edge_pairs];
else
    fprintf('looking at all pairs\n');
    pairs = [];
    for i = 1 : K
        for j = i + 1 : K
            pairs = [pairs; i j];
        end
    end
end

end

