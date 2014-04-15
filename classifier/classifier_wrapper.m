function classes = classifier_wrapper(emp, triple, f, opt)
% emp is entire empirical distribution, num_vars by num_samples matrix
% opt contains options to pass to classifier
% f is classifier function handle
% triple defines all conditioning sets, should pass triples{t} from output
% of gen_triples

rho = -Inf;

for c = 1:length(triple.cond_set)
    trip = [triple.i,triple.j,triple.cond_set{c}];
    emp_c = emp(trip,:);
    rho = max(rho,f(emp_c,opt));
    printf(2,'%d, %d\n',length(triple.cond_set{c}),rho);
end

classes = threshold(opt.range,rho);

