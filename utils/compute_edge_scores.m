function E = compute_edge_scores(emp, opt, f)

% number of variables
K = size(emp,1);

% initialize edge scores
E = -Inf*ones(K);

triples = gen_triples(K, 2);

prealloc = o.prealloc(emp, opt);
for t = 1:length(triples)
    rho = classifier_wrapper(emp, triples{t}, f, opt, prealloc)
end


