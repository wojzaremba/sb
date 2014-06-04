function test_edge_scores()

disp('test_edge_scores...')

seed_rand(2);

% vstruct network
bn_opt = struct('variance', 0.05, 'network', 'vstruct', 'arity', 1, ...
    'data_gen', 'quadratic_ggm', 'moralize', false, 'tile', 2);
bnet = make_bnet(bn_opt);
dag_v = bnet.dag;
data_v = normalize_data(samples(bnet, 200));

% chain network
bn_opt.network = 'chain';
bn_opt.n = 5;
bn_opt.tile = 2;
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

end

function E = test_compute_edge_scores(opt, data, dag, max_condset, pre)
    nvars = size(data, 1);
    [E, edge_opt] = compute_edge_scores(data, opt, max_condset, pre);
    triples = gen_triples(nvars, 0:max_condset);
    T = dsep_cond_sets(dag, triples);
    assert(isequal(find(E > 1), find(T == 1)));
    assert(isequal(intersect(find(~isinf(T)), find(E < 1)), find(T == 0)));
end




