function test_gen_cpd_dist()

bnet = mk_bnet3();
CPD = gen_cpd_dist(bnet);

assert(size(CPD, 3) == 9);

% CPD 1
assert(length(find((reshape(CPD(:,:,1),1,4)- [0.45 0.1  0.05 0.4]) > eps))==0);
disp('CPD 1 correct');

% CPD 8
assert(length(find((reshape(CPD(:,:,8),1,4)- [.27 .095 .63 0.005]) > eps))==0);
disp('CPD 8 correct');

% CPD 9
assert(length(find((reshape(CPD(:,:,9),1,4)- [.06 .76 .14 .04]) > eps))==0);
disp('CPD 9 correct');




