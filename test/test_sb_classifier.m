disp('test_sb_classifier...');

seed_rand(1);
samples_size = 1000;
emp_indep = [randi(2, 1, samples_size); randi(2, 1, samples_size)];
opt = struct('arity', 2,'rho_range', [0 1], 'params',struct('eta',0.01,'alpha',1));

assert(abs(sb_classifier(emp_indep, [1, 2], opt))<1e-5);

emp_dep = [randi(3, 1, samples_size); randi(2, 1, samples_size)];
emp_dep(2, emp_dep(1, :) == 3) = 1;
emp_dep(1, emp_dep(1, :) == 3) = 2;

assert(abs(sb_classifier(emp_dep, [1, 2], opt)-1)<1e-3);

z = sign(rand(1, samples_size) - 0.5);
x = z .* sign(rand(1, samples_size)-0.9);
y = -z .* sign(rand(1, samples_size)-0.9);
emp_dep = [x; y; z];
emp_dep(emp_dep == -1) = 2;
assert(sb_classifier(emp_dep, [1, 2], opt) > 0.6);
assert(sb_classifier(emp_dep, [1 2 3], opt) < 0.06);

    
