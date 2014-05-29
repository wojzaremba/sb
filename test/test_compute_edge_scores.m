function test_compute_edge_scores();

disp('test_compute_edge_scores...')

rand('seed',1);
randn('seed',2);

max_condset = 2;

% vstruct network
bn_opt = struct('variance', 0.05, 'network', 'vstruct', 'arity', 1, ...
    'data_gen', 'quadratic_ggm', 'moralize', false, 'n', 4);
bnet = make_bnet(bn_opt);
dag_v = bnet.dag;
data_v = normalize_data(samples(bnet, 200));

% chain network
bn_opt.network = 'chain';
bnet = make_bnet(bn_opt);
dag_ch = bnet.dag;
data_ch = normalize_data(samples(bnet, 200));

% SB3 scores with pvalues
opt = struct('classifier', @kci_classifier, 'prealloc', @kci_prealloc, ...
    'arity', 1, 'kernel', GaussKernel(), 'pval', true);
test_opt(opt, data_v, dag_v, max_condset);
test_opt(opt, data_ch, dag_ch, max_condset);

% SB3 scores without pvalues
opt.pval = false;
test_opt(opt, data_v, dag_v, max_condset);
test_opt(opt, data_ch, dag_ch, max_condset);

% SB2 scores (not working)
% arity = 3;
% opt = struct('classifier', @sb_classifier, 'prealloc', @dummy_prealloc, ...
%     'params',struct('eta',0.01,'alpha',1.0), 'arity', arity);
% data_v = discretize_data(data_v, arity);
% data_ch = discretize_data(data_ch, arity);
% test_opt(opt, data_v, dag_v, max_condset);
% test_opt(opt, data_ch, dag_ch, max_condset);

end

function test_opt(opt, data, dag, max_condset)
nvars = size(data, 1);
E = compute_edge_scores(data, opt, max_condset);
triples = gen_triples(nvars, 0:max_condset);
T = dsep_cond_sets(dag, triples);
assert(isequal(find(E > 0.4), find(T == 1)));
assert(isequal(intersect(find(~isinf(E)), find(E < 0.03)), find(T == 0)));
end

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

