function test_discretize()
disp('test_discretize...');

bnet = mk_asia_ggm(0.05);
randn('seed',1);

s = samples(bnet,1000);
s = discretize(s,10);

assert(min(s(:)) == 1);
assert(max(s(:)) == 10);

assert(abs(regress(s(5,:)',s(4,:)') - 1.0325) < 0.01);

s2 = discretize(s,10);
assert(isequal(s2,s));