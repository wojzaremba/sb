function test_mk_child_linear_gauss()
disp('test_mk_child_linear_gauss...');

close all;
covariance = 0.5;
bnet = mk_child_linear_gauss(covariance);
s = samples(bnet,1000);

scatter(s(1,:),s(2,:));
title('upper pair of nodes in asia network');

figure
scatter(s(14,:),s(20,:));
title('bottom pair of nodes in asia network');
