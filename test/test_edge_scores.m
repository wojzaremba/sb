function test_edge_scores()

disp('test_edge_scores... (need to test add_edge_scores)')

seed_rand(2);

% vstruct network
bn_opt = struct('variance', 0.05, 'network', 'vstruct', 'arity', 1, ...
    'data_gen', 'quadratic_ggm', 'moralize', false, 'n', 4);
bnet = make_bnet(bn_opt);
dag_v = bnet.dag;
data_v = normalize_data(samples(bnet, 200));

% chain network
bn_opt.network = 'chain';
bnet = make_bnet(bn_opt);
dag_cq = bnet.dag;
data_cq = normalize_data(samples(bnet, 200));

% SB3 scores with pvalues
opt = struct('classifier', @kci_classifier, ...
    'arity', 1, 'kernel', GaussKernel(), 'pval', true);
pre_v = kci_prealloc(data_v, opt);
pre_cq = kci_prealloc(data_cq, opt);
E_v_pval = test_compute_edge_scores(opt, data_v, dag_v, 2, pre_v);
E_cq_pval = test_compute_edge_scores(opt, data_cq, dag_cq, 1, pre_cq);

% SB3 scores without pvalues
opt.pval = false;
E_v = test_compute_edge_scores(opt, data_v, dag_v, 2, pre_v);
E_cq = test_compute_edge_scores(opt, data_cq, dag_cq, 1, pre_cq);

% S_v = compute_rho_scores(pre_v, 100);
% S_cq = compute_rho_scores(pre_cq, 100);
% test_add_edge_scores(S_v, E_v_pval);
% test_add_edge_scores(S_cq, E_cq_pval);
% test_add_edge_scores(S_v, E_v);
% test_add_edge_scores(S_cq, E_cq);

end

function E = test_compute_edge_scores(opt, data, dag, max_condset, pre)
    nvars = size(data, 1);
    E = compute_edge_scores(data, opt, max_condset, pre);
    triples = gen_triples(nvars, 0:max_condset);
    T = dsep_cond_sets(dag, triples);
    assert(isequal(find(E > 0.4), find(T == 1)));
    assert(isequal(intersect(find(~isinf(E)), find(E < 0.03)), find(T == 0)));
end

function test_add_edge_scores(S, E)
    S1 = sum_S(S);
    S2 = sum_S(add_edge_scores(S, E, 1));
    d1 = S2 - S1;
    d2 = sum(E(triu(E)));
    assert(abs(d2 - d1) < 0.01);
end

function total = sum_S(S)
    total = 0;
    for i = 1:length(S)
        for j = 1:length(S{i})
            assert(~isinf(S{i}{j}.score) && ~isnan(S{i}{j}.score));
            total = total + S{i}{j}.score;
        end
    end
end
% idea: make fully connected graph, so that each 

% ~~~~
% compare directly with SB scores from c++ code
% 
% data = load('test/asia1000/asia1000.dat');
% data = data';
% data(data == 0) = 2;
% arity = 2;
% 
% [E0, info0] = compute_edge_scores(data, opt, 0);
% B0 = -load('test/asia1000/asia1000_sb_min_edge_scores.0');
% 
% [E1, info1] = compute_edge_scores(data, opt, 1);
% B1 = -load('test/asia1000/asia1000_sb_min_edge_scores.1');
% 
% [E2, info2] = compute_edge_scores(data, opt, 2);
% B2 = -load('test/asia1000/asia1000_sb_min_edge_scores.2');

