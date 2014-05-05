disp('test_compute_edge_scores...')

rand('seed',1);
randn('seed',2);
% bn_opt = struct('network', 'chain', 'arity', 2, 'type', 'random');
% bnet = make_bnet(bn_opt);
bnet = mk_bnet4();
K = size(bnet.dag, 1);
arity = get_arity(bnet);
N = 200;

empty = struct('name', 'none');
opt = struct('classifier', @sb_classifier, 'prealloc', @dummy_prealloc, ...
    'params',struct('eta',0.01,'alpha',1.0), 'arity', arity);

data = samples(bnet, N);

maxS = 2;
E = compute_edge_scores(data, opt, maxS);
triples = gen_triples(K, maxS);

T = -Inf*ones(K);

for t = 1:length(triples)
    trip = triples{t};
   for c = 1:length(trip.cond_set)
       T(trip.i, trip.j) = max(T(trip.i, trip.j), dsep(trip.i, trip.j, trip.cond_set{c}, bnet.dag));
   end
end

assert(isequal(intersect(find(~isinf(E)), find(E > 0.4)), find(T == 1)));
assert(isequal(intersect(find(~isinf(E)), find(E < 0.01)), find(T == 0)));



data = load('test/asia1000/asia1000.dat');
data = data';
data(data == 0) = 2;
arity = 2;

E0 = compute_edge_scores(data, opt, 0);
B0 = -load('test/asia1000/asia1000_sb_min_edge_scores.0');

E1 = compute_edge_scores(data, opt, 1);
B1 = -load('test/asia1000/asia1000_sb_min_edge_scores.1');

E2 = compute_edge_scores(data, opt, 2);
B2 = -load('test/asia1000/asia1000_sb_min_edge_scores.2');



