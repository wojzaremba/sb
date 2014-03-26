function test_gen_triples()

triples = gen_triples(4,1);
assert(length(triples)==18);
assert(isequal(triples{1},[1 2]));
assert(isequal(triples{18},[3 4 2]));