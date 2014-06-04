disp('test_mmhc...')

seed_rand(1);

arity = 3;
bn_opt = struct('network', 'Y', 'arity', arity, 'data_gen', 'random', ...
    'moralize', false);
bnet = make_bnet(bn_opt);
data = samples(bnet, 300);
K = size(bnet.dag, 1);
G = mmhc(data', arity);
pdag_pred = dag_to_cpdag(G);
pdag_true = dag_to_cpdag(bnet.dag);
assert(shd(pdag_pred, pdag_true) == 0);

