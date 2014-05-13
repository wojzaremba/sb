disp('test_gen_triples...');

% only conditioning on smaller sets
triples = gen_triples(4, [0 : 2]);
assert(length(triples) == 6);
assert(length(triples{1}.cond_set) == 4);
assert(isequal(triples{1}.cond_set{4}, [3 4]));
assert(isequal(triples{6}.cond_set{3}, 2));

% conditioning on smaller sets and larger sets
triples = gen_triples(6, [0 1 2 3 4]);
assert(length(triples) == 15); % (n * (n-1)) / 2, n = 6
assert(length(triples{1}.cond_set) == 16);
assert(isequal(triples{1}.cond_set{end}, 3:6));
assert(isempty(triples{end}.cond_set{1}));



