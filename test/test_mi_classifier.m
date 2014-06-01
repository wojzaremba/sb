disp('test_mi_classifier...');

seed_rand(1);
samples_size = 10000;

small = 3e-4;
large = 0.02;

emp_indep = [randi(2, 1, samples_size); randi(2, 1, samples_size); randi(2, 1, samples_size)];
opt_min = struct('arity', 2,'thresholds',[0.001, 1], 'rho_range', [0 1], 'aggregation', 'min');
opt_mean = struct('arity', 2,'thresholds',[0.001, 1], 'rho_range', [0 1], 'aggregation', 'mean');
assert(mi_classifier(emp_indep, [1, 2], opt_min) < small);
assert(mi_classifier(emp_indep, [1 2 3], opt_min) < small);

assert(mi_classifier(emp_indep, [1, 2], opt_mean) < small);
assert(mi_classifier(emp_indep, [1 2 3], opt_mean) < small);

emp_dep = [randi(3, 1, samples_size); randi(2, 1, samples_size)];
emp_dep(2, emp_dep(1, :) == 3) = 1;
emp_dep(1, emp_dep(1, :) == 3) = 2;

assert(mi_classifier(emp_dep, [1, 2], opt_min) > large);
assert(mi_classifier(emp_dep, [1, 2], opt_mean) > large);

z = sign(rand(1, samples_size) - 0.5);
x = z .* sign(rand(1, samples_size)-0.9);
y = -z .* sign(rand(1, samples_size)-0.9);
emp_dep = [x; y; z];
emp_dep(emp_dep == -1) = 2;
assert(mi_classifier(emp_dep, [1, 2], opt_min) > large);
assert(mi_classifier(emp_dep, [1 2 3], opt_min) < small);
assert(mi_classifier(emp_dep, [1, 2], opt_mean) > large);
assert(mi_classifier(emp_dep, [1 2 3], opt_mean) < small);

