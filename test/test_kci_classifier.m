function test_kci_classifier()
    disp('test_kci_classifier...');
    
    rand('seed', 1);
    randn('seed',1);
    samples_size = 1000;
    emp_indep = [randi(2, 1, samples_size); randi(2, 1, samples_size)];

    x = randn(1,samples_size);
    y = x.^2 + randn(1,samples_size);
    emp_dep = [x; y];
    emp_dep = normalize_data(emp_dep);
    emp_indep = normalize_data(emp_indep);
    
    printf(2,'  linear kernel...\n');
    opt = struct('arity', 2,'kernel', LinearKernel());
    
    assert(kci_classifier(emp_indep, [1, 2], opt)<5e-2);
    assert(kci_classifier(emp_dep, [1, 2], opt)<5e-2);
    
    % kci with linear kernel is equivalent to computing partial correlation 
    assert(abs(kci_classifier(emp_indep, [1, 2], opt)-pc_classifier(emp_indep, [1, 2], opt))<1e-3);
    assert(abs(kci_classifier(emp_dep, [1, 2], opt)-pc_classifier(emp_dep, [1, 2], opt))<1e-3);

    printf(2,'  gauss kernel...\n');
    opt.kernel = GaussKernel();
    assert(kci_classifier(emp_indep, [1, 2], opt)<5e-2);
    assert(kci_classifier(emp_dep, [1, 2], opt)>0.2);
   
    
    