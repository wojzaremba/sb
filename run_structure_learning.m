function [SHD, T1, T2] = run_structure_learning(network, type, variance, arity)

num_exp = 10;
Nvec = 50:50:500;

bn_opt = struct('variance', variance, 'network', network, 'arity', 1, 'type', type);
bnet = make_bnet(bn_opt);

true_G = bnet.dag;
true_Pdag = dag_to_cpdag(true_G);
SHD = zeros(num_exp, length(Nvec));
T1 = zeros(num_exp, length(Nvec)); % score time
T2 = zeros(num_exp, length(Nvec)); % structure search
maxpa = 2;
maxS = 2;

opt = struct('classifier', @sb_classifier, 'params',struct('eta',0.01,'alpha',1.0),'arity', arity);

for exp = 1:num_exp
    fprintf('exp %d...\n',exp);
    for N_idx = 1:length(Nvec)
        N = Nvec(N_idx);
        fprintf('N = %d\n', N);
        emp = normalize_data(samples(bnet,N));
        
        tic;
        S = compute_bic(emp, arity, maxpa);
        E = compute_edge_scores(emp, opt, maxS);
        S = add_edge_scores(S, E);
        S = prune_scores(S);
        T1(exp, N_idx) = toc;
        
        [G, T2(exp, N_idx)] = run_gobnilp(S);
        pred_Pdag = dag_to_cpdag(G);
        SHD(exp,N_idx) = shd(true_Pdag,pred_Pdag); 
    end
end

plot(Nvec, mean(SHD, 1));
xlabel('number of samples');
ylabel('structural hamming distance');
title('SHD vs. N, asia network, random CPDs, arity=2');

figure
T = T1 + T2;
h(1) = plot(Nvec, mean(T1, 1));
hold on
h(2) = plot(Nvec, mean(T2, 1));
xlabel('number of samples');
ylabel('runtime (sec)');
title('Runtime vs. N, asia network, random CPDs, arity=2');
legend(h,{'score time', 'structure search'});

