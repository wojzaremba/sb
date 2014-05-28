disp('test_mmhc...')

randn('seed', 1);
rand('seed', 1);

arity = 3;
bn_opt = struct('network', 'Y', 'arity', arity, 'type', 'random', ...
    'moralize', false);
bnet = make_bnet(bn_opt);
data = samples(bnet, 300);
K = size(bnet.dag, 1);
v = arity*ones(1, K);
G = mmhc(data', v);
pdag_pred = dag_to_cpdag(G);
pdag_true = dag_to_cpdag(bnet.dag);
assert(shd(pdag_pred, pdag_true) == 0);

% bn_opt = struct('network', 'asia', 'arity', 4, 'type', 'random', ...
%     'moralize', false, 'variance', 0.05);
% bnet = make_bnet(bn_opt);
% data = samples(bnet, 400);
% G = mmhc(data', 4);
% pdag_pred = dag_to_cpdag(G);
% pdag_true = dag_to_cpdag(bnet.dag);
% fprintf('hamming distance = %d\n', shd(pdag_pred, pdag_true));
% %assert(shd(pdag_pred, pdag_true) == 0);




