disp('test_flatten_triples...')

triples = gen_triples(5,2);
triples_f = flatten_triples(triples);

num_cond = length(triples{1}.cond_set);
assert(length(triples_f) == length(triples)*num_cond);
assert(isequal(triples_f{num_cond}.cond_set, triples{1}.cond_set{num_cond}));