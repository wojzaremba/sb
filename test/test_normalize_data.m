function test_normalize_data()

bnet = mk_asia_linear(10);
rand('seed', 1);
s = samples(bnet,500);

s = normalize_data(s);
assert(norm(mean(s,2)) < 1e-13);
assert(norm(std(s,[],2) - ones(size(s,1),1)) < 1e-13)

s2 = normalize_data(s);
assert(norm(s2-s) < 1e-4);

end

