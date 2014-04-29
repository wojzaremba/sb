disp('test_get_marginal_dist...');

bnet = mk_bnet3();
D = get_marginal_dist([1,2],bnet);
assert(length(find((D(:)- [0.45 0.1  0.05 0.4]') > eps))==0);

D = get_marginal_dist([2,3,1],bnet);
assert(length(find((D(:)- [.27 .095 .63 0.005 .06 .76 .14 .04]') > eps))==0);




