function test_kci_classifier()
    rand('seed', 1);
    disp('test_kci_classifier...');
    samples_size = 1000;
    emp_indep = [randi(2, 1, samples_size); randi(2, 1, samples_size)];

    
    emp_dep = [randi(3, 1, samples_size); randi(2, 1, samples_size)];
    emp_dep(2, emp_dep(1, :) == 3) = 1;
    emp_dep(1, emp_dep(1, :) == 3) = 2;
    
    disp('  linear kernel...');
    opt = struct('arity', 2,'kernel',LinearKernel(),'range',[0.001,10]);
    assert(isequal(kci_classifier(emp_indep, opt),[1; 1]));
    assert(isequal(kci_classifier(emp_dep, opt),[0; 1]));
    
    disp('  gauss kernel...');
    opt.kernel = GaussKernel();
    assert(isequal(kci_classifier(emp_indep, opt),[1; 1]));
    assert(isequal(kci_classifier(emp_dep, opt),[0; 1]));
    
    
    