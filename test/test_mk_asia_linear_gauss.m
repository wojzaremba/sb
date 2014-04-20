function test_mk_asia_linear_gauss()
disp('test_mk_asia_linear_gauss...');

close all;
covariance = 0.05;
bnet = mk_asia_linear_gauss(covariance);
randn('seed',1);
s = samples(bnet,1000);
assert(abs(regress(s(5,:)',s(4,:)') - 1.017) < 0.01);
