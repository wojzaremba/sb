function test_normalize_discrete()

bnet = mk_asia_linear(10);
rand('seed', 1);
s = samples(bnet,500);

s = normalize_discrete(s);
s2 = normalize_discrete(s);

assert(norm(s2-s) < 1e-4);

end

