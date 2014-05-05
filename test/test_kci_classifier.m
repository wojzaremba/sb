disp('test_kci_classifier...');

rand('seed', 1);
randn('seed',1);
samples_size = 500;
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

small = 8e-2;
large = 0.15;

fprintf('  linear kernel...\n');
opt = struct('arity', 2,'kernel', LinearKernel(), 'pval', false);

assert(kci_classifier(emp_indep, [1, 2], opt, []) < small);
assert(kci_classifier(emp_dep, [1, 2], opt, []) < small); % correlation is 0 because the distribution is symmetric about x = 0
assert(kci_classifier(emp_dep2, [1 2], opt, []) > large); 
assert(kci_classifier(emp_dep2, [1 2 3], opt, []) < small);

% kci with linear kernel is equivalent to computing partial correlation
assert(abs(kci_classifier(emp_indep, [1, 2], opt, [])-pc_classifier(emp_indep, [1, 2], opt))<1e-3);
assert(abs(kci_classifier(emp_dep, [1, 2], opt, [])-pc_classifier(emp_dep, [1, 2], opt))<1e-3);

fprintf('  gauss kernel...\n');
opt.kernel = GaussKernel();

assert(kci_classifier(emp_indep, [1, 2], opt, []) < small);
assert(kci_classifier(emp_dep, [1, 2], opt, []) > large);
assert(kci_classifier(emp_dep2, [1 2], opt, []) > large); 
assert(kci_classifier(emp_dep2, [1 2 3], opt, []) < small);

fprintf('  laplace kernel...\n');
opt.kernel = LaplaceKernel();

assert(kci_classifier(emp_indep, [1, 2], opt, []) < small);
assert(kci_classifier(emp_dep, [1, 2], opt, []) > large);
assert(kci_classifier(emp_dep2, [1 2], opt, []) > large); 
assert(kci_classifier(emp_dep2, [1 2 3], opt, []) < small);
   
    
fprintf('  indicator kernel...\n');
opt.kernel = IndKernel();
    
assert(kci_classifier(emp_indep, [1, 2], opt, []) < small);
assert(kci_classifier(emp_dep2, [1 2], opt, []) > large); 
assert(kci_classifier(emp_dep2, [1 2 3], opt, []) < small);

N = [100 200 500];
opt.pval = true;
opt.kernel = GaussKernel();

for i = 1:length(N)
    samples_size = N(i);
    
%     emp_indep = [randi(2, 1, samples_size); randi(2, 1, samples_size)];
%     emp_indep = normalize_data(emp_indep);
    
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
    
    %[~, indep(i)] = kci_classifier(emp_indep, [1, 2], opt, []);
    [~, dep(i)] = kci_classifier(emp_dep, [1, 2], opt, []);
    [~, dep2u(i)] = kci_classifier(emp_dep2, [1 2], opt, []); 
    %[~, dep2c(i)] = kci_classifier(emp_dep2, [1 2 3], opt, []);
    
end

%assert(issorted(-indep));
assert(issorted(dep));
assert(issorted(dep2u));
%assert(issorted(-dep2c));

