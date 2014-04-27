% function test_run_gobnilp()
disp('test_run_gobnilp...');


randn('seed',1);
rand('seed',1);
bnet = mk_bnet4_vstruct();
arity = get_arity(bnet);
data = samples(bnet,1000);

DAG_pred = run_gobnilp(data, arity);
DAG_true = bnet.dag;

PDAG_pred = dag_to_cpdag(DAG_pred);
PDAG_true = dag_to_cpdag(DAG_true);

hamming_distance = shd(PDAG_pred, PDAG_true);

assert(hamming_distance == 0);


bnet = mk_asia_random(2);
data = samples(bnet,2500);

DAG_pred = run_gobnilp(data, arity);
DAG_true = bnet.dag;

PDAG_pred = dag_to_cpdag(DAG_pred);
PDAG_true = dag_to_cpdag(DAG_true);

hamming_distance = shd(PDAG_pred, PDAG_true);

assert(hamming_distance == 0);
