function [SHD, T1, T2] = run_structure_learning(network, edge_scores)

num_exp = 5;
Nvec = 50:50:400;
maxS = 2;
maxK = 5;
psi = 1;

type = 'quadratic_ggm';
variance = 0.05;

bn_opt = struct('variance', variance, 'network', network, 'arity', 1,... 
'type', type, 'moralize', false);
bnet = make_bnet(bn_opt);

true_G = bnet.dag;
true_Pdag = dag_to_cpdag(true_G);
SHD = zeros(num_exp, length(Nvec));
T1 = zeros(num_exp, length(Nvec)); % score time
T2 = zeros(num_exp, length(Nvec)); % structure search

% opt = struct('classifier', @sb_classifier, 'params',...
% struct('eta', 0.01,'alpha', 1.0), 'arity', arity, 'prealloc', ...
% @dummy_prealloc);
opt = struct( 'pval', false, 'kernel', GaussKernel(), 'classifier', ...
    @kci_classifier, 'prealloc', @kci_prealloc);

for exp = 1:num_exp
    fprintf('exp %d...\n',exp);
    for N_idx = 1:length(Nvec)
        N = Nvec(N_idx);
        fprintf('N = %d\n', N);
        emp = normalize_data(samples(bnet,N));
        pre = opt.prealloc(emp, opt);
        
        tic;
        %S = compute_bic(emp, arity, maxpa);
        S = compute_rho_scores(pre, maxK);
        if edge_scores
            E = compute_edge_scores(emp, opt, maxS);
            S = add_edge_scores(S, E, psi);
            S = prune_scores(S);
        end
        T1(exp, N_idx) = toc;
        [G, T2(exp, N_idx)] = run_gobnilp(S);
        pred_Pdag = dag_to_cpdag(G);
        SHD(exp,N_idx) = shd(true_Pdag,pred_Pdag); 
        fprintf('hamming distance = %d\n', SHD(exp, N_idx));
    end
end

if edge_scores
    s = '';
else
    s = 'no';
end

subplot(1, 2, 1)
plot(Nvec, mean(SHD, 1), 'b-', 'linewidth', 2);
xlabel('number of samples');
ylabel('structural hamming distance');
title(sprintf('SHD vs. N, %s network, %s edge scores', network, s), 'fontsize', 14);

subplot(1, 2, 2)
h(1) = plot(Nvec, mean(T1, 1),'r-','linewidth', 2);
hold on
h(2) = plot(Nvec, mean(T2, 1), 'b-', 'linewidth', 2);
xlabel('number of samples');
ylabel('runtime (sec)');
title(sprintf('Runtime vs. N, %s network %s edge scores', network, s), 'fontsize', 14);
legend(h,{'score time', 'structure search'});

