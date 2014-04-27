function E = compute_edge_scores(emp, opt)

% number of variables
K = size(emp,1);

% initialize edge scores
R = zeros(K);

triples = gen_triples(K, 2);

prealloc = opt.prealloc(emp, opt);
for t = 1:length(triples)
    R(triples{t}.i,triples{t}.j) = classifier_wrapper(emp, triples{t}, opt.classifier, opt, prealloc);
end

E = -log(R);




