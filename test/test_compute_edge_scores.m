disp('test_compute_edge_scores...')

rand('seed',1);
randn('seed',1);

bnet = mk_bnet4_vstruct(3);
K = size(bnet.dag, 1);
arity = get_arity(bnet);
N = 200;

empty = struct('name', 'none');
opt = struct('classifier', @sb_classifier, 'rho_range', [0 1],...
    'prealloc', @dummy_prealloc, 'kernel', empty,...
    'color', 'm','params',struct('eta',0.01,'alpha',1.0),...
    'normalize',false,'name','bayesian conditional MI', 'arity', arity);

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