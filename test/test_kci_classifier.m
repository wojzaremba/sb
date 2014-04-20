function test_kci_classifier()
    disp('test_kci_classifier...');
    
    rand('seed', 1);
    randn('seed',1);
    samples_size = 1000;
    emp_indep = [randi(2, 1, samples_size); randi(2, 1, samples_size)];

    emp_dep = [randi(3, 1, samples_size); randi(2, 1, samples_size)];
    emp_dep(2, emp_dep(1, :) == 3) = 1;
    emp_dep(1, emp_dep(1, :) == 3) = 2;

    x = randn(1,samples_size);
    y = x.^2 + randn(1,samples_size);
    %emp_dep = [x; y];
    %emp_dep = normalize_data(emp_dep);
    emp_indep = normalize_data(emp_indep);
    
    printf(2,'  linear kernel...\n');
    opt = struct('arity', 2,'kernel',LinearKernel());
    kci_classifier(emp_indep, opt)
    kci_classifier(emp_dep, opt)
    
    %assert(kci_classifier(emp_indep, opt)<5e-2);
    %assert(kci_classifier(emp_dep, opt)<5e-2);
    
    % kci with linear kernel is equivalent to computing partial correlation 
    assert(abs(kci_classifier(emp_indep, opt)-pc_classifier(emp_indep, opt))<1e-3);
    assert(abs(kci_classifier(emp_dep, opt)-pc_classifier(emp_dep, opt))<1e-3);

    printf(2,'  gauss kernel...\n');
    opt.kernel = GaussKernel();
    kci_classifier(emp_indep, opt)
    kci_classifier(emp_dep, opt)
    %assert(kci_classifier(emp_indep, opt)<5e-2);
    %assert(kci_classifier(emp_dep, opt)>0.2);
   
    
    