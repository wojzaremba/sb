function test_get_cpd()

bnet = mk_bnet3();
CPD = get_cpd([1,2],bnet);
assert(length(find((CPD(:)- [0.45 0.1  0.05 0.4]') > eps))==0);

CPD = get_cpd([2,3,1],bnet);
assert(length(find((CPD(:)- [.27 .095 .63 0.005 .06 .76 .14 .04]') > eps))==0);




