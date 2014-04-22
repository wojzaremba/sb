disp('test_mk_asia_large_arity...');

arity = 2;
num_samples = 10000;

bnet1 = mk_asia_large_arity_nonlinear(arity);
bnet2 = mk_asia_large_arity(arity);

s1 = samples(bnet1, num_samples);
s2 = samples(bnet2, num_samples);

emp1 = s1([4,5],:);
emp2 = s2([4,5],:);

counts1 = cond_emp_to_counts(emp1,arity);
counts2 = cond_emp_to_counts(emp2,arity);

P1 = counts1./num_samples
P2 = counts2./num_samples

