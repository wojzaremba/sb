function dummy()
assert(0)
-d function dummy()\nassert(0)
function test_mk_asia_linear_gauss()
disp('test_mk_asia_linear_gauss...');

close all;
covariance = 0.5;
bnet = mk_asia_linear_gauss(covariance);
randn('seed',1);
s = samples(bnet,1000);
assert(abs(regress(s(5,:)',s(4,:)') - 1.017) < 0.01);
% 
% scatter(s(4,:),s(5,:));
% title('upper pair of nodes in asia network');
% 
% figure
% scatter(s(6,:),s(8,:));
% title('bottom pair of nodes in asia network');
