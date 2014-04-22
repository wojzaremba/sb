disp('test_mi_classifier...');

rand('seed',1);
samples_size = 100000;

emp_indep = [randi(2, 1, samples_size); randi(2, 1, samples_size); randi(2, 1, samples_size)];
opt = struct('arity', 2,'thresholds',[0.001, 1], 'rho_range', [0 1]);
assert(mi_classifier(emp_indep, [1, 2], opt) < 1e-4);
assert(mi_classifier(emp_indep, [1 2 3], opt) < 1e-4);

emp_dep = [randi(3, 1, samples_size); randi(2, 1, samples_size)];
emp_dep(2, emp_dep(1, :) == 3) = 1;
emp_dep(1, emp_dep(1, :) == 3) = 2;

assert(mi_classifier(emp_dep, [1, 2], opt) > 0.02);

z = sign(rand(1, samples_size) - 0.5);
x = z .* sign(rand(1, samples_size)-0.9);
y = -z .* sign(rand(1, samples_size)-0.9);
emp_dep = [x; y; z];
emp_dep(emp_dep == -1) = 2;
assert(mi_classifier(emp_dep, [1, 2], opt) > 0.02);
assert(mi_classifier(emp_dep, [1 2 3], opt) < 1e-4);

