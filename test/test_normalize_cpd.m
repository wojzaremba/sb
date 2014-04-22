disp('test_normalize_cpd...');

randn('seed',1);
cpd = mk_random_cpd(5,3);

cpd = normalize_cpd(cpd);
cpd2 = normalize_cpd(cpd);

assert(isempty(find(abs(cpd-cpd2)>1e-15)));
