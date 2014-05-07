disp('test_run_gobnilp...');


randn('seed',1);
rand('seed',1);
opt = struct('network', 'Y', 'arity', 3, 'type', 'random', 'moralize', false);
bnet = make_bnet(opt);
arity = get_arity(bnet);
data = samples(bnet,1000);
maxpa = 2;
S = compute_bic(data, arity, maxpa);
S = prune_scores(S);

DAG_pred = run_gobnilp(S);
DAG_true = bnet.dag;

PDAG_pred = dag_to_cpdag(DAG_pred);
PDAG_true = dag_to_cpdag(DAG_true);

hamming_distance = shd(PDAG_pred, PDAG_true);

assert(hamming_distance == 0);


%bnet2 = mk_asia_random(3);
%opt.network = 'asia';
%opt.arity = 3;
bnet = make_bnet(opt);
%compare_bnets(bnet,bnet2);
data = samples(bnet,1000);
arity = get_arity(bnet);
S = compute_bic(data, arity, maxpa);
S = prune_scores(S);

DAG_pred = run_gobnilp(S);
DAG_true = bnet.dag;

PDAG_pred = dag_to_cpdag(DAG_pred);
PDAG_true = dag_to_cpdag(DAG_true);

hamming_distance = shd(PDAG_pred, PDAG_true);

assert(hamming_distance == 0);
