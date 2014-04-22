disp('test_kci_classifier...');

rand('seed', 1);
randn('seed',1);
samples_size = 1000;
emp_indep = [randi(2, 1, samples_size); randi(2, 1, samples_size)];
emp_indep = normalize_data(emp_indep);

x = randn(1,samples_size);
y = x.^2 + randn(1,samples_size);
emp_dep = [x; y];
emp_dep = normalize_data(emp_dep);

z = sign(rand(1, samples_size) - 0.5);
x = z .* sign(rand(1, samples_size)-0.9);
y = -z .* sign(rand(1, samples_size)-0.9);
emp_dep2 = [x; y; z];
emp_dep2(emp_dep2 == -1) = 2;
emp_dep2 = normalize_data(emp_dep2);


printf(2,'  linear kernel...\n');
opt = struct('arity', 2,'kernel', LinearKernel());

%prealloc_dep = kci_prealloc(emp_dep, opt);
%prealloc_indep = kci_prealloc(emp_indep, opt);
%prealloc_dep2 = kci_prealloc(emp_dep2, opt);

assert(kci_classifier(emp_indep, [1, 2], opt, []) < 5e-2);
assert(kci_classifier(emp_dep, [1, 2], opt, []) < 5e-2); % correlation is 0 because the distribution is symmetric about x = 0
assert(kci_classifier(emp_dep2, [1 2], opt, []) > 0.2); 
assert(kci_classifier(emp_dep2, [1 2 3], opt, []) < 5e-2);

% kci with linear kernel is equivalent to computing partial correlation
assert(abs(kci_classifier(emp_indep, [1, 2], opt, [])-pc_classifier(emp_indep, [1, 2], opt))<1e-3);
assert(abs(kci_classifier(emp_dep, [1, 2], opt, [])-pc_classifier(emp_dep, [1, 2], opt))<1e-3);

printf(2,'  gauss kernel...\n');
opt.kernel = GaussKernel();

assert(kci_classifier(emp_indep, [1, 2], opt, []) < 5e-2);
assert(kci_classifier(emp_dep, [1, 2], opt, []) > 0.2);
assert(kci_classifier(emp_dep2, [1 2], opt, []) > 0.2); 
assert(kci_classifier(emp_dep2, [1 2 3], opt, []) < 5e-2);

% prealloc_dep = kci_prealloc(emp_dep, opt);
% prealloc_dep2 = kci_prealloc(emp_dep2, opt);
% prealloc_indep = kci_prealloc(emp_indep, opt);

% check that preallocated version matches on-the-fly computation
% assert(abs(kci_classifier(emp_indep, [1, 2], opt, []) - kci_classifier(emp_indep, [1 2], opt, prealloc_indep)) < 1e-15 );
% assert(abs(kci_classifier(emp_dep, [1, 2], opt, []) - kci_classifier(emp_dep, [1 2], opt, prealloc_dep)) < 1e-15 );
% assert(abs(kci_classifier(emp_dep2, [1, 2], opt, []) - kci_classifier(emp_dep2, [1 2], opt, prealloc_dep2)) < 1e-15 );
% assert(abs(kci_classifier(emp_dep2, [1 2 3], opt, []) - kci_classifier(emp_dep2, [1 2 3], opt, prealloc_dep2)) < 1e-15 );



   
    
    
