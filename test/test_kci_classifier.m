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

small = 0.95;
large = 0.99;

fprintf('  linear kernel...\n');
opt = struct('arity', 2,'kernel', LinearKernel(), 'pval', true);

[~, info_ind] = kci_classifier(emp_indep, [1, 2], opt, []);
[~, info_dep] = kci_classifier(emp_dep, [1, 2], opt, []);
[~, info_dep2] = kci_classifier(emp_dep2, [1 2], opt, []);
[~, info_dep23] = kci_classifier(emp_dep2, [1 2 3], opt, []);

assert(info_ind.pval < small);
assert(info_dep.pval < small); % correlation is 0 because the distribution is symmetric about x = 0
assert(info_dep2.pval > large); 
assert(info_dep23.pval < small);

% kci with linear kernel is equivalent to computing partial correlation
assert(abs(info_ind.Sta - pc_classifier(emp_indep, [1, 2], opt)) < 1e-3);
assert(abs(info_dep.Sta - pc_classifier(emp_dep, [1, 2], opt)) < 1e-3);

fprintf('  gauss kernel...\n');
opt.kernel = GaussKernel();

[~, info_ind] = kci_classifier(emp_indep, [1, 2], opt, []);
[~, info_dep] = kci_classifier(emp_dep, [1, 2], opt, []);
[~, info_dep2] = kci_classifier(emp_dep2, [1 2], opt, []);
[~, info_dep23] = kci_classifier(emp_dep2, [1 2 3], opt, []);

assert(info_ind.pval < small);
assert(info_dep.pval > large);
assert(info_dep2.pval > large); 
assert(info_dep23.pval < small);

fprintf('  laplace kernel...\n');
opt.kernel = LaplaceKernel();

[~, info_ind] = kci_classifier(emp_indep, [1, 2], opt, []);
[~, info_dep] = kci_classifier(emp_dep, [1, 2], opt, []);
[~, info_dep2] = kci_classifier(emp_dep2, [1 2], opt, []);
[~, info_dep23] = kci_classifier(emp_dep2, [1 2 3], opt, []);

assert(info_ind.pval < small);
assert(info_dep.pval > large);
assert(info_dep2.pval > large); 
assert(info_dep23.pval < small);
    
fprintf('  indicator kernel...\n');
opt.kernel = IndKernel();

[~, info_ind] = kci_classifier(emp_indep, [1, 2], opt, []);
[~, info_dep] = kci_classifier(emp_dep, [1, 2], opt, []);
[~, info_dep23] = kci_classifier(emp_dep2, [1 2 3], opt, []);

assert(info_ind.pval < small);
assert(info_dep2.pval > large); 
assert(info_dep23.pval < small);
    
assert(kci_classifier(emp_indep, [1, 2], opt, []) < small);
assert(kci_classifier(emp_dep2, [1 2], opt, []) > large); 
assert(kci_classifier(emp_dep2, [1 2 3], opt, []) < small);

N = [100 200 500];
opt.pval = true;
opt.kernel = GaussKernel();

for i = 1:length(N)
    samples_size = N(i);
    
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
    
    dep(i) = kci_classifier(emp_dep, [1, 2], opt, []);
    dep2u(i) = kci_classifier(emp_dep2, [1 2], opt, []); 
    
end

assert(issorted(dep));
assert(issorted(dep2u));

