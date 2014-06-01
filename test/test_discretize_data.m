disp('test_discretize_data...');

bnet = mk_asia_linear_gauss(0.05);
seed_rand(1);
s = samples(bnet,1000);
s = discretize_data(s,10);

assert(min(s(:)) == 1);
assert(max(s(:)) == 10);

assert(abs(regress(s(5,:)',s(4,:)') - 1.0325) < 0.01);

s2 = discretize_data(s,10);
assert(isequal(s2,s));
