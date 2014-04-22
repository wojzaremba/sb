disp('test_gen_triples...');
triples = gen_triples(4,2);
assert(length(triples)==6);
assert(length(triples{1}.cond_set) == 4);
assert(isequal(triples{1}.cond_set{4},[3 4]));
assert(isequal(triples{6}.cond_set{3},[2]));
