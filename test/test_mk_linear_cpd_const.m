disp('test_mk_linear_cpd_const...');

cpd = mk_linear_cpd_const(10,2);
cpd2 = normalize_cpd(cpd);
assert(isempty(find(abs(cpd-cpd2)>1e-10)));
