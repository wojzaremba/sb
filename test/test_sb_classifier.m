function test_sb_classifier()
disp('test_sb_classifier...');

rand('seed',1);

samples_size = 1000;
emp_indep = [randi(2, 1, samples_size); randi(2, 1, samples_size)];
opt = struct('arity', 2,'params',struct('eta',0.01,'alpha',1));

sb_classifier(emp_indep, opt)
assert(abs(sb_classifier(emp_indep, opt))<1e-5);

emp_dep = [randi(3, 1, samples_size); randi(2, 1, samples_size)];
emp_dep(2, emp_dep(1, :) == 3) = 1;
emp_dep(1, emp_dep(1, :) == 3) = 2;

assert(abs(sb_classifier(emp_dep, opt)-1)<1e-3);
    